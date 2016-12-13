#install.packages("devtools")
#library(devtools)
#devtools::install_github("ReportMort/rdfp")
#library(rdfp)

#Fixes causal impact package error
#devtools::install_github("HenrikBengtsson/devtools@hotfix/parse_deps")
#devtools::install_github("google/CausalImpact")

libraries <- c(
  'devtools',
  'dtw',
  'stringi',
  'lubridate',
  'dplyr',
  'reshape2',
  'ggplot2',
  'httr',
  'rdfp',
  'forecast',
  'bsts',
  'CausalImpact',
  'dygraphs'
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

job_request <-
  list(reportJob = list(
    reportQuery = list(
      dimensions = 'DATE',
      dimensions = 'PARTNER_NAME',
      dimensions = 'PARTNER_ID',
      columns = 'PARTNER_MANAGEMENT_HOST_IMPRESSIONS',
      columns = 'HOST_CLICKS',
      columns = 'HOST_REVENUE',
      startDate = list(year = 2015, month = 09, day = 11),
      endDate = list(year = 2016, month = 07, day = 31),
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

#Convert to data frame, filter by partner
dfp_partner_results <- dfp_results %>%
  select(Dimension.DATE,
         Dimension.PARTNER_NAME,
         Column.HOST_IMPRESSIONS) %>%
  mutate(Dimension.DATE = as.Date(Dimension.DATE)) %>%
  filter(Dimension.PARTNER_NAME == "AMI")

#ts() creates a time series object
myts <- ts(dfp_partner_date2[,3], start=c(2015,9,11), end=c(2016,7,31), frequency = 325)

onyData <- dfp_partner_date2[,c(1,3)]

plot(forecast(fit,h=20))



