	subroutine plots(nome,xw,yw,iwo)
	character nome*(*),wind*12
        common /finestra/iprimafi
        common /prima/iprivo
        common /finestracorrente/indwin
	lx=xw
	ly=yw
        if (iprivo.ne.888) then
c	write (*,*) 'Libreria grafica XRot  by Ivan Ferraro'
        iprivo=888
c	print *,'dammi win id'
c	read (*,*) iprimafi
        call getenv('WINDOWID',wind)
c        print *,wind,'  WIND'
        read(wind,213) iprimafi
213     format(i12)
        end if

	call primofuoco(iprimafi)
        iwi=-1
        iwo=500
        ix=0
        iy=0
        ism=0
	call plotsc(nome,ix,iy,lx,ly,iprimafi,iwi,iwo,ism,indwin)
c	call fufo(iprimafi)
	return
	end

	subroutine plotspm(nome,xw,yw,iwo)
	character nome*(*),wind*8
        common /finestra/iprimafi
        common /prima/iprivo
        common /finestracorrente/indwin
	lx=xw
	ly=yw
        if (iprivo.ne.888) then
	write (*,*) 'Libreria grafica XRot  by Ivan Ferraro'
        iprivo=888
c	print *,'dammi win id'
c	read (*,*) iprimafi
        call getenv('WINDOWID',wind)
c        print *,wind
        read(wind,213) iprimafi
213     format(i8)
        end if

	call primofuoco(iprimafi)
        iwi=-1
        iwo=500
        ix=0
        iy=0
        ism=1
	call plotsc(nome,ix,iy,lx,ly,iprimafi,iwi,iwo,ism,indwin)
c	call fufo(iprimafi)
	return
	end

        subroutine leggi(stri)
        character*(*) stri
        character eof
        byte b
        equivalence (eof,b)
        common /finestra/iprimafi
        common /finestre/nfi(3),nfiop(3),nwinat
c        call prefuoco(ifi,kfla)
        b=-1
        if(nwinat.ne.0)call fufo(iprimafi)
        read(*,'(a)',end=10) stri
20      continue
c        call fufo(ifi)
        if(nwinat.gt.0.and.nwinat.le.3) call pop(nfi(nwinat),0,0)
        if(nwinat.ne.0)call visua
        return
10      stri(1:1)=eof
        go to 20
        end                                                                

        subroutine finestradentro(ix,iy,lx,ly,iwi,iwo)
        character nome*10
        common /finestra/iprimafi
        common /finestracorrente/indwin
        call primofuoco(iprimafi)
        ism=0
        call plotsc(nome,ix,iy,lx,ly,iprimafi,iwi,iwo,ism,indwin)
c        call fufo(iprimafi)
        return
        end

        subroutine finestradentropm(ix,iy,lx,ly,iwi,iwo)
        character nome*10
        common /finestra/iprimafi
        common /finestracorrente/indwin
        call primofuoco(iprimafi)
        ism=1
        call plotsc(nome,ix,iy,lx,ly,iprimafi,iwi,iwo,ism,indwin)
c        call fufo(iprimafi)
        return
        end

        subroutine finestranascosta(ix,iy,lx,ly,iwi,iwo)
        character nome*10
        common /finestra/iprimafi
        common /finestracorrente/indwin
        call primofuoco(iprimafi)
        ism=2
        call plotsc(nome,ix,iy,lx,ly,iprimafi,iwi,iwo,ism,indwin)
