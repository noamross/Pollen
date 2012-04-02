require(stratigraph)
require(utils)
require(graphics)
require(stats)

#' @import stratigraph zoo
getpctAP <- function(site, plot=FALSE) {
  fulldata <- readGPDascii(paste('ftp://ftp.ncdc.noaa.gov/pub/data/paleo/pollen/asciifiles/fossil/ascfiles/gpd/', site, '.txt', sep=''))
  pctAPseries <- pctAP(fulldata)
  year <- fulldata$absolute.ages
  if(plot) {
    plot(year, pctAPseries, type="l", xlab="Years before Present (1950)", ylab="Fraction Arboreal Pollen", xlim=c(max(year), min(year)))
  }
  series <- cbind(year, pctAPseries)
  colnames(series) <- c("Years BP", "Pct AP"); rownames(series) <- NULL
  return(series)
}

linpctAP <- function(pctAPseries, ts=TRUE) {
  a <- approx(pctAPseries[,1], pctAPseries[,2], n=nrow(pctAPseries))
  if(ts) {
    tseries <- ts(a$y, start=a$x[1], end=a$x[length(a$x)], frequency = length(a$x)/(a$x[length(a$x)] - a$x[1]))
    return(tseries)
  }
  cbind(a$x, a$y)
}

pctAP = function(GPD) {
  #This function converts pollen count data loaded from a GPD file into a vector of %arboreal pollen, using the taxonomic cateogries providedpct
  return(rowSums(GPD$counts[,which(GPD$tax.cat == "A")])/rowSums(GPD$counts[,which(GPD$tax.cat != "X" & GPD$tax.cat != "Z" & GPD$tax.cat != "-")]))
}