C
C=======================================================================
C
C Pass a median filter contained within a circular aperture over a
C two-dimensional image.
C
C=======================================================================
C
      include 'arrays.inc'
      PARAMETER (MAXCOL=16 020)
      CHARACTER IFILE*30, OFILE*30, SWITCH*30, NAME*30
      CHARACTER SQUEEZ*8, STRING*8, CASE*6, YN*1
      REAL ORIG(MAXCOL,MAXCOL), COPY(MAXCOL), BAD(2), RADIUS(2)
C
C=======================================================================
C
C Get the required information.
C
      IFILE = ' '
      CALL GETNAM ('Input picture:', IFILE)
      IF (IFILE .EQ. 'END-OF-FILE') CALL BYEBYE
      PICTUR(1) = IFILE
      IMGTYP(1) = ' '
      DATTYP(1) = ' '
      CALL OPNPIC (1, 'R', IER)
      IF (IMID(1) .LE. 0) THEN
         CALL STUPID ('Unable to open input image '//IFILE)
         CALL OOPS
      END IF
      CALL OBJECT (1, NAME)
      CALL GETDAT ('Smoothing radius, percentile:', RADIUS, 2)
      IF (RADIUS(1) .LE. -1.E19) CALL BYEBYE
      CALL GETDAT ('Minimum, maximum valid data-value:', BAD, 2)
      IF (BAD(1) .EQ. -1.1E15) THEN
         CALL TBLANK
         BAD(2) = 1.E19
      END IF
      CALL GETYN ('Subtract?', YN)
      OFILE=SWITCH(IFILE, CASE('f'))
      I = LENGTH(OFILE)
      J = NINT(RADIUS(1))
      STRING = SQUEEZ(J, K)
      WRITE (OFILE(I+1:I+K),6) STRING(1:K)
    6 FORMAT (A)
      CALL GETNAM ('Output picture:', OFILE)
      IF (OFILE .EQ. 'END-OF-FILE') CALL BYEBYE
C
C Open output file.
C
      CALL COPPIC (OFILE, IER)
C
C Read data from input file, storing as REAL*4.
C
      LY = 1
      NY = NROW(1)
      CALL RDSECT (1, LY, NY, ORIG, MAXCOL, IER)
      CALL SMOOTH (ORIG, MAXCOL, RADIUS, BAD, YN, COPY)
      CALL CLPIC (2, IER)
      CALL CLPIC (1, IER)
      CALL BYEBYE
C
      END!
C
C#######################################################################
C
      SUBROUTINE SMOOTH (ORIG, MAXP, RADIUS, BAD, YN, COPY)
      include 'arrays.inc'
      PARAMETER (MAXR=100)
      CHARACTER LINE*5, YN*1
      REAL ORIG(MAXP,MAXP), COPY(MAXP), VECTOR(MAXR*MAXR)
      REAL BAD(2), RADIUS(2)
      INTEGER MAXP
      LOGICAL SUB
      IF (YN .EQ. 'Y') THEN
         SUB = .TRUE.
      ELSE
         SUB = .FALSE.
      END IF
      IRADIUS=MAX(1, INT(RADIUS(1)))
      JRADIUS=MIN(MAXR**2, INT(RADIUS(1)**2))
C
C Perform the smoothing.
C
C
C Outer double loop.
C
      CALL OVRWRT (' ', 1)
      DO 2900 JCEN=1,NROW(1)
      IF (MOD(JCEN,20) .EQ. 0) THEN
         WRITE (LINE,1) JCEN
    1    FORMAT (I5)
         CALL OVRWRT (LINE, 2)
      END IF
      IDY=MIN (IRADIUS, JCEN-1, NROW(1)-JCEN)
C
      DO 2890 ICEN=1,NCOL(1)
      IDX=MIN (IRADIUS, ICEN-1, NCOL(1)-ICEN)
c     IF ((ICEN .EQ. 20) .AND. (JCEN .EQ. 20)) THEN
c        PRINT *, ICEN, JCEN
c        DO J=JCEN-IDY,JCEN+IDY
c           PRINT 6661, (NINT(ORIG(I,J)), I=ICEN-IDX,ICEN+IDX)
c6661       FORMAT (1X, 13I6)
c        END DO
c     END IF
      N=0
C
C Central pixel.  If the central pixel is bad, the output pixel
C is bad.
C
      IF ((ORIG(ICEN,JCEN) .GE. BAD(1)) .AND.
     .     (ORIG(ICEN,JCEN) .LE. BAD(2))) THEN
         N=1
         VECTOR(N)=ORIG(ICEN,JCEN)
      ELSE
         IF (SUB) THEN
            COPY(ICEN) = 1.1E15
         ELSE
            COPY(ICEN) = 0.
         END IF
         GO TO 2890
      END IF
C
C Same row.
C
      IF (IDX .GT. 0) THEN
         DO 2480 I=1,IDX
            J=ICEN-I
            K=ICEN+I
            IF ((ORIG(J,JCEN) .GE. BAD(1)) .AND.
     .          (ORIG(J,JCEN) .LE. BAD(2)) .AND.
     .          (ORIG(K,JCEN) .GE. BAD(1)) .AND.
     .          (ORIG(K,JCEN) .LE. BAD(2))) THEN
               N=N+1
               VECTOR(N)=ORIG(J,JCEN)
               N=N+1
               VECTOR(N)=ORIG(K,JCEN)
            END IF
 2480    CONTINUE
      END IF
C
C The rest (if any).
C
      IF (IDY .GT. 0) THEN
         DO 2500 L=JCEN-IDY,JCEN-1
            M=JCEN+(JCEN-L)
C
C Same column.
C
            IF ((ORIG(ICEN,L) .GE. BAD(1)) .AND.
     .          (ORIG(ICEN,L) .LE. BAD(2)) .AND.
     .          (ORIG(ICEN,M) .GE. BAD(1)) .AND.
     .          (ORIG(ICEN,M) .LE. BAD(2))) THEN
               N=N+1
               VECTOR(N)=ORIG(ICEN,L)
               N=N+1
               VECTOR(N)=ORIG(ICEN,M)
            END IF
            IF (IDX .GT. 0) THEN
               DO 2490 I=1,IDX
                  IF ((JCEN-L)**2 + I**2 .GT. JRADIUS) GO TO 2490
                  J=ICEN-I
                  K=ICEN+I
                  IF ((ORIG(J,L) .GE. BAD(1)) .AND.
     .                (ORIG(J,L) .LE. BAD(2)) .AND.
     .                (ORIG(K,M) .GE. BAD(1)) .AND.
     .                (ORIG(K,M) .LE. BAD(2))) THEN
                     N=N+1
                     VECTOR(N)=ORIG(J,L)
                     N=N+1
                     VECTOR(N)=ORIG(K,M)
                  END IF
                  IF ((ORIG(J,M) .GE. BAD(1)) .AND.
     .                (ORIG(J,M) .LE. BAD(2)) .AND.
     .                (ORIG(K,L) .GE. BAD(1)) .AND.
     .                (ORIG(K,L) .LE. BAD(2))) THEN
                     N=N+1
                     VECTOR(N)=ORIG(J,M)
                     N=N+1
                     VECTOR(N)=ORIG(K,L)
                  END IF
 2490          CONTINUE
            END IF
 2500    CONTINUE
      END IF
c     IF ((ICEN .EQ. 20) .AND. (JCEN .EQ. 20)) THEN
c        PRINT *, 'SUB =', SUB
c        PRINT 6661, (NINT(VECTOR(I)), I=1,N)
c     END IF
      IF (N .LE. 0) THEN
         IF (SUB) THEN
            COPY(ICEN) = 1.E15
         ELSE
            COPY(ICEN) = 0.
         END IF
      ELSE
         M = MAX(1, MIN(N, NINT(RADIUS(2)*N)))
         IF (SUB) THEN
            COPY(ICEN) = ORIG(ICEN,JCEN) - PCTILE(VECTOR,N,M)
         ELSE
            COPY(ICEN) = PCTILE(VECTOR,N,M)
         END IF
      END IF
c     IF ((ICEN .EQ. 20) .AND. (JCEN .EQ. 20)) THEN
c        PRINT *, N, COPY(ICEN)
c        READ (5,*)
c     END IF
 2890 CONTINUE
      CALL WRROW (2, JCEN, COPY, IER)
 2900 CONTINUE
C
C End of outer double loop.
C
      CALL OVRWRT ('Done.          '//CHAR(7), 2)
      RETURN
      END!