c        call fufo(iprimafi)
        return
        end
        
        subroutine plotsi(nome,lx,ly,iwo)
        character nome*(*)
        common /finestra/iprimafi
        common /finestracorrente/indwin
        write (*,*) 'window opened'
        call primofuoco(iprimafi)
        iwi=-1
        ix=0
        iy=0
        call plotsc(nome,ix,iy,lx,ly,iprimafi,iwi,iwo,0,indwin)
	call fufo(iprimafi)
        return
        end

	subroutine plot(ax,ay,n3)
	iax=ax
	iay=ay
	call ploti(iax,iay,n3)
	return
	end

	subroutine plotnv(ax,ay,n3)
	iax=ax
	iay=ay
	call plotinv(iax,iay,n3)
	return
	end

	subroutine line(n,x,y)
	dimension x(1),y(1)
	call plot(x(1),y(1),3)
	do i=2,n
	call plot(x(i),y(i),2)
	end do
	return
	end

	subroutine linenv(n,x,y)
	dimension x(1),y(1)
        iax=x(1)
        iay=y(1)
	call plotinv(iax,iay,3)
	do i=2,n
        iax=x(i)
        iay=y(i)
	call plotinv(iax,iay,2)
	end do
	return
	end

	subroutine linenvf(n,x,y,fatz)
	dimension x(1),y(1)
        iax=x(1)*fatz
        iay=y(1)*fatz
	call plotinv(iax,iay,3)
	do i=2,n
        iax=x(i)*fatz
        iay=y(i)*fatz
	call plotinv(iax,iay,2)
	end do
	return
	end

	subroutine symbol(x,y,r,string,r1,nn)
	character string*(*)
	ix=x
	iy=y
	ir=r
	call symboli(ix,iy,ir,string,nn)
	return
	end

	subroutine vcursr(c,ix,iy)
	character c*(*)
        ikk=0
        call joystki(c,ix,iy,ikk)
        if(c.eq.'e'.or.c.eq.'u') then
                call controllapuls(ix,np)
                ix=np
        end if
c	write(6,10) 7,7,7
10	format(3a1,$)
	return
	end
        

	subroutine cross(c,ix,iy)
	character c*(*)
        dimension i6x(6),i6y(6)
        data i6x/500,500,500,500,-500,1500/
        data i6y/500,1500,-500,500,500,500/

        ikk=0
        call crosshair(c,ix,iy,ikk,6,i6x,i6y)
        if(c.eq.'e'.or.c.eq.'u') then
                call controllapuls(ix,np)
                ix=np
        end if
c	write(6,10) 7,7,7
10	format(3a1,$)
	return
	end
	subroutine joystk(c,ix,iy)
	character c*(*)
        ikk=1
	write(6,10) 7,7,7
        call joystki(c,ix,iy,ikk)
        if(c.eq.'e'.or.c.eq.'u') then
                call controllapuls(ix,np)
                ix=np
        end if
10	format(3a1,$)
	return
	end

        subroutine pan(ix,iy)
        character c
        call cambiacurs(60,0)
        ix2=ix
        iy2=iy
        call vcursr(c,ix2,iy2)
        izx=ix2-ix
        izy=iy2-iy
        ix=izx
        iy=izy
        call pan2(izx,izy)
        call cambiacurs(68,0)
        return
        end

        subroutine erase(x1,y1,w,h)
        ix=x1
        iy=y1
        iw=w
        ih=h
        call erasei(ix,iy,iw,ih,0)
        return
        end
        
        subroutine erasenv(x1,y1,w,h)
        ix=x1
        iy=y1
        iw=w
        ih=h
        call erasei(ix,iy,iw,ih,1)
        return
        end

        subroutine creapuls(iwi,idpul,ix,iy,llx,ly,stringa,nst,kf,ncol)
        character stringa*(*)
c------------------------------------------------------------------------
        integer nfi(500)
        real px(500),py(500),dx(500),dy(500)
        character*50 str(500)
        integer istr(500)
        integer idpulsa
        common /pulsanti/nfi,px,py,dx,dy,str,istr,idpulsa
        data idpulsa/0/
c------------------------------------------------------------------------
c        print*,'creapuls iwi,ix,iy,llx,ly,nst',iwi,ix,iy,
c     *  llx,ly,nst,idpul
        idpulsa=idpulsa+1
        idpul=idpulsa
        lx=llx
        px(idpul)=ix
        py(idpul)=iy
        dx(idpul)=lx
        dy(idpul)=ly
        str(idpul)=stringa
        istr(idpul)=nst
