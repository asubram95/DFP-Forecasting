# dfp-forecasting
Forecasting models for better DFP projections.

##Groundwork

+ DFPResults pulls the DFP data and converts it into a zoo object, imp_series
+ top_25_weekly is a zoo series of the top 25 partners by impression volume
+ CorrAnalysis outputs a correlation plot, partner_cor_p, between all the partners and extracts the strongest correlations (either positive or negative) into a data frame, strongest_cor. It also produces a (ugly) stacked bar chart, top_10_percentages.
  * We see some surprisingly strong correlations between partners and also that the top 10 partners account for 70% of all impression volume
+ ForecastEnsemble contains forecast.ensemble, which finds the best forecasting method for a particular partner
  * ensemble_results is a list of graphs that shows the best method for each of the top 25 partners
  
##Next Steps

+ ForecastEnsemble only gives the best forecast method. We need to actually run those best forecasts and then compare them to the DFP forecasts using some metric of error, e.g. causal impact
+ Examine possible causes of the strong correlations that were found by 
  * examining the site level 
  * correlating changes in the time series to campaign starts and ends
  * correlating changes in the time series to significant events, e.g. the 2016 election
