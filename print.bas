.binary
.options
.elfos
10  REM Basic/02 terminal I/O string routines. December 31, 2021
15  debug = 1
20  buffer_size = 64
30  buffer_ptr  = alloc(buffer_size)
40  for i = 0 to (buffer_size-2)   
50  poke buffer_ptr+i,i+64        : REM place ascii table in buffer
60  next i    
70  ptr=buffer_ptr+buffer_size-1  : REM set ptr to end of buffer
80  poke ptr,0

90  print "Print/read test version 1.8",buffer_ptr,ptr

120 for char = 64 to 127          : REM print out ASCII characters 1 at a time
140 gosub 9200                    : REM call PRINT_CHAR       
150 next char
160 print

190 gosub 9300                     : REM call PRINT_MSG using buffer_ptr
200 print

220 print "Input test message?";   : REM issue prompt
225 gosub 9500                     : REM turn local echo on
230 gosub 9400                     : REM call READ_MSG
240 print
250 gosub 9300                     : REM call PRINT_MSG
260 print

300 print "Use @ to quit. Input test character?";
305 gosub 9600                     : REM turn local echo off
310 gosub 9100                     : REM call READ_CHAR
330 if char = 64 goto 400          : REM if character is @ we exit
340 gosub 9200                     : REM call PRINT_CHAR
345 print
350 goto 300

400 print
420 gosub 9500                      : REM turn local echo on
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
        inc    rf                   ; point to lsb byte of 16 bit word
#ifdef  use32bits
        inc    rf                   ; for 32 bit word we need 
        inc    rf                   ; to skip over 2 more bytes
#endif
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
#ifdef  use32bits
        inc    rf                   ; for 32 bit word we need 
        inc    rf                   ; to skip over 2 more bytes
#endif
        ldn    rf                  ; get character into d
        sep    r4                  ; call f_type routine
        dw   f_type
        end
9220 return

9300 REM PRINT_MSG - print asciiz string to terminal
9310    asm
        ldi    v_buffer_ptr.1     ; point to buffer pointer msb
        phi    rd
        ldi    v_buffer_ptr.0     ; point to buffer pointer lsb
        plo    rd                 ; now rf has address of ptrprin
        inc    rd                 ; now point to lsb of 16 bit pointer
#ifdef  use32bits
        inc    rd                   ; for 32 bit word we need 
        inc    rd                   ; to skip over 2 more bytes
#endif
        ldn    rd                 ; now load lsb of pointer
        plo    rf                 ; re.0 now pointing lsb  buffer address
        dec    rd                 ; rf now points to msb of pointer
        ldn    rd                 ; d = msb of pointer
        phi    rf                 ; save msb of buffer pointer
        sep    scall              ; call f_msg to output asciiz string
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
#ifdef  use32bits
        ldi    0
        str    rf
        inc    rf                   ; for 32 bit word we need
        str    rf 
        inc    rf                   ; to skip over 2 more bytes
#endif
        ldn    rf                 ; now load lsb of pointer
        plo    re                 ; re.0 now pointing first buffer address
        dec    rf                 ; rf now points to second byte of pointer 
        ldn    rf                 ; d = second byte of pointer
        phi    rf                 ; save second  byte of buffer pointer
        glo    re
        plo    rf      
        sep   scall               ; call f_input to read ascii string
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