c        print*,'lx',lx
        call finestradentropm(ix,iy,lx,ly,iwi,iwo)
        nfi(idpul)=iwo
        call cambiafi(iwo)
        call box(0.,0.,dx(idpul),dy(idpul),ncol)
        call newpen(15)
        if(nst*8.lt.lx)then
                r=3
                if(kf.eq.0)then
                        rx=8
                else
                        rx=(lx-nst*8)/2
                end if
                ry=(ly-9)/2
        elseif(nst*6.lt.lx)then
                r=2
                if(kf.eq.0)then
                        rx=8
                else
                        rx=(lx-nst*8)/2
                end if
                ry=(ly-7)/2
        else
                r=1
                if(kf.eq.0)then
                        rx=8
                else
                        rx=(lx-nst*8)/2
                end if
                ry=(ly-6)/2
        end if
        call symbol(rx,ry,r,stringa,r1,nst)
        return
        end

        subroutine controllapuls(npi,np)
        integer nfi(500)
        real px(500),py(500),dx(500),dy(500)
        character*50 str(500)
        integer istr(500)
        integer idpulsa
        common /pulsanti/nfi,px,py,dx,dy,str,istr,idpulsa
c        print*,'idpul',idpulsa
        np=0
        do i=1,idpulsa
c        print*,'idpulsa,i,,npi,nfi(i)',idpulsa,i,npi,nfi(i)
        if(nfi(i).eq.npi) then
                np=i
                return
        end if
        end do
        return
        end

        subroutine finestrapuls(np,nf)
        integer nfi(500)
        real px(500),py(500),dx(500),dy(500)
        character*50 str(500)
        integer istr(500)
        integer idpulsa
        common /pulsanti/nfi,px,py,dx,dy,str,istr,idpulsa
        nf=nfi(np)
        return
        end


        subroutine pulson(n)
        integer nfi(500)
        real px(500),py(500),dx(500),dy(500)
        character*50 str(500)
        integer istr(500)
        integer idpulsa
        common /pulsanti/nfi,px,py,dx,dy,str,istr,idpulsa
        call cambiafi(nfi(n))
        call pulson1(0.,0.,dx(n),dy(n))
        return
        end

        subroutine pulsoff(n)
        integer nfi(500)
        real px(500),py(500),dx(500),dy(500)
        character*50 str(500)
        integer istr(500)
        integer idpulsa
        common /pulsanti/nfi,px,py,dx,dy,str,istr,idpulsa
        call cambiafi(nfi(n))
        call pulsoff1(0.,0.,dx(n),dy(n))
        return
        end

        subroutine createnda(iwi,nnte,ix,iy,nupul,scritte,lscri)
        character*(*) scritte(*)
        dimension lscri(*)
C----------------------------------------------------------------
        integer nutenda(20)
        integer nupulperte(20)
        integer indpul(20,20)
        integer itatt(20)
        integer nte
        common /tenda/nutenda,nupulperte,indpul,itatt,nte
c---------------------------------------------------------------
        integer nfi(500)
        real px(500),py(500),dx(500),dy(500)
        character*50 str(500)
        integer istr(500)
        integer idpulsa
        common /pulsanti/nfi,px,py,dx,dy,str,istr,idpulsa
c----------------------------------------------------------------
        idpul=idpulsa
        nte=nte+1
        nnte=nte
        call cambiafi(iwi)
        nl=nupul
        ly=20*nl
        call finestranascosta(ix,iy,150,ly,iwi,iwo)
        nutenda(nte)=iwo
        itatt(nte)=0
c        print *,'tenda1,nte,nutenda(nte)',nte,nutenda(nte)
        nupulperte(nte)=nl
        do i=1,nl
c        print*,'i,nutenda(nte),lscri,scritte',
c     *  i,nutenda(nte),lscri(i),scritte(i)
        call creapuls(nutenda(nte),idpul,0,(i-1)*20,150,20,scritte(i),
     *  lscri(i),0,11)
