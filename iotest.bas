.elfos
.binary
.options
10  REM Test I/O functions in 1802 BASIC/2 compiler. Nov 21, 2021
20  buffer_size = 16
30  buffer_ptr  = alloc(buffer_size)
40  for i = 0 to (buffer_size-1)   
50  poke buffer_ptr+i,i+1
66  next i
70  x1=1:y1=5:z1=25
80  print "I/O test 1.5 started"
90  print "1 Open for Input"
100 print "2 Open for Output"
110 print "3 Open for Append"
120 print "4 Close"
130 print "5 Put to file"
140 print "6 Get from file"
150 print "7 FREAD"
160 print "8 FWRITE
170 print "9 Delete test file "
175 print "10 Terminate program"
180 print "File position=";POS(1)   
190 input "command",c
195 on c gosub 1100,1200,1300,1400,1500,1600,1700,1800,1900,2000
300 print
310 goto 90

1100 open "iotest.dat"   for input as #1
1110 print "OPEN/I ioflag=";ioflag; "  ioresult=";ioresult
1120 return

1200 open "iotest.dat"   for output as #1
1210 print "OPEN/O ioflag=";ioflag; "  ioresult=";ioresult
1220 return

1300 open "iotest.dat"   for append as #1
1310 print "OPEN/A ioflag=";ioflag; "  ioresult=";ioresult
1320 return

1400 close #1
1410 print "CLOSE ioflag=";ioflag; "  ioresult=";ioresult
1420 return

1500 put #1 x1,y1,z1
1510 print "PUT    ioflag=";ioflag; "  ioresult=";ioresult
1520 return

1600 get #1 x2,y2,z2
1610 print "GET    ioflag=";ioflag; "  ioresult=";ioresult
1620 print x2,y2,z2
1630 if EOF(1) print "**End of file detected**""
1640 return

1700 fread #1 buffer_ptr,buffer_size
1710 print "FREAD  ioflag=";ioflag; "  ioresult=";ioresult
1720 for i=0 to buffer_size-1
1730 print peek(buffer_ptr+i)
1740 next i
1750 if EOF(1) print "**End of file detected**"
1760 return

1800 fwrite #1 buffer_ptr,buffer_size
1810 print "FWRITE ioflag=";ioflag; "  ioresult=";ioresult
1830 return

1900 delete "iotest.dat"
1910 print "DELETE ioflag=";ioflag; " ioresult=";ioresult
1920 return

2000 dealloc(buffer_ptr)
2020 print "All done. bye bye"
2030 end
