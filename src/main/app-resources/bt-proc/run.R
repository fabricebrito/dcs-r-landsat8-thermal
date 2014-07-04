#!/usr/bin/Rscript --vanilla --slave --quiet

# load rciop library to access the developer cloud sandbox functions
library("rciop")

# load the application package when mvn installed it
library(rLandsat8, lib.loc="/application/share/R/library")


# read the inputs coming from stdin
f <- file("stdin")
open(f)

while(length(ls8.ref <- readLines(f, n=1)) > 0) {
  
  rciop.log("INFO", paste("processing product", ls8.ref))
  
  
  
}
