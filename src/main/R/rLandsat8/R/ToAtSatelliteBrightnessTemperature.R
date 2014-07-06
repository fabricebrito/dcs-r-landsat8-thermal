#' creates a raster with the brightness temperature extrcted from Landsat tirs1 band
#' @description Creates a raster with the brightness temperature extrcted from Landsat tirs1 band.
#'
#' @param product name of the product, e.g. LC80522102014165LGN00. It must be in the working directory.
#' @return brightness temperature raster
#' @examples \dontrun{
#' ToAtSatelliteBrightnessTemperature("LC80522102014165LGN00")
#' }
#'
#' @export
#' @import raster

ToAtSatelliteBrightnessTemperature <- function(product) {
  
  l <- ReadLandsat8(product)

  ml <- as.numeric(l$metadata$radiance_mult_band_10)
  al <- as.numeric(l$metadata$radiance_add_band_10)
  k1 <- as.numeric(l$metadata$k1_constant_band_10)
  k2 <- as.numeric(l$metadata$k2_constant_band_10)

  bt <- k2 / log(k1 / (ml * l$band$tirs1 + al) + 1) - 273.15 

  return(bt)

}
