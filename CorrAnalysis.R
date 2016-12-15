#Correlation analysis
#Run DFPResults.R first

#Filter by partner, and then make a column for each
#Key them by date
#cor() gives a correlation matrix of the correlations between possible pairs of variables
#rcorr() in HMisc gives p values
#corrgram() in corrgram graphically represents this

library(zoo)
zoolibrary(gtools) 
library(Hmisc)

PARTNER1 <- partners[1]
PARTNER2 <- partners[2]

#Build correlation matrix
impressions <- function(x){
  t <- dfp_results %>%
    select(Dimension.PARTNER_MANAGEMENT_PARTNER_NAME, Column.PARTNER_MANAGEMENT_HOST_IMPRESSIONS) %>%
    filter(Dimension.PARTNER_MANAGEMENT_PARTNER_NAME == x) %>%
    select(Column.PARTNER_MANAGEMENT_HOST_IMPRESSIONS)
  colnames(t) <- x
  return(t)
}

partners <- unique(dfp_results$Dimension.PARTNER_MANAGEMENT_PARTNER_NAME)
for(partner in partners){
  x <- impressions(partner)
  partner_cor <- c(partner_cor, x)
}
rownames(partner_corr) <- unique(dfp_results$Dimension.DATE)
x <- lapply(dfp_results, impressions)

x <- impressions(partners[1])
y <- impressions(partners[2])



#Build data frames
ye <- function(x){
  p1 <- dfp_results %>%
  select(Dimension.DATE, Dimension.PARTNER_MANAGEMENT_PARTNER_NAME, Column.PARTNER_MANAGEMENT_HOST_IMPRESSIONS) %>%
  filter(Dimension.PARTNER_MANAGEMENT_PARTNER_NAME == x)
  p1 <- select(p1, Dimension.DATE, Column.PARTNER_MANAGEMENT_HOST_IMPRESSIONS)
  colnames(p1) <- c("Date", paste(x, 'HOST IMPRESSIONS'))
  return(p1)
}

imp_list<-lapply(partners, ye)
imp_list_zoo <- lapply(imp_list, zoo)

x <- imp_list_zoo[[1]]
y <- imp_list_zoo[[2]]

#Stack
cmapply <- function(FUN, ..., MoreArgs = NULL, SIMPLIFY = TRUE, USE.NAMES = TRUE){
  l <- expand.grid(..., stringsAsFactors=FALSE)
  r <- do.call(mapply, c(
    list(FUN=FUN, MoreArgs = MoreArgs, SIMPLIFY = SIMPLIFY, USE.NAMES = USE.NAMES), 
    l
  ))
  if (is.matrix(r)) r <- t(r) 
  cbind(l, r)
}

  








p2 <- dfp_results %>%
  select(Dimension.DATE, Dimension.PARTNER_MANAGEMENT_PARTNER_NAME, Column.PARTNER_MANAGEMENT_HOST_IMPRESSIONS) %>%
  filter(Dimension.PARTNER_MANAGEMENT_PARTNER_NAME == y)

  partner_corr <- left_join(partner1_temp, partner2_temp, by="Dimension.DATE") %>%
  select(Dimension.DATE, Column.PARTNER_MANAGEMENT_HOST_IMPRESSIONS.x, Column.PARTNER_MANAGEMENT_HOST_IMPRESSIONS.y)
  
  colnames(partner_corr) <- c("Date", paste(x, 'HOST IMPRESSIONS'), paste(y, 'HOST IMPRESSIONS'))









partner1_temp <- dfp_results %>%
  select(Dimension.DATE, Dimension.PARTNER_MANAGEMENT_PARTNER_NAME, Column.PARTNER_MANAGEMENT_HOST_IMPRESSIONS) %>%
  filter(Dimension.PARTNER_MANAGEMENT_PARTNER_NAME == PARTNER1)

partner2_temp <- dfp_results %>%
  select(Dimension.DATE, Dimension.PARTNER_MANAGEMENT_PARTNER_NAME, Column.PARTNER_MANAGEMENT_HOST_IMPRESSIONS) %>%
  filter(Dimension.PARTNER_MANAGEMENT_PARTNER_NAME == PARTNER2)

partner_corr <- left_join(partner1_temp, partner2_temp, by="Dimension.DATE") %>%
  select(Dimension.DATE, Column.PARTNER_MANAGEMENT_HOST_IMPRESSIONS.x, Column.PARTNER_MANAGEMENT_HOST_IMPRESSIONS.y)
colnames(partner_corr) <- c("Date", paste(PARTNER1, 'HOST IMPRESSIONS'), paste(PARTNER2, 'HOST IMPRESSIONS'))
  
#C
orrelation between supposedly independent partners
cor(partner_corr[,2], partner_corr[,3])
