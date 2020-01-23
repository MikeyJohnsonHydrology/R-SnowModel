# R-SnowModel

##### This R script compiles, runs, and translates the fortran code SNOWMODEL (Liston and Elder, 2006)

##### A Distributed Snow-Evolution Modeling System (SnowModel) https://doi.org/10.1175/JHM548.1

##### To properly run this code, you will need a Fortran compiler and a working version of SNOWMODEL
##### I use a MacBook Pro and GFortran https://gcc.gnu.org/wiki/GFortranBinariesMacOS

##### Fortran gridded data is saved in a GrADS file
##### I translante this data using R code from Marcos Longo https://github.com/mpaiao

##### I have posted two folders with this project that I use to test my script.
##### 1) "snowmodel_test", this is Dr. Glen Liston's code for a demo run of SnowModel_16_05_09
##### 2) "Singel_Cell_Test", this uses SnowModel_16_05_09 and simulates snow at the Hogg Pass SNOTEL for water year 2003 & 2004

##### This is my early draft of the readme file, I plan to expand more on the steps to run the program.

##### -Mikey, January 23, 2020
