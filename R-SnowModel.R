##################################################################################################
### SnowModel Run Script, by Mikey Johnson, Univeristy of Nevada Reno, < mikeyj@nevada.unr.edu >
### this script was developed to make a full SnowModel run
### step will require you to set some varibles depending on how you want to run the model
###
### last eddited 11-09-2019

#### Loading packages ########################################################################
#These must be already installed on your system 
library(lubridate)# date time manipulation
library(ggplot2)  #plotting
library(dplyr)    #data manipulation
library(plyr)     #data manipulation
library(plotly)   #interactive plotting
library(cowplot)  #publication-ready plots
library(devtools) #developer tools, simplifying tasks

#### Setting working directorys #############################################################
# Setting the source file location
sfl <- dirname(rstudioapi::getActiveDocumentContext()$path)  # this is the source file location of R-SnowModel.R
#sfl <- "~/Documents/R Scripts/SnowModel"                    # alternatitive manual process

# Working directory for demo run of SnowModel
# ** If you have these in the correct directory they should be good to run out of the box. **
#wd <- paste(sfl,"snowmodel_test",sep="/")     # this file is the demo run of SnowModel
wd <- paste(sfl,"Singel Cell Test",sep="/")     # this file is a single cell test at Hogg Pass SNOTEL, https://wcc.sc.egov.usda.gov/nwcc/site?sitenum=526

# My curent working directory of the MRB SnowModel
#wd <- "~/Desktop/MRB Project/SnowModel/Model Runs/McKenzie V6" # singel cell version for the MRB Project
#wd <- "~/Desktop/McKenzie V7" # singel cell version for the MRB Project


setwd(wd)


#### Step 1: compilling and running Fortran #################################################
setwd(paste(wd,"code",sep="/"))
system("sh compile_snowmodel.script")
setwd(wd)
system("./snowmodel")


#### Step 2: reading the GrADS file #####################################################
# to run this file you will need a folder with R-Snowmodel.R, ctlfile.R, gridp.R, gridt.R, readgrads.R
# you can either save these files to to the same location as R-Snowmodel or source them from the internet

# this code sources the files from a saved version in the same location as R-Snowmodel (I use this if I am not conected to the internet)
#setwd(sfl)   # This Directory is the folder with R-Snowmodel
#source("ctlfile.R")                          # https://github.com/mpaiao/ED2/blob/master/R-utils/readctl.r  
#source("gridp.R")                            # https://github.com/mpaiao/ED2/blob/master/R-utils/gridp.r
#source("gridt.R")                            # https://github.com/mpaiao/ED2/blob/master/R-utils/gridt.r
#source("readgrads.R")                        # https://github.com/mpaiao/ED2/blob/master/R-utils/readgrads.r

# this code sources the files from mpaiao's GitHub page
source_url("https://raw.githubusercontent.com/mpaiao/ED2/master/R-utils/readctl.r")
source_url("https://raw.githubusercontent.com/mpaiao/ED2/master/R-utils/gridp.r")
source_url("https://raw.githubusercontent.com/mpaiao/ED2/master/R-utils/gridt.r")
source_url("https://raw.githubusercontent.com/mpaiao/ED2/master/R-utils/readgrads.r")


setwd(paste(wd,"outputs",sep="/"))

# ** This code below allows you to read any of the varables that are saved by your SnowModel run. **
# ** Please note, that the control file format need to be set up in a specific way for th readctl function to work. **
# ** You can look at my demo control files to see the format, spacing is importent in the control file. **

### Reading the "microment.gdat" ###
#micromet.info <- readctl("micromet.ctl")                  # Reading micromet
#ta <- readgrads(vari="ta",info=micromet.info)             # air temperature (deg C)
#rh <- readgrads(vari="rh",info=micromet.info)             # relative humidity (%)
#u  <- readgrads(vari="u",info=micromet.info)              # meridional wind component (m/s)
#v  <- readgrads(vari="v",info=micromet.info)              # zonal wind component (m/s)
#wspd <- readgrads(vari="wspd",info=micromet.info)         # wind speed (m/s)
#wdir <- readgrads(vari="wdir",info=micromet.info)         # wind direction (0-360, true N)
#qsi  <- readgrads(vari="qsi",info=micromet.info)          # incoming solar radiation reaching the surface (W/m2)
#qli  <- readgrads(vari="qli",info=micromet.info)          # incoming longwave radiation reaching the surface (W/m2)
#prec <- readgrads(vari="prec",info=micromet.info)         # precipitation (m/time_step)


