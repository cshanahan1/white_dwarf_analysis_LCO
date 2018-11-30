      character file*30, line*30, switch*30, extend*30, case*4
      character commas*20
      logical repeat
      repeat = .false.
      call tblank
      file = ' '
      ntot = 0
      call getarg (1, file)
      if (file .ne. ' ') go to 1100
      repeat = .true.
 1000 call getnam('.mch file:', file)
      if (file .eq. 'END-OF-FILE') call byebye
      if (file .eq. 'EXIT') call byebye
 1100 file = extend(file,case('mch'))
      call infile (1, file, istat)
      if (istat .ne. 0) go to 1000
      file = switch (file, '.lns')
      call outfil (3, file, istat)
      k = 0
 2000 read (1,*,end=9000) line
      nl = length(line)
      if (line(nl-3:nl) .eq. '.stc') go to 2000
      call infile (2, line, istat)
      call check (2, nl)
      n = 0
 2100 read(2, *, err=2100, end=3000) i
      if (i .le. 0) go to 2100
      n = n+1
      go to 2100
c
 3000 call clfile (2)
      k = k+1
      write (3,3) n, line(1:length(line))
    3 format (i9, 2x, a)
      ntot = ntot+n
      go to 2000
c
 9000 call clfile (1)
      write (6,3)
      line = commas(ntot, n)
      file = commas(k, l)
      write (6,4) line(1:n), file(1:l)
    4 format (/2x, a, ' lines in ', a, ' files')
      write (3,4) line(1:n), file(1:l)
      call clfile (3)
      if (repeat) then
         file = 'EXIT'
         go to 1000
      end if
c
      call byebye
      end
