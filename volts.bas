10 REM CONVERT VOLTS TO POWER IN WATTS FOR ANY LOAD
20 REM WRITTEN BY B. MURPHY FEB 17, 2020
25 REM MODIFIED FOR 1802 Basic compiler JUN 25, 2021
30 PRINT "RMS VOLTS VS PEAK VOLTS VS POWER CALCULATOR V1.0"
35 PRINT            
40 INPUT "ENTER IMPEDANCE IN OHMS ",Z! 
60 INPUT "ENTER RMS VOLTAGE START RANGE ",S!
80 INPUT "ENTER RMS VOLTAGE END RANGE ",E!
100 INPUT "ENTER RMS VOLTAGE INCREMENT ",I!
120 PRINT                                                                     
130 LET V!=S!                                                                   
140 LET P!=V!*V!/Z!
150 LET K!=V!*2.*1.414
160 PRINT "RMS VOLTS ",V!,"  PP VOLTS ",K!," POWER ",P!," WATTS"
170 LET V!=V!+I!
180 IF V!<=E! GOTO 140
190 PRINT                                                                     
200 INPUT "ANOTHER RUN?  ENTER 1 FOR YES ",R
220 IF R = 1 GOTO 30
230 PRINT                                                                     
240 PRINT "ALL DONE. BYE BYE"                                                 
250 END
