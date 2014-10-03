#!/usr/bin/Rscript --vanilla --slave --quiet

# load rciop library to access the developer cloud sandbox functions
library("rciop")
library("rgeos")
library("stringr")

# load the application package when mvn installed it
library(rLandsat8, lib.loc="/application/share/R/library")

# get the extent of the area of interest in UTM coordinates, Landsat scenes will be clipped 
aoi.bbox <- as.numeric(unlist(strsplit(rciop.getparam("extent"), ",")))
aoi.extent <- extent(aoi.bbox[1], aoi.bbox[3], aoi.bbox[2], aoi.bbox[4])

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
  rciop.log("INFO", paste0("downloading", ls8.url, "to", ls8.identifier))
  rciop.copy (url=ls8.downloadUrl, target=TMPDIR, uncompress=FALSE)
  
  # extract the compressed Landsat 8 product
  rciop.log("INFO", paste("extracting product", ls8.identifier))
  untar(paste(TMPDIR, "/", ls8.identifier ,".tar.gz", sep=""), exdir = ls8.identifier)
  
  # read the data
  rciop.log("INFO", paste0("Loading", ls8.identifier, "dataset"))
  ls8 <- ReadLandsat8(ls8.identifier, aoi.extent)
  
  # create the result filenames, a geotiff and a png
  ls8.png <- paste0(TMPDIR, "/", ls8.identifier, ".png")
  ls8.tif <- paste0(TMPDIR, "/", ls8.identifier, ".tif")
 
  if (GetOrbitDirection(ls8) == 'A') {
    rciop.log("INFO", paste0("Ascending orbit, saving TIRS1 band:", ls8.png))
    
    # ascending direction, execute thermal analysis  
    raster.image <- ls8$band$tirs1
    writeRaster(raster.image, filename=ls8.tif, format="GTiff", overwrite=TRUE) 
    
    # saving png
    png(filename = ls8.png)
    plot(raster.image, col=grey(rev(seq(0, 1, by = 1/255))))
    dev.off()

  } else {
    
    rciop.log("INFO", paste0("Descending orbit, saving RGB image:", ls8.png))
    
    # descending direction, get RGB picture
    raster.image <- ToRGB(ls8, "swir2", "nir", "green") 
    writeRaster(raster.image, filename=ls8.tif, format="GTiff", overwrite=TRUE) 
    
    # saving png
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
  rciop.log("INFO", "Cleaning-up")
  file.remove(ls8.png)
  file.remove(ls8.tif)
  unlink(paste(TMPDIR, ls8.identifier, sep="/"), recursive=TRUE)

}
