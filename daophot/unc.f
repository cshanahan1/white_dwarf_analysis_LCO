      character*132 line, expand
      character*30 file, temp, switch, extend, direct, tmp, logfile,
     .     jobfile
      character*12 dir
      integer length
      logical pds, loop
      call getarg (1, direct)
      if (direct .eq. ' ') then
         call getchr ('Directory:', direct, ndi)
      else
         ndi = length(direct)
      end if
c
      call getarg (2, file)
      if (file .eq. ' ') then
         loop = .true.
      else 
         loop = .false.
      end if
 1000 if (loop) call getnam ('Input file name:', file)
      if ((file.eq.'END-OF-FILE').or.(file.eq.'EXIT'))
     .     call byebye
      do i=30,1,-1
         if (file(i:i) .eq. '+') then
            pds = .true.
            file = file(1:i-1)//' '
            go to 1100
         else if (file(i:i) .ne. ' ') then
            pds = .false.
            go to 1100
         end if
      end do
 1100 file = extend(file, 'mch')
      call infile (1, file, istat)
      if (istat .ne. 0) then
         call stupid ('Unable to open ' // file)
         file = 'EXIT'
         go to 1000
      end if
      jobfile = switch(file, '.mon')
      call outfil (3, jobfile, istat)
      write (3,2) '#!/bin/csh'
      write (3,2) 'cd ', direct(1:length(direct))
      call remove ( expand(switch(file,'.imh')) )
      call remove ( expand(switch(file,'.pix')) )
      call remove ( expand(switch(file,'.fits')) )
      call remove ( expand(switch(file,'j.imh')) )
      call remove ( expand(switch(file,'j.pix')) )
      call remove ( expand(switch(file,'j.fits')) )
      logfile = switch(file,'.log')
      write (3,1) 'montage2 << DONE >>! ', logfile(1:length(logfile))
    1 format (2a)
      file = switch(file, ' ')
      lfile = length(file)
      write (3,1) file(1:lfile)
      write (3,1) 'j'
      write (3,1) '1 0.5'
      write (3,1) '-1.05E19 -1.05E19'
      write (3,1) '-1.05E19 -1.05E19'
      write (3,1) '1'
      write (3,1) 'y'
      write (3,1) file(1:lfile)//'j'
      call confrm (ndi, logfile, jobfile)
      temp = extend(file, 'unc')
      call outfil (2, temp, istat)
c     write (2,2) 'cd ', direct(1:length(direct))
      temp = switch(temp, '.com')
      call outfil (11, temp, istat)
      temp = switch(temp, '.put')
      call outfil (10, temp, istat)
      temp = switch(temp, '.del')
      tmp = switch(temp, '.tmp')
      lt = length(tmp)
      call outfil (13, temp, istat)
      temp = switch(temp, '.rom')
      call outfil (14, temp, istat)
      temp = switch(temp, '.grb')
      call outfil (12, temp, istat)
      n = 0
 2000 read (1,*,end=3000) temp
      j = 1
      l = length(temp)
      if (temp(l-3:l) .eq. '.stc') go to 2000
      if ((.not. pds) .and. (temp(l-3:l) .eq. '.pds')) go to 2000
      if (temp(l-3:l) .eq. '.mag') go to 2000
      if (temp(l-3:l) .eq. '.nmg') go to 2000
      do i=1,l
         if (temp(i:i) .eq. ':') then
            j = i
            go to 2001
         end if
      end do
      if (j .eq. 1) then
         call stupid ('No path to ' // temp(1:l))
         go to 2000
      end if
 2001 continue
      dir = temp(1:j-1)
      line = expand(switch(temp,'.*.Z'))
      write (2,2) 'uncompress -f ', line(1:length(line))
    2 format (4a)
      line = expand(switch(temp,'.*'))
      write (11,2) 'compress ', line(1:length(line))
      line = expand(switch(temp,'.*'))
      n = n+1
      if (n .eq. 1) then
         write (10,2) 'ls ' // line(1:length(line)) // ' >! put'
      else
         write (10,2) 'ls ' // line(1:length(line)) // ' >> put'
      end if
      line = expand(switch(temp,'j.imh'))
      l = length(line)
      write (3,2) 'if ( -e ', line(1:l), ' ) \\rm ', line(1:l)
      line = expand(switch(temp,'j.pix'))
      write (3,2) 'if ( -e ', line(1:l), ' ) \\rm ', line(1:l)
      line = expand(switch(temp,'j.fits'))
      l = length(line)
      write (3,2) 'if ( -e ', line(1:l), ' ) \\rm ', line(1:l)
      line = expand(switch(temp,'*.imh*'))
      temp = switch(temp, ' ')
      k = 1
      do i=1,30
         if (temp(i:i) .eq. ':') k = i+1
         if (temp(i:i) .ne. ' ') j = i
      end do
      write (13,2) 'grep ''$'''//temp(1:k-2)//'/'//
     .      temp(k:j)//'''\\.'' $tar/cdrom.del >! '//tmp(1:lt)//
     .     ' ; source '//tmp(1:lt)
      write (14,2) 'grep \\$'//temp(1:k-2)//'/'//temp(k:j)//
     .     '"\\." $tar/cdrom.lis >! '//tmp(1:lt)//' ; source ',
     .     tmp(1:lt)
      write (12,2) './'//dir(1:length(dir))//'/'//temp(k:j)//'.imh'
      write (12,2) './'//dir(1:length(dir))//'/'//temp(k:j)//'.imh.Z'
      write (12,2) './'//dir(1:length(dir))//'/'//temp(k:j)//'.pix'
      write (12,2) './'//dir(1:length(dir))//'/'//temp(k:j)//'.pix.Z'
      write (12,2) './'//dir(1:length(dir))//'/'//temp(k:j)//'.fits'
      write (12,2) './'//dir(1:length(dir))//'/'//temp(k:j)//'.fits.Z'
      go to 2000
 3000 call clfile (1)
      call clfile (2)
      call clfile (10)
      call clfile (11)
      write (3,1) 'montage2 << DONE >>! ', logfile(1:length(logfile))
      write (3,1) file(1:lfile)
      write (3,1) ' '
      write (3,1) '1 0.5'
      write (3,1) '-1.05E19 -1.05E19'
      write (3,1) '-1.05E19 -1.05E19'
      write (3,1) '1'
      write (3,1) 'y'
      write (3,1) file(1:lfile)
      write (3,1) 'DONE'
      call clfile (3)
      call clfile (12)
      write (13,1) 'if ( -e '//tmp(1:lt)//' ) rm '//tmp(1:lt)
      write (14,1) 'if ( -e '//tmp(1:lt)//' ) rm '//tmp(1:lt)
      call clfile (13)
      call clfile (14)
      file = 'EXIT'
      if (loop) go to 1000
      call byebye
      end!
