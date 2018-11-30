C
C=======================================================================
C
C A short program to read in an image from an IRAF image file and 
C determine the median, and standard deviation of the brightness value.
C
C=======================================================================
C
      include 'arrays.inc'
      PARAMETER (MAXDAT= 150 994 944)
      DOUBLE PRECISION TOTAL,DEV
      REAL D(MAXDAT), LIMIT
      CHARACTER PICTURE*40, CASE*40, RNDOFF*9
      CHARACTER TEXT1*9, TEXT2*9, TEXT3*9, TEXT4*7, TEXT5*9, TEXT6*9
      INTEGER IMAX, JMAX, IMIN, JMIN
      CALL FABORT
      PICTURE = 'median.dat'
      PICTURE = CASE(PICTURE)
      CALL OUTFIL (1, PICTURE, ISTAT)
C
C=======================================================================
C
C Open the picture file.
C
      NSAMP = 1
      PICTURE=' '
 1000 WRITE (6,*)
      CALL GETNAM ('Input picture:',PICTURE)
      IF ((PICTURE.EQ.'EXIT').OR.(PICTURE.EQ.'END-OF-FILE')) CALL BYEBYE
C
      DO I=1,30
         IF (PICTURE(I:I) .EQ. '/') THEN
            READ (PICTURE(I+1:30),*) NSAMP
            PICTURE(I:30) = ''
            GO TO 1001
         END IF
      END DO
C
 1001 CONTINUE
      CALL ATTACH (PICTURE, NCOL, NROW)
      IF (NCOL(1) .LE. 0) THEN
         PICTURE = 'EXIT'
         GO TO 1000
      END IF
      IF (DATTYP(1) .EQ. 'SHRT') THEN
         LIMIT = 32767.
      ELSE IF (DATTYP(1) .EQ. 'LONG') THEN
         LIMIT = 32767.**2
      ELSE IF (DATTYP(1) .EQ. 'REAL') THEN
         LIMIT = 1.E10
      ELSE
         CALL STUPID ('Invalid data type.')
         CALL CLPIC (1, IER)
         GO TO 1000
      END IF
C
      LX = 1
      LY = 1
      MX = NCOL(1)
      MY = NROW(1)
      CALL RDARAY (1, LX, LY, MX, MY, NCOL(1), D, IER)
C
      IMIN = 0
      JMIN = 0
      IMAX = 0
      JMAX = 0
      RMIN=1.E30
      RMAX=-1.E30
      N = 0
      DO I=1,NCOL(1)*NROW(1),NSAMP
         IF ((D(I) .LT. LIMIT) .AND. (D(I) .GE. -LIMIT)) THEN
            IF (D(I).LT.RMIN) THEN
               RMIN = D(I)
               JMIN = (I-1)/NCOL(1) + 1
               IMIN = I - NCOL(1)*(JMIN-1)
            END IF
C
            IF (D(I).GT.RMAX) THEN
               RMAX = D(I)
               JMAX = I/NCOL(1) + 1
               IMAX = I - NCOL(1)*(JMAX-1)
            END IF
            N = N+1
            D(N) = D(I)
         END IF
      END DO
C
      CALL CLPIC (1, IER)
C
      MID=(N+1)/2
      VALUE  = PCTILE(D, N, MID)
      VHI = PCTILE(D(MID+1), N-MID, NINT(0.9544*MID))
      VLO = PCTILE(D, MID-1, NINT(0.0456*MID))
      TOTAL=0.0
      DEV=0.0
      P = 0.0
      DO 3000 I=1,N
         DELTA=D(I)-VALUE
         IF ((D(I) .GE. VLO) .AND. (D(I) .LE. VHI)) THEN
            TOTAL = TOTAL+DELTA
            DEV = DEV + ABS(DELTA)
            P = P+1.
         END IF
 3000 CONTINUE
      AVERAG=TOTAL/P+VALUE
      STDDEV = 1.4495*DEV/P
      IF (VALUE .GT. STDDEV) THEN
         VHI = STDDEV/VALUE
      ELSE
         VHI = 0.
      END IF
      WRITE (6,*)
      TEXT1 = RNDOFF(VALUE, 9, 3)
      TEXT2 = RNDOFF(AVERAG, 9, 3)
      TEXT3 = RNDOFF(STDDEV, 9, 3)
      TEXT4 = RNDOFF(VHI, 7, 3)
      TEXT5 = RNDOFF(RMIN, 9, 2)
      TEXT6 = RNDOFF(RMAX, 9, 2)
      WRITE (6,601) ' Median:', TEXT1,'  Mean:', TEXT2,
     .     '  Std dev:', TEXT3, '  Rel dev:', TEXT4
  601 FORMAT (A, A9, A, A9, A, A9, A, A7)
      WRITE (6,602) ' Minimum:', TEXT5, ' at', IMIN, JMIN,
     .     '    Maximum:', TEXT6, ' at', IMAX, JMAX
  602 FORMAT (A, A9, A, 2I6, A, A9, A, 2I6)
      DO I=1,30
         IF (PICTURE(I:I) .NE. ' ') J = I
      END DO
      WRITE (1,101) TEXT1, TEXT2, TEXT3, TEXT4,
     .     TEXT5, IMAX, JMAX, TEXT6, IMIN, JMIN, N, PICTURE(1:J)
  101 FORMAT (1X, 3A9, A7, A9, 2I6, A9, 2I6, I11, 2X, A)
      PICTURE='EXIT'
      GO TO 1000
      END!
