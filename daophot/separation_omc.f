      parameter (max=2 000 000)
      character*1000 line(max)
      character*30 file, switch, text, extend
      character*7 rndoff, strng
      real x(max), y(max), f(max), cont(max)
      integer id(max), index(max), index2(max), nline(max)
      real limit
c
      data beta /2./
      call getdat ('Effective FWHM:', hwhm, 1)
      call getdat ('Limit:', limit, 1)
      if (limit .lt. -1.e15) call tblank
      hwhm = hwhm/2.
      smax = 20.*hwhm
      smaxsq = smax**2
      a = hwhm**2/(2.**(1./beta)-1.)
      file = ' '
  900 null = 0
  910 call getnam ('Input file:', file)
      if (file .eq. 'EXIT') call byebye
      file = extend(file, 'nmg')
      call infile (1, file, istat)
      if (istat .ne. 0) then
         call stupid ('Unable to open '//file(1:length(file)))
         file = 'EXIT'
         go to 910
      end if
      file = switch(file, '.sep')
      call outfil (2, file, istat)
  990 n = 0
 1000 n = n+1
 1001 call rdchar (1, line(n), nline(n), istat)
      if (istat .lt. 0) go to 1001
      if (istat .gt. 0) go to 2000
      if (line(n)(1:4) .eq. ' NL ') then
         write (2,2) line(n)(1:nline(n))
         call rdchar (1, line(n), nline(n), istat)
         write (2,2) line(1)(1:nline(n))
         read (1,*)
         strng = rndoff(2.*hwhm, 6, 3)
         write (2,2) ' FWHM =', strng(1:6)
    2    format (a, 1x, a)
         go to 1001
      else if (line(n)(4:7) .eq. 'FILT') then
         write (2,2) line(n)(1:nline(n))
         go to 1001
      else
*         read (line(n),*) id(n), x(n), y(n), ff
         read (line(n),*) id(n), a1, a2, a3, a4, a5, a6, a7, a8, a9, 
*     #                    a1, a2, a3, a4, a5, a6, a7, a8, ff, a10,    !B wfi  
*     #                    a1, a2, ff, a4, a5, a6, a7, a8, a9, a10,    !B acs  
     #                    a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, 
     #                    ff, a2, a3, a4, a5, a6, a7, a8, a9, a10,     !V wfi  
     #                    a1, a2, a3, a4, a5, a6, a7, a8, a9, xx, yy  
         x(n) = xx * 60. 
         y(n) = yy * 60. 
      end if
      if (ff .gt. 50.) then
         if (null .eq. 0) then
            call getyn ('Keep invalid stars?', text)
            if (text(1:1) .eq. 'Y') then
               null = null+1
               write (2,2) line(n)(1:nline(n)), ' 99999'
            else 
               null = -1
            end if
         else if (null .gt. 0) then
            null = null+1
            write (2,2) line(n)(1:nline(n)), ' 99999'
         end if
         go to 1001
      end if
      f(n) = 10.**(0.4*(20.-ff))
      if (n .lt. max) go to 1000
      call stupid ('Too many stars!')
      call oops
 2000 n = n-1
      write (text, 5) n, ' read.'
    5 format (i9, a)
      call ovrwrt (text, 1)
c
c Sort by x.
c
      call quick (x, n, index)
      call clfile (1)
c
c Convert magnitudes to fluxes.
c
*      do j=1,n
*      end do
c
c Find the degree by which each star is contaminated by other stars
c within 20*HWHM.
c
      do jj = 1,n
         if (mod(jj,1000) .eq. 0) then
            write (text, 5) jj
            call ovrwrt (text, 2)
         end if
         j = index(jj)
         sum = 0.
         if (jj .ne. 1) then
            do 3300 kk=jj-1,1,-1
               dx = x(jj)-x(kk)
               if (dx .gt. smax) go to 3400
               k = index(kk)
               dy = dx**2 + (y(j)-y(k))**2
               if (dy .gt. smaxsq) go to 3300
               sum = sum + f(k)/(1.+dy/a)**beta
 3300       end do
         end if
 3400    continue
         if (jj .ne. n) then
            do 3500 kk=jj+1,n
               dx = x(kk)-x(jj)
               if (dx .gt. smax) go to 3600
               k = index(kk)
               dy = dx**2 + (y(j)-y(k))**2
               if (dy .gt. smaxsq) go to 3500
               sum = sum + f(k)/(1.+dy/a)**beta
 3500       end do
         end if
 3600    sum = sum/f(j)
         if (sum .gt. 1.E-15) then
            cont(jj) = -2.5*alog10(sum)
         else
            cont(jj) = 99.999
         end if
      end do
c
      call quick (cont, n, index2)
      do jjj=n,1,-1
         if (cont(jjj) .lt. limit) go to 3900
         if (mod(jjj,1000) .eq. 0) then
            write (text, 5) jjj
            call ovrwrt (text, 2)
         end if
         jj = index2(jjj)
         j = index(jj) 
         strng = rndoff(cont(jjj), 7, 3)
         write (2,2) line(j)(1:nline(j)),strng
      end do
      jjj = 0
 3900 write (text,5) n-jjj, ' kept.'
      call ovrwrt (text, 3)
      if (null .gt. 0) write (6,5) null, ' invalid.'
      call clfile (3)
      file = 'EXIT'
      call tblank
      go to 900
      end!
