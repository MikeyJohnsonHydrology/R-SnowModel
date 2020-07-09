c mikey_sm_subroutines.f

c A series of fortran subroutines that can be added to SnowModel


c Canopy_Cover_Data_Import, Added: April 8, Last edited: April 8
c Mikey's code to import gridded percent canopy cover "cc_frac"
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

      SUBROUTINE Canopy_Cover_Data_Import(nx,ny,nx_max,ny_max,
     &  cc_frac)

      implicit none

      integer i, j, k, nx, ny, iheader, nx_max, ny_max
      real cc_frac(nx_max,ny_max)
      character*80 cc_frac_fname
      logical isfound

      iheader = 6

c Setting the filepath
      cc_frac_fname =
     &'topo_vege/Hogg_Pass_SNOTEL_100M_cc.dat'

c Checking to see if the file exists
      inquire(file=cc_frac_fname, exist=isfound)

      if (.NOT.isfound) then
        print*, 'File Not Found: check filepath --> ',cc_frac_fname
        stop
      end if

c Opening the cc_frac file

      open(unit=70,file=cc_frac_fname)
      iheader = 6
      do k=1,iheader
        read (70,*)
      enddo

c Read the data in as real numbers, and do the yrev.
      do j=ny,1,-1
        read (70,*) (cc_frac(i,j),i=1,nx)
      enddo

c Closing the cc_frac file
c      close(70)

      print*, 'Canopy cover successfully imported (MJ)'
      print*
      return
      end

ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


c Albedo decay function (Open, Forest, Burned Forest), Gleason & Nolin 2016
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

      SUBROUTINE SNOW_ALBEDO_OPEN(sprec,Qm,albedo,dt)

      implicit none

      real sprec
      real Qm
      real albedo
      real albedo_open_max
      real albedo_open_min
      real k_melt
      real k_no_melt
      real dt

      albedo_open_max = 0.8
      albedo_open_min = 0.5
      k_melt = 0.01/86400      ! daily rate/second in a day
      k_no_melt = 0.01/86400   ! daily rate/second in a day

      if (sprec.gt.0.0015/86400*dt) then  ! 0.0015 m/day / second in a day
       albedo = albedo_open_max

      else
        if(Qm.gt.0)then
          albedo = albedo_open_min +
     &    (albedo - albedo_open_min) * exp(-k_melt * dt)
        else
          albedo = albedo_open_min +
     &    (albedo - albedo_open_min) * exp(-k_no_melt * dt)
        endif
      endif

      return
      end

ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

      SUBROUTINE SNOW_ALBEDO_FOREST(sprec,Qm,albedo,dt)

      implicit none

      real sprec
      real Qm
      real albedo
      real albedo_forest_max
      real albedo_forest_min
      real k_melt
      real k_no_melt
      real dt

      albedo_forest_max = 0.7
      albedo_forest_min = 0.4
      k_melt = 0.018/86400         ! daily rate/second in a day
      k_no_melt = 0.01/86400       ! daily rate/second in a day

      if (sprec.gt.0.0015/86400*dt) then  ! 0.0015 m/day / second in a day
       albedo = albedo_forest_max

      else
        if(Qm.gt.0)then
          albedo = albedo_forest_min +
     &    (albedo - albedo_forest_min) * exp(-k_melt * dt)
        else
          albedo = albedo_forest_min +
     &    (albedo - albedo_forest_min) * exp(-k_no_melt * dt)
        endif
      endif

      return
      end

ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

      SUBROUTINE SNOW_ALBEDO_BURNED_FOREST(sprec,Qm,albedo,dt)

      implicit none

      real sprec
      real Qm
      real albedo
      real albedo_bforest_max
      real albedo_bforest_min
      real k_melt
      real k_no_melt
      real dt

      albedo_bforest_max = 0.58
      albedo_bforest_min = 0.3
      k_melt = 0.018/86400           ! daily rate/second in a day
      k_no_melt = 0.01/86400         ! daily rate/second in a day

      if (sprec.gt.0.0015/86400*dt) then  ! 0.0015 m/day / second in a day
       albedo = albedo_bforest_max

      else
        if(Qm.gt.0)then
          albedo = albedo_bforest_min +
     &    (albedo - albedo_bforest_min) * exp(-k_melt * dt)
        else
          albedo = albedo_bforest_min +
     &    (albedo - albedo_bforest_min) * exp(-k_no_melt * dt)
        endif
      endif

      return
      end

ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
