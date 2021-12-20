.elfos
.binary
.options
10  print "File I/O test Version 1.4 December 19, 2021"
15  debug = 0                      : REM set debug switch to 1 to turn on
20  buffer1_size    = 256:  buffer2_size    = 256
25  file_number = 1                 : REM indicate we are using file #1
30  inp_buffer_size = 256:  owt_buffer_size = 256
35  control_z = 26 
40  ioflag = 0: ioresult = 0: in_char = 0: crchar = 13
45  maximum_reads   = 1000          : REM maximum number of reads

50  gosub 1000                      : REM allocate buffer_1
55  gosub 1200                      : REM allocate buffer_2
60  gosub 1300                      : REM allocate terminal input  buffer 
65  gosub 1400                      : REM allocate terminal output buffer
70  gosub 30100                     : REM store compiler iobuffer into io_buffer_ptr



100 print "Use <CNTL>z to cancel. file name?":
105 for i = 0 to 25                 : REM allow 26 characters to be inputed
110 gosub 9100                      : REM read character from terminal
120 if debug print " in_char=", in_char:
130 if in_char = crchar goto 185    : REM check for CR
135 if in_char = control_z goto 800 : REM check for CNTL_Z

150 poke inp_buffer_ptr+i,in_char
160 next i
170 print " file name too long"
180 goto 100

185 print
190 poke inp_buffer_ptr+i,0        : REM file name needs binary zero at end    
200 buffer1_ptr = inp_buffer_ptr   : REM source string contains file name
210 buffer2_ptr = io_buffer_ptr    : REM targe string is for open routine
220 gosub 9800

230 gosub 30000                    : REM open file for input as #1
240 if debug print "OPEN/I ioflag=";ioflag; "  iosresul=";IORESULT
250 if ioflag <> 0 goto 820
260 for i = 0 to maximum_reads
270 gosub 1700                      : REM read records from file
280 save_buffer_ptr = out_buffer_ptr
290 owt_buffer_ptr = inp_buffer_ptr
300 gosub 9300                      : REM print record
310 if EOF(file_number) goto 100
320 next i
330 print "maximum number of reads requests exceded


800 print 
805 print "all done. bye bye"
810 goto  32000                    : REM we are all done
820 print "file not found"
830 goto 100




1000  REM allocate buffer 1 
1020  buffer1_ptr   = alloc(buffer1_size)
1080  return

1200  REM allocate buffer 2    
1220  buffer2_ptr   = alloc(buffer2_size)
1280  return

1300  REM allocate buffer for teminal input routines
1320  inp_buffer_ptr  = alloc(inp_buffer_size)
1340  return

1400  REM allocate buffer for teminal output routines
1420  owt_buffer_ptr  = alloc(owt_buffer_size)
1440  return



1700 REM read from file number number 1, placing a binary zero at end of buffer
1710 fread #1 inp_buffer_ptr,inp_buffer_size-1
1720 if debug print "FREAD  ioflag=";ioflag; "  ioresult=";ioresult
1730 last_buffer_ptr = inp_buffer_ptr+ioresult
1740 poke last_buffer_ptr,0
1750 return

9100 REM READ_CHAR - read on character from terminal
9110    asm
f_read: equ    0ff06h              ; f_read vector
        sep    r4                  ; read a single character from terminal
        dw     f_read
        plo    re
        ldi    v_in_char.1         ; point to character variable
        phi    rf
        ldi    v_in_char.0
        plo    rf                  ; now pointing to msb of char
        ldi    0
        str    rf                  ; zero out msb of char
        inc    rf                  ; point to lsb of char variable
        glo    re                  ; retrieve read character             
        str    rf                  ; and store in lsb of char variable
        end
9120 return





9300 REM PRINT_MSG - print asciiz string to terminal
9310    asm
        ldi    v_owt_buffer_ptr.1 ; point to buffer pointer msb
        phi    rf
        ldi    v_owt_buffer_ptr.0     ; point to buffer pointer lsb
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
        ldi    v_buffer2_ptr.0    ; point to buffer pointer lsb
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





30000 REM Open file for input as #1. This is a hack to allow
30010 REM an abritray file to be open at runtime.
30020 REM iobuffer should have the file name set upon entry
30030   asm       
        ldi             013h                   ; Need to allocate 531 bytes
        plo             rc
        ldi             2
        phi             rc
        sep             scall                   ; Allocate memory from the heap
        dw              alloc
        ldi             (file1_+0*2).0         ; Point to file handle
        plo             rd
        ldi             (file1_+0*2).1
        phi             rd
        ghi             rf                      ; store allocated memory to handle
        str             rd
        inc             rd
        glo             rf
        str             rd
        ghi             rf                      ; transfer fildes address to RD
        phi             rd
        glo             rf
        plo             rd
        glo             rf                      ; DTA is 19 bytes highter
        adi             19
        plo             rf
        ghi             rf                      ; propagate carry
        adci            0
        phi             rf                      ; RF now points to dta
        inc             rd                      ; point to DTA entry in FILDES
        inc             rd
        inc             rd
        inc             rd
        ghi             rf                      ; write DTA address
        str             rd
        inc             rd
        glo             rf
        str             rd
        dec             rd                      ; restore RD
        dec             rd
        dec             rd
        dec             rd
        dec             rd
        ldi             iobuffer.1              ; Point to filename
        phi             rf
        ldi             iobuffer.0
        plo             rf
        ldi             16                      ; Open for read only
        plo             r7                      ; set open flags
        sep             scall                   ; Call Elf/OS to open the file
        dw              0306h
        sep             scall                   ; Set I/O return variables
        dw              ioresults
        end
30040 return


30100 REM get compiler iobuffer address in Basic space
30105   asm
        ldi             v_io_buffer_ptr.1       ; get basic iobuffer ptr
        phi             rf
        ldi             v_io_buffer_ptr.0
        plo             rf
        ldi             iobuffer.1              ; point to i/o buffer.1
        str             rf                      ; and stor in io_buffer_ptr.1
        ldi             iobuffer.0              ; point to i/o buffer.1
        inc             rf                      ; bump pointer by one
        str             rf                      ; and store in io_buffer_ptr.0
        end
30110 return

30500  data 0                                   : REM keep compiler happy
32000  end

