#Testing stratigraphy package in R

require(stratigraph)
require(gdata)
require(xtable)
billys = readGPDascii("Data/billys.txt") #load the GPD file into a variable
threepines = readGPDascii("Data/3pines.txt")

Read 1323 items
Number of taxa:  105 
Number of levels:  77

pctAP = function(GPD) {
  #This function converts pollen count data loaded from a GPD file into a vector of %arboreal pollen, using the taxonomic cateogries providedpct
  return(rowSums(GPD$counts[,which(GPD$tax.cat == "A")])/rowSums(GPD$counts))
}

plot_pctAP = function(pctAP, ages) {
	#Plot a stratigraph of the %AP by age
	plot(pctAP, ages, type="l", ylim = rev(range(ages)))
}

sites = read.csv("Data/_Williams2010sites.csv", header=TRUE)
gpdindex = read.csv("Data/_index.txt", header=FALSE)
sources = paste(trim(gpdindex[,4]),", ",trim(gpdindex[,5]), sep="")
lat = left()
colnames()

## Making a list of files used in the Williams(2010) data

filenames = list.files("Data/GPD/.")		#Make a vector of all files in the GPD database
sitenames = rep(0, length(filenames))		#Make an empty vector for site names
for (i in 1:length(filenames)) {
	data = scan(paste("Data/GPD/", filenames[i], sep=""), sep="\n", what="", skip=9, nlines=1, quiet=TRUE)	#Load the site name line from the GPD file
	name = trim(sub(pattern="# Site name:      ", replacement="", x = data)) #Trim the line to just the site name
	sitenames[i] = name #put this in the name vector
	}

wsites=read.csv("Data/_Williams2010sites.csv")  #Load the Williams 2010 site table
files <- filenames[match(wsites[,"SiteName"],sitenames)]  #Select the files whose site names match those in Williams 2010
files <- files[!is.na(files)] #Remove NAs (sites not in the GPD database)

APs = matrix(NA,nrow=length(files),ncol=1000)
ages = APs
max.length = 0
for (i in 1:length(files)) {
	data = readGPDascii(paste("Data/GPD/", files[i], sep=""))
	APs[i,1:length(data$absolute.ages)] = pctAP(data)
	ages[i,1:length(data$absolute.ages)] = data$absolute.ages
	if(length(data$absolute.ages) > max.length){max.length <- length(data$absolute.ages) }
}
AP <- APs[,1:max.length]
age <- ages[,1:max.length]

matplot(ages, APs)