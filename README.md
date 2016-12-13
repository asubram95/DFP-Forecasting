# dfp-forecasting
Forecasting models for better DFP projections.

##Steps
+ Examine possible correlation between supposedly independent publishers using correlation analysis

+ Look at inventory forecasting for each individual partner
  * DFP provides this, using aggregated moving averages
  * DFP only provides up to 120 days; can we do more?
  * Compare fast moving averages vs slow moving averages

+ Start by examining publisher by publisher, then generalize to site by site, then generalize to actual placements

+ Tweak models to look for trends, and then use that as a cutoff point to forecast
  * Reduces margin of error
  * Prevents skewing from times with little to no activity (flatline areas)

##Notes
	▪	Look for seasonality

	▪	Holt-Winters time scale model
		⁃	Time scale model that uses exponential smoothing

	▪	There are different types of moving averages functions used for prediction
		⁃	MOMA - Mother Of all Moving Averages

	▪	Causal impact
		⁃	Verifies a model
		⁃	Estimates the effect of a designated intervention on a time series

	▪	Momentum = Volatility

	▪	Keep a separate model for each publisher and site
		⁃	Can build a data frame of these models

	▪	GLMs may help

	▪	Cointegration is correlation, but for time series variables

	▪	Afterwards, consider looking at the available inventory rate and how much of that inventory Kargo takes up 		   (inventory capitalization rate)
