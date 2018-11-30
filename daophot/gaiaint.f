        program gaiaint
C
C       by G. Iannicola - August 2006
C
        dimension x(10000),y(10000),wei(10000),pes(4),par(100),parg(100)
        character fno*50,st1*15,st2*15,st3*15,mpa
        dimension rx2(1000),ry2(1000),rx0(2),ry0(4),ym(10000),yg(10000),
     *  yres(10000),rmo(1000),rga(1000),rrm(1000),rrg(1000)
        dimension ipul(14),knn(14),rx(10000),ry(10000)
        character nome*12,nn(14)*10,car
        data nn/'Data ',' Inp. HX-L ','Sky ','Fit M. ','Fit G. ',
     *  'Pesi ','Integ ','Fix Par. ','Del Comp ','Beta ','? ',
     *  'Inp. Man. ','Modify ','EXIT '/
        data pes/4*1./,fs/0.7/,knn/4,10,3,7,6,4,5,8,8,4,1,9,7,4/
        fcon=0
        ifit=0
        beta=0
        ifm=0
        ifg=0
        lfl=0
        inp=0
        do i=1,10000
          wei(i)=1
        end do
        rx0(1)=120
        rx0(2)=770
        ry0(1)=250
        ry0(2)=250
        ry0(3)=125
        ry0(4)=125
        kopen=0
        open(2,file='pf.dat',status='unknown')
        np=0
        idpul=0
        par(1)=0.
        parg(1)=0.
        nome='Int.ve Gaia '
        nc=0
        tx=800
        ty=700
        call plots(nome,tx,ty,nw0)
        call box(1.,0.,100.,ty-1.,11)
        do i=1,14
          ky=40*(i-1)+10
          lcol=11
          if(i.eq.1) lcol=3
          if(i.eq.8) lcol=28
          if(i.eq.4.or.i.eq.5) lcol=7
          if(i.eq.2.or.i.eq.12.or.i.eq.3.or.i.eq.10.or.i.eq.13) lcol=22
          if(i.eq.14) lcol=1
          call creapuls(nw0,idpul,10,ky,80,30,nn(i),knn(i),1,lcol)
          ipul(i)=idpul
          if(i.eq.10) then
            call cambiafi(nw0)
            call box(92.,300.,6.,30.,1)
          end if
          if(i.eq.6) then
            call cambiafi(nw0)
            call box(92.,460.,6.,30.,2)
          end if
          if(i.eq.7) then
            call cambiafi(nw0)
            call box(92.,420.,6.,30.,2)
          end if
        end do
        call cambiafi(nw0)
        st1='I. Ferraro & '
        st2='G. Iannicola '
        st3='Graphics '
        call symbol(10.,80.,3.,st1,1.,12)
        call symbol(10.,65.,3.,st2,1.,12)
        call symbol(10.,50.,3.,st3,1.,8)
99      call vcursr(car,lx,ly)
        if(car.eq.'e') then
          if(lx.gt.0) kpf=lx
            if(kpf.gt.0) call pulson(kpf)
        end if
        if(car.eq.'u') then
          if(lx.gt.0) kpf=lx
          if(kpf.gt.0) call pulsoff(kpf)
          kpf=0
          call cambiafi(nw0)
        end if
C ---------------- Action 1  -  DATA --------------------------
        if(ipul(1).eq.kpf.and.car.eq.'(') then
          if(kopen.eq.1) then
            close(1)
          end if
          kopen=1
          nc=0
          fno=' '
222       print *,'nome file dati'
          read(*,234) fno
234       format(a50)
          open(1,file=fno,status='old',err=222)
          call cambiafi(nw0)
          call erase(100.,1.,tx-100.,ty)
          np=0
          ymax=-9999
          do i=1,10000
            read(1,*,end=101) x(i),y(i)
            if(y(i).gt.ymax) then
              ymax=y(i)
              xmax=x(i)
              imax=i
            end if
            np=np+1
          end do
101       if(fcon.gt.0) then
            do i=1,np
              wei(i)=fcon/y(i)
            end do
          end if
          do i=1,np
            rx(i)=x(i)*650/x(np)+120
            ry(i)=y(i)*400/ymax+250
          end do
          inp=1
          fsca=400./ymax
          fscar=0
          call newpen(2)
          call linenv(2,rx0,ry0)
          call newpen(9)
          call linenv(np,rx,ry)
          call visua
          call pulsoff(kpf)
