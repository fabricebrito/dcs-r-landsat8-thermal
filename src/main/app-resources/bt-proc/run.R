#!/usr/bin/Rscript --vanilla --slave --quiet

# load rciop library to access the developer cloud sandbox functions
library("rciop")
library("rgeos")
library("stringr")

# load the application package when mvn installed it
library(rLandsat8, lib.loc="/application/share/R/library")

aoi.bbox <- as.numeric(unlist(strsplit(rciop.getparam("extent"), ",")))
aoi.extent <- extent(ext[1], ext[3], ext[2], ext[4])

# read the inputs coming from stdin
f <- file("stdin")
open(f)

setwd(TMPDIR)

while(length(ls8.ref <- readLines(f, n=1)) > 0) {
  
  rciop.log("INFO", paste("processing product", ls8.ref))
  
  ls8.url <- rciop.casmeta(field="dclite4g:DataSet", url=ls8.ref)$output
  ls8.downloadUrl <- rciop.casmeta(field="dclite4g:onlineResource", url=ls8.ref)$output
  ls8.identifier <- strsplit(rciop.casmeta(field="dc:identifier", url=ls8.ref)$output, ":")[[1]][2]
 
  # download Landsat 8 product
  rciop.log("INFO", paste("downloading", ls8.url, "to", ls8.identifier, sep=" "))
  rciop.copy (url=ls8.downloadUrl, target=TMPDIR, uncompress=FALSE)
  
  # extract the compressed Landsat 8 product
  rciop.log("INFO", paste("extracting product", ls8.identifier))
  untar(paste(TMPDIR, "/", ls8.identifier ,".tar.gz", sep=""), exdir = ls8.identifier)
  
  # read the data
  rciop.log("INFO", paste("Loading", ls8.identifier, "dataset", sep=" "))
  ls8 <- ReadLandsat8(ls8.identifier, aoi.extent)
  
  ls8.png <- paste0(TMPDIR, "/", ls8.identifier, ".png")
  ls8.tif <- paste0(TMPDIR, "/", ls8.identifier, ".tif")
 
  if (GetOrbitDirection(ls8)=='A') {
    rciop.log("INFO", paste("Ascending orbit, saving grey image:", ls8.png, sep=" "))
    
    # ascending direction, execute thermal analysis  
    raster.image <- ToRGB(ls8$band$tirs1)
    writeRaster(raster.image, filename=ls8.tif, format="GTiff", overwrite=TRUE) 
    
    # saving png gray file
    png(filename = ls8.png)
    plot(raster.image, col=grey(rev(seq(0, 1, by = 1/255))))
    dev.off()

  } else {
    
    rciop.log("INFO", paste("Descending orbit, saving RGB image:", ls8.png, sep=" "))
    # descending direction, get RGB picture
    raster.image <- ToRGB(ls8$band$red, ls8$band$green, ls8$band$blue)
    writeRaster(raster.image, filename=ls8.tif, format="GTiff", overwrite=TRUE) 
    
    # saving png color file
    png(filename = ls8.png)
    plotRGB(raster.image, r=1, g=2, b=3)
    dev.off()
  }

  # publish it
  res <- rciop.publish(ls8.png, recursive=FALSE, metalink=TRUE)
  if (res$exit.code==0) { published <- res$output }
  
  # publish it
  res <- rciop.publish(ls8.tif, recursive=FALSE, metalink=TRUE)
  if (res$exit.code==0) { published <- res$output }

  # clean up
  file.remove(ls8.png)
  file.remove(ls8.tif)
  junk <- dir(path=TMPDIR, pattern=ls8.identifier)

  rciop.log("DEBUG", junk)
}
