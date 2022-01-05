.elfos
.binary
.options
10  REM This program demonstates how to open any file using Basic/02.
15  REM file_number, file_open_type and io_buffer must be set prior
20  REM to calling the assember open routine at line 30000.

30  print "File I/O test Version 2.1 January 4th, 2022
35  debug = 0                       : REM set debug to 1 for a debug trace
40  file_number = 5                 : REM indicate file number to open (1-8)
45  file_open_type = 16             : REM open for read only

50  buffer1_size    = 256:  buffer2_size    = 256
55  inp_buffer_size = 256:  out_buffer_size = 256

60  control_z = 26: bschar =8: crchar =13
65  ioflag = 0: ioresult = 0: in_char = 0
70  maximum_reads   = 1000          : REM maximum number of reads
75  file_name_max = 19              : REM maximum file name size for ElfOS

80  gosub 1000                      : REM allocate buffer_1
81  gosub 1200                      : REM allocate buffer_2
82  gosub 1300                      : REM allocate terminal input  buffer 
83  gosub 1400                      : REM allocate terminal output buffer
84  gosub 30700                     : REM compiler iobuffer into io_buffer_ptr
85  if debug print "compiler I/O buffer address ";io_buffer_ptr


100 print "Use <CNTL>z to cancel. File name?":
105 j = 0                           : REM set file buffer offset to 0
110 gosub 9100                      : REM read character from terminal
120 if debug print " in_char=", in_char:
130 if in_char = crchar goto 190    : REM check for CR
135 if in_char = control_z goto 800 : REM check for CNTL_Z
140 if in_char = bschar    goto 160 : REM is this a back space?
150 poke inp_buffer_ptr+j,in_char   : REM store character in buffer
155 goto 170
160 j = j - 1                       : REM back up pointer
163 if j < 0 j = 0                  : REM if we backed up too far, reset        
165 goto 175                        : REM do not increase pointer 
170 j = j + 1                       : REM bump pointer in buffer
175 if j <= file_name_max goto 110
180 print " File name too long"
185 goto 100

190 print
195 poke inp_buffer_ptr+j,0         : REM file name needs zero at end    
200 buffer1_ptr = inp_buffer_ptr    : REM source string contains file name
210 buffer2_ptr = io_buffer_ptr     : REM target string is for open routine
220 gosub 9800                      : REM copy file name into iobuffer

230 gosub 30000                     : REM open file 
240 if debug print "OPEN/I ioflag=";ioflag; "  iosresul=";IORESULT
250 if ioflag <> 0 goto 860
260 for i = 0 to maximum_reads
270 gosub 1700                      : REM read records from file
280 save_buffer_ptr = out_buffer_ptr: REM Not needed but there for future use
290 out_buffer_ptr = inp_buffer_ptr
300 gosub 9300                      : REM print whole record
310 if EOF(file_number) goto 900    : REM end-of-file reached? 
320 next i
330 print "maximum number of reads requests exceded


800 print
840 print "All done. bye bye"
850 goto  32000                    : REM we are all done
860 print "file not found"
870 goto 100
900 gosub 30500                      : REM call close route using filenum
910 if debug print "CLOSE ioflag=";ioflag; "  iosresul=";IORESULT
920 goto 100


1000  REM allocate buffer 1 
1020  buffer1_ptr   = alloc(buffer1_size)
1080  return

1200  REM allocate buffer 2    
1220  buffer2_ptr   = alloc(buffer2_size)
1280  return

1300  REM allocate buffer for teminal input routines
1310  inp_buffer_ptr  = 0
1320  inp_buffer_ptr  = alloc(inp_buffer_size)
1340  return

1400  REM allocate buffer for teminal output routines
1420  out_buffer_ptr  = alloc(out_buffer_size)
1440  return


1700 REM FREAD from file number X, placing a binary zero at end of buffer
1710 fread #5 inp_buffer_ptr,inp_buffer_size-1
1720 if debug print "FREAD  ioflag=";ioflag; "  ioresult=";ioresult
1730 last_buffer_ptr = inp_buffer_ptr+ioresult
1740 poke last_buffer_ptr,0
1750 return


9100 REM READ_CHAR - read on character from terminal
9110    asm
f_read: equ    0ff06h              ; f_read vector
        sep    scall               ; read a single character from terminal
        dw     f_read
        plo    re
        ldi    v_in_char.1         ; point to character variable
        phi    rf
        ldi    v_in_char.0
        plo    rf                  ; now pointing to msb of char
        ldi    0
        str    rf                  ; zero out msb of char
        inc    rf                  ; point to lsb of char variable
#ifdef  use32bits
        inc    rf                   ; for 32 bit word we need 
        inc    rf                   ; to skip over 2 more bytes
#endif
        glo    re                  ; retrieve read character             
        str    rf                  ; and store in lsb of char variable
        end
9120 return



9300 REM PRINT_MSG - print asciiz string to terminal
9310    asm
        ldi    v_out_buffer_ptr.1 ; point to buffer pointer msb
        phi    rf
        ldi    v_out_buffer_ptr.0     ; point to buffer pointer lsb
        plo    rf                 ; now rf has address of ptrprin
        inc    rf                 ; now point to lsb of pointer
#ifdef  use32bits
        inc    rf                 ; for 32 bit word we need 
        inc    rf                   ; to skip over 2 more bytes
#endif
        ldn    rf                 ; now load lsb of pointer
        plo    re                 ; re.0 now pointing lsb  buffer address
        dec    rf                 ; rf now points to msb of pointer
        ldn    rf                 ; get second byte of buffer address
        phi    rf                 ; save msb of buffer pointer
        glo    re
        plo    rf                 ; save first byte of address
        sep    scall              ; call f_msg to output asciiz string
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
#ifdef  use32bits
        inc    rf                   ; for 32 bit word we need 
        inc    rf                   ; to skip over 2 more bytes
