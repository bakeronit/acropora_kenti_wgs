library(sf)
library(raster)
library(ggplot2)
library(rgdal)
library(grid)
library(ggsci)
library(ggrepel)
library(tidyverse)
library(RColorBrewer)

source("scripts/my_color.R")

gbr <- readOGR(dsn = "data/zipfolder",layer = "Great_Barrier_Reef_Features")
#summary(gbr)
gbr <- base::subset(gbr,FEAT_NAME != "Rock")
gbr <- base::subset(gbr,FEAT_NAME != "Sand")
gbr <- base::subset(gbr,FEAT_NAME != "Cay")


#geo_bounds <- c(left = 145.3, bottom = -20.50, right = 149.00, top = -16.0)
geo_bounds <- c(left = 145, bottom = -19.40, right = 147.3, top = -16.6)



Sites.grid <- expand.grid(lon_bound = c(geo_bounds[1], geo_bounds[3]), 
                          lat_bound = c(geo_bounds[2], geo_bounds[4]))
coordinates(Sites.grid) <- ~ lon_bound + lat_bound
gbr_coral <- crop(gbr, extent(Sites.grid))
gbr_coral <- fortify(gbr_coral,region = "FEAT_NAME")


samples <- read_tsv("data/samples.txt")
cities <- read_tsv("data/cities.txt")
islands <- read_tsv("data/islands.txt")

cols <- c("#ADB49F","#ADB49F","lightgrey")
names(cols) <- c("Island","Mainland","Reef")
fill_cols <- c(cols,site_colors())



p1<-ggplot() + 
  geom_polygon(data=gbr_coral,aes(x=long,y=lat,group=group,fill=id))+ scale_fill_manual(values=fill_cols)+
  coord_equal(expand=FALSE)+
  geom_point(data=samples,aes(x=long,y=lat,fill=type,size=n/10),color="black",size=5,shape=21) +
  geom_text(data=cities,aes(x=long,y=lat,label=name),size=4,nudge_x=-0.1) +
  geom_text(data = islands, aes(x = long, y = lat, label = stringr::str_wrap(name,5) ), size = 2.5, color="grey21") +
  geom_text_repel(data=samples, aes(x=long,y=lat,label=type,color=type),fontface="bold",nudge_x = 0.12,segment.alpha=0) + 
  scale_color_manual(values = site_colors()) +
  scale_x_continuous(breaks=seq(145,147.5, 0.5),labels = c(paste(seq(145,147.5,0.5),"°E",sep=""))) +
  scale_y_continuous(breaks=seq(-19.5,-16,0.5),labels=c(paste(seq(19.5,16, -0.5),"°S", sep=""))) +
  annotate(geom="text", x=145.4, y=-19.3, label="Queensland, Australia",color="black",fontface="bold")+
  theme(legend.title = element_blank(),
      legend.position = "none",
      panel.background = element_rect(fill = "White",colour = "Black", size = 0.5),
      panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
      axis.title.x = element_blank(),
      axis.title.y = element_blank(),
      plot.margin = unit(c(0, 0, 0, 0), "cm"))


p1
region <- data.frame(xmin=geo_bounds[1],ymin=geo_bounds[2],xmax=geo_bounds[3],ymax=geo_bounds[4])
qld <- base::subset(gbr,FEAT_NAME != "Reef")

p2<-ggplot()+
  geom_polygon(data = qld,aes(x=long,y=lat,group=group),fill="#ADB49F") +
  coord_equal()+theme_bw()+labs(x=NULL,y=NULL) +
  geom_rect(data = region,aes(xmin=xmin,ymin=ymin,xmax = xmax, ymax=ymax), color="grey11", size = 0.2,
            linetype=1,fill="grey81",alpha=0.6)+
  theme(axis.text.x =element_blank(),
        axis.text.y= element_blank(), 
        axis.ticks=element_blank(),
        axis.title.x =element_blank(),
        axis.title.y= element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_rect(color = NA))


png(file="figures/Atenius-sampling.png",w=5.2,h=7.2, res=300,units = "in")
grid.newpage()
v1<-viewport(width = 1, height = 1, x = 0.5, y = 0.5) #plot area for the main map
v2<-viewport(width = 0.2, height = 0.2, x = 0.2, y = 0.25) #plot area for the inset map
print(p1,vp=v1) 
print(p2,vp=v2)
dev.off()
