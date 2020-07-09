ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

      subroutine remapper_main(iter,nx,ny,conc,thck,dt,deltax,deltay)

c Note: This must be compiled with pgf90 or gfortran.
      use snow_transport

      implicit none

c     include snowmodel.inc

c dp is coming from snow_transport.F90, which gets it from
c   snow_remap.F90.
c     parameter (dp=kind(1.0d0))

      integer i,j,irec_day,iter,nx,ny
      real secs_in_sim

c The number of remapping loops required to satisfy stability,
c   and the associated time step (in seconds).
      real dt_use
      integer n_remap_loop,n_remap_loops

c Ice velocity conversion factor to go from km/day to m/s.
      real xkmPday_to_mPs

c Grid increment.
      real deltax,deltay
      real(dp) dx_dbl,dy_dbl

c Velocity field (m/s) at cell centers.
      real u(nx,ny),v(nx,ny)

c Velocity field (m/s) at cell corners.
      real uvel(nx-1,ny-1),vvel(nx-1,ny-1)
      real(dp) uvel_dbl(nx-1,ny-1),vvel_dbl(nx-1,ny-1)

c Snow or swe or ice thickness (m).
      real thck(nx,ny)
      real(dp) thck_dbl(nx,ny)

c Sea ice concentration (0-1).
      real conc(nx,ny)
      real(dp) conc_dbl(nx,ny)

c Time step in secs.
      real dt
      real(dp) dt_dbl

c Advective CFL number.
      real adv_cfl

c Number of tracers to transport (just temperature if ntracer = 1).
c   Can be set to a different value in glissade.F90.
      integer ntracer

c Convertion factor for u, and v, from km/day to m/s.
      xkmPday_to_mPs = 1000.0 / 86400.0

c Number of tracers to transport (I do not think this can be 0);
c   but this is based on something I read, not something I tried.
      ntracer = 1

c Find the day (the simulation day) that corresponds to this iter.
c   This is the record of the daily concentration and u, v fields.
      secs_in_sim = dt * real(iter - 1)
      irec_day = int(secs_in_sim / 86400.0) + 1
c     print *,'irec_day =',irec_day

c Open the u, v input data file the first time it is needed.
      if (iter.eq.1) then
        open (446,file='seaice/ice_motion.gdat',
     &    form='unformatted',access='direct',recl=4*nx*ny*2)
      endif

c Read in the velocity arrays for this day.
      read (446,rec=irec_day)
     &  ((u(i,j),i=1,nx),j=1,ny),((v(i,j),i=1,nx),j=1,ny)

c Convert the data from km/day to m/s.
      do j=1,ny
        do i=1,nx
          u(i,j) = xkmPday_to_mPs * u(i,j) 
          v(i,j) = xkmPday_to_mPs * v(i,j) 
        enddo
      enddo

c These ice velocity data are on the grid cell centers.  The
c   remapping model requires them to be on the grid cell corners.
      do j=1,ny-1
        do i=1,nx-1
          uvel(i,j) = (u(i,j) + u(i+1,j) + u(i,j+1) + u(i+1,j+1))/4.0
          vvel(i,j) = (v(i,j) + v(i+1,j) + v(i,j+1) + v(i+1,j+1))/4.0
        enddo
      enddo

c The conc and u, v are consistent (if conc=0.0, then u=v=0.0).
c   Make sure the thck=0.0 if conc=0.0.  If you don't do this you
c   may get a CFL error.
      do j=1,ny
        do i=1,nx
          if (conc(i,j).eq.0.0) thck(i,j) = 0.0
        enddo
      enddo

c Take uvel and vvel (in m/s) inputs, and calculate the number
c   of time loops that must be used and the time increment of
c   those loops, that are required for the incremental remapping
c   routine to satisfy the stability constraints.
      call get_remap_loops (nx,ny,uvel,vvel,dt,deltax,deltay,
     &  dt_use,n_remap_loops,xkmPday_to_mPs)

c Call the transport scheme.  glissade_transport_driver expects dt
c   in seconds, uvel/vvel in m/s, and some of the variables are
c   double precision.
      dt_dbl = dt_use
      dx_dbl = deltax
      dy_dbl = deltay
      do j=1,ny
        do i=1,nx
          thck_dbl(i,j) = thck(i,j)
          conc_dbl(i,j) = conc(i,j)
        enddo
      enddo
      do j=1,ny-1
        do i=1,nx-1
          uvel_dbl(i,j) = uvel(i,j)
          vvel_dbl(i,j) = vvel(i,j)
        enddo
      enddo

c Run the incremental remapper, while satisfying the stability
c   constraints.
      do n_remap_loop=1,n_remap_loops

        print *,'       in remap loop',n_remap_loop

        call glissade_transport_driver(dt_dbl,dx_dbl,dy_dbl,nx,ny,
     &    ntracer,uvel_dbl,vvel_dbl,thck_dbl,conc_dbl)

