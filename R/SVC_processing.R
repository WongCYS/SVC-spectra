library(tidyverse)

#Location of all the raw .sig files 
file_list <- list.files("C:/Users/cyswong/Documents/UCDavis/Beans/Reflectance/20211004", full.names = T, pattern = ".sig")
file_list2 <- sub(".*/", "", file_list)    #Extract scan ID numbers

#For loop to read and append all scans to single df
dataset <- data.frame()
for (i in 1:length(file_list)){
  temp_data <- read.csv2(file_list[i], sep = "", header=F, skip = 30)
  temp_data[1:4] <- lapply(temp_data[1:4], as.numeric)
  #temp_data <- as.rspec(temp_data,whichwl = "V1") #For interpolating spectra to 1 nm resolution; needs the pavo library
  temp_data$id <- file_list2[i]
  print(paste(file_list2[i], which(file_list == file_list[i]), "out of", length(file_list)))
  dataset <- rbind(dataset, temp_data)
}

#Name the columns
names(dataset) <- c("wavelength", "reference", "radiance", "reflectance", "scan")

#Plot all spectra
ggplot(dataset, aes(x=wavelength,y=reflectance, color = scan, group = scan)) +   #Or color = ID
  geom_line(show.legend = F,size=.5)+
  scale_x_continuous("Wavelength (nm)",limits = c(300,2500), breaks = seq(400,2500,200))+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1))

#Convert to wide format
df_wide <- dataset %>% select(wavelength, reflectance, scan) %>%
  pivot_wider(names_from = wavelength, values_from = reflectance, id_cols = scan, values_fn = mean)

#Calculate some vegetation indices
df_wide$NDVI <- (df_wide$`800.9` - df_wide$`680.8`) / (df_wide$`800.9` + df_wide$`680.8`)
df_wide$PRI <- (df_wide$`531.3` - df_wide$`570.4`) / (df_wide$`531.3` + df_wide$`570.4`)

#plot PRI and NDVI plot to look at spread
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
#write.csv(df_wide,'20211004_wide.csv', row.names = FALSE)         #Wide format