!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
!                                                             
!   snow_transport.F90 - part of the Community Ice Sheet Model (CISM)  
!                                                              
!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
!
!   Copyright (C) 2005-2014
!   CISM contributors - see AUTHORS file for list of contributors
!
!   This file is part of CISM.
!
!   CISM is free software: you can redistribute it and/or modify it
!   under the terms of the Lesser GNU General Public License as published
!   by the Free Software Foundation, either version 3 of the License, or
!   (at your option) any later version.
!
!   CISM is distributed in the hope that it will be useful,
!   but WITHOUT ANY WARRANTY; without even the implied warranty of
!   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!   Lesser GNU General Public License for more details.
!
!   You should have received a copy of the Lesser GNU General Public License
!   along with CISM. If not, see <http://www.gnu.org/licenses/>.
!
!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
!
! This module contains drivers for incremental remapping and upwind ice transport.
!
! Author: William Lipscomb
!         Los Alamos National Laboratory
!         Group T-3, MS B216
!         Los Alamos, NM 87545
!         USA
!         <lipscomb@lanl.gov>
!
!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
!
! This version was created from ice_transport_driver in CICE, revision 313, 6 Jan. 2011.
! The repository is here: http://oceans11.lanl.gov/svn/CICE

  module snow_transport

!   use snow_remap, only: dp,nhalo,glissade_horizontal_remap, &
!     make_remap_mask, puny
    use snow_remap, only: dp,glissade_horizontal_remap, &
      make_remap_mask

    implicit none
!   save
!   private
!   public :: glissade_transport_driver, ntracer

!=======================================================================

  contains

!=======================================================================
!
    subroutine glissade_transport_driver(dt,                   &
                                         dx,       dy,         &
                                         nx,       ny,         &
                                         ntracer,              &
                                         uvel,     vvel,       &
                                         thck, conc)


      ! This subroutine solves the transport equations for one timestep
      ! using the conservative remapping scheme developed by John Dukowicz
      ! and John Baumgardner and modified for sea ice by William
      ! Lipscomb and Elizabeth Hunke.
      !
      ! This scheme preserves monotonicity of ice area and tracers.  That is,
      ! it does not produce new extrema.  It is second-order accurate in space,
      ! except where gradients are limited to preserve monotonicity. 
      !
      ! Optionally, the remapping scheme can be replaced with a simple
      ! first-order upwind scheme.
      !
      ! author William H. Lipscomb, LANL
      !
      ! input/output arguments

      real(dp), intent(in) ::     &
         dt,                   &! time step (s)
         dx, dy                 ! gridcell dimensions (m)
                                ! (cells assumed to be rectangular)

      integer, intent(in) ::   &
         nx, ny,               &! horizontal array size
         ntracer                ! number of tracers

      real(dp), intent(in), dimension(nx-1,ny-1) :: &
         uvel, vvel             ! horizontal velocity components (m/s)
                                ! (defined at horiz cell corners, vertical interfaces)

      real(dp), intent(inout), dimension(nx,ny) :: &
         thck                   ! ice thickness (m), defined at horiz cell centers

      real(dp), intent(in), dimension(nx,ny) :: &
         conc                   ! ice concentration, defined at horiz cell centers

      ! local variables

      integer ::     &
         i, j, k         ,&! cell indices
         ilo,ihi,jlo,jhi ,&! beginning and end of physical domain
         nt              ,&! tracer index
         nhalo

      real(dp), dimension (nx,ny) ::     &
         thck_mask         ! = 1. if ice is present, = 0. otherwise

      real(dp), dimension (nx,ny,ntracer) ::     &
         tracer            ! tracer values

      integer ::     &
         icells            ! number of cells with ice

      integer, dimension(nx*ny) ::     &
         indxi, indxj      ! compressed i/j indices

      real(dp), dimension(nx,ny) ::   &
         edgearea_e     ,&! area of departure regions for east edges
         edgearea_n       ! area of departure regions for north edges

! I don't see how to get this in here yet.
      nhalo = 2

!     print *, nhalo,dt,nx,ny,dx,dy,ntracer

      !-------------------------------------------------------------------
      ! Initialize
      !-------------------------------------------------------------------

      !Note: (ilo,ihi) and (jlo,jhi) are the lower and upper bounds of the local domain
      ! (i.e., grid cells owned by this processor).

      ilo = nhalo + 1
      ihi = nx - nhalo
      jlo = nhalo + 1
      jhi = ny - nhalo

      !-------------------------------------------------------------------
      ! NOTE: Mass and tracer arrays (thck, temp, etc.) must be updated in 
      !       halo cells before this subroutine is called. 
      !-------------------------------------------------------------------

      !-------------------------------------------------------------------
      ! Fill thickness and tracer arrays.
      ! Assume that temperature (if present) is tracer 1, and age (if present)
      !  is tracer 2.  Add more tracers as needed.
      ! If no tracers are present, then only the ice thickness is transported.
      !  In this case we define a dummy tracer array, since glissade_horizontal_remap
      !  requires that a tracer array be passed in.
      !-------------------------------------------------------------------

      !-------------------------------------------------------------------
      ! Define a mask: = 1 where ice is present (thck > 0), = 0 otherwise         
      ! The mask is used to prevent tracer values in cells without ice from
      !  being used to compute tracer gradients.
      !-------------------------------------------------------------------

! Here I am sending in the conc array, and it is returning the conc mask.
      call make_remap_mask (nx,           ny,                 &
                            ilo, ihi,     jlo, jhi,           &
                            nhalo,        icells,             &
                            indxi(:),     indxj(:),           &
                            conc(:,:),    thck_mask(:,:))

      !-------------------------------------------------------------------
      ! Remap ice thickness and tracers
      !-------------------------------------------------------------------

      edgearea_e(:,:) = 0.d0
      edgearea_n(:,:) = 0.d0

      tracer(:,:,1) = 0.d0    ! dummy array

      !-------------------------------------------------------------------
      ! Main remapping routine: Step ice thickness and tracers forward in time.
      !-------------------------------------------------------------------

      call glissade_horizontal_remap (dt,                                    &
                                      dx,                dy,                 &
                                      nx,                ny,                 &
                                      ntracer,           nhalo,              &
                                      thck_mask(:,:),    icells,             &
                                      indxi(:),          indxj(:),           &
                                      uvel(:,:),         vvel(:,:),          &
                                      thck(:,:),         tracer(:,:,ntracer),&
                                      edgearea_e(:,:),   edgearea_n(:,:))

    end subroutine glissade_transport_driver

!=======================================================================

  end module snow_transport

!=======================================================================