C ---------------- Action 2  -  INPUT COMP. ---------------------
        else if(ipul(2).eq.kpf.and.car.eq.'(') then
          if(beta.gt.0) then
            coe=2*sqrt(2**(1./beta)-1)
          else
            coe=1
          end if
          call cambiafi(nw0)
111       call vcursr(car,lx,ly)
          if(car.ne.'('.or.ly.le.125) go to 111
          call newpen(1)
          rx2(1)=lx-9
          rx2(2)=lx+9
          ry2(1)=ly
          ry2(2)=ly
          call linenv(2,rx2,ry2)
          rx2(1)=lx
          rx2(2)=lx
          ry2(1)=ly-9
          ry2(2)=ly+9
          call linenv(2,rx2,ry2)
          call visua
          ind=3*(nc+1)
          if(ly.gt.250) then
            par(ind-1)=(ly-250.)*ymax/400.
          else
            par(ind-1)=(ly-125)*fscar
          end if
          par(ind)=(lx-120.)*x(np)/650.
          parg(ind-1)=par(ind-1)
          parg(ind)=par(ind)
112       call vcursr(car,lx,ly)
          if(car.ne.'(') go to 112
          rx2(1)=lx-9
          rx2(2)=lx+9
          ry2(1)=ly
          ry2(2)=ly
          call linenv(2,rx2,ry2)
          rx2(1)=lx
          rx2(2)=lx
          ry2(1)=ly-9
          ry2(2)=ly+9
          call linenv(2,rx2,ry2)
          call visua
          call newpen(9)
          parg(ind+1)=2*abs((lx-120.)*x(np)/650.-par(ind))
          par(ind+1)=parg(ind+1)/coe
          nc=nc+1
          call pulsoff(kpf)
C ---------------- Action 3  -  INPUT SKY -----------------------
        else if(ipul(3).eq.kpf.and.car.eq.'(') then
          call cambiafi(nw0)
113       call vcursr(car,lx,ly)
          if(car.ne.'(') go to 113
          call newpen(1)
          rx2(1)=lx-9
          rx2(2)=lx+9
          ry2(1)=ly
          ry2(2)=ly
          call linenv(2,rx2,ry2)
          rx2(1)=lx
          rx2(2)=lx
          ry2(1)=ly-9
          ry2(2)=ly+9
          call linenv(2,rx2,ry2)
          call visua
          ind=3*nc
          par(1)=(ly-250.)*ymax/400.
          parg(1)=par(1)
          call pulsoff(kpf)
C ---------------- Action 6  -  Pesi  ----------------------------
        else if(ipul(6).eq.kpf.and.car.eq.'(') then
          print *,'fattore el/ADU (0 = no pesi)'
          read(*,*) fcon
          call cambiafi(nw0)
          if(fcon.gt.0) then
            if(np.gt.0) then
              do i=1,np
                wei(i)=fcon/y(i)
              end do
            end if
            call box(92.,460.,6.,30.,3)
          else
            do i=1,np
              wei(i)=1
            end do
            call box(92.,460.,6.,30.,2)
          end if 
          call pulsoff(kpf)
          call visua
C ---------------- Action 7  -  Integrale ------------------------
        else if(ipul(7).eq.kpf.and.car.eq.'(') then
          ifit=1-ifit
          call cambiafi(nw0)
          if(ifit.eq.1) kcol=3
          if(ifit.eq.0) kcol=2
          call box(92.,420.,6.,30.,kcol)
          call pulsoff(kpf)
          call visua
C ---------------- Action 8  -  FIXED PAR. -----------------------
        else if(ipul(8).eq.kpf.and.car.eq.'(') then
          print *,' flag: 0 tutto variabile (default)'
          print *,'       1 fondo fisso'
          print *,'       2 posiz. fisse'
          print *,'       3 fondo e posiz. fisse'
          print *,'       4 sigma fissi'
          print *,'       5 fondo + sigma fissi'
          print *,'       6 posiz.+ sigma fissi'
          print *,'       7 fondo + posiz. + sigma fissi'
          read(*,22) lfl
22        format(i6)
          call pulsoff(kpf)
C ---------------- Action 13  -  MODIFY PARAMETER ----------------
        else if(ipul(13).eq.kpf.and.car.eq.'(') then
          print *,'modifica: fondo - larghezze - posizioni (f/l/p)'
          read(*,127) mpa