#endif
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
        inc    rd                 ; now point to lsb of poi
#ifdef  use32bits
        inc    rd                   ; for 32 bit word we need 
        inc    rd                   ; to skip over 2 more bytes
#endif
        ldn    rd                 ; now load first byte of pointer
        plo    re                 ; re.0 now pointing to byte 1 of  buffer_2 address
        dec    rd                 ; rd now points to second byte of pointer
        ldn    rd                 ; d = second byte of pointer
        phi    rd                 ; save second byte of buffer_2 pointer
        glo    re                 ; d = lsb of pointer
        plo    rd                 ; save lsb of pointer
        sep    scall
        dw     f_strcpy           ; BIOS string copy call
        end
9820  return



30000 REM OPEN
30030   asm
;
; Inputs:  file_number    : 1-8
;          file_open_type : Elf/OS file open code
;          iobuffer       : file name
; Outputs: open file status set in ioflag and ioresult
;
       
        ldi             013h                   ; Need to allocate 531 bytes -
        plo             rc                     ; 512 bytes for I/O buffer and
        ldi             2                      ; 19 bytes for fildes
        phi             rc
        sep             scall                  ; Allocate memory from the heap
        dw              alloc
        ldi             file1_.0               ; Point to file handle number 1
        plo             rd
        ldi             file1_.1
        phi             rd
        

        ldi             v_file_number.1
        phi             rc
        ldi             v_file_number.0
        plo             rc
        inc             rc
#ifdef  use32bits
        inc             rc                    ; for 32 bit word we need 
        inc             rc                    ; to skip over 2 more bytes
#endif    
        ldn             rc                      ; we now have file number
; The following code assumes the file handles are in consecutive order
open_1: smi             1                       ; test file number
        lbz             open_2                  ; do we have the correct file #?
        inc             rd                      ; bump addres to
        inc             rd                      ;   to next file handle
        lbr             open_1                  ; and try again

open_2: ghi             rf                      ; store allocated memory to handle
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
        ldi             v_file_open_type.1       ; get opentype addr
        phi             rf
        ldi             v_file_open_type.0
        plo             rf
        inc             rf                       ; point to lsb 
#ifdef  use32bits
        inc             rf                       ; for 32 bit word we need 
        inc             rf                        ; to skip over 2 more bytes
#endif     
        ldn             rf                       ; load open type
        plo             r7                       ; and save for Elf/OS open call

        ldi             iobuffer.1              ; Point to filename
        phi             rf
        ldi             iobuffer.0
        plo             rf
        sep             scall                   ; Call Elf/OS to open the file
        dw              0306h
        sep             scall                   ; Set I/O return variables
        dw              ioresults
        end
30040 return


30500 REM CLOSE
30510   asm
;
; Inputs:  file_number    : 1-8
; Outputs: file close and memory freed
;
        ldi             file1_.0                ; Point to file handle number 1
        plo             rf
        ldi             file1_.1
        phi             rf
        ldi             v_file_number.1
        phi             rc
        ldi             v_file_number.0
        plo             rc
        inc             rc
#ifdef  use32bits
        inc             rc                      ; for 32 bit word we need 
        inc             rc                      ; to skip over 2 more bytes
#endif     
        ldn             rc                      ; we now have file number  
; The following code assumes the file handles are in consecutive order
close_1:smi             1                       ; test file number
        lbz             close_2                 ; do we have correct file #?
        inc             rf                      ; bump addres to
        inc             rf                      ;   to next file handle
        lbr             close_1                 ; and try again
close_2:lda             rf                                ; Retrieve FILDES
        phi             rd
        lda             rf
        plo             rd
        sep             scall                   ; Call Elf/OS to close the file
        dw              0312h                   ; o_close uses rd as pointer
        sep             scall 
        dw              ioresults               ; Set I/O return variables

        ldi             file1_.0                ; Point to file handle number 1
        plo             rd
        ldi             file1_.1
        phi             rd
        ldi             v_file_number.1
        phi             rc
        ldi             v_file_number.0
        plo             rc
        inc             rc
#ifdef  use32bits
        inc             rc                      ; for 32 bit word we need 
        inc             rc                      ; to skip over 2 more bytes
#endif       
        ldn             rc                     ; we now have actual file number
; The following code assumes the file handles are in consecutive order
close_3:smi             1                       ; test file number
        lbz             close_4                 ; do we have correct file #?
        inc             rd                      ; bump addres to
        inc             rd                      ;   to next file handle
        lbr             close_3                 ; and try again   
close_4:lda   rd                                ; Retrieve FILDES 
        phi   rf
        lda   rd
        plo   rf
        sep   scall                             ; deallocate memory used by file
        dw    dealloc                           ; deallocate uses rf as pointer
        end
30520 return

30700 REM get compiler iobuffer address in Basic space
30710   asm
        ldi             v_io_buffer_ptr.1       ; get basic iobuffer ptr
        phi             rf
        ldi             v_io_buffer_ptr.0
        plo             rf 
#ifdef  use32bits         
        inc             rf                      ; for 32 bit word we need 
        inc             rf                      ; to skip over 2 more bytes
#endif    
        ldi             iobuffer.1              ; point to i/o buffer.1
        str             rf                      ; and stor in io_buffer_ptr.1
        ldi             iobuffer.0              ; point to i/o buffer.0
        inc             rf                      ; bump pointer by one
        str             rf                      ; and store in io_buffer_ptr.0
        end
30720 return


31900  data 0                                   : REM keep compiler happy
32000  end

