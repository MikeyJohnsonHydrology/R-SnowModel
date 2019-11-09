DSET  ^snowpack.gdat
TITLE SnowModel
UNDEF -9999.0
XDEF 2 LINEAR 590947.0000 100.0
YDEF 2 LINEAR 4919124.0000 100.0
ZDEF    1 LEVELS 1
TDEF  731 LINEAR 12:00Z01oct2002 1dy
VARS   16
snowd       1  0 snow depth (m)
rosnow      1  0 snow density (kg/m3)
swed        1  0 snow-water-equivalent depth (m)
runoff      1  0 runoff from base of snowpack (m/time_step)
rain        1  0 liquid precipitation (m/time_step)
sprec       1  0 solid precipitation (m/time_step)
qcs         1  0 canopy sublimation (m/time_step)
canopy      1  0 canopy interception store (m)
sumqcs      1  0 summed canopy sublimation during simulation (m)
sumprec     1  0 summed precipitation during simulation (m)
sumsprec    1  0 summed snow precipitation during simulation (m)
sumunload   1  0 summed canopy unloading during the simulation (m)
sumroff     1  0 summed runoff during the simulation (m)
sumswemelt  1  0 summed snow-water-equivalent melt (m)
sumsublim   1  0 summed static-surface sublimation (m)
wbal        1  0 summed water balance error during the simulation (m)
ENDVARS
