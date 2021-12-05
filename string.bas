.binary
.options
.elfos
10  REM Basic/02 terminal I/O string routines. November 30, 2021
20  print "Starting print/read/string test version 1.3"
25  cmpresult = 2                   : REM string compare result 0=equal
27  input_char = 0: output_char = 0 : REM input & output I/O routines

30  gosub 1000                     : REM allocate and initialize buffer_1
40  gosub 1200                     : REM allocate and initialize buffer_2
42  gosub 1300                     : REM allocate terminal input  buffer 
44  gosub 1400                     : REM allocate terminal output buffer

50  gosub 9700                     : REM compare the two buffers
60  if cmpresult = 0   print "strings are equal"
70  if cmpresult = 1   print "string 1 is greater than string 2"
80  if cmpresult = 255 print "string 1 is less than string 2"



120 for output_char = 64 to 127    : REM print out ASCII characters 1 at a time
140 gosub 9200                     : REM call PRINT_CHAR       
150 next output_char
160 print


200 print
205 gosub 9800                     : REM copy string 1 on top of string 2
210 out_buffer_ptr= buffer2_ptr+32   : REM point to ASCII character 
215 gosub 9300                     : REM call PRINT_MSG
218 print

220 print "Input test message?";   : REM issue prompt
225 gosub 9500                     : REM turn local echo on
230 gosub 9400                     : REM call READ_MSG
235 print
240 out_buffer_ptr = inp_buffer_ptr
250 gosub 9300                     : REM call PRINT_MSG
260 print

300 print "Test character?";       : REM issue prompt
305 gosub 9600                     : REM turn local echo off
310 gosub 9100: output_char = input_char                             
340 gosub 9200                     : REM call PRINT_CHAR
350 print                          : REM output CR,LF
355 if input_char = 64 goto 400 
360 goto 300

400 print
420 dealloc(buffer1_ptr )          : REM deallocate buffer
439 gosub 9500                     : REM turn local echo back on
450 print "All done. bye bye"
500 goto 11000




1000  REM initialize buffer 1 with with 0-255
1010  buffer1_size = 256
1020  buffer1_ptr   = alloc(buffer1_size)
1030  for i = 0 to (buffer1_size-2)   
1040  poke buffer1_ptr +i,i           : REM place ascii table in buffer
1050  next i    
1060  last_ptr=buffer1_ptr +buffer1_size-1 : REM set end_ptr to send of buffer
1070  poke last_ptr,0              : REM place binary zero at end of buffer
1080  return


1200  REM initialize buffer 2 with 0-255       
1210  buffer2_size = 256 
1220  buffer2_ptr   = alloc(buffer2_size)
1230  for i = 0 to (buffer1_size-2)   
1240  poke buffer2_ptr +i,i           : REM characters in buffer2
1250  next i    
1260  last_ptr=buffer2_ptr +buffer2_size-1 : REM now set last_ptr to end of buffer
1270  poke last_ptr,0                : REM place binary zero at end of buffer
1280  return

1300  REM get buffer for teminal input routines
1310  inp_buffer_size = 256
1320  inp_buffer_size  = alloc(inp_buffer_size)
1340  return

1400  REM get buffer for teminal outputroutines
1410  out_buffer_size = 256
1420  out_buffer_ptr  = alloc(out_buffer_size)
1440  return

9100 REM READ_CHAR - read on character from terminal
9110    asm
f_read: equ    0ff06h              ; f_read vector
        sep    r4                  ; read a single character from terminal
        dw     f_read
        plo    re
        ldi    v_input_char.1       ; point to character variable
        phi    rf
        ldi    v_input_char.0
        plo    rf                   ; now pointing to msb of char
        inc    rf                   ; point to lsb of char variable
        glo    re                   ; retrieve read character             
        str    rf                   ; and store in lsb of char variable
        end
9120 return




9200 REM PRINT_CHAR - print 1 character to terminal
9210    asm 
        ldi    v_output_char.1     ; point to character variable
        phi    rf
        ldi    v_output_char.0
        plo    rf                  ; now pointing to msb of char
        inc    rf                  ; point to lsb byte of 16 bit  word
        ldn    rf                  ; get character into d
        sep    r4                  ; call f_type routine
        dw   f_type
        end
9220 return


