#Correlation analysis
#Run DFPResults.R first
#cor() gives a correlation matrix of the correlations between possible pairs of variables
#rcorr() in HMisc gives p values
#corrgram() in corrgram graphically represents this

library(zoo)
library(gtools) 
library(Hmisc)

partners <- unique(dfp_results$Dimension.PARTNER_MANAGEMENT_PARTNER_NAME)

#Build time series of impressions

#Function to extract impression column for each partner
get.impressions <- function(x){
  p1 <- dfp_results %>%
  select(Dimension.DATE, Dimension.PARTNER_MANAGEMENT_PARTNER_NAME, Column.PARTNER_MANAGEMENT_HOST_IMPRESSIONS) %>%
  filter(Dimension.PARTNER_MANAGEMENT_PARTNER_NAME == x)
  p1 <- select(p1, Dimension.DATE, Column.PARTNER_MANAGEMENT_HOST_IMPRESSIONS)
  colnames(p1) <- c("Date", x)
  return(p1)
}

#Convert to zoo object
imp_list_zoo <- lapply(lapply(partners, get.impressions), read.zoo)

#Build series
impression_series <- data.frame()
for(animal in imp_list_zoo){
  suppressWarnings(
    impression_series <- merge.zoo(impression_series, animal)
    )
}
colnames(impression_series) <- partners
index(impression_series) <- as.Date(index(impression_series))

View(impression_series)


  
#Correlation between supposedly independent partners
cor(partner_corr[,2], partner_corr[,3])
