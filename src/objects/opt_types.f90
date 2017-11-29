module options_types

    use icar_constants,             only : kMAX_STRING_LENGTH, MAXLEVELS, MAXFILELENGTH, MAX_NUMBER_FILES, MAXVARLENGTH
    use time_object,                only : Time_type
    use time_delta_object,          only : time_delta_t

    implicit none


    ! ------------------------------------------------
    ! type to store integer options for each physics package
    ! ------------------------------------------------
    type physics_type
        integer::microphysics
        integer::advection
        integer::boundarylayer
        integer::landsurface
        integer::watersurface
        integer::radiation
        integer::convection
        integer::windtype
    end type physics_type


    ! ------------------------------------------------
    ! store Microphysics sensitivity options
    ! ------------------------------------------------
    type mp_options_type
        real    :: Nt_c
        real    :: TNO
        real    :: am_s
        real    :: rho_g
        real    :: av_s, bv_s, fv_s, av_i
        real    :: av_g, bv_g
        real    :: Ef_si, Ef_rs, Ef_rg, Ef_ri
        real    :: C_cubes, C_sqrd
        real    :: mu_r
        real    :: t_adjust
        logical :: Ef_rw_l, EF_sw_l

        integer :: update_interval  ! maximum number of seconds between updates
        integer :: top_mp_level     ! top model level to process in the microphysics
        real    :: local_precip_fraction    ! fraction of grid cell precip to keep local vs distributing to surrounding
    end type mp_options_type

    ! ------------------------------------------------
    ! store Blocked flow options
    ! ------------------------------------------------
    type block_options_type
        real    :: blocking_contribution  ! fractional contribution of flow blocking perturbation that is added [0-1]
        real    :: smooth_froude_distance ! distance (m) over which Froude number is smoothed
        integer :: n_smoothing_passes     ! number of times the smoothing window is applied
        real    :: block_fr_max           ! max froude no at which flow is only partially blocked above, no blocking
        real    :: block_fr_min           ! min froude no at which flow is only partially blocked below, full blocking
        logical :: block_flow             ! switch to use or not use the flow blocking parameterization
    end type block_options_type

    ! ------------------------------------------------
    ! store Linear Theory options
    ! ------------------------------------------------
    type lt_options_type
        integer :: buffer                   ! number of grid cells to buffer around the domain MUST be >=1
        integer :: stability_window_size    ! window to average nsq over
        real    :: max_stability            ! limits on the calculated Brunt Vaisala Frequency
        real    :: min_stability            ! these may need to be a little narrower.
        logical :: variable_N               ! Compute the Brunt Vaisala Frequency (N^2) every time step
        logical :: smooth_nsq               ! Smooth the Calculated N^2 over vert_smooth vertical levels
        integer :: vert_smooth              ! number of model levels to smooth winds over in the vertical

        real    :: N_squared                ! static Brunt Vaisala Frequency (N^2) to use
        real    :: linear_contribution      ! fractional contribution of linear perturbation to wind field (e.g. u_hat multiplied by this)
        logical :: remove_lowres_linear     ! attempt to remove the linear mountain wave from the forcing low res model
        real    :: rm_N_squared             ! static Brunt Vaisala Frequency (N^2) to use in removing linear wind field
        real    :: rm_linear_contribution   ! fractional contribution of linear perturbation to wind field to remove from the low-res field

        real    :: linear_update_fraction   ! fraction of linear perturbation to add each time step
        logical :: spatial_linear_fields    ! use a spatially varying linear wind perturbation
        logical :: linear_mask              ! use a spatial mask for the linear wind field
        logical :: nsq_calibration          ! use a spatial mask to calibrate the nsquared (brunt vaisala frequency) field

        ! Look up table generation parameters
        real    :: dirmax, dirmin           ! minimum and maximum directions to use in the LUT (typically 0 and 2*pi)
        real    :: spdmax, spdmin           ! minimum and maximum wind speeds to use in the LU (typically 0 and ~30)
        real    :: nsqmax, nsqmin           ! minimum and maximum brunt_vaisalla frequencies (typically ~1e-8 and 1e-3)
        integer :: n_dir_values, n_nsq_values, n_spd_values ! number of LUT bins for each parameter
        real    :: minimum_layer_size       ! Minimum vertical step to permit when computing LUT.
                                            ! If model layers are thicker, substepping will be used.

        logical :: read_LUT, write_LUT      ! options to read the LUT from disk (or write it)
        character(len=MAXFILELENGTH) :: u_LUT_Filename  ! u LUT filename to write
        character(len=MAXFILELENGTH) :: v_LUT_Filename  ! v LUT filename to write
        logical :: overwrite_lt_lut         ! if true any existing LUT file will be over written

    end type lt_options_type

    ! ------------------------------------------------
    ! store Advection options
    ! ------------------------------------------------
    type adv_options_type
        logical :: boundary_buffer          ! buffer to smooth a bit to cut down on oscillations at the border if FCT is not used
        logical :: flux_corrected_transport ! use Flux Corrected Transport (FCT) to maintain stability and prevent any wild oscllations
        integer :: mpdata_order             ! accuracy order for MP_DATA advection scheme.
    end type adv_options_type


    ! ------------------------------------------------
    ! store Online Bias Correction options
    ! ------------------------------------------------
    type bias_options_type
        character(len=MAXFILELENGTH):: filename             ! file containing bias correction data
        character(len=MAXVARLENGTH) :: rain_fraction_var    ! name of variable containing the fraction to multiply rain by
    end type bias_options_type

    ! ------------------------------------------------
    ! store Land Surface Model options
    ! ------------------------------------------------
    type lsm_options_type
        character (len=MAXVARLENGTH) :: LU_Categories   ! land use categories to read from VEGPARM.tbl (e.g. "USGS")
        integer :: update_interval                      ! minimum time to let pass before recomputing LSM ~300s (it may be longer)  [s]
        ! the following categories will be set by default if an known LU_Category is used
        integer :: urban_category                       ! LU index value that equals "urban"
        integer :: ice_category
        integer :: water_category
        ! use monthly vegetation fraction data, not just a single value
        logical :: monthly_vegfrac
    end type lsm_options_type


    ! ------------------------------------------------
    ! store all model options
    ! ------------------------------------------------
    type parameter_options_type
        character (len=MAXVARLENGTH) :: version,comment

        ! file names
        character (len=MAXFILELENGTH) :: init_conditions_file, linear_mask_file, nsq_calibration_file
        character (len=MAXFILELENGTH), dimension(MAX_NUMBER_FILES) :: boundary_files,ext_wind_files ! note these can't be allocatable because gfortran does not support allocatable components inside derived type coarrays...
        character (len=MAXFILELENGTH) :: output_file,restart_file,output_file_frequency

        ! variable names from init/BC/wind/... files
        character (len=MAXVARLENGTH) :: landvar,latvar,lonvar,uvar,ulat,ulon,vvar,vlat,vlon, &
                                        hgt_hi,lat_hi,lon_hi,ulat_hi,ulon_hi,vlat_hi,vlon_hi, &
                                        pvar,pbvar,tvar,qvvar,qcvar,qivar,qrvar,qsvar,qgvar,hgtvar, &
                                        shvar,lhvar,pblhvar,zvar,zbvar,&
                                        soiltype_var, soil_t_var,soil_vwc_var,soil_deept_var, &
                                        vegtype_var,vegfrac_var, linear_mask_var, nsq_calibration_var, &
                                        swdown_var, lwdown_var, &
                                        sst_var, rain_var, time_var

        ! Filenames for files to read various physics options from
        character(len=MAXFILELENGTH) :: mp_options_filename, lt_options_filename, adv_options_filename, &
                                        lsm_options_filename, bias_options_filename, block_options_filename
        character(len=MAXFILELENGTH) :: calendar


        ! various boolean options
        logical :: debug                ! outputs a little more information at runtime (not much at present)
        logical :: interactive          ! set to true if running at the commandline to see %complete printed
        logical :: ideal                ! this is an ideal simulation, forcing will be held constant
        logical :: readz                ! read atmospheric grid elevations from file
        logical :: readdz               ! read atm model layer thicknesses from namelist
        logical :: external_winds       ! read a high res 3d wind field from an external file (e.g. a high res WRF run)
        logical :: mean_winds           ! use only a mean wind field across the entire model domain
        logical :: mean_fields          ! use only a mean forcing field across the model boundaries
        logical :: restart              ! this is a restart run, read model conditions from a restart file
        logical :: qv_is_spec_humidity  ! if true the input water vapor is assumed to be specific humidity instead of mixing ratio
        logical :: t_is_potential       ! if true the input temperature is interpreted as potential temperature
        logical :: z_is_geopotential    ! if true the z variable is interpreted as geopotential height
        logical :: z_is_on_interface    ! if true the z variable is interpreted as residing at model level interfaces
        logical :: advect_density       ! properly incorporate density into the advection calculations.
                                        ! Doesn't play nice with linear winds
        logical :: high_res_soil_state  ! read the soil state from the high res input file not the low res file
        logical :: surface_io_only      ! just output surface variables to speed up run and thin output

        integer :: buffer               ! buffer to remove from all sides of the high res grid supplied
        ! various integer parameters/options
        integer :: ntimesteps           ! total number of time steps to be simulated (from the first forcing data)
        integer :: nz                   ! number of model vertical levels
        integer :: ext_winds_nfiles     ! number of extrenal wind filenames to read from namelist
        type(Time_type) :: restart_time ! Date of the restart time step
        ! integer :: restart_step         ! step in forcing data to begin running
        integer :: restart_date(6)      ! date to initialize from (y,m,d, h,m,s)
        integer :: restart_step_in_file ! step in restart file to initialize from

        ! various real parameters/options
        real :: dx                      ! grid cell width [m]
        real :: dxlow                   ! forcing model grid cell width [m]
        real :: in_dt                   ! time step between forcing inputs [s]
        type(time_delta_t) :: input_dt  ! store in_dt as a time delta object
        real :: out_dt                  ! time step between output [s]
        type(time_delta_t) :: output_dt ! store out_dt as a time delta object
        real :: outputinterval          ! time steps per output
        real :: inputinterval           ! time steps per input
        real :: smooth_wind_distance    ! distance over which to smooth the forcing wind field (m)
        logical :: time_varying_z       ! read in a new z coordinate every time step and interpolate accordingly
        real :: cfl_reduction_factor    ! amount to multiple CFL by to improve stability (typically 1)
        integer :: cfl_strictness       ! CFL method 1=3D from 1D*sqrt(3), 2=ave.3D wind*sqrt(3), 3=sum.3D wind, 4=opt3 * sqrt(3), 5 = sum(max.3d)

        ! date/time parameters
        type(Time_type) :: initial_time ! Date of the first forcing time step
        type(Time_type) :: start_time   ! Date to start running the model
        type(Time_type) :: end_time     ! End point for the model simulation

        real :: t_offset                ! offset to temperature because WRF outputs potential temperature-300

        ! note this can't be allocatable because gfortran does not support allocatable components inside derived type coarrays...
        real, dimension(MAXLEVELS)::dz_levels ! model layer thicknesses to be read from namelist
        logical :: use_agl_height       ! interpolate from forcing to model layers using Z above ground level, not sea level

        ! physics parameterization options
        logical :: use_mp_options
        logical :: use_lt_options
        logical :: use_block_options
        logical :: use_adv_options
        logical :: use_lsm_options
        logical :: use_bias_correction

        integer :: warning_level        ! level of warnings to issue when checking options settings 0-10.
                                        ! 0  = Don't print anything
                                        ! 1  = print serious warnings
        ! (DEFAULT if debug=True)       ! 2  = print all warnings
                                        ! 3-4 ... nothing specified equivalent to 2
        ! (DEFAULT if debug=False)      ! 5  = Stop for options that are likely to break the model (print all warnings)
                                        ! 6-8... nothing specified equivalent to 5
                                        ! 9  = stop on serious warnings only
                                        ! 10 = stop on all warnings
    end type parameter_options_type

end module options_types