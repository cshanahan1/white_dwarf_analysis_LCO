      character text*9, rndoff*9
 1000 read (5,*,end=9000) x
      text = rndoff (x, 9, 3)
      print *, '"',text,'"'
      print*
      go to 1000
 9000 stop
      end
