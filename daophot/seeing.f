      PARAMETER (MAX=5000)
      CHARACTER*113 LINE(MAX)
      CHARACTER*30 FILE(MAX), SWITCH, NAME, EXTEND
      REAL S(MAX), G(MAX), SEEING(MAX)
      INTEGER INDEX(MAX)
      LOGICAL LOOP
C
      CALL GETARG (1, FILE(1))
      IF (FILE(1) .NE. ' ') THEN
         LOOP = .FALSE.
         GO TO 900
      END IF
      LOOP = .TRUE.
C
  800 CALL TBLANK
      CALL GETNAM ('Input .mch file:', FILE(1))
      IF ((FILE(1) .EQ. 'END-OF-FILE') .OR.
     .     (FILE(1) .EQ. 'EXIT')) CALL BYEBYE
  900 FILE(1) = EXTEND(FILE(1), 'mch')
      CALL INFILE (1, FILE(1), ISTAT)
      FILE(1) = SWITCH(FILE(1), '.see')
      CALL OUTFIL (3, FILE(1), ISTAT)
      CALL TBLANK
      N = 0
 1000 N = N+1
 1010 READ (1,100,END=2000) LINE(N)
  100 FORMAT (A)
      READ (LINE(N),*) NAME, A, B, C, D, E, F, G(N)
      NAME = SWITCH(NAME, '.psf')
      CALL INFILE (2, NAME, ISTAT)
      IF (ISTAT .NE. 0) THEN
         CALL STUPID ('Unable to open '//NAME)
         CALL TBLANK
         GO TO 1010
      END IF
      READ (2,*)
      READ (2,*) PAR1, PAR2
      CALL CLFILE (2)
C
C Image scale in arcsec per pixel
C
      S(N) = SQRT(ABS(C*F) + ABS(D*E))
C
C PAR1 and PAR2 are HWWM in pixels
C
      SEEING(N) = S(N) * (PAR1 + PAR2)
      FILE(N) = SWITCH(NAME, ' ')
      WRITE (LINE(1),4) N, SWITCH(NAME,' '), SEEING(N), 
     .     S(N), G(N)
    4 FORMAT (I7, 2X, A26, 3F8.3)
      WRITE (6,100) LINE(1)(1:67)
      GO TO 1000
 2000 N = N-1
      CALL QUICK (SEEING, N, INDEX)
      CALL TBLANK
      DO I=1,N
         J = INDEX(I)
         WRITE (3,2) SEEING(I), FILE(J), S(J), G(J)
    2    FORMAT (F7.3, 2X, A26, 2F7.3)
      END DO
      WRITE (6,3) 'Best: ', SEEING(1), '    Median: ', 
     .     0.5*(SEEING(N/2+1) + SEEING((N+1)/2)), '    Worst: ',
     .     SEEING(N)
    3 FORMAT (/A, F6.3, A, F6.3, A, F6.3)
      CALL CLFILE (1)
      CALL CLFILE (3)
      IF (LOOP) THEN
         FILE(1) = 'EXIT'
         GO TO 800
      END IF
C
      CALL BYEBYE
      END!