c        print *,'i,nte,idpul'
        indpul(nte,i)=idpul
        end do
        return
        end

        subroutine chiuditenda(nnte)
C----------------------------------------------------------------
        integer nutenda(20)    ! numero finestra di ogni tenda
        integer nupulperte(20) ! numero pulsanti per ogni tenda
        integer indpul(20,20)  ! indici dei pulsanti contenuti
        integer itatt(20)
        integer nte            ! numero tende attive
        common /tenda/nutenda,nupulperte,indpul,itatt,nte
c---------------------------------------------------------------
        integer nfi(500)
        real px(500),py(500),dx(500),dy(500)
        character*50 str(500)
        integer istr(500)
        integer idpulsa
        common /pulsanti/nfi,px,py,dx,dy,str,istr,idpulsa
c----------------------------------------------------------------
        call chiudifinestra(nutenda(nnte))
        idpulsa=idpulsa-nupulperte(nte)
        nte=nte-1
        return
        end
        
        subroutine attivatenda(nnte)
C----------------------------------------------------------------
        integer nutenda(20)    ! numero finestra di ogni tenda
        integer nupulperte(20) ! numero pulsanti per ogni tenda
        integer indpul(20,20)  ! indici dei pulsanti contenuti
        integer itatt(20)
        integer nte            ! numero tende attive
        common /tenda/nutenda,nupulperte,indpul,itatt,nte
c---------------------------------------------------------------
        integer nfi(500)
        real px(500),py(500),dx(500),dy(500)
        character*50 str(500)
        integer istr(500)
        integer idpulsa
        common /pulsanti/nfi,px,py,dx,dy,str,istr,idpulsa
c----------------------------------------------------------------
        itatt(nnte)=1
        call cambiafi(nutenda(nnte))
        call visua
c        call box(0.,0.,150.,60.,2)
        do i=1,nupulperte(nnte)
c        call controllapuls(indpul(nnte,i),npf)
        npf=indpul(nnte,i)
c        call cambiafi(npf)
c        call visua
        call pulsoff(npf)
c        print*,'attiva i,nupulperte,nnte,indpul,npf',
c     *  i,nupulperte(nnte),nnte,indpul(nnte,i),npf
        end do
        return
        end

        subroutine disattivatenda(nnte)
C----------------------------------------------------------------
        integer nutenda(20)    ! numero finestra di ogni tenda
        integer nupulperte(20) ! numero pulsanti per ogni tenda
        integer indpul(20,20)  ! indici dei pulsanti contenuti
        integer itatt(20)
        integer nte            ! numero tende attive
        common /tenda/nutenda,nupulperte,indpul,itatt,nte
c---------------------------------------------------------------
        integer nfi(500)
        real px(500),py(500),dx(500),dy(500)
        character*50 str(500)
        integer istr(500)
        integer idpulsa
        common /pulsanti/nfi,px,py,dx,dy,str,istr,idpulsa
c----------------------------------------------------------------
        if(nnte.gt.0)then
          itatt(nnte)=0
          call nascondifinestra(nutenda(nnte))
        else
          do i=1,nte
            if(itatt(i).eq.1)then
              call nascondifinestra(nutenda(i))
              itatt(i)=0
            end if
          end do
        end if
        return
        end

        subroutine controllatenda(np,it,nt)
C----------------------------------------------------------------
        integer nutenda(20)
        integer nupulperte(20)
        integer indpul(20,20)
        integer itatt(20)
        integer nte
        common /tenda/nutenda,nupulperte,indpul,itatt,nte
