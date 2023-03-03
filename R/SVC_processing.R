

#Read SVC .sig file-------------------------------------------------------------
read_svc_long <- function(sig_file){
  require(dplyr)
  ID <- sub(".*/", "", sig_file)    #Extract scan ID number
  df <- read.csv2(sig_file, sep = "", header=F, skip = 30)
  df[1:4] <- lapply(df[1:4], as.numeric)
  df <- df %>% group_by(V1) %>% summarise_all(mean) 
  df$id <- ID
  names(df) <- c("wavelength", "reference", "radiance", "reflectance", "scan")
  return(df)
}

#Read SVC .sig file only reflectance as wide format-----------------------------
read_svc_rfl_wide <- function(sig_file){
  require(dplyr)
  require(tidyr)
  ID <- sub(".*/", "", sig_file)    #Extract scan ID number
  df <- read.csv2(sig_file, sep = "", header=F, skip = 30)
  df[1:4] <- lapply(df[1:4], as.numeric)
  df <- df %>% group_by(V1) %>% summarise_all(mean) 
  df$scan <- ID
  names(df) <- c("wavelength", "reference", "radiance", "reflectance", "scan")
  df <- select(df, 'scan', 'wavelength', 'reflectance')
  df <- pivot_wider(df, names_from = wavelength, values_from = reflectance)
  return(df)
}


#calculates vegetation index using (a - b) / (a + b)----------------------------
calc_VI <- function(df, b1 = 845, b2 = 645, bufferb1 = 5, bufferb2 = 5){
  b1 <- which.min(abs(b1 - as.numeric(names(df), options(warn=-1))))   #Identify first band and start range
  b2 <- which.min(abs(b2 - as.numeric(names(df), options(warn=-1))))   #Identify second band and end range
  ((rowMeans(df[b1-buffer1:b1+buffer1]) - rowMeans(df[b2-buffer2:b2+buffer2])) /      #vegetation index equation
      (rowMeans(df[b1-buffer1:b1+buffer1]) + rowMeans(df[b2-buffer2:b2+buffer2])))
}


