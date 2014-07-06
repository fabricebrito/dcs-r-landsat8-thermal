#' creates a raster with the NBR vegetation index
#' @description Creates a raster with the with the LSWI vegetation index: NBR =(ρNIR −ρSWIR2)/(ρNIR +ρSWIR2)
#'
#' @param product name of the product, e.g. LC80522102014165LGN00. It must be in the working directory.
#' @return brightness temperature raster
#' @examples \dontrun{
#' ls8 <- ReadLandsat8("LC80522102014165LGN00")
#' r <- ToNBR(ls8)
#' }
#'
#' @export
#' @import raster

ToNBR <- function(landsat8) {

  # NBR =(ρNIR −ρSWIR2)/(ρNIR +ρSWIR2)
  nir <- ToTOAReflectance(landsat8, "nir")
  swir2 <- ToTOAReflectance(landsat8, "swir2")
  
  nbr <- (nir - swir2) / (nir + swir2)
  
  return(nbr)

}