### Reading the "enbal.gdat" ###
#enbal.info <- readctl("enbal.ctl")                           # Readind enbal
#ta <- readgrads(vari="ta",info=enbal.info)                   # air temperature (deg C)
#tsfc <- readgrads(vari="tsfc",info=enbal.info)               # surface (skin) temperature (deg C)
#qsi  <- readgrads(vari="qsi",info=enbal.info)                # incoming solar radiation reaching the surface (W/m2)
#qli  <- readgrads(vari="qli",info=enbal.info)                # incoming longwave radiation reaching the surface (W/m2)
#qle  <- readgrads(vari="qle",info=enbal.info)                # emitted longwave radiation (W/m2)
#qh   <- readgrads(vari="qh",info=enbal.info)                 # sensible heat flux (W/m2)
#qe   <- readgrads(vari="qe",info=enbal.info)                 # latent heat flux (W/m2)
#qc   <- readgrads(vari="qc",info=enbal.info)                 # conductive heat flux (W/m2)
#qm   <- readgrads(vari="qm",info=enbal.info)                 # melt energy flux (W/m2)
#albedo <- readgrads(vari="albedo",info=enbal.info)           # albedo (0-1)
#ebal <- readgrads(vari="ebal",info=enbal.info)               # energy balance error (W/m2)


snowpack.info <- readctl("snowpack.ctl")                     # Reading snowpack
#snowd <- readgrads(vari="snowd",info=snowpack.info)          #snow depth (m)
#rosnow <- readgrads(vari="rosnow",info=snowpack.info)        #snow density (kg/m3)
swed <- readgrads(vari="swed",info=snowpack.info)            #snow-water-equivalent depth (m)
#runoff <- readgrads(vari="runoff",info=snowpack.info)        #runoff from base of snowpack (m/time_step)
#rain <- readgrads(vari="rain",info=snowpack.info)            #liquid precipitation (m/time_step)
#sprec <- readgrads(vari="sprec",info=snowpack.info)          #solid precipitation (m/time_step)
#qcs <- readgrads(vari="qcs",info=snowpack.info)              #canopy sublimation (m/time_step)
#canopy <- readgrads(vari="canopy",info=snowpack.info)        #canopy interception store (m)
#sumqcs <- readgrads(vari="sumqcs",info=snowpack.info)        #summed canopy sublimation during simulation (m)
#sumprec <- readgrads(vari="sumprec",info=snowpack.info)      #summed precipitation during simulation (m)
#sumsprec <- readgrads(vari="sumsprec",info=snowpack.info)    #summed snow precipitation during simulation (m)
#sumunload <- readgrads(vari="sumunload",info=snowpack.info)  #summed canopy unloading during the simulation (m)
#sumroff <- readgrads(vari="sumroff",info=snowpack.info)      #summed runoff during the simulation (m)
#sumswemelt <- readgrads(vari="sumswemelt",info=snowpack.info)#summed snow-water-equivalent melt (m)
#sumsublim <- readgrads(vari="sumsublim",info=snowpack.info)  #summed static-surface sublimation (m)
#wbal <- readgrads(vari="wbal",info=snowpack.info)            #summed water balance error during the simulation (m)




#### Step 3a: selecting the data of intrest (single cell) ################################
#[day#,z,x,y] this matrix is set up so that x=1, y=1 is the lower left corner of the model
# to properly compare you should compare varible of intrest to $glat and $glon
# I may need to find a way to include elevation data or look at the data in QGIS

#test.date <- as.POSIXct(substr(swed$gtime, start=2, stop=18),format="%m/%d/%y %H:%M:%OS", tz="UTC")
#test.date

ggplotly(ggplot()+
  geom_point(aes(as.Date(swed$gtime),swed$swed[,1,1,1])) +
  theme_cowplot(12))

#plot(canopy$gtime,canopy$canopy[,1,1,1])    # canopy interception [m]
#plot(sumqcs$gtime,sumqcs$sumqcs[,1,1,1])    # summed canopy sublimation during simulation [m]

#plot(wspd$gtime,wspd$wspd[,1,1,1])          # wind speed in [m/s]
#plot(rh$gtime,rh$rh[,1,1,1])                # relative humidity (%)
#plot(ta$gtime,ta$ta[,1,1,1])                # air temperature (deg C)



#### Step 3b: selecting the data of intrest (MRB Grid) ##################################

#mk.modled.swe <- swed$swed[,1,1013,653]

