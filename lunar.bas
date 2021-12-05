10 REM Lunar Lander
20 REM DO
25 REM B = burn rate, F = fuel, H = height, V = velocity T = time
30 PRINT "Beginning lunar landing Program 69"
40 PRINT
60 PRINT
70 B = 0
80 F = 150
90 H = 1000
110 T = 0
120 V = 50
140 REM DO
150 PRINT "Sec", T, " Feet", H, " Speed", V, " Fuel", F
160 INPUT "Units",B
180 IF B >= 0 GOTO 220
190 PRINT
200 PRINT "Landing aborted"
210 END
220 REM END IF
230 IF B > 30 B = 30
240 IF B > F B = F
250 REM DO
260 W = V - B + 5
270 F = F - B
280 H = H - (V + W) / 2
290 IF H <= 0 GOTO 380
300 T = T + 1
310 V = W
320 IF F > 0 GOTO 380
330 IF B > 0 PRINT "**** Out of fuel ****"
340 PRINT "Sec", T, " Feet", H, " Speed", V, " Fuel", F
350 B = 0
360 GOSUB 900
370 GOTO 250
380 REM LOOP
390 IF H > 0 GOTO 140
400 REM LOOP
410 PRINT "***** Lunar contact *****"
420 GOSUB 900
430 H = H + (W + V) / 2
440 IF B = 5 GOTO 490
450 N = V * V + H * (10 - 2 * B)
460 S =SQRT(N) 
470 D = (S - V) / (5 - B)
480 GOTO 510
490 REM ELSE
500 IF V> 0 D = H / V
510 REM RUNEND IF
520 W = V + (5 - B) * D
530 PRINT "Touchdown at", T + D, "seconds."
540 PRINT "Landing velocity", W, "feet/sec."
550 PRINT F, "units of fuel remaining."
560 GOSUB 900
570 IF W <> 0 GOTO 600
580 PRINT "Congratulations! A perfect landing!!"
590 PRINT "Your license will be renewed.......later."
600 REM END IF
610 IF W <= 2 GOTO 640
620 PRINT "           Sorry  but you blew it          "
630 PRINT "Appropriate condolences will be sent to your next of kin."
640 REM END IF
650 PRINT
660 GOSUB 900
670 N = 0
680 INPUT "Another mission? Enter 1 or 0",N
700 PRINT
710 IF N = 1 GOTO 20
720 REM LOOP
730 PRINT "Control over and out."
740 GOTO 950
900 REM DELAY
910 A = 1
920 A = A + 1   
930 IF A < 10 GOTO 920
940 RETURN
950 END
