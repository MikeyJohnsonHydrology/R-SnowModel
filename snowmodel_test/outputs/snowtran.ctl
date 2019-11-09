DSET  ^snowtran.gdat
TITLE SnowModel
UNDEF -9999.0
XDEF   31 LINEAR 0 0.2
YDEF   31 LINEAR 0 0.2
ZDEF    1 LEVELS 1
TDEF  319 LINEAR 01Z01oct2002 1dy
VARS    7
snowd       1  0 snow depth (m)
subl        1  0 sublimation at this time step (m)
salt        1  0 saltation transport at this time step (m)
susp        1  0 suspended transport at this time step (m)
subgrid     1  0 tabler snow redistribution at this time step (m)
sumsubl     1  0 summed sublimation during the simulation (m)
sumtrans    1  0 summed blowing-snow transport during simulation (m)
ENDVARS
