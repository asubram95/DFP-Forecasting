#Correlation analysis

library(Hmisc)
#Correlation between supposedly independent partners
x <- dfp_results[1:2]
y <- dfp_results[4:6]
cor(x,y)
