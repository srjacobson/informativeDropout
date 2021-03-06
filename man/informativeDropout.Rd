% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/informativeDropout.R
\name{informativeDropout}
\alias{informativeDropout}
\title{informativeDropout}
\usage{
informativeDropout(data, model.options, ids.var, outcomes.var, groups.var,
  covariates.var, times.dropout.var, times.observation.var,
  censoring.var = NULL, method = "bayes.splines", dist = "normal")
}
\arguments{
\item{data}{the data set}

\item{model.options}{model options}

\item{ids.var}{column of the data set containing participant identifiers}

\item{outcomes.var}{column of the data set containing the outcome variable}

\item{groups.var}{column of the data set indicating the treatment groups}

\item{covariates.var}{list of columns in the data set containing covariates}

\item{times.dropout.var}{column of the data set containing dropout times}

\item{times.observation.var}{column of the data set containing observation times}

\item{censoring.var}{column with indicators for administrative censoring (Dirichlet models only)}

\item{method}{the modeling method, valid values are 'bayes.splines', 'dirichlet', 'mixed.splines'}

\item{dist}{the distribution of the outcome, valid values are "gaussian" or "binary"}
}
\description{
informativeDropout
}
\seealso{
bayes.splines.model.options

dirichlet.model.options
}
