#!/usr/bin/Rscript --vanilla --slave --quiet

# load rciop library to access the developer cloud sandbox functions
library("rciop")

library(stringr)

# load the application package when mvn installed it
library(rLandsat8, lib.loc="/application/share/R/library")


# read the inputs coming from stdin
f <- file("stdin")
open(f)

while(length(ls8.ref <- readLines(f, n=1)) > 0) {
  
  rciop.log("INFO", paste("processing product", ls8.ref))
  
  ls8.url <- rciop.casmeta(field="dclite4g:onlineResource", url=l8.ref)$output
  
  ls8.identifier <- strsplit(rciop.casmeta(field="dc:identifier", url=l8.ref)$output, ":")[[1]][2]
  
  DownloadLandsat(url=ls8.url, output.name=ls8.identifier)
  
  # extract the compressed Landsat 8 product
  
  # calculate the brightness temperature
  bt <- BrightnessTemperature(ls8.identifier)
  
  
  
}