127       format(a1)
          if(mpa.eq.'f'.or.mpa.eq.'F') then
          print*,'valore fondo - attuali moffat e gauss',par(1),parg(1)
            read(*,*) par(1)
            parg(1)=par(1)
          else if(mpa.eq.'l'.or.mpa.eq.'L') then
             do i=1,nc
               in=i*3+1
       print *,'comp.',i,' attuali M e G',par(im),parg(in),'(D:invar.)'
               read(*,128) vsig
128            format(f10.0)
               if(vsig.gt.0) then
                 par(in)=vsig
                 parg(in)=vsig
               end if
             end do
          else if(mpa.eq.'p'.or.mpa.eq.'P') then
             do i=1,nc
               in=i*3
       print *,'comp.',i,' attuali M e G',par(im),parg(in),'(D:invar.)'
               read(*,128) vsig
               if(vsig.gt.0) then
                 par(in)=vsig
                 parg(in)=vsig
               end if
             end do
          end if
          call pulsoff(kpf)
C ---------------- Action 9  -  DELETE COMPONENT -----------------
        else if(ipul(9).eq.kpf.and.car.eq.'(') then
          if(nc.gt.0) then
            print *,'SKY :  ',par(1),parg(1)
            do i=1,nc
              ind=i*3-1
              print 55,i,(par(j),j=ind,ind+2),(parg(j),j=ind,ind+2)
55            format(i3,6f8.2)
            end do
            print *,' '
            print *,'Component to delete'
            read(*,*) nde
            if(nde.gt.0.and.nde.le.nc) then
              nc=nc-1
              if(nde.le.nc) then
                do i=nde,nc
                  ind=i*3-1
                  par(ind)=par(ind+3)
                  par(ind+1)=par(ind+4)
                  par(ind+2)=par(ind+5)
                  parg(ind)=parg(ind+3)
                  parg(ind+1)=parg(ind+4)
                  parg(ind+2)=parg(ind+5)
                end do
              end if
            end if
          else
            print *,'*****  NO COMPONENT  *****'
          end if
          call pulsoff(kpf)
C ---------------- Action 10  -  BETA  ---------------------------
        else if(ipul(10).eq.kpf.and.car.eq.'(') then
          print *,'beta'
          read(*,*) beta
          call cambiafi(nw0)
          kcol=3
          if(beta.le.0) kcol=1
          call box(92.,300.,6.,30.,kcol)
          call pulsoff(kpf)
          call visua
          call pulsoff(kpf)
C ---------------- Action 11  -  INFO COMP. ----------------------
        else if(ipul(11).eq.kpf.and.car.eq.'(') then
          print *,'sky ',par(1)
          print *,'nr. comp. - beta ',nc,beta
          if(nc.gt.0) then
            print *,'nr.  -  H   -   X0  -  LM -   H   -    X0  -  LG'
            do ii=1,nc
              ind=ii*3
              print 7,ii,par(ind-1),par(ind),par(ind+1),
     *        parg(ind-1),parg(ind),parg(ind+1)
7             format(i3,2(f9.2,f8.2,f7.1))
            end do
          end if
          call pulsoff(kpf)
C ---------------- Action 12  -  ADD COMP ------------------------
        else if(ipul(12).eq.kpf.and.car.eq.'(') then
          print *,'new comp: H - X0 - WIDHT'
          read(*,*) par(nc*3+2),par(nc*3+3),par(nc*3+4)
          nc=nc+1
          parg(nc*3-1)=par(nc*3-1)
          parg(nc*3)=par(nc*3)
          parg(nc*3+1)=par(nc*3+1)
          call pulsoff(kpf)
C ---------------- Action 14  -  EXIT  ---------------------------
        else if(ipul(14).eq.kpf.and.car.eq.'(') then
          go to 98
C ---------------- Action 4  -  FIT MOFFAT  ----------------------
        else if(ipul(4).eq.kpf.and.car.eq.'(') then
          if(beta.le.0) then
93          print *,'beta'
            read(*,*) beta
            call cambiafi(nw0)
            kcol=3
            if(beta.le.0)  go to 93
            call box(92.,300.,6.,30.,kcol)
            call pulsoff(kpf)
            call visua
          end if
c          print *,'par',(par(it),it=1,4)
          sqm=scarm(x,y,np,nc,par,beta,wei,ifit)
          sqrif=999999.
          dsqm=abs((sqrif-sqm)/sqm)
          iter=0
          do while(iter.lt.100.and.dsqm.gt.0.0001)
            if(ifit.eq.0) then
              call mvar(x,y,np,nc,par,wei,beta,fs,pes,lfl)
