#!/usr/bin/Rscript --vanilla --slave --quiet

# load rciop library to access the developer cloud sandbox functions
library("rciop")
library("rgeos")
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
  
  ls8.url <- rciop.casmeta(field="dclite4g:DataSet", url=ls8.ref)$output
  ls8.downloadUrl <- rciop.casmeta(field="dclite4g:onlineResource", url=ls8.ref)$output
  ls8.identifier <- strsplit(rciop.casmeta(field="dc:identifier", url=ls8.ref)$output, ":")[[1]][2]
 
  # download Landsat 8 product
  rciop.log("INFO", paste("downloading", ls8.url, "to", ls8.identifier, sep=" "))
  rciop.copy (url=ls8.downloadUrl, target=TMPDIR, uncompress=FALSE)
  
  # extract the compressed Landsat 8 product
  rciop.log("INFO", paste("extracting product", ls8.identifier))
  untar(paste(TMPDIR, "/", ls8.identifier ,".tar.gz", sep=""), exdir = ls8.identifier)
  
  ls8.polygon <- rciop.casmeta(field="dct:spatial", url=ls8.ref)$output
  # loading the bounding box
  the.polygon<-readWKT(ls8.polygon)

  # crop the image taking the 60% of the image 
  rciop.log("INFO", paste("computing the extent object to crop the images"))
  delta.x <- abs(the.polygon@bbox["x","max"] - the.polygon@bbox["x","min"])
  delta.y <- abs(the.polygon@bbox["y","max"] - the.polygon@bbox["y","min"])
  xmin <- as.integer((the.polygon@bbox["x","min"] + ( delta.x * 0.6 ) / 2))
  xmax <- as.integer((the.polygon@bbox["x","max"] - ( delta.x * 0.6 ) / 2))
  ymin <- as.integer((the.polygon@bbox["y","min"] + ( delta.y * 0.6 ) / 2))
  ymax <- as.integer((the.polygon@bbox["y","max"] - ( delta.x * 0.6 ) / 2))
  ext <- extent(xmin, xmax, ymin, ymax)
  rciop.log("INFO", paste("xmin:",xmin,"ymin:",ymin,"xmax:",xmax,""))

  # read the data
  ls8 <- ReadLandsat8(ls8.identifier, ext)
  
  ls8.png <- paste0(TMPDIR, "/", ls8.identifier, ".png")
  # ls8.tif <- paste0(TMPDIR, "/", ls8.identifier, ".tif")
  if(GetOrbitDirection(ls8)=='A'){
    # ascending direction, execute thermal analysis  
    raster.image <- ToRGB(ls8$band$tirs1)
    # saving png gray file
    png(filename = ls8.png)
    plot(raster.image, col=grey(rev(seq(0, 1, by = 1/255))))
    dev.off()

  }else{
    # descending direction, get RGB picture
    raster.image <- ToRGB(ls8$band$red, ls8$band$green, ls8$band$blue)
    # saving png color file
    png(filename = ls8.png)
    plotRGB(raster.image, r=1, g=2, b=3)
    dev.off()
  }
  # saving geotif raster
  # writeRaster(thermal, filename=ls8.tif, format="GTiff", overwrite=TRUE) 
  
  # publish it
  # res <- rciop.publish(ls8.png, FALSE, FALSE)
  # if (res$exit.code==0) { published <- res$output }
  
  # res <- rciop.publish(ls8.tif, FALSE, FALSE)
  # if (res$exit.code==0) { published <- res$output }

  # clean up
  # file.remove(ls8.png)
  # file.remove(ls8.tif)
  # junk <- dir(path=TMPDIR, pattern=ls8.identifier)

  # rciop.log("DEBUG", junk)
}
