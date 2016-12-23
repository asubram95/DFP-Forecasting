#Correlation analysis
#Run DFPResults.R first

library(corrplot)

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
}

#Aggregate weekly and graph
top_25_weekly <- apply.weekly(top_25_df, mean)

#par(oma=c(0,0,0,0))
#par(mar=default.margin)

#p test
res <- cor.mtest(top_25_weekly,0.99)
partner_cor_p <- corrplot(
  cor(top_25_weekly),
  method = 'square',
  order = 'AOE',
  p.mat = res[[1]],
  sig.level = 0.01,
  insig = 'blank',
  tl.cex = 0.5
)
dev.copy(
  png,
  "partner_cor_p.png",
  width = 6.5,
  height = 6,
  units = "in",
  res = 300
)
dev.off()

#strongest_cor is a df with the strongest correlations between the top 25 partners (either positive or negative)
strongest_cor <-cor(top_25_weekly)
strongest_cor[lower.tri(strongest_cor, diag=TRUE)] <- NA  #Flag the duplicates, i.e. the bottom half
strongest_cor <- as.data.frame(as.table(strongest_cor))  
strongest_cor <- na.omit(strongest_cor)  
strongest_cor <- strongest_cor[order(-abs(strongest_cor$Freq)), ] 
View(strongest_cor)

#Partner impression volumes in an ugly ass stacked bar chart
percent <- function(x){
  (x/imp_total)*100
}

imp_total <- sum(imp_sums)
partner_percents <- lapply(imp_sums, percent)
partner_percents_df <- as.data.frame(cbind(Partner = names(partner_percents[1:10]), value = partner_percents[1:10]))
# partner_percents_df <-
#   rbind(partner_percents_df, c("Other (not the top 10)", 
#                                Reduce("+", partner_percents[11:67])
#   ))
partner_percents_df$Partner <- as.character(partner_percents_df$Partner)
partner_percents_df$value <- as.numeric(partner_percents_df$value)
partner_percents_df$Partner <- reorder(partner_percents_df$Partner, partner_percents_df$value, decreasing = T)

partner_percents_bar <- partner_percents_df %>%
  ggplot(aes(x = "", y = value, fill = Partner)) +
  geom_bar(width = 1, stat = "identity", color="black") +
  #coord_polar("y", start = 0) +
  labs(title = "Impression Volume of Top 10 Partners \n Accounts for 90% of all impressions") +
  theme(plot.title = element_text(hjust = 0.5)) 
#partner_percents_bar

dev.copy(
  png,
  "top_10_percentages.png",
  width = 6.5,
  height = 6,
  units = "in",
  res = 300
)
dev.off()

#We see that the top 10 partners account for 70$ of all impression volume