c              print *,'no integ.'
            else
              call mvari(x,y,np,nc,par,wei,beta,fs,pes,lfl)
c              print *,'integ.'
            end if
c          print *,'par',(par(it),it=1,4)
            iter=iter+1
            sqm=scarm(x,y,np,nc,par,beta,wei,ifit)
            dsqm=abs((sqrif-sqm)/sqm)
            sqrif=sqm
          end do
          rymax=-99999
          rymin=-rymax
          do i=1,np
            ym(i)=par(1)
            do j=1,nc
              ind=3*j-1
              if(ifit.eq.0) then
              ym(i)=ym(i)+
     *        par(ind)*(1.+((x(i)-par(ind+1))/par(ind+2))**2)**(-beta)
              else
        ym(i)=ym(i)+galem(par(ind),par(ind+2),beta,x(i)-.5,par(ind+1))
              end if
            end do
            yres(i)=y(i)-ym(i)
            rymax=amax1(rymax,yres(i))
            rymin=amin1(rymin,yres(i))
          end do
          fsca=400./ymax
          fscar=120./amax1(rymax,abs(rymin))
          if(fscar.gt.fsca) fscar=fsca
          do i=1,np
            rmo(i)=ym(i)*fsca+250
            rrm(i)=yres(i)*fscar+125
          end do
          call pulsoff(kpf)
          call cambiafi(nw0)
          call newpen(1)
          call linenv(np,rx,rmo)
c          call erase(100.,1.,tx-100.,249.)
          call newpen(3)
          call linenv(np,rx,rrm)
          call newpen(2)
          call linenv(2,rx0,ry0(3))
          call newpen(9)
          call visua
          ifm=1
          print *,'  '
          print *,'Moffat - parametri fit'
          print *,'fondo = ',par(1)
          print *,'altezza - posizione - sigma'
          do i=1,nc
            in=i*3
            print *,par(in-1),par(in),par(in+1)
          end do
          print *,' iterazioni - sqm ',iter,sqm
          print *,'  '
          call cambiafi(nw0)
          call erase(100.,1.,tx-100.,ty)
          call newpen(2)
          call linenv(2,rx0,ry0)
          if(ifm.eq.1) then
            call newpen(1)
            call linenv(np,rx,rmo)
            call newpen(3)
            call linenv(np,rx,rrm)
            call newpen(2)
            call linenv(2,rx0,ry0(3))
          end if
          call newpen(9)
          call linenv(np,rx,ry)
          call visua
          call pulsoff(kpf)
C ---------------- Action 5  -  FIT GAUSS  -----------------------
        else if(ipul(5).eq.kpf.and.car.eq.'(') then
          iter=0
          sqrif=999999.
          sqmg=scar(x,y,np,nc,parg,wei,ifit)
          dsqmg=abs((sqrif-sqmg)/sqmg)
          do while(iter.lt.100.and.dsqmg.gt.0.0001)
            if(ifit.eq.0) then
              call gvar(x,y,np,nc,parg,wei,fs,pes,lfl)
            else
              call gvari(x,y,np,nc,parg,wei,fs,pes,lfl)
            end if
            iter=iter+1
            sqm=scar(x,y,np,nc,parg,wei,ifit)
            dsqmg=abs((sqrif-sqm)/sqm)
            sqrif=sqm
          end do
          rymax=-99999
          rymin=-rymax
          do i=1,np
            yg(i)=parg(1)
            do j=1,nc
              ind=3*j-1
              if(ifit.eq.0) then
              yg(i)=yg(i)+parg(ind)*
     *        exp(-4*alog(2.)*((x(i)-parg(ind+1))/parg(ind+2))**2)
              else
         yg(i)=yg(i)+galeg(parg(ind),parg(ind+2),x(i)-.5,parg(ind+1))
              end if
            end do
            yres(i)=y(i)-yg(i)
            rymax=amax1(rymax,yres(i))
            rymin=amin1(rymin,yres(i))
          end do
          fsca=400./ymax
          fscar=120./amax1(rymax,abs(rymin))
          if(fscar.gt.fsca) fscar=fsca
          do i=1,np
            rga(i)=yg(i)*fsca+250
            rrg(i)=yres(i)*fscar+125
          end do
          call pulsoff(kpf)
          call cambiafi(nw0)
          call newpen(5)
          call linenv(np,rx,rga)
