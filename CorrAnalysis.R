#Correlation analysis
#Run DFPResults.R first
#cor() gives a correlation matrix of the correlations between possible pairs of variables
#rcorr() in HMisc gives p values
#corrgram() in corrgram graphically represents this

library(zoo)
library(xts)
library(gtools) 
library(Hmisc)
library(corrplot)

partners <- unique(dfp_results$Dimension.PARTNER_MANAGEMENT_PARTNER_NAME)

#Build time series of impressions

#Function to extract impression column for each partner
<<<<<<< HEAD
get.imps <- function(x){
=======
get.impressions <- function(x){
>>>>>>> f384a107d252f46fd900f3b6593d5ae9e00383a5
  p1 <- dfp_results %>%
  select(Dimension.DATE, Dimension.PARTNER_MANAGEMENT_PARTNER_NAME, Column.PARTNER_MANAGEMENT_HOST_IMPRESSIONS) %>%
  filter(Dimension.PARTNER_MANAGEMENT_PARTNER_NAME == x)
  p1 <- select(p1, Dimension.DATE, Column.PARTNER_MANAGEMENT_HOST_IMPRESSIONS)
  colnames(p1) <- c("Date", x)
  return(p1)
}

#Convert to zoo object
imp_zoo <- lapply(lapply(partners, get.imps), read.zoo)

#Build series (this is a zoo object)
imp_series <- data.frame()
for(imp in imp_zoo){
  suppressWarnings(
<<<<<<< HEAD
    imp_series <- merge.zoo(imp_series, imp))
}
colnames(imp_series) <- partners
index(imp_series) <- as.Date(index(imp_series))
imp_series <- na.fill(imp_series, 0)
View(imp_series)

#Correlation between supposedly independent partners

#Significance test
cor.mtest <- function(mat, conf.level = 0.95){
  mat <- as.matrix(mat)
  n <- ncol(mat)
  p.mat <- lowCI.mat <- uppCI.mat <- matrix(NA, n, n)
  diag(p.mat) <- 0
  diag(lowCI.mat) <- diag(uppCI.mat) <- 1
  for(i in 1:(n-1)){
    for(j in (i+1):n){
      tmp <- cor.test(mat[,i], mat[,j], conf.level = conf.level)
      p.mat[i,j] <- p.mat[j,i] <- tmp$p.value
      lowCI.mat[i,j] <- lowCI.mat[j,i] <- tmp$conf.int[1]
      uppCI.mat[i,j] <- uppCI.mat[j,i] <- tmp$conf.int[2]
    }
  }
  return(list(p.mat, lowCI.mat, uppCI.mat))
=======
    impression_series <- merge.zoo(impression_series, animal))
>>>>>>> f384a107d252f46fd900f3b6593d5ae9e00383a5
}

#Corrplot
imp_series_df <- as.data.frame(imp_series)
corrplot((cor(imp_series_df)))

#Top 25 by volume
imp_sums <- sort(
  apply(imp_series_df, 2, sum), 
  decreasing=TRUE)
imp_top_25 <- names(imp_sums[1:25])
imp_top_25 <- select(imp_series_df, one_of(imp_top_25))

#No p-test
corrplot(cor(imp_top_25), 
         method = 'square',
         order='AOE', 
         tl.cex=0.5)

#P-test; blank squares are below the significance level
res1 <- cor.mtest(imp_top_25,0.95)
corrplot(cor(imp_top_25), 
         method = 'square', 
         order='AOE', 
         p.mat=res1[[1]], 
         sig.level = 0.05, 
         insig='blank', 
         tl.cex=.5)

#Aggregate weekly and graph
imp_weekly <- apply.weekly(imp_top_25, mean)

#No p test
corrplot(cor(imp_weekly), 
         method = 'square',
         order='AOE', 
         tl.cex=0.5)

#p test
res1 <- cor.mtest(imp_weekly,0.95)
corrplot(cor(imp_weekly), 
         method = 'square', 
         order='AOE', 
         p.mat=res1[[1]], 
         sig.level = 0.05, 
         insig='blank', 
         tl.cex=.5)


<<<<<<< HEAD
=======
  
#Correlation between supposedly independent partners
cor(partner_corr[,2], partner_corr[,3])
>>>>>>> f384a107d252f46fd900f3b6593d5ae9e00383a5
