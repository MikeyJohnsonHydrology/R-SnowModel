##################################################################################################
### SnowModel Run Script, For SnowModel_2020-03-28
###
### This script was developed to make a full SnowModel run and plot results.
###
### Written by: Mikey Johnson, University of Nevada Reno, < mikeyj@nevada.unr.edu >
### last edited 04-01-2020
##################################################################################################

#### Loading packages ############################################################################
#These must be already installed on your system 
library(dplyr)      # data manipulation
library(ggplot2)    # plotting
library(plotly)     # interactive plotting
library(cowplot)    # publication-ready plots
library(devtools)   # developer tools, simplifying tasks


#### Setting working directorys #################################################################
# Setting the source file location
sfl <- dirname(rstudioapi::getActiveDocumentContext()$path)  # this is the source file location of R-SnowModel.R

# Working directory for demo runs of SnowModel
# ** If you have these in the correct directory they should be good to run out of the box. **
wd <- paste(sfl,"Singel_Cell_Test_Hogg_Pass_SM2020-03-28",sep="/")     # this file is the demo run of SnowModel

#### Step 1: compilling and running SnowModel ###################################################
setwd(paste(wd,"code",sep="/"))
system("sh compile_snowmodel.script")       # Compile SnowModel
setwd(wd)
system("./snowmodel")                       # Run SnowModel


#### Step 2: reading the GrADS file #############################################################
# To run this file you will need a folder with R-Snowmodel.R, ctlfile.R, gridp.R, gridt.R, readgrads.R.
# Theses functions were developed by Marcos Longo and are available on his GitHub (mpaiao).
# These files can eith be saved to same location as R-Snowmodel or source them from the GitHub.

# this code sources the files from a saved version in the same location as R-Snowmodel (I use this if I am not conected to the internet)
#setwd(sfl)   # This Directory is the folder with R-Snowmodel
#source("ctlfile.R")          # https://github.com/mpaiao/ED2/blob/master/R-utils/readctl.r  
#source("gridp.R")            # https://github.com/mpaiao/ED2/blob/master/R-utils/gridp.r
#source("gridt.R")            # https://github.com/mpaiao/ED2/blob/master/R-utils/gridt.r
#source("readgrads.R")        # https://github.com/mpaiao/ED2/blob/master/R-utils/readgrads.r

# this code sources the files from Marcos Longo's GitHub page
source_url("https://raw.githubusercontent.com/mpaiao/ED2/master/R-utils/readctl.r")
source_url("https://raw.githubusercontent.com/mpaiao/ED2/master/R-utils/gridp.r")
source_url("https://raw.githubusercontent.com/mpaiao/ED2/master/R-utils/gridt.r")
source_url("https://raw.githubusercontent.com/mpaiao/ED2/master/R-utils/readgrads.r")

# Move the corrected .ctl files into the snowmodel/outputs/wo_assim folder

# Changing the directory to the outputs file
setwd(paste(wd,"outputs","wo_assim",sep="/"))

SWED.info <- readctl("swed.ctl")
SWED <- readgrads(vari="swed",info=SWED.info) # snow-water-equivalent depth (m)

ggplotly(ggplot()+
           geom_point(aes(as.Date(SWED$gtime),SWED$swed[,1,1,1])) +
           theme_cowplot(12))

April.1 <- SWED$swed[183,1,,]


# Below is the example format for a .ctl file to be read into "readctl" funtion
# Note: you do not use the "# " at the beginning

# DSET ^../../outputs/wo_assim/swed.gdat
# TITLE SnowModel single-variable output file
# UNDEF    -9999.0
# XDEF     2 LINEAR     590975.39000000         100.00000000
# YDEF     2 LINEAR     4919155.4600000         100.00000000
# ZDEF     1 LINEAR 1 1
# TDEF     731 LINEAR 12Z01oct2002  1dy
# VARS     1
# swed     1  0 snow-water-equivalent depth (m)
# ENDVARS



