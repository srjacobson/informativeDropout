#
# Demo reproducing the results of the manuscript
#
# Moore CM, Carlson NE, MaWhinney S, Kreidler SM.,
# "A Dirichlet Process Mixture Model for Non-Ignorable Dropout.",
# 2018, under review.
#
#
library(dplyr)

# load the data set of untreated hiv participants
data("untreated_hiv")
# remove patients with none or 1 observations
nobs_by_patid = untreated_hiv %>% group_by(patid) %>% summarise(nobs=n())
data = left_join(untreated_hiv, nobs_by_patid, by="patid") %>% 
  filter(nobs > 1) %>%
  arrange(patid, years)
# mark participants as censored administratively if dropout is equal to the
# max dropout time
max_drop = max(data$drop_day)
data$delta<-ifelse(data$drop_day==max_drop, 1,0)
data$baselogcd4xt = data$baselogcd4*data$years
# convert drop days to years
data$drop_year = data$drop_day/365

# calculate the mean of the log dropout times - used as the prior for cluster means
mean_log_dropout = mean(log(unique.data.frame(data[,c("patid", 'drop_year')])$drop_year))

# set the data frame columns for outcomes, covariates, etc.
ids.var="patid"
outcomes.var="logcd4"
groups.var="hard_drug" 
covariates.var=c("baselogcd4", "baselogcd4xt") 
times.dropout.var="drop_year" 
times.observation.var="years"
censoring.var = "delta"
dist = "gaussian"
method="dirichlet"

model.options=dirichlet.model.options(iterations=200000, n.clusters=60, burnin=50000, thin=1,
                                      print=1000,
                                      dropout.offset=0,
                                      dropout.estimationTimes = c(1,2,3,4,5),
                                      dropout.estimationTimes.censored = c(4,5),
                                      dp.concentration=1,
                                      dp.concentration.alpha=1,
                                      dp.concentration.beta=1,
                                      dp.cluster.sigma = diag(3),
                                      dp.cluster.sigma.nu0 = 5,
                                      dp.cluster.sigma.T0 = diag(3),
                                      dp.dist.mu0 = c(0,0,mean_log_dropout),
                                      dp.dist.mu0.mb = c(0,0,mean_log_dropout),
                                      dp.dist.mu0.Sb = diag(3),
                                      dp.dist.sigma0 = diag(3),
                                      dp.dist.sigma0.nub = 5,
                                      dp.dist.sigma0.Tb = diag(3),
                                      betas.covariates = c(1.0, 0.1),
                                      betas.covariates.mu = c(0,0),
                                      betas.covariates.sigma = 100*diag(2),
                                      sigma.error = 1,
                                      sigma.error.tau = 0.001, 
                                      density.slope.domain = NULL,
                                      density.intercept.domain = NULL)

fit = informativeDropout(data, model.options, ids.var, 
                         outcomes.var, groups.var,
                         covariates.var, 
                         times.dropout.var, times.observation.var,
                         censoring.var=censoring.var,
                         method=method, dist=dist)

# summarize the result
summary(fit)

# calculate difference in slope between hard drug users and non-users
expected_slope_diff = unlist(lapply(fit$iterations, function(x) { 
  # hard drug users minus non-users
  expected.slope_diff = x$expected.slope[[2]] - x$expected.slope[[1]]
  return (ifelse(is.null(expected.slope_diff), 0, expected.slope_diff))
}))
diff_df = data.frame(
  mean=c(mean(expected_slope_diff)),
  median=c(median(expected_slope_diff)),
  ci_lower=c(quantile(expected_slope_diff, probs=0.025)),
  ci_upper=c(quantile(expected_slope_diff, probs=0.975))
)
print("Group difference in slope (hard drug users minus non-users)")
print(diff_df)