c          call erase(100.,1.,tx-100.,249.)
          call newpen(3)
          call linenv(np,rx,rrg)
          call newpen(2)
          call linenv(2,rx0,ry0(3))
          call newpen(9)
          call visua
          ifg=1
          print *,'  '
          print *,'Gauss - parametri fit'
          print *,'fondo = ',parg(1)
          print *,'altezza - posizione - sigma'
          do i=1,nc
            in=i*3
            print *,parg(in-1),parg(in),parg(in+1)
          end do
          print *,' iterazioni - sqm ',iter,sqm
          print *,'  '
          call cambiafi(nw0)
          call erase(100.,1.,tx-100.,ty)
          call newpen(2)
          call linenv(2,rx0,ry0)
          if(ifg.eq.1) then
            call newpen(5)
            call linenv(np,rx,rga)
            call newpen(3)
            call linenv(np,rx,rrg)
            call newpen(2)
            call linenv(2,rx0,ry0(3))
          end if
          call newpen(9)
          call linenv(np,rx,ry)
          call visua
          call pulsoff(kpf)
C -----------------------  READ X Y -------------------------------
        else if(car.eq.'('.and.inp.eq.1) then
          xo=(lx-120)*x(np)/650.
          if(ly.ge.250) then
            yo=(ly-250.)/fsca
          else
            if(fscar.gt.0) then
              yo=(ly-125.)/fscar
            else
              y0=0
            end if
          end if
          print *,xo,yo
        end if
C -----------------------  LOOP  ----------------------------------
        go to 99
C -----------------------  EXIT  ----------------------------------
98      write(2,19) fno
19      format('# file dati:  ',a50)
        write(2,11) par(1),parg(1)
11      format('#  sky moffat - gauss ',2f10.3)
        print *,'fondo  ',par(1),parg(1)
        write(2,13)
13      format('#',2x,'Nr.',4x,'HM',8x,'x0 M',6x,'R M',6x,
     *  'HG',8x,'x0 G',8x,'R G')
        do i=1,nc
          in=i*3
          write(2,12) i,par(in-1),par(in),par(in+1),
     *    parg(in-1),parg(in),parg(in+1)
12        format('# ',i3,6f10.3)
          print *,i,par(in-1),par(in),par(in+1),
     *    parg(in-1),parg(in),parg(in+1)
        end do
        do i=1,np
          xx=x(i)
          tm=0
          tg=0
          do j=1,nc
            k=j*3-1
            if(ifit.eq.0) then
          tm=tm+par(k)*(1+(xx-par(k+1))**2/par(k+2)**2)**(-beta)
          tg=tg+parg(k)*exp(-4*alog(2.)*(xx-parg(k+1))**2/parg(k+2)**2)
            else
              tm=tm+galem(par(in-1),par(in+1),beta,x(i)-0.5,par(in))
              tg=tg+galeg(parg(in-1),parg(in+1),x(i)-0.5,parg(in))
            end if
          end do
          tm=tm+par(1)
          tg=tg+parg(1)
          write(2,9) xx,tm,rm1,rm2,tg,f1,f2
9         format(7f10.3)
        end do
        stop
        end
        function scarm(x,y,np,nc,par,beta,wei,ifit)
        dimension x(*),y(*),par(*),wei(*)
        scarm=0
        do i=1,np
          v=par(1)
          do j=1,nc
            in=j*3
            if(ifit.eq.0) then
        v=v+par(in-1)*(1.+(par(in)-x(i))**2/(par(in+1)**2))**(-beta)
            else
              v=v+galem(par(in-1),par(in+1),beta,x(i)-0.5,par(in))
            end if
          end do
          scarm=scarm+(v-y(i))**2*wei(i)
        end do
        scarm=sqrt(scarm/np)
        return
        end
        function scar(x,y,np,nc,par,wei,ifit)
        dimension x(*),y(*),par(*),wei(*)
        scar=0
        do i=1,np
          v=par(1)
          do j=1,nc
            in=j*3
            if(ifit.eq.0) then
        v=v+par(in-1)*exp(-4*alog(2.)*(par(in)-x(i))**2/(par(in+1)**2))
            else
              v=v+galeg(par(in-1),par(in+1),x(i)-0.5,par(in))
            end if
          end do
          scar=scar+(v-y(i))**2*wei(i)
        end do
        scar=sqrt(scar/np)
        return
        end
