

#Read SVC .sig file-------------------------------------------------------------
read_svc_long <- function(sig_file){
  require(dplyr)
  ID <- sub(".*/", "", sig_file)                                                #Extract scan ID number
  df <- read.csv(sig_file, sep = "", header=F, skip = 30)                       #Read .sig and skip for 30 lines of metadata
  df[1:4] <- lapply(df[1:4], as.numeric)                                        #Set columns as numeric
  df <- df %>% group_by(V1) %>% summarise_all(mean)                             #Make it a dataframe rather than list                      
  df$id <- ID                                                                   #Append ID column
  names(df) <- c("wavelength", "reference", "radiance", "reflectance", "scan")  #Rename columns
  return(df)
}

#Read SVC .sig file only reflectance as wide format-----------------------------
read_svc_rfl_wide <- function(sig_file){
  require(dplyr)
  require(tidyr)
  ID <- sub(".*/", "", sig_file)                                                #Extract scan ID number
  df <- read.csv(sig_file, sep = "", header=F, skip = 30)                       #Read .sig and skip for 30 lines of metadata
  df[1:4] <- lapply(df[1:4], as.numeric)                                        #Set columns as numeric
  df <- df %>% group_by(V1) %>% summarise_all(mean)                             #Make it a dataframe rather than list   
  df$scan <- ID                                                                 #Append ID column
  names(df) <- c("wavelength", "reference", "radiance", "reflectance", "scan")  #Rename columns
  df <- select(df, 'scan', 'wavelength', 'reflectance')                         #Keep only scan ID, wavelengths, and reflectance
  df <- pivot_wider(df, names_from = wavelength, values_from = reflectance)     #Convert dataframe to wide format
  return(df)
}


#calculates vegetation index using (a - b) / (a + b)----------------------------
calc_VI <- function(df, b1 = 845, b2 = 645, bufferb1 = 5, bufferb2 = 5){
  b1 <- which.min(abs(b1 - as.numeric(names(df), options(warn=-1))))            #Identify first band and start range
  b2 <- which.min(abs(b2 - as.numeric(names(df), options(warn=-1))))            #Identify second band and end range
  ((rowMeans(df[b1-buffer1:b1+buffer1]) - rowMeans(df[b2-buffer2:b2+buffer2])) /      #vegetation index equation
      (rowMeans(df[b1-buffer1:b1+buffer1]) + rowMeans(df[b2-buffer2:b2+buffer2])))
}


