      subroutine remove (file)
      character*(*) file
      do i=1,len(file)
         if (file(i:i) .ne. ' ') j = i
      end do
      if (j .gt. 0) write (3,6) 'if (-f ', file(1:j), 
     .     ' ) rm ', file(1:j)
    6 format (4a)
      return
      end!
c
c
c
      subroutine confrm (ndi, logfile, jobfile)
      character*(*) logfile, jobfile
      if (ndi .gt. 0) then
         write (3,1) logfile(1:length(logfile)), 
     .               jobfile(1:length(jobfile)), 
     .               logfile(1:length(logfile))
    1    format ('DONE'/'set temp=`tail -2 ', a, ' | head -1`'/
     .       'if ("$temp" != "Good bye.") then'/
     .       'cat << DONE >>! ~/running'//
     .       '`hostname` *BOMBED* ', a/
     .       'DONE'/
     .       'date >>! ~/running'/
     .       'exit'/'endif'/
     .       'cat << DONE >>! ', a/
     .       'Continuing...'//'DONE')
      else
         write (3,2)
    2    format ('DONE')
      end if
      return
      end!
c
c
c
      subroutine renam (file1, file2)
      character*(*) file1, file2
      write (3,1) file1
    1 format ('if (! -f ', a, ') then'/
     .        'cat << DONE >>! ~/running'//
     .        '`hostname` *BOMBED* a batch job.'/
     .        'DONE'/
     .        'date >>! ~/running'/
     .        'exit'/
     .        'endif')
      j = len(file1)
      do i=1,j
         if (file1(i:i) .ne. ' ') n1=i
         if (file2(i:i) .ne. ' ') n2=i
      end do
      call remove (file2(1:n2))
      write (3,3) 'mv ', file1(1:n1), ' ', file2(1:n2)
    3 format (4a)
      return
      end
c
c
c
      subroutine startup (direc, ndi, pict, jobfile, logfile)
      character*80 switch
      character*(*) direc, pict, jobfile, logfile
      write (3,3) '#!/bin/csh'
    3 format (2a)
      if (ndi .gt. 0) then
         write (3,3) 'cd ', direc(1:ndi)
      end if
      logfile = switch(pict, '.log')
      call remove (logfile)
      return
      end!
c
c
c
      subroutine restart (direc, ndi, pict, jobfile, logfile)
      character*80 switch
      character*(*) direc, pict, jobfile, logfile
      write (3,3) '#!/bin/csh'
    3 format (2a)
      if (ndi .gt. 0) then
         write (3,3) 'cd ', direc(1:ndi)
      end if
      logfile = switch(pict, '.log')
      return
      end!
c
c
c
      subroutine run (progrm, logfile)
      character*(*) progrm, logfile
      write (3,3) progrm, ' << DONE >>! ', logfile(1:length(logfile))
    3 format (3a)
      return
      end!
c
c
c
      subroutine shutdwn (dir, ndi, logfile, jobfile)
      character*132 expand, name
      character*(*) logfile, jobfile, dir
      write (3,3) 'cat << DONE >>! ', logfile
    3 format (3a)
      write (3,3) 'Successful completion.'
      write (3,3) 'DONE'
      name = '$HOME/hook.dat'
      name = expand(name)
      open (1, file=name, status='unknown')
  100 read (1,*,end=200)
      go to 100
  200 continue
C     call infile (1, '$HOME/hook.dat', istat)
C     if (istat .eq. 0) then
C1000    read (1,1,end=2000) line
C   1    format (a)
C        go to 1000
C     end if
 2000 write (name,3) dir(1:ndi), '/', jobfile
      name = expand(name)
      do k=132,1,-1
         if (name(k:k) .ne. ' ') go to 2001
      end do
 2001 write (1,2) name(1:k)
    2 format (a)
      call clfile (1)
      return
      end!
