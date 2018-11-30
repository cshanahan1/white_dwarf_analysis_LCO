      character file*40, line*132, extend*40, rndoff*9, case*4
      character text(6)*9
      real chi(1 000 000), mag(1 000 000), datum(1 000 000), col(15)
      real median
      call tblank
      call getarg (1, file)
      call getarg (2, line)
      if (file .eq. ' ') 
     .     call getnam ('Input file list:', file)
      file = extend(file, 'mch')
      call infile (0, file, istat)
      if (istat .ne. 0) then
         call stupid ('Unable to open input file.')
         call oops
      end if
      file = 'chi.out'
      call delfil (2, file, istat)
      call outfil (2, file, istat)
 1000 file = ' '
      if (line .eq. ' ') then
         call getdat ('Column:', x, 1)
      else
         read (line,*) x
      end if
      mcol = nint(x)
      ncol = max0(mcol, 4)
      m = 0
 1010 m = m+1
      call rdchar (0, line, n, istat)
      if (istat .gt. 0) then
         call clfile (0)
         call clfile (2)
         call byebye
      end if
 1020 if (line(1:1) .eq. ' ') then
         line = line(2:n)//' '
         go to 1020
      end if
      if (line(1:1) .eq. '''') then
         line = line(2:n)//' '
      end if
      do i=1,30
         if (line(i:i) .eq. '''') line(i:i) = ' '
         if (line(i:i) .eq. ' ') go to 1030
      end do
 1030 read (line(1:i),1) file
    1 format (a)
      file = extend(file,case('als'))
      call infile (1, file, istat)
      if (istat .ne. 0) goto 1010
      call tblank
      write (6,*) file
      call tblank
      call rdchar (1, line, n, istat)
      if (line(1:4) .eq. ' NL ') then
         read(1,*) nl
         read(1,*) 
      else
         rewind(1) 
         nl = 1
      end if
      rmin = 1.e38
      rmax = -1.e38
      n = 0
 2000 n = n + 1
 2001 call rdchar (1,line,k,istat)
      if (istat .gt. 0) go to 3000
      if (istat .lt. 0) go to 2001
      read (line,*,err=2001,end=2001) (col(i), i=1,ncol)
      if (nl .eq. 2) read(unit=1, fmt=*) 
      mag(n) = col(4)
      chi(n) = col(4)
      datum(n) = col(mcol)
      if (datum(n) .lt. rmin) rmin = datum(n)
      if (datum(n) .gt. rmax) rmax = datum(n)
      goto 2000
 3000 call clfile (1)
      n = n - 1
      if (n .le. 0) go to 1010
      median = pctile(chi, n, (n+1)/2) + pctile(chi, n, (n/2)+1)
      median = 0.5 * median
      m = 0
      do i=1,n
         if (mag(i) .gt. median) then
            m = m+1
            chi(m) = datum(i)
         end if
      end do
      faint = pctile(chi, m, (m+1)/2) + pctile(chi, m, (m/2)+1)
      faint = 0.5*faint
      m = 0
      sum = 0.
      do i=1,n
         if (mag(i) .lt. median) then
            m = m+1
            chi(m) = datum(i)
         end if
      end do
      bright = pctile(chi, m, (m+1)/2) + pctile(chi, m, (m/2)+1)
      bright = 0.5*bright
      all = pctile(datum, n, (n+1)/2) + pctile(datum, n, (n/2)+1)
      all = 0.5*all
      sigma = pctile(datum, n, nint(0.6915*n)) - 
     .     pctile(datum, n, nint(0.3085*n))
      text(1) = rndoff(faint, 9, 3)
      text(2) = rndoff(bright, 9, 3)
      text(3) = rndoff(all, 9, 3)
      text(4) = rndoff(sigma, 9, 3)
      text(5) = rndoff(rmin, 9, 3)
      text(6) = rndoff(rmax, 9, 3)
      write(6,6) text, n
    6 format(/'   Faint median = ', a9,
     .       /'  Bright median = ', a9, 
     .       /' Overall median = ', a9,
     .       /'          Sigma = ', a9,
     .       /'  Minimum value = ', a9,
     .       /'  Maximum value = ', a9,
     .       /'Number of stars =',i10/)
      write (2,2) text, n, file
    2 format (6a9, i9, 2x, a)
      goto 1010
      end
