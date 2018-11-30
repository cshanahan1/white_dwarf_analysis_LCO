C
C=======================================================================
C
C Program to read in any of the data files created by DAOPHOT and
C find pairs of stars within a certain critical distance of each other,
C deleting the less certain.
C
C              OFFICIAL DAO VERSION:  1996 March 8
C
C=======================================================================
C
      PARAMETER  (MAXSTR=2 000 000)
C
C Parameters
C
C MAXSTR is the maximum number of stars permitted in a data file.
C
      CHARACTER*132 LINE(MAXSTR)
      REAL X(MAXSTR), Y(MAXSTR), MAG(MAXSTR), SIG(MAXSTR), RADIUS(2)
      INTEGER INDEX(MAXSTR), NLINE(MAXSTR)
      LOGICAL KEEP(MAXSTR)
C
      CHARACTER*132 HEAD
      CHARACTER*30 FILE, SWITCH, EXTEND
C
C-----------------------------------------------------------------------
C
C SECTION 1
C
C Get ready.
C
C Find out how the user wants to sort.
C
      CALL GETDAT ('Inner, outer radii:', RADIUS, 2)
      IF (RADIUS(1) .LT. 0.) CALL OOPS             ! CTRL-Z was entered
      RADSQI=RADIUS(1)**2
      RADSQO=RADIUS(2)**2
C
C Get input file name, open the file, and read its header.
C
      FILE=' '
 1000 CALL GETNAM ('Input file name:', FILE)
      IF (FILE .EQ. 'EXIT') CALL BYEBYE
      IF (FILE .EQ. 'END-OF-FILE') CALL OOPS        ! CTRL-Z was entered
C
      FILE = EXTEND (FILE, 'als')
      WRITE (6,6) FILE
    6 FORMAT (/A/)
      CALL INFILE (2, FILE, ISTAT)
      FILE = SWITCH(FILE, '.str')
      CALL OUTFIL (3, FILE, ISTAT)
      FILE = SWITCH(FILE, '.jnk')
      CALL OUTFIL (1, FILE, ISTAT)
C
      CALL RDCHAR (2, HEAD, N, ISTAT)
      IF (HEAD(1:4) .EQ. ' NL ') THEN
         WRITE (3, 320) HEAD(1:N)
  320    FORMAT (A)
         WRITE (1, 320) HEAD(1:N)
         CALL RDCHAR (2, HEAD, N, ISTAT)
         READ (HEAD,*) NL
         WRITE (3,320) HEAD(1:N)
         WRITE (1,320) HEAD(1:N)
         READ (2,*)
         WRITE (3,*)
         WRITE (1,*)
      ELSE
         REWIND (2)
         NL=1
      END IF
C
C-----------------------------------------------------------------------
C
C SECTION 2
C
C Read the input file in line by line, verbatim.  Extract the datum 
C according to which we wish to sort.  Sort these data.  Then write 
C the file out again, line by line, verbatim, but in the new order.
C
      I=0
 2000 I=I+1                                    ! Begin loop over stars
      IF (I .GT. MAXSTR) GO TO 2100
C
 2010 CALL RDCHAR (2, LINE(I), NLINE(I), ISTAT)
      IF (ISTAT .GT. 0) GO TO 2100
      IF (ISTAT .LT. 0) GO TO 2010
      IF (NLINE(I) .LE. 6) GO TO 2010         ! Blank line encountered
      IF (NL .EQ. 2) READ (2,*)
      READ (LINE(I),*,ERR=2010) J, X(I), Y(I), MAG(I), SIG(I)
      KEEP(I) = .TRUE.
      GO TO 2000
C
C Perform the sort.
C
 2100 NSTAR=I-1                                      ! Number of stars
      PRINT 6661, NSTAR
 6661 FORMAT (/I8, ' read.')
      NKEPT = 0
      CALL CLFILE (2)
      IF (NSTAR .LE. 0) THEN
         CALL CLFILE (2)
         CALL CLFILE (1)
         FILE='EXIT'
         GO TO 1000
      END IF
      CALL QUICK (Y, NSTAR, INDEX)
      DO 2600 I=1,NSTAR-1
         K = INDEX(I)
         DO 2400 J=I+1,NSTAR
            L = INDEX(J)
            DY = (Y(J)-Y(I))**2
            IF (DY .GT. RADSQO) GO TO 2500
            DY = DY+(X(L)-X(K))**2
            IF (DY .LT. RADSQO) THEN
               IF (DY .LT. RADSQI) THEN
                  KEEP(I) = .FALSE.
                  KEEP(J) = .FALSE.
               ELSE
                  IF (SIG(K) .LT. SIG(L)) THEN
                     KEEP(J) = .FALSE.
                  ELSE
                     KEEP(I) = .FALSE.
                  END IF
               END IF
            END IF
 2400    CONTINUE
 2500    IF (KEEP(I)) THEN
            NKEPT = NKEPT+1
            WRITE (3,320) LINE(K)(1:NLINE(K))
         ELSE
            WRITE (1,320) LINE(K)(1:NLINE(K))
         END IF
 2600 CONTINUE
      K = INDEX(NSTAR)
      IF (KEEP(K)) THEN
         NKEPT = NKEPT+1
         WRITE (3,320) LINE(K)(1:NLINE(K))
      END IF
      PRINT 6662, NKEPT
 6662 FORMAT (I8, ' kept.')
      CALL CLFILE (3)
      CALL CLFILE (1)
      FILE = 'EXIT'
      GO TO 1000
      END!