c The conc and u, v are consistent (if conc=0.0, then u=v=0.0).
c   Make sure the thck=0.0 if conc=0.0.
        do j=1,ny
          do i=1,nx
            conc_dbl(i,j) = conc(i,j)
            if (conc_dbl(i,j).eq.0.0) thck_dbl(i,j) = 0.0
          enddo
        enddo

      enddo

      do j=1,ny
        do i=1,nx
          thck(i,j) = real(thck_dbl(i,j))
        enddo
      enddo

      return
      end

ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

      subroutine get_remap_loops (nx,ny,uvel,vvel,dt,deltax,deltay,
     &  dt_use,n_remap_loops,xkmPday_to_mPs)

c The subroutine takes input of uvel and vvel in m/s, and
c   outputs the number of time loops that must be used, and the
c   time increment of those loops, that remapping program must use
c   in order to satisfy the CFL condition.

c Perform a CFL check by calculating the advective CFL.  The remapping
c   program requires that for divergent fields, max(u or v)*dt/dx < 0.5,
c   to ensure trajectories do not cross.  (Old code below).
c       do j=1,ny-1
c         do i=1,nx-1
c           adv_cfl =
c    &        max(dt*abs(uvel(i,j))/deltax,dt*abs(vvel(i,j))/deltay)
c           if (adv_cfl.ge.0.5) then
c             print *, 'dt is too big for advective CFL:'
c             print *, 'adv_cfl, u, v =',adv_cfl,uvel(i,j),vvel(i,j)
c           endif
c         enddo
c       enddo

c Other Notes: the ice velocities are fast enough that the CFL
c   condition is violated if you use 1-day time steps.  Typical
c   max daily ice velocities are 60 km/day.  So this means the daily
c   time step must be reduced by 1/3, or 8-hour time steps or less
c   will work.  Therefore, a 3-hour time step is okay.  This is
c   for the 25-km EASE grid.  If you use a 12.5-km grid, then you
c   will need a 4-hour time step, so the 3-hour time step should
c   still be okay on the 12.5-km EASE grid.

      implicit none

      integer nx,ny,i,j,n_remap_loops

      real uvel(nx-1,ny-1),vvel(nx-1,ny-1)

      real adv_cfl,deltax,deltay,dt,xkmPday_to_mPs,vel_max,dt_hr,
     &  dt_use,dt_hr_use

c Sweep through the domain to find the largest u or v.
      vel_max = 0.0
      do j=1,ny-1
        do i=1,nx-1
          vel_max = max(vel_max,abs(uvel(i,j)),abs(vvel(i,j)))
        enddo
      enddo

c This is the CFL condition.
      adv_cfl = dt * vel_max / min(deltax,deltay)

c This is the max allowable time increment, in hours.
      dt_hr = 0.5 * min(deltax,deltay)/vel_max/dt*24.0/(86400.0/dt)

c     print *, adv_cfl,dt_hr

c Now find the largest dt that is evenly divisible into 24 hours,
c   i.e., 24, 12, 8, 6, 4, 3, 2, 1.  There must be a smarter way
c   to do this.
      if (dt.eq.86400.0) then
        if (dt_hr.gt.24.0) dt_hr_use = 24.0
        if (dt_hr.le.24.0) dt_hr_use = 12.0
        if (dt_hr.le.12.0) dt_hr_use = 8.0
        if (dt_hr.le.8.0) dt_hr_use = 6.0
        if (dt_hr.le.6.0) dt_hr_use = 4.0
        if (dt_hr.le.4.0) dt_hr_use = 3.0
        if (dt_hr.le.3.0) dt_hr_use = 2.0
        if (dt_hr.le.2.0) dt_hr_use = 1.0
        if (dt_hr.le.1.0) then
          print *,'this code does not allow such fast ice speeds'
          print *,'speed (km/day) =',vel_max/xkmPday_to_mPs
          stop
        endif
c Find the number of sub-dt loops that have to be performed.
        n_remap_loops = nint(24.0/dt_hr_use)
      elseif (dt.eq.10800.0) then
        if (dt_hr.gt.3.0) dt_hr_use = 3.0
        if (dt_hr.le.3.0) dt_hr_use = 1.0
        if (dt_hr.le.1.0) then
          print *,'this code does not allow such fast ice speeds'
          print *,'speed (km/day) =',vel_max/xkmPday_to_mPs
          stop
        endif
c Find the number of sub-dt loops that have to be performed.
        n_remap_loops = nint(3.0/dt_hr_use)
      else
        print *,'this code only allows 24- and 3-hour time steps'
        stop
      endif

c     print *,dt_hr_use

c Convert this from hours to seconds.
      dt_use = dt_hr_use * 3600.0

c     print *,'dt used in remap loops =',dt_use
c     print *,'number of remap loops in the day =',n_remap_loops

      return
      end

ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