9300 REM PRINT_MSG - print asciiz string to terminal
9310    asm
        ldi    v_out_buffer_ptr.1     ; point to buffer pointer msb
        phi    rf
        ldi    v_out_buffer_ptr.0     ; point to buffer pointer lsb
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
; Input   rf = string_1 pointer   
; Output: inputed characters in string_1
;         DF= 0 Input finished with CR
;         DF= 1 Input finished with <CNTL>C
;
        ldi    v_inp_buffer_ptr.1    ; point to buffer pointer msb
        phi    rf
        ldi    v_inp_buffer_ptr.0    ; point to buffer pointer lsb
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

9700 REM STRCMP
9710    asm
; Input rf = string_1 pointer
;       rd = string_2 pointer
; Output: string_1 = string_2 D=00
;         string_1 > string_2 D=01
;         string_1 < string_2 D=ff
;
f_strcmp: equ  0ff12h
        ldi    v_buffer1_ptr.1     ; point to buffer pointer msb
        phi    rf
        ldi    v_buffer1_ptr.0     ; point to buffer pointer lsb
        plo    rf                 ; now rf has address of ptr
        inc    rf                 ; now point to lsb of pointer 
        ldn    rf                 ; now load lsb of pointer
        plo    re                 ; re.0 now pointing lsb  buffer address
        dec    rf                 ; rf now points to msb of pointer
        ldn    rf                 ; d = msb of pointer
        phi    rf                 ; save msb of buffer 1 pointer
        glo    re                 ; d = lsb of pointer
        plo    rf                 ; save lsb of pointer
        ldi    v_buffer2_ptr.1     ; point to buffer 2 pointer msb
        phi    rd
        ldi    v_buffer2_ptr.0     ; point to buffer pointer lsb
        plo    rd                 ; now rf has address of ptr
        inc    rd                 ; now point to lsb of pointer 
        ldn    rd                 ; now load lsb of pointer
        plo    re                 ; re.0 now pointing lsb  buffer address
        dec    rd                 ; rf now points to msb of pointer
        ldn    rd                 ; d = msb of pointer
        phi    rd                 ; save msb of buffer pointer
        glo    re                 ; d = lsb of pointer
        plo    rd                 ; save lsb of pointer
        sep    r4
        dw     f_strcmp           ; BIOS string compare call
        plo    re
        ldi    v_cmpresult.1      ; point to result variable
        phi    rf
        ldi    v_cmpresult.0
        plo    rf                 ; now pointing to msb of cmpresult variable
        inc    rf                 ; point to lsb of cmpresult variable
        glo    re                 ; retrieve f_strcmp result value              
        str    rf                 ; and store in lsb of cmpresult variable
        end
9720  return


9800 REM STRCPY
9810    asm
; Input rf = string_1 pointer  source string with binary zero termination
;       rd = string_2 pointer  target string
; Output: None
;
f_strcpy: equ  0ff18h
        ldi    v_buffer1_ptr.1    ; point to buffer pointer msb
        phi    rf
        ldi    v_buffer1_ptr.0    ; point to buffer pointer lsb
        plo    rf                 ; now rf has address of ptr
        inc    rf                 ; now point to lsb of pointer 
        ldn    rf                 ; now load lsb of pointer
        plo    re                 ; re.0 now pointing lsb  buffer address
        dec    rf                 ; rf now points to msb of pointer
        ldn    rf                 ; d = msb of pointer
        phi    rf                 ; save msb of buffer 1 pointer
        glo    re                 ; d = lsb of pointer
        plo    rf                 ; save lsb of pointer
        ldi    v_buffer2_ptr.1    ; point to buffer 2 pointer msb
        phi    rd
        ldi    v_buffer2_ptr.0     ; point to buffer pointer lsb
        plo    rd                 ; now rf has address of ptr
        inc    rd                 ; now point to lsb of pointer 
        ldn    rd                 ; now load lsb of pointer
        plo    re                 ; re.0 now pointing lsb  buffer 2 address
        dec    rd                 ; rf now points to msb of pointer
        ldn    rd                 ; d = msb of pointer
        phi    rd                 ; save msb of buffer pointer
        glo    re                 ; d = lsb of pointer
        plo    rd                 ; save lsb of pointer
        sep    r4
        dw     f_strcpy           ; BIOS string copy call
        end
9820  return



10000 data 0                      : REM keep compiler happy
11000 dealloc(buffer1_ptr)
11010 dealloc(buffer2_ptr)
11020 dealloc(out_buffer_ptr)
11030 dealloc(inp_buffer_ptr)
11040 end

