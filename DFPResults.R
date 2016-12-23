#install.packages("devtools")
#library(devtools)
#devtools::install_github("ReportMort/rdfp")
#library(rdfp)

#Fixes causal impact package error
#devtools::install_github("HenrikBengtsson/devtools@hotfix/parse_deps")
#devtools::install_github("google/CausalImpact")

PARTNER <- 'AMI'

libraries <- c(
  'devtools',
  'dtw',
  'stringi',
  'lubridate',
  'reshape2',
  'ggplot2',
  'httr',
  'rdfp',
  'forecast',
  'bsts',
  'CausalImpact',
  'dygraphs',
  'dplyr',
  'zoo',
  'xts',
  'gtools'
)

#Install/load required libraries
for (lib in libraries) {
  if (!require(lib, character.only = TRUE))
    install.packages(lib)
  library(lib, character.only = TRUE)
}


options(rdfp.network_code = "98790044")
options(rdfp.application_name = "DFP4CAST")
options(rdfp.client_id = "464626437027-9jhegr6nc070jmcep66d9gv7n2dmqi7u.apps.googleusercontent.com")
options(rdfp.client_secret = "h-gn_J02jS7mnh8HkdGyk8ug")

#Creates OAuth token
dfp_auth()

#Check current user or network
user_info <- dfp_getCurrentUser()
user_info
network_info <- dfp_getCurrentNetwork()
network_info

##Reports require 3 steps from the ReportService: 1) request the report, 2) check on its status, 3) download.

#Create a reportJob object
currentMonth <- format(Sys.Date(), "%m")
currentDay <- format(Sys.Date(), "%d")

job_request <-
  list(reportJob = list(
    reportQuery = list(
      dimensions = 'DATE',
      dimensions = 'PARTNER_MANAGEMENT_PARTNER_NAME',
      dimensions = 'PARTNER_MANAGEMENT_PARTNER_ID',
      columns = 'PARTNER_MANAGEMENT_HOST_IMPRESSIONS',
      columns = 'PARTNER_MANAGEMENT_HOST_CLICKS',
      columns = 'PARTNER_MANAGEMENT_HOST_REVENUE',
      startDate = list(year = 2015, month = 01, day = 01),
      endDate = list(year = 2017, month = currentMonth, day = currentDay),
      dateRangeType = 'CUSTOM_DATE'
    )
  ))

dfp_runReportJob_result <- dfp_runReportJob(job_request)
#dfp_runReportJob_result$id
#dfp_runReportJob_result$reportJobStatus

#Check request status until status = COMPLETED
request_data_status <- list(reportJobId = dfp_runReportJob_result$id)
dfp_getReportJobStatus_result <- dfp_getReportJobStatus(request_data_status)

counter <- 0
while (dfp_getReportJobStatus_result != 'COMPLETED' & counter < 10) {
  dfp_getReportJobStatus_result <- dfp_getReportJobStatus(request_data_status)
  Sys.sleep(3)
  counter <- counter + 1
}

#Download the file
file_request <- list(reportJobId = dfp_runReportJob_result$id, exportFormat = 'CSV_DUMP')
dfp_getReportDownloadURL_result <- dfp_getReportDownloadURL(file_request)
download.file(as.character(dfp_getReportDownloadURL_result), destfile = "DFPresults.csv")
dfp_results <- read.csv('DFPresults.csv', header = TRUE, sep = ",", stringsAsFactors = FALSE)

#Filter by partner
dfp_partner_results <- dfp_results %>%
  select(Dimension.DATE, Dimension.PARTNER_MANAGEMENT_PARTNER_NAME, Column.PARTNER_MANAGEMENT_HOST_IMPRESSIONS) %>%
  mutate(Dimension.DATE = as.Date(Dimension.DATE)) %>%
  filter(Dimension.PARTNER_MANAGEMENT_PARTNER_NAME == PARTNER)

View(dfp_results)

#Build a time series of all the impressions
get.imp <- function(x){
  p1 <- dfp_results %>%
    select(Dimension.DATE, Dimension.PARTNER_MANAGEMENT_PARTNER_NAME, Column.PARTNER_MANAGEMENT_HOST_IMPRESSIONS) %>%
    filter(Dimension.PARTNER_MANAGEMENT_PARTNER_NAME == x)
  p1 <- select(p1, Dimension.DATE, Column.PARTNER_MANAGEMENT_HOST_IMPRESSIONS)
  colnames(p1) <- c("Date", x)
  return(p1)
}

#Convert to zoo object
partners <- unique(dfp_results$Dimension.PARTNER_MANAGEMENT_PARTNER_NAME)
imp_zoo <- lapply(lapply(partners, get.imp), read.zoo)

#Build series (this is a zoo object)
imp_series <- data.frame()
for(imp in imp_zoo){
  suppressWarnings(
    imp_series <- merge.zoo(imp_series, imp))
}
colnames(imp_series) <- partners
index(imp_series) <- as.Date(index(imp_series))
imp_series <- na.fill(imp_series, 0)
#View(imp_series)

#Consider the top 25 partners by volume
imp_df <- as.data.frame(imp_series)
imp_sums <- sort(
  apply(imp_df, 2, sum), 
  decreasing=TRUE)
top_25 <- names(imp_sums[1:25])
top_25_df <- select(imp_df, one_of(top_25))

#Aggregate Weekly to clean up noise
top_25_weekly <- apply.weekly(top_25_df, mean)


#View(dfp_partner_results)
#View(imp_series)
#View(top_25)
#View(top_25_weekly)

