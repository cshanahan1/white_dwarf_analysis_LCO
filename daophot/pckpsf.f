      SUBROUTINE  PCKPSF  (ID, X, Y, M, S, INDEX, D, HOLD, MAXN, 
     .     FITRAD, PSFRAD, VARY)
C
C=======================================================================
C
C Subroutine to read in any of the data files created by DAOPHOT and
C to select reasonable candidates for PSF stars:
C
C   (1) More than a critical distance from the edge of the frame, and
C   (2) Having no brighter star within a critical distance.
C
C              OFFICIAL DAO VERSION:  2001 October 19
C
C=======================================================================
C
      IMPLICIT NONE
      INTEGER MAXN
C
C MAXN is the maximum number of stars permitted in a data file.
C
      REAL X(MAXN), Y(MAXN), M(MAXN), S(MAXN), D(MAXN), HOLD(MAXN)
      INTEGER ID(MAXN), INDEX(MAXN)
C
      REAL ABS, PCTILE
C
      CHARACTER COOFIL*40, MAGFIL*40, PSFFIL*40, PROFIL*40, GRPFIL*40, 
     .     SWITCH*40, FILE*40, CASE*4, LINE*132
      REAL PSFRAD, FITRAD, RADSQ, DY, RADIUS, LOBAD, HIBAD, THRESH
      REAL AP1, PHPADU, READNS, FRAD, XYMIN, XMAX, YMAX, MAGLIM
      REAL VARY, DBAR
      INTEGER I, J, N, NREQ, ISTAR, JSTAR, ISTAT, NL, NCOL, NROW
      INTEGER ITEMS, NSTAR, NVARY, NMIN, NHOLD
      LOGICAL SHARP
C
      COMMON /FILNAM/ COOFIL, MAGFIL, PSFFIL, PROFIL, GRPFIL
C
C-----------------------------------------------------------------------
C
C SECTION 1
C
C Get input file name, open the file, and read its header.
C
      SHARP = .TRUE.
      NVARY = NINT(VARY)
      NVARY = (NVARY+2)*(NVARY+1)/2
      NMIN = MAX(1,NVARY)
      CALL TBLANK
      CALL GETNAM ('Input file name:', MAGFIL)
      IF ((MAGFIL .EQ. 'END-OF-FILE') .OR. 
     .     (MAGFIL .EQ. 'EXIT')) THEN
         MAGFIL = ' '
         RETURN
      END IF
