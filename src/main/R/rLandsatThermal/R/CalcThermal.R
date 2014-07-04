CalcThermal(product) {
  
  l <- ReadLandsat8(product)

  ML <- as.numeric(l$metadata$radiance_mult_band_10)
  AL <- as.numeric(l$metadata$radiance_add_band_10)
  K1 <- as.numeric(l$metadata$k1_constant_band_10)
  K2 <- as.numeric(l$metadata$k2_constant_band_10)

  SST <- K2 / log(K1 / (ML * l$band$tirs1 + AL) + 1) - 273.15 

  return(SST)

}