c---------------------------------------------------------------
        it=0
        do j=1,nte
        do i=1,20
        if(indpul(j,i).eq.np)then
                it=i
                nt=j
                return
        end if
        end do
        end do
        return
        end
        
        subroutine box(x1,y1,dx,dy,nc)
        call newpen(nc)
        ix1=x1
        iy1=y1
        idx=dx
        idy=dy
        call boxc(ix1,iy1,idx,idy)
        call newpen(15)
        call plotnv(x1,y1,3)
        xa=ix1+idx-1
        call plotnv(xa,y1,2)
        ya=iy1+idy-1
        call plotnv(xa,ya,2)
        ya=y1+1.
        call plotnv(x1+1.,ya,3)
        xa=x1
        call plotnv(xa,ya,2)
        ya=iy1+idy-2
        call plotnv(xa,ya,2)
        call newpen(9)
        call plotnv(x1,y1+1,3)
        ya=iy1+idy-1
        call plotnv(x1,ya,2)
        xa=ix1+idx-2
        call plotnv(xa,ya,2)
        call plotnv(x1+1,y1+2,3)
        ya=iy1+idy-2
        call plotnv(x1+1,ya,2)
        xa=ix1+idx-3
        call plotnv(xa,ya,2)
        call visua
        return
        end

        subroutine pulson1(x1,y1,dx,dy)
        ix1=x1
        iy1=y1
        idx=dx
        idy=dy
        call newpen(9)
        call plotnv(x1,y1,3)
        xa=ix1+idx-1
        call plotnv(xa,y1,2)
        ya=iy1+idy-1
        call plotnv(xa,ya,2)
        ya=y1+1.
        call plotnv(x1+1.,ya,3)
        xa=x1
        call plotnv(xa,ya,2)
        ya=iy1+idy-2
        call plotnv(xa,ya,2)
        call newpen(15)
        call plotnv(x1,y1+1,3)
        ya=iy1+idy-1
        call plotnv(x1,ya,2)
        xa=ix1+idx-2
        call plotnv(xa,ya,2)
        call plotnv(x1+1,y1+2,3)
        ya=iy1+idy-2
        call plotnv(x1+1,ya,2)
        xa=ix1+idx-3
        call plotnv(xa,ya,2)
        call visua
        return
        end
        
        subroutine pulsoff1(x1,y1,dx,dy)
        ix1=x1
        iy1=y1
        idx=dx
        idy=dy
        call newpen(15)
        call plotnv(x1,y1,3)
        xa=ix1+idx-1
        call plotnv(xa,y1,2)
        ya=iy1+idy-1
        call plotnv(xa,ya,2)
        ya=y1+1.
        call plotnv(x1+1.,ya,3)
        xa=x1
        call plotnv(xa,ya,2)
        ya=iy1+idy-2
        call plotnv(xa,ya,2)
        call newpen(9)
        call plotnv(x1,y1+1,3)
        ya=iy1+idy-1
        call plotnv(x1,ya,2)
        xa=ix1+idx-2
        call plotnv(xa,ya,2)
        call plotnv(x1+1,y1+2,3)
        ya=iy1+idy-2
        call plotnv(x1+1,ya,2)
        xa=ix1+idx-3
        call plotnv(xa,ya,2)
        call visua
        return
        end

        subroutine scrivi(nf,ix,iy,stringa,nc,ds,icf,ics)
        character*(*) stringa
        character c,nu
        byte ic,nul
        equivalence (c,ic),(nu,nul)
        nul=0
        x=ix
        y=iy
        stringa=nu
        nc=0
        ic=0
        call cambiafi(nf)
        do while(ic.ne.13)
        call carattere(c)
c        call vcursr(c,iix,iiy)
        if(ic.eq.13) then
                return
        else if(ic.eq.8.or.ic.eq.127) then
                if(nc.gt.0) then
                call newpen(icf)
                call symbol(x,y,ds,stringa,r1,nc)
                        stringa(nc:nc)=nu
                        nc=nc-1
                call newpen(ics)
                call symbol(x,y,ds,stringa,r1,nc)
                end if
        else
                call newpen(icf)
                call symbol(x,y,ds,stringa,r1,nc)
                nc=nc+1
                stringa(nc:nc)=c
                call newpen(ics)
                call symbol(x,y,ds,stringa,r1,nc)
        end if
        end do
        return
        end