C
      CALL INFILE (2, MAGFIL, ISTAT)
      IF (ISTAT .NE. 0) THEN
         CALL STUPID ('Error opening input file '//MAGFIL)
         RETURN
      END IF
C
      CALL GETDAT ('Desired number of stars, faintest magnitude:', X, 2)
      IF (X(1) .LE. 0.5) THEN
         CALL CLFILE (2)
         RETURN
      END IF
      NREQ = NINT(X(1))
      MAGLIM = AMIN1(X(2), 90.)
C
C Generate output file name and open the file.
C
      FILE = SWITCH (MAGFIL, CASE('.lst'))
      CALL GETNAM ('Output file name:', FILE)
      CALL OUTFIL (3, FILE, ISTAT)
      IF (ISTAT .NE. 0) THEN
         CALL STUPID ('Error opening output file '//FILE)
         CALL CLFILE (2)
         RETURN
      END IF
C
      NL = 0
      CALL RDHEAD (2, NL, NCOL, NROW, LOBAD, HIBAD, THRESH, AP1,
     .     PHPADU, READNS, FRAD)
      IF (NL .EQ. 0) NL = 1
      IF (NL .GT. 3) NL = 1
C
C Copy input file header to output file.
C
      ITEMS = 6
      IF (FRAD .GT. 0.) ITEMS = 7
      CALL WRHEAD (3, 3, NCOL, NROW, ITEMS, LOBAD, HIBAD, THRESH,
     .     AP1, PHPADU, READNS, FRAD)
      XYMIN = FITRAD + 1.
      XMAX = REAL(NCOL) - FITRAD
      YMAX = REAL(NROW) - FITRAD
      RADIUS = PSFRAD
      RADSQ = RADIUS**2
C
C-----------------------------------------------------------------------
C
C SECTION 2
C
C Read the input file in star by star.
C
      NHOLD = 0
      I=0
 2000 I=I+1
C
 2010 CONTINUE
      IF (NL .EQ. 2) THEN
         READ (2,202,END=2100)
         CALL RDCHAR (2, LINE, N, ISTAT)
         READ (LINE,201,IOSTAT=J) ID(I), X(I), Y(I), M(I), D(I)
  201    FORMAT (I7, 4F9.3)
         IF (D(I) .LE. 0.001) THEN
            SHARP = .FALSE.
         ELSE
            D(I) = M(I) - D(I)
            IF (D(I) .LT. 0.) THEN
               READ (2,*)
               GO TO 2010
            END IF
         END IF
         READ (2,202) S(I)
  202    FORMAT (26X, F8.4)
      ELSE
         READ (2,321,END=2100) ID(I), X(I), Y(I), M(I), S(I)
      END IF
      IF (ID(I) .EQ. 0) GO TO 2010
      IF (M(I) .LT. 90.) THEN
         IF ((M(I) .LE. MAGLIM) .AND. (D(I) .GT. -50.)) THEN
            NHOLD = NHOLD+1
            HOLD(NHOLD) = D(I)
         END IF
      ELSE IF (M(I) .GT. 99.5) THEN
         M(I) = -M(I)
      END IF
      IF (I .LT. MAXN) GO TO 2000
C
      CALL STUPID ('*** WARNING ***  Too many stars in input file.')
      WRITE (6,6) MAXN
    6 FORMAT (I10, ' stars have been read.  I will work with these.')
      I = I+1
C
C Perform the selection.
C
 2100 NSTAR=I-1
      CLOSE (2)
C
C If we are selecting against galaxies, determine the median delta mag.
C
      IF (NHOLD .LE. NVARY) SHARP = .FALSE.
      IF (SHARP) THEN
         DBAR = PCTILE (HOLD, NHOLD, NINT(0.4*NHOLD))
      ELSE
         DBAR = 99.
      END IF
      CALL QUICK (M, NSTAR, INDEX)
      I = INDEX(1)
      IF ((M(1) .GT. -90.) .AND. (X(I) .GE. XYMIN) .AND.
     .     (Y(I) .GE. XYMIN) .AND. (X(I) .LE. XMAX) .AND.
     .     (Y(I) .LE. YMAX) .AND. (D(I) .LT. DBAR+3.*S(I))) THEN
         IF (S(I) .LT. 9999.999) THEN
            WRITE (3,321) ID(I), X(I), Y(I), M(1), S(I), D(I)
c  321       FORMAT (I7, 5F9.3)
  321       FORMAT (I7, 5F10.3)
         ELSE
            WRITE (3,322) ID(I), X(I), Y(I), M(1), S(I), D(I)
  322       FORMAT (I7, 3F9.3, F9.2, F9.3)
         END IF
         N = 1
         IF (N .GE. NREQ) GO TO 2200
      ELSE
         N = 0
      END IF
C
      DO 2195 ISTAR=2,NSTAR
         I = INDEX(ISTAR)
         IF ( (M(ISTAR) .LT. -90.) .OR. (X(I) .LT. XYMIN) .OR.
     .         (Y(I) .LT. XYMIN) .OR. (X(I) .GT. XMAX) .OR.
     .         (Y(I) .GT. YMAX) .OR. (D(I) .GT. DBAR+3.*S(I)) .OR.
     .         ((M(ISTAR) .GE. MAGLIM) .AND. (N .GE. NMIN))
     .         ) GO TO 2195
C
         DO 2190 JSTAR=1,ISTAR-1
            J = INDEX(JSTAR)
            DY = ABS(Y(J)-Y(I))
            IF (DY .GE. RADIUS) GO TO 2190
            DY = DY**2 + (X(J)-X(I))**2
            IF (DY .LT. RADSQ) GO TO 2195
 2190    CONTINUE
C
         IF (S(I) .LT. 9999.999) THEN
            WRITE (3,321) ID(I), X(I), Y(I), M(ISTAR), S(I), D(I)
         ELSE
            WRITE (3,322) ID(I), X(I), Y(I), M(ISTAR), S(I), D(I)
         END IF
         N = N+1
         IF (N .GE. NREQ) GO TO 2200
 2195 CONTINUE
C
 2200 CLOSE (3)
      IF (N .EQ. 1) THEN
         WRITE (6,8) N
    8    FORMAT (/I10, ' suitable candidate was found.'/)
      ELSE
         WRITE (6,7) N
    7    FORMAT (/I10, ' suitable candidates were found.'/)
      END IF
      RETURN
C
      END
