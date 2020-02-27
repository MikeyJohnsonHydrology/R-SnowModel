#####################################################################################################
### R-SnowModel Calibration Script (Beta Version)
###
### This scrip uses the work flow from R-SnowModel.R and SNOTEL_SnowModel_Comparison.R to help
### with SnowModel calibration. Currently this script is desinged for a single run but I anticipate
### that I will write this into a loop to best calibrate SnowModel.
###
### By: Mikey Johnson, University of Nevada Reno, mikeyj@nevada.unr.edu
### Last eddited: 2020-02-20
#####################################################################################################


#### Loading packages ###############################################################################
#These must be already installed on your system 
library(dplyr)      # data manipulation
library(ggplot2)    # plotting
library(plotly)     # interactive plotting
library(cowplot)    # publication-ready plots
library(devtools)   # developer tools, simplifying tasks
library(snotelr)    # a package to easily pull SNOTEL data
library(hydroGOF)   # functions for the comparison of simulated and observed data


#### Sourcing Read GrADS functions ##################################################################
# this code sources the files from Marcos Longo's GitHub page
source_url("https://raw.githubusercontent.com/mpaiao/ED2/master/R-utils/readctl.r")
source_url("https://raw.githubusercontent.com/mpaiao/ED2/master/R-utils/gridp.r")
source_url("https://raw.githubusercontent.com/mpaiao/ED2/master/R-utils/gridt.r")
source_url("https://raw.githubusercontent.com/mpaiao/ED2/master/R-utils/readgrads.r")


#### Setting working directorys #####################################################################
# Setting the source file location
sfl <- dirname(rstudioapi::getActiveDocumentContext()$path)  # this is the source file location of R-SnowModel.R
wd <- paste(sfl,"Singel_Cell_Test",sep="/")                  # this folder is a single cell test at Hogg Pass SNOTEl (you will need this folder to be in the same folder as this R script)
setwd(wd)                                                    # Setting the working directory to the version of SnowModel to be run.


#### Work Flow ######################################################################################
# 1) Load the SNOTEL information (if calibrating a model you should only need to run this step once)
# 2) Set paramter values for the SnowModel Run
# 3) Compile and run SnowModel
# 4) Read the GrADS file and storing the timeseries of SWE
# 5) Plot the SNOTEL and SnowModel data
# 6) Quantitiative comparision of SNOTEL and SnowModel data


#### 1) Load the SNOTEL information #################################################################
Hogg_Pass <- snotel_download(site_id = 526, internal = TRUE)
HP.snotel <- Hogg_Pass[which(Hogg_Pass$date >= "2002-10-01" & Hogg_Pass$date <= "2004-09-30"),]
observed.swe <- HP.snotel$snow_water_equivalent #[mm]


#### 2) Set paramter values for the SnowModel Run ###################################################
# snowmodel.par file
gap_frac = 0.2                # line 604, orignal value 0.2
albedo_snow_forest = 0.55     # line 806, orignal value 0.35
albedo_snow_clearing = 0.60   # line 814, orignal value 0.60
max_layers = 1                # line 889, orignal value 1

new.snowmodel.par <- readLines("snowmodel.par")
new.snowmodel.par[604] <- paste("      gap_frac = ", gap_frac, sep="")
new.snowmodel.par[806] <- paste("      albedo_snow_forest = ", albedo_snow_forest, sep="")
new.snowmodel.par[814] <- paste("      albedo_snow_clearing = ", albedo_snow_clearing, sep="")
new.snowmodel.par[889] <- paste("      max_layers = ", max_layers, sep="")
writeLines(new.snowmodel.par,"snowmodel.par")

# micromet_code.f file 
rain_snow_transition_temperature <- "1.0"     # line 399, orignal value 2.0

new.micromet_code.f <- readLines("code/micromet_code.f")
new.micromet_code.f[399] <- paste("          if (Tair_grid(i,j).lt.",rain_snow_transition_temperature,"+Tf) then", sep="")
writeLines(new.micromet_code.f,"code/micromet_code.f")

# snowpack_code.f file
ro_snowmax <- "550.0"                         # line 929, orignal value 550.0

new.snowpack_code.f <- readLines("code/snowpack_code.f")
new.snowpack_code.f[929] <- paste("      ro_snowmax = ", ro_snowmax, sep="")
writeLines(new.snowpack_code.f,"code/snowpack_code.f")


#### 3) Compile and run SnowModel ###################################################################
setwd(paste(wd,"code",sep="/"))
system("sh compile_snowmodel.script")      # Compile SnowModel
setwd(wd)
system("./snowmodel")                      # Run SnowModel 


#### 4) Reading SnowModel GrADS output ##############################################################
# Changing the directory to the outputs file
setwd(paste(wd,"outputs",sep="/"))

# Reading the SWE from the snowpack GrADS file 
snowpack.info <- readctl("snowpack.ctl")                     # Reading snowpack
swed <- readgrads(vari="swed",info=snowpack.info)            #snow-water-equivalent depth (m)
modeled.swe <- (swed$swed[,1,1,1])*1000 #[mm]


#### 5) Plot the SNOTEL and SnowModel data ##########################################################
plot(1:731, observed.swe, type='l', ylim = c(0, 1500), xaxt = "n", xlab="Water Year 2003 & 2004", ylab="SWE (mm)", main="HoggPass SNOTEL")
axis(side = 1, at = c(0,92,183,274,365,458,549,640), labels = c("Oct","Jan","Apr","Jul","Oct","Jan","Apr","Jul"))
#abline(v=307, col="black", lty=2)
points(1:731, modeled.swe, type='l', lty=2, lwd=2, col = "blue")
legend("topleft", legend=c("SNOTEL","SnowModel"), col=c("black","blue"), lty=c(1,2), lwd(1,2),cex=0.8, bty="n")


#### 6) Quantitiative comparision of SNOTEL and SnowModel data ######################################
#### Nash–Sutcliffe model efficiency
nonzero <- which(modeled.swe!=0 & observed.swe!=0)    # Finding all the data where both the modeled and observed data is not zero
Nash.Sutcliffe.Efficency <- NSE(modeled.swe[nonzero], observed.swe[nonzero])
paste("Nash-Sutcliffe Efficency =", Nash.Sutcliffe.Efficency)

#### R-Squared
R_Squared  <- cor(modeled.swe[nonzero],observed.swe[nonzero]) ^ 2
paste("R-Squared =",R_Squared)


