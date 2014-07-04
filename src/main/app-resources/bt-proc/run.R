#!/usr/bin/Rscript --vanilla --slave --quiet

# load rciop library to access the developer cloud sandbox functions
library("rciop")

library(stringr)

# load the application package when mvn installed it
library(rLandsat8, lib.loc="/application/share/R/library")

load("/application/.usgs.cred.rdata")

# read the inputs coming from stdin
f <- file("stdin")
open(f)

setwd(TMPDIR)

while(length(ls8.ref <- readLines(f, n=1)) > 0) {
  
  rciop.log("INFO", paste("processing product", ls8.ref))
  
  ls8.url <- rciop.casmeta(field="dclite4g:onlineResource", url=ls8.ref)$output
  
  ls8.identifier <- strsplit(rciop.casmeta(field="dc:identifier", url=ls8.ref)$output, ":")[[1]][2]
 
  rciop.log("INFO", paste("downloading", ls8.url, "to", ls8.identifier, sep=" "))
  DownloadLandsat(url=ls8.url, output.name=ls8.identifier)
  
  rciop.log("INFO", paste("extracting product", ls8.identifier))
  # extract the compressed Landsat 8 product
  untar(ls8.identifier)

  # calculate the brightness temperature
  bt <- BrightnessTemperature(ls8.identifier)
  
  ls8.png <- paste0(TMPDIR, "/", ls8.identifier, ".png")
  png(filename=ls8.png)
  brk <- c(10, 20, 30, 40, 50)
  plot(bt, breaks=brk, col=rainbow(10))
  dev.off()
  
  # publish it
  res <- rciop.publish(ls8.png, FALSE, FALSE)
  if (res$exit.code==0) { published <- res$output }
  
  # clean up
  file.remove(ls8.png)
  junk <- dir(path=TMPDIR, pattern=ls8.identifier)

  rciop.log("DEBUG", junk)
}
