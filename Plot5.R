library("data.table")
library("ggplot2")
setwd("C:/R/4_Exploratory_DATA")
path <- getwd()
getwd()
download.file(url = "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"
              , destfile = paste(path, "dataFiles.zip", sep = "/"))
unzip(zipfile = "dataFiles.zip")

# Load the NEI & SCC data frames.
NEI <- data.table::as.data.table(x = readRDS("summarySCC_PM25.rds"))
SCC <- data.table::as.data.table(x = readRDS("Source_Classification_Code.rds"))
NEI
SCC

# Gather the subset of the NEI data which corresponds to vehicles
vehiclesSCC <- SCC[grepl("vehicle", SCC$SCC.Level.One, ignore.case=TRUE), SCC]
vehiclesNEI <- NEI[NEI[, SCC] %in% vehiclesSCC,]

scc.mobile <- grepl("mobile", SCC$SCC.Level.One, ignore.case=TRUE)
scc <- SCC[scc.mobile,]$SCC
scc
nei <- NEI[(fips == "24510") & (SCC %in% scc) & (type=="ON-ROAD"), 
           sum(Emissions), by=year]
setnames(nei, 2, "total.emissions")

#plot the data
plot(nei$year, nei$total.emissions, 
     type="b", yaxt="n", xaxt="n", pch=20,
     xlab="Year", ylab="Emissions (in tons)",
     main="PM 2.5 emissions from motor vehicles in Baltimore")
round.by <- 1
axis(2, at=seq(0,300,100), labels=format(as.double(seq(0,300,100)), nsmall=0))
axis(1, at=nei$year, labels=nei$year)
text(nei$year, nei$total.emissions, 
     round(nei$total.emissions/round.by, 2), 
     cex=0.6, pos=c(4,2,4,2))

#save the plot to png
dev.copy(png, file="plot5.png")
dev.off()

#return the data to the caller
nei
}

