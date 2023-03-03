# Handling SVC data

For mass opening SVC .sig data with radiance and reflectance:
```
source("~/UCDavis/Github/SVC/R/SVC_processing.R")
file_list <- list.files("C:/Users/cyswong/Documents/UCDavis/Beans/Reflectance/20211004", full.names = T)

#For loop to read and append all scans to single df
df <- data.frame()
for (i in 1:length(file_list)){
  print(paste(file_list[i], i, which(file_list == i), 'out of', length(file_list)))
  temp_data <- read_svc_long(file_list[i])
  df <- rbind(df, temp_data)
}
```

For mass opening SVC .sig data with only reflectance as wide format:
```
source("~/UCDavis/Github/SVC/R/SVC_processing.R")
file_list <- list.files("C:/Users/cyswong/Documents/UCDavis/Beans/Reflectance/20211004", full.names = T)

#For loop to read and append all scans to single df
df <- data.frame()
for (i in 1:length(file_list)){
  print(paste(file_list[i], i, which(file_list == i), 'out of', length(file_list)))
  temp_data <- read_svc_rfl_wide(file_list[i])
  df <- rbind(df, temp_data)
}
```

For calculating vegetation indices from the wide format data:
```
#Example caluations of NDVI and PRI from wide format data
df$NDVI <- calc_VI(df, a = 845, b = 645, buffer1 = 20, buffer2 = 20)
df$PRI <- calc_VI(df, a = 531, b = 570, buffer1 = 5, buffer2 = 5)
```
