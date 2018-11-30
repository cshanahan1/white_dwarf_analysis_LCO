      PARAMETER (MXPNT = 7)
      CHARACTER LINE*300
      CHARACTER NAME*30, FILE*30, SWITCH*30, EXTEND*30
      CHARACTER DRNDFF*12, OUTX(10)*12, OUTY(10)*12
      DOUBLE PRECISION TERM(10), C(10,10), VX(10), VY(10), 
     .     AX(10), AY(10)
      DOUBLE PRECISION COEFF(20), COEFF1(20), FFEOC1(6)
      DOUBLE PRECISION XS, YS
      LOGICAL REPEAT
C
C#######################################################################
C
      PNTS = REAL(MXPNT-1)
      TERM(1) = 1.D0
      CALL GETARG (1, FILE)
      IF (FILE .EQ. '') THEN
         REPEAT = .TRUE.
      ELSE
         REPEAT = .FALSE.
         GO TO 1010
      END IF
 1000 CALL GETNAM ('Input .mch name:', FILE)
      IF (FILE .EQ. 'EXIT') STOP
 1010 FILE = EXTEND(FILE, 'mch')
      CALL INFILE (1, FILE, ISTAT)
      IF (ISTAT .NE. 0) THEN
         CALL STUPID ('Cannot open '//FILE)
         CALL OOPS
      END IF
      FILE = SWITCH(FILE, '.tra')
      CALL OUTFIL (2, FILE, ISTAT)
C
 1020 CALL RDCHAR (1, LINE, M, ISTAT)
      print*,'A ',line(1:m)
      IF (ISTAT .GT. 0) THEN
         CALL STUPID ('File is empty!')
         CALL CLFILE (1)
         CALL OOPS
      END IF
      IF (LINE(1:1) .EQ. 'C') GO TO 1020
C
      IF (M .GT. 200) THEN
         READ (LINE,*) NAME, (COEFF1(J), J=1,6),
     .        DMAG1, SIG, (COEFF1(J), J=7,20)
         MODE1 = 20
         WRITE (2,1) NAME, 0., 0., 1., 0., 0., 1., 0., SIG, 
     .        (0., J=7,20)
    1    FORMAT (1X, '''', A, '''', 2F10.4, 4F12.9, F9.3, F8.4,
     .              14F12.9)
      ELSE IF (M .GT. 150) THEN
         READ (LINE,*) NAME, (COEFF1(J), J=1,6),
     .        DMAG1, SIG, (COEFF1(J), J=7,12)
         MODE1 = 12
         WRITE (2,1) NAME, 0., 0., 1., 0., 0., 1., 0., SIG, 
     .        (0., J=7,12)
      ELSE
         READ (LINE,*) NAME, (COEFF1(J), J=1,6), DMAG1, SIG
         MODE1 = 6
         WRITE (2,1) NAME, 0., 0., 1., 0., 0., 1., 0., SIG
      END IF
C
      CALL INVRT (COEFF1, MODE1, FFEOC1)
      CALL INFILE (9, NAME, ISTAT)
      IF (ISTAT .NE. 0) THEN
         CALL STUPID ('Unable to open '//NAME)
         CALL CLFILE (2)
         CALL CLFILE (1)
         CALL OOPS
      END IF
      CALL RDHEAD (9, NL, NCOL, NROW, DM, DM, DM, DM, DM, DM, DM)
      RCOL1 = REAL(NCOL)
      RROW1 = REAL(NROW)
c     open (11, file='master.out', status='new')
c     call wrhead (11, 1, ncol, nrow, 7, DM, DM, DM, DM, DM, DM, DM)
C
 2000 CALL RDCHAR (1, LINE, M, ISTAT)
      print*,'B ',line(1:m)
      IF (ISTAT .GT. 0) GO TO 9000
      IF (LINE(1:1) .EQ. 'C') GO TO 2000
C
      IF (M .GT. 200) THEN
         READ (LINE,*) NAME, (COEFF(J), J=1,6),
     .        DMAG, SIG, (COEFF(J), J=7,20)
         MODE = 20
      ELSE IF (M .GT. 130) THEN
         READ (LINE,*) NAME, (COEFF(J), J=1,6),
     .        DMAG, SIG, (COEFF(J), J=7,12)
         MODE = 12
      ELSE
         READ (LINE,*) NAME, (COEFF(J), J=1,6), DMAG, SIG
         MODE = 6
      END IF
C
      CALL INFILE (9, NAME, ISTAT)
      IF (ISTAT .NE. 0) THEN
         CALL STUPID ('Unable to open '//NAME)
         CALL CLFILE (2)
         CALL CLFILE (1)
         CALL OOPS
      END IF
C
      CALL RDHEAD (9, NL, NCOL, NROW, DM, DM, DM, DM, DM, DM, DM)
      RCOL = REAL(NCOL)
      RROW = REAL(NROW)
      CALL CLFILE (9)
c     open (12, file='slave.out', status='new')
c     call wrhead (12, 1, ncol, nrow, 7, DM, DM, DM, DM, DM, DM, DM)
C
C=======================================================================
C
C Prepare accumulation buffers for least squares.
C
      M = MODE/2
      DO J=1,M
         VX(J) = 0.D0
         VY(J) = 0.D0
         DO I=1,M
            C(I,J) = 0.D0
         END DO
      END DO
C
C Start accumulating.
C
      DX = (RCOL1-1.)/PNTS
      DY = (RROW1-1.)/PNTS
      DO J=0,MXPNT-1
         Y = 1. + J*DY
         DO I=0,MXPNT-1
            X = 1. + I*DX
            CALL GTFM (X, Y, RCOL, RROW, COEFF, MODE, XX, YY)
C
C XX,YY are the position in the old master frame.  Now transform
C these to the position in the new master frame: XXX,YYY.
C
            CALL BCKWRD (XX, YY, RCOL1, RROW1, COEFF1, FFEOC1, 
     .           MODE1, XXX, YYY)
C
C Now the least squares.
C
            TERM(2) = X
            TERM(3) = Y
            IF (M .GT. 3) THEN
               XS = 2.D0*(X-1.D0)/DBLE(RCOL-1.) - 1.D0
               YS = 2.D0*(Y-1.D0)/DBLE(RROW-1.) - 1.D0
               TERM(4) = 1.5D0*XS**2 - 0.5D0
               TERM(5) = XS*YS
               TERM(6) = 1.5D0*YS**2 - 0.5D0
               IF (M .GT. 6) THEN
                  TERM(7) = XS * TERM(4)
                  TERM(8) = YS * TERM(4)
                  TERM(9) = XS * TERM(6)
                  TERM(10) = YS * TERM(6)
               END IF
            END IF
C
            DO L=1,M
               VX(L) = VX(L) + XXX*TERM(L)
               VY(L) = VY(L) + YYY*TERM(L)
               DO K=1,M
                  C(K,L) = C(K,L) + TERM(K)*TERM(L)
               END DO
            END DO
         END DO
      END DO
C
C-----------------------------------------------------------------------
C
      CALL DINVRS (C, 10, M, ISTAT)
      CALL DVMUL (C, 10, M, VX, AX)
      CALL DVMUL (C, 10, M, VY, AY)
C
      OUTX(1) = DRNDFF(AX(1), 10, 4)
      OUTY(1) = DRNDFF(AY(1), 10, 4)
      DO J=2,3
         OUTX(J) = DRNDFF(AX(J), 12, 9)
         OUTY(J) = DRNDFF(AY(J), 12, 9)
      END DO
      IF (M .LE. 3) THEN
         WRITE (2,2) NAME, (OUTX(I), OUTY(I), I=1,3), DMAG-DMAG1, SIG
    2    FORMAT (1X, '''', A, '''', 2A10, 4A12, F9.3, F8.4, 14A12)
      ELSE
         DO J=4,M
            OUTX(J) = DRNDFF(AX(J), 12, 9)
            OUTY(J) = DRNDFF(AY(J), 12, 9)
         END DO
         WRITE (2,2) NAME, (OUTX(I), OUTY(I), I=1,3), DMAG-DMAG1, SIG,
     .        (OUTX(I), OUTY(I), I=4,M)
      END IF
      GO TO 2000
C
C=======================================================================
C
 9000 CALL CLFILE (1)
      CALL CLFILE (2)
      FILE = 'EXIT'
      IF (REPEAT) GO TO 1000
      STOP
      END!
C
C#######################################################################
C
C Invert the first six transformation constants.
C
      SUBROUTINE INVRT (COEFF, MODE, FFEOC)
      DOUBLE PRECISION COEFF(20), FFEOC(6), DENOM
      DENOM = COEFF(3)*COEFF(6)-COEFF(4)*COEFF(5)
      FFEOC(3) = COEFF(6)/DENOM
      FFEOC(4) = -COEFF(4)/DENOM
      FFEOC(5) = -COEFF(5)/DENOM
      FFEOC(6) = COEFF(3)/DENOM
      FFEOC(1) = (COEFF(2)*COEFF(5) - COEFF(1)*COEFF(6))/DENOM
      FFEOC(2) = (COEFF(1)*COEFF(4) - COEFF(2)*COEFF(3))/DENOM
      RETURN
      END
C
C#######################################################################
C
      SUBROUTINE  BCKWRD  (XX, YY, RCOL, RROW, COEFF, FFEOC, MODE, X, Y)
      DOUBLE PRECISION COEFF(20), FFEOC(6)
C
C Use the crude inverse constants to project the master-system position
C to an approximate position in this frame.
C
      OLDX = 0.
      OLDY = 0.
      OLDERX = 0.
      OLDERY = 0.
      X = FFEOC(1) + FFEOC(3)*XX + FFEOC(5)*YY
      Y = FFEOC(2) + FFEOC(4)*XX + FFEOC(6)*YY
 1000 CONTINUE
C
C Now apply the forward transformation to this position to see how
C close we come to the starting point.
C
      CALL GTFM (X, Y, RCOL, RROW, COEFF, MODE, DX, DY)
      DX = XX - DX
      DY = YY - DY
      IF ((DX .EQ. OLDERX) .AND. (DY .EQ. OLDERY)) RETURN
      X = X + FFEOC(3)*DX + FFEOC(5)*DY
      Y = Y + FFEOC(4)*DX + FFEOC(6)*DY
      R = DX**2 + DY**2
      IF (R .LT. 2.E-6) RETURN
      IF (R .GT. 1.E20) RETURN
      OLDERX = OLDX
      OLDERY = OLDY
      OLDX = DX
      OLDY = DY
      GO TO 1000
      END!
