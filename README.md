# R-SnowModel

#### This repository has a series of scripts that I use to run SNOWMODEL (Liston and Elder, 2006)

##### A Distributed Snow-Evolution Modeling System (SnowModel) https://doi.org/10.1175/JHM548.1

##### To properly run this code, you will need a Fortran compiler and a working version of SNOWMODEL
##### I use a MacBook Pro and GFortran https://gcc.gnu.org/wiki/GFortranBinariesMacOS

##### Fortran gridded data is saved in a GrADS file
##### I translante this data using R code from Marcos Longo https://github.com/mpaiao

##### --- I have posted two folders with this project that I use to test my script. ---
##### 1) "snowmodel_test", this is Dr. Glen Liston's code for a demo run of SnowModel_16_05_09
##### 2) "Singel_Cell_Test", this uses SnowModel_16_05_09 and simulates snow at the Hogg Pass SNOTEL for water year 2003 & 2004

##### --- I have added three scritps that are usefull for SnowModel runs. ---
##### 1) R-SnowModel.r : a script to compile, run, and read SnowModel
##### 2) SNOTEL_SnowModel_Comparison.r : a script to compare SnowModel resutls to SNOTEL data
##### 3) R-SnowModel-Calibration.r : a script to change SnowModel parameters and compare to SNOTEL data (This is code is still in development)

##### This is my early draft of the readme file (I plan to add more).

##### -Mikey, Feburary 27, 2020
