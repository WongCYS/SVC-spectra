#Reads in SVC data

library(tidyverse)

#Location of all the raw .sig files 
file_list <- list.files("C:/Users/cyswong/Documents/UCDavis/Beans/Reflectance/20211004", full.names = T, pattern = ".sig")
file_list2 <- sub(".*/", "", file_list)    #Extract scan ID number

#For loop to read and append all scans to single df
dataset <- data.frame()
for (i in 1:length(file_list)){
  temp_data <- read.csv2(file_list[i], sep = "", header=F, skip = 30)
  temp_data[1:4] <- lapply(temp_data[1:4], as.numeric)
  temp_data$id <- file_list2[i]
  print(paste(file_list2[i], which(file_list == file_list[i]), "out of", length(file_list)))
  dataset <- rbind(dataset, temp_data)
}

#Name the columns
names(dataset) <- c("wavelength", "reference", "radiance", "reflectance", "scan")

#Plot all spectra
ggplot(dataset, aes(x = wavelength,y = reflectance, color = scan, group = scan)) +   #Or color = ID
  geom_line(show.legend = F,size=.5)+
  scale_x_continuous("Wavelength (nm)",limits = c(300,2500), breaks = seq(400,2500,200))+
  scale_y_continuous("Reflectance (%)")
  theme_bw()+
  theme(axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1))

#Convert to wide format
df_wide <- dataset %>% select(wavelength, reflectance, scan) %>%
  pivot_wider(names_from = wavelength, values_from = reflectance, id_cols = scan, values_fn = mean)

#Define function to calculate vegetation indices
#calculates vegetation index using (a:b - c:d) / (a:b + c:d)
calc_VI <- function(df, a, b, buffer1, buffer2){
  b1 <- which.min(abs(a - as.numeric(names(df), options(warn=-1))))   #Identify first band and start range
  b2 <- which.min(abs(b - as.numeric(names(df), options(warn=-1))))   #Identify second band and end range
  ((rowMeans(df_wide[b1-buffer1:b1+buffer1]) - rowMeans(df_wide[b2-buffer2:b2+buffer2])) /      #vegetation index equation
      (rowMeans(df_wide[b1-buffer1:b1+buffer1]) + rowMeans(df_wide[b2-buffer2:b2+buffer2])))
}

#Example NDVI red 620 to 670 nm and NIR 841 to 876 nm
df_wide$NDVI <- calc_VI(df_wide, 870, 680, 20, 20)   
#Example PRI r531 526 to 536 nm and r570 565 to 575 nm
df_wide$PRI <- calc_VI(df_wide, 531, 570, 2, 2)

#Quick PRI and NDVI plot to look at spread
ggplot(df_wide,aes(x = scan,y = PRI))+      
  geom_point()+
  scale_y_continuous(bquote("PRI"))+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1))

ggplot(df_wide,aes(x = scan,y = NDVI))+      
  geom_point()+
  geom_jitter(width = 0,size = 1.5, show.legend = FALSE)+
  scale_y_continuous(bquote("NDVI"))+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1))

#export csv
#write.csv(dataset,'20211004_long.csv', row.names = FALSE)        #Long format
write.csv(df_wide,'20211004_wide.csv', row.names = FALSE)         #Wide format
