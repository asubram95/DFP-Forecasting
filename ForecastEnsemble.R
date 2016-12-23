#Compares multiple forecast models for a time series and finds the best one, according to the least MASE
#Takes univariate series
#Easily extendable by adding more forecasts into forecast.ensemble
#Beware of computation time

#The ensemble function
forecast.ensemble <- function(series) {
  data <- coredata(series)
  len <- length(series)
  h <- floor(len * 0.2)   #Set test data to be ~20% of total data
  training <- data[1:(len - h)]
  test <- as.vector(data[(len - h + 1):len])
  
  #The three forecasts: neural network, theta, ARIMA
  fc1 <- forecast(nnetar(training), h = h)
  fc2 <- thetaf(training, h = h)
  fc3 <- forecast(auto.arima(training), h = h)
  
  #Initialize variables
  fc123 <- fc23 <- fc13 <- fc12 <- fc1
  
  #Replace point forecasts with averages of member forecasts
  fc12$mean <- (fc1$mean + fc2$mean) / 2
  fc13$mean <- (fc1$mean + fc3$mean) / 2
  fc23$mean <- (fc2$mean + fc3$mean) / 2
  fc123$mean <- (fc1$mean + fc2$mean + fc3$mean) / 3
  
  #Calculate MASEs 
  mases <- c(
    accuracy(fc1, test)[2, 6],
    accuracy(fc2, test)[2, 6],
    accuracy(fc3, test)[2, 6],
    accuracy(fc12, test)[2, 6],
    accuracy(fc13, test)[2, 6],
    accuracy(fc23, test)[2, 6],
    accuracy(fc123, test)[2, 6]
  )
  
  message("Finished model fitting")
  names(mases) <- c("n",
                    "f",
                    "a",
                    "nf",
                    "an",
                    "fa",
                    "nfa")
  return(mases)
}

#Creates a time series from a column in a data frame
get.ts <- function(partner, datefield){
  ts <- zoo(partner, order.by = datefield)
  return(ts)
}

###Run on DFP
weekfield <- as.Date(as.character(rownames(top_25_weekly), format = "%Y-%m-%d"))
dayfield <- as.Date(as.character(rownames(top_25_df), format = "%Y-%m-%d"))

#Get ensembles for each
weekly_series <- lapply(top_25_weekly, get.ts, datefield = weekfield)
weekly_ensemble <- lapply(weekly_series, forecast.ensemble)

##Results

week <- weekly_ensemble[3]


best.model <- function(ensemble){
  results <- data.frame(ensemble)
  colnames(results)[1] <- "MASE"
  results$model <- as.character(names(ensemble))
  results$frequency <- rep.int("Weekly", times = c(7))
  results <- arrange(results, MASE)
  
  leg <- "f: Theta\n a: ARIMA\n n: Neural network" 
  
  ensemble_graph <- results %>%
    ggplot(aes(
      x = model,
      y = MASE
    )) +
    geom_point(size = 3, color = 'red') +
    geom_path(color = "red", group = 1) +
    scale_x_discrete(limits = results$model) +
    scale_y_continuous("Mean Scaled Absolute Error (MASE)") +
    labs(title = "Average Error of Three Different Forecasting Methods \n Weekly Aggregated DFP Impression Data", x = "Ensemble of models \n f: Theta   a: ARIMA   n: Neural network") +
    theme(plot.title = element_text(hjust = 0.5)) 
  
  return(ensemble_graph)
}
 
ensemble_results <-lapply(weekly_ensemble, best.model)


