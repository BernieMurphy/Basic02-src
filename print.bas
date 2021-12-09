.binary
.options
.elfos
10  REM Basic/02 terminal I/O string routines. November 30, 2021

20  buffer_size = 64
30  buffer_ptr  = alloc(buffer_size)
40  for i = 0 to (buffer_size-2)   
50  poke buffer_ptr+i,i+64         : REM place ascii table in buffer
60  next i    
70  end_ptr=buffer_ptr+buffer_size-1 : REM now set last_ptr to end of buffer
80  poke end_ptr,0                : REM place binary zero at end of buffer

90  print "Starting print/read test version 1.5"

120 for char = 64 to 127           : REM print out ASCII characters 1 at a time
140 gosub 9200                     : REM call PRINT_CHAR       
150 next char
160 print

190 gosub 9300                     : REM call PRINT_MSG using buffer_ptr
200 print


220 print "Input test message?";   : REM issue prompt
225 gosub 9500                     : REM turn local echo on
230 gosub 9400                     : REM call READ_MSG
250 gosub 9300                     : REM call PRINT_MSG
260 print

300 print "Test character?";       : REM issue prompt
305 gosub 9600                     : REM turn local echo off
310 gosub 9100                     : REM call READ_CHAR
340 gosub 9200                     : REM call PRINT_CHAR
350 print                          : REM output CR,LF
355 if char = 64 goto 400 
360 goto 300

400 print
420 dealloc(buffer_ptr)            : REM deallocate buffer
439 gosub 9500                     : REM turn local echo back on
450 print "All done. bye bye"
500 goto 9900

9100 REM READ_CHAR - read on character from terminal
9110    asm
f_read: equ    0ff06h              ; f_read vector
        sep    r4                  ; read a single character from terminal
        dw     f_read
        plo    re
        ldi    v_char.1             ; point to character variable
        phi    rf
        ldi    v_char.0
        plo    rf                   ; now pointing to msb of char
        inc    rf                   ; point to lsb of char variable
        glo    re                   ; retrieve read character             
        str    rf                   ; and store in lsb of char variable
        end
9120 return




9200 REM PRINT_CHAR - print 1 character to terminal
9210    asm 
        ldi    v_char.1            ; point to character variable
        phi    rf
        ldi    v_char.0
        plo    rf                  ; now pointing to msb of char
        inc    rf                  ; point to lsb byte of 16 bit  word
        ldn    rf                  ; get character into d
        sep    r4                  ; call f_type routine
        dw   f_type
        end
9220 return

9300 REM PRINT_MSG - print asciiz string to terminal
9310    asm
        ldi    v_buffer_ptr.1     ; point to buffer pointer msb
        phi    rf
        ldi    v_buffer_ptr.0     ; point to buffer pointer lsb
        plo    rf                 ; now rf has address of ptrprin
        inc    rf                 ; now point to lsb of pointer 
        ldn    rf                 ; now load lsb of pointer
        plo    re                 ; re.0 now pointing lsb  buffer address
        dec    rf                 ; rf now points to msb of pointer
        ldn    rf                 ; d = msb of pointer
        phi    rf                 ; save msb of buffer pointer
        glo    re                 ; d = lsb of pointer
        plo    rf                 ; save lsb of pointer 
        sep    r4                 ; call f_msg to output asciiz string
        dw     f_msg
        end
9320 return

9400 REM READ_MSG - read string from terminal
9410    asm
        ldi    v_buffer_ptr.1     ; point to buffer pointer msb
        phi    rf
        ldi    v_buffer_ptr.0     ; point to buffer pointer lsb
        plo    rf                 ; now rf has address of ptr
        inc    rf                 ; now point to lsb of pointer 
        ldn    rf                 ; now load lsb of pointer
        plo    re                 ; re.0 now pointing lsb  buffer address
        dec    rf                 ; rf now points to msb of pointer
        ldn    rf                 ; d = msb of pointer
        phi    rf                 ; save msb of buffer pointer
        glo    re                 ; d = lsb of pointer
        plo    rf                 ; save lsb of pointer 
        sep    r4                 ; call f_input to read ascii string
        dw     f_input            ; call BIOS input routine
        end 
9440 return

9500 REM Echo_ON
9510    asm
        ghi    re                 ; get baud constant
        ori    1                  ; turn echo bit on
        phi    re                 ; update baud constant
        end
9520 return

9600 REM Echo_OFF
9610    asm
        ghi    re                 ; get baud constant
        ani    0feH               ; turn echo bit off
        phi    re                 ; update baud constant
        end
9620 return


9800 data 0                       : REM keep compiler happy
9900 end
