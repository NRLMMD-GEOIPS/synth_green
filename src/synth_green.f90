module synth_green
    use config
    use m_clip
    ! use errors
    ! use prettyprint
    ! use file_io_utils
    ! use string_operations

    implicit none

    integer, parameter :: bd = 8
    character(512), parameter :: land_fname = trim(ancildat_path) // '/synth_green/land.bin'
    character(512), parameter :: deep_fname = trim(ancildat_path) // '/synth_green/deep.bin'
    character(512), parameter :: shallow_fname = trim(ancildat_path) // '/synth_green/shallow.bin'
    logical :: LOADED = .false.
    integer(bd), parameter :: lut_size = 300
    real, dimension(lut_size, lut_size, lut_size), target :: LAND_LUT, SHALLOW_LUT, DEEP_LUT
    logical, dimension(lut_size, lut_size, lut_size), target :: LAND_LUT_MASK, SHALLOW_LUT_MASK, DEEP_LUT_MASK

    contains

    subroutine load_luts()
        if (.not. LOADED) then
            open(30, file=land_fname, form='unformatted', access='direct',  &
                 recl=size(LAND_LUT)*4, action='read')
            read(30, rec=1) LAND_LUT
            close(30)
            LAND_LUT_MASK = LAND_LUT .ge. 0.0

            open(30, file=deep_fname, form='unformatted', access='direct', &
                 recl=size(DEEP_LUT)*4, action='read')
            read(30, rec=1) DEEP_LUT
            close(30)
            DEEP_LUT_MASK = DEEP_LUT .ge. 0.0

            open(30, file=shallow_fname, form='unformatted', access='direct', &
                 recl=size(SHALLOW_LUT)*4, action='read')
            read(30, rec=1) SHALLOW_LUT
            close(30)
            SHALLOW_LUT_MASK = SHALLOW_LUT .ge. 0.0

            LOADED = .true.
        endif
    end subroutine load_luts

    subroutine get_synth_green(lines, samples, nir, red, blu, lsm, grn, code)
        !----------------------------------------------------
        ! Produces a synthetic green value based on input near infrared,
        ! red, and blue pixel data and AHI-based lookup tables.
        !----------------------------------------------------
        implicit none
        integer, parameter :: bd = 8
        integer(bd), intent(in) :: lines, samples
        real(bd), dimension(lines, samples), intent(in) :: nir, red, blu
        integer(bd), dimension(lines, samples), intent(in) :: lsm

        integer(bd), dimension(lines, samples) :: ired, inir, iblu
        integer(bd) :: ir_l, ir_h, in_l, in_h, ib_l, ib_h, cnt, i, j
        real, dimension(lut_size, lut_size, lut_size) :: lut
        logical, dimension(lut_size, lut_size, lut_size) :: mask
        integer(bd), parameter :: minind = 1
        integer(bd), parameter :: maxind = 300 

        integer(bd) :: grn_cnt
        real(bd) :: grn_sum
        real(bd), dimension(lines*samples) :: flat_grn
        real(bd), dimension(lines, samples), intent(out) :: grn
        integer(bd), intent(out) :: code

        !f2py integer(bd), intent(in) :: lines, samples
        !f2py real(bd), dimension(lines, samples), intent(in) :: nir, red, blu
        !f2py integer(bd), dimension(lines, samples), intent(in) :: lsm
        !f2py real(bd), dimension(lines, samples), intent(out) :: grn
        !f2py integer(bd), intent(out) :: code

        print *, 'Getting indexes'
        inir = nint(nir * 200.0 + 0.5)
        ired = nint(red * 200.0 + 0.5)
        iblu = nint(blu * 200.0 + 0.5)

        print *, 'Clipping indexes to range'
        inir = clip(inir, minind, maxind)
        ired = clip(ired, minind, maxind)
        iblu = clip(iblu, minind, maxind)

        print *, 'Loading LUTs'
        call load_luts()

        print *, 'Starting retrieval'
        grn(:, :) = -999.0
        do j=1, samples
            if (mod(j, 100) == 0) then
                print *, j
            endif
            do i=1, lines
                if (LAND_LUT_MASK(ired(i, j), inir(i, j), iblu(i, j))) then
                    grn(i, j) = LAND_LUT(ired(i, j), inir(i, j), iblu(i, j))
                else
                    cnt = 5
                    do while ((grn(i, j) < 0.0) .and. (cnt <= 0))
                        ir_l = ired(i, j) - cnt
                        ir_h = ired(i, j) + cnt
                        in_l = inir(i, j) - cnt
                        in_h = inir(i, j) + cnt
                        ib_l = iblu(i, j) - cnt
                        ib_h = iblu(i, j) + cnt
                        if (lsm(i, j) == 1) then
                            grn_cnt = count(LAND_LUT_MASK(ir_l:ir_h, in_l:in_h, ib_l:ib_h))
                            if (grn_cnt > 0) then
                                grn_sum = sum(LAND_LUT(ir_l:ir_h, in_l:in_h, ib_l:ib_h), &
                                              mask=LAND_LUT_MASK(ir_l:ir_h, in_l:in_h, ib_l:ib_h))
                            endif
                        else if ((lsm(i, j) == 0) .or. (lsm(i, j) == 2) .or. &
                                 (lsm(i, j) == 3) .or. (lsm(i, j) == 4)) then
                            grn_cnt = count(SHALLOW_LUT_MASK(ir_l:ir_h, in_l:in_h, ib_l:ib_h))
                            if (grn_cnt > 0) then
                                grn_sum = sum(SHALLOW_LUT(ir_l:ir_h, in_l:in_h, ib_l:ib_h), &
                                              mask=SHALLOW_LUT_MASK(ir_l:ir_h, in_l:in_h, ib_l:ib_h))
                                grn(i, j) = grn_sum / grn_cnt
                            endif
                        else
                            grn_cnt = count(DEEP_LUT_MASK(ir_l:ir_h, in_l:in_h, ib_l:ib_h))
                            if (grn_cnt > 0) then
                                grn_sum = sum(DEEP_LUT(ir_l:ir_h, in_l:in_h, ib_l:ib_h), &
                                              mask=DEEP_LUT_MASK(ir_l:ir_h, in_l:in_h, ib_l:ib_h))
                                grn(i, j) = grn_sum / grn_cnt
                            endif
                        endif
                    enddo
                    cnt = cnt + 1
                endif
            enddo
        enddo

        where (grn < 0.0)
            grn = 0.5 * (red + blu)
        endwhere

        ! Print the number of elements that are not set
        print *, count(grn < 0.0), size(grn)
        ! Combine green and nir to fix green offset problem from AHI
        grn = 0.93 * grn + 0.07 * nir

        code = 0
    end subroutine get_synth_green

    ! subroutine get_synth_green(lines, samples, nir, red, blu, lsm, grn, code)
    !     implicit none
    !     integer, parameter :: bd = 8
    !     integer(bd), intent(in) :: lines, samples
    !     real(bd), dimension(lines, samples), intent(in) :: nir, red, blu
    !     integer(bd), dimension(lines, samples), intent(in) :: lsm

    !     real(bd), dimension(lines, samples), intent(out) :: grn
    !     integer(bd), intent(out) :: code

    !     !f2py integer(bd), intent(in) :: lines, samples
    !     !f2py real(bd), dimension(lines, samples), intent(in) :: nir, red, blu
    !     !f2py integer(bd), dimension(lines, samples), intent(in) :: lsm
    !     !f2py real(bd), dimension(lines, samples), intent(out) :: grn
    !     !f2py integer(bd), intent(out) :: code

    !     call load_luts()
    !     grn = pixel_get_synth_green(nir, red, blu, lsm)
    !     code = 0
    ! end subroutine

end module synth_green
