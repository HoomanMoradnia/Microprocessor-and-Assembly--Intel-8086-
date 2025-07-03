org 100h


.data
matrix_dim_prompt db 'Enter matrix X Y:', '$'
matrix_data_prompt db 'Enter rows:', '$'
scalar_data_prompt db 'Enter a scalar value:', '$'
matrix_col_prompt db 'Enter column count of matrix:', '$'
matrix_det_dim_err db 'Only 2x2 and 3x3 matrix determinants are supported.', '$'
enter_any_prompt db 'Enter any character to return...', '$'
prg_opts_1_prompt db '1. Addition of Matrix', '$'
prg_opts_2_prompt db '2. Subtraction of Matrix', '$'
prg_opts_3_prompt db '3. Transpose of a Matrix', '$'
prg_opts_4_prompt db '4. Scalar Multiplication of a Matrix', '$'
prg_opts_5_prompt db '5. Matrix Multiplication', '$'
prg_opts_6_prompt db '6. Determinant of a Matrixt', '$'
prg_opts_7_prompt db '7. Exit', '$'

newline db 0dh, 0ah, '$'
zerostr db '$'
buf_len EQU 200
input_buffer db buf_len, 0, buf_len dup (0), '$'
format_buffer db buf_len+1 dup (?)
conv_buffer db 5 dup (0)
num_buffer dw 10 dup (?)

matrix_1 dw 1024 dup(0)
matrix_2 dw 1024 dup(0)
matrix_3 dw 1024 dup(0)


.code

main PROC
    CALL $clear_term
    LEA DI, matrix_1
    XOR AX, AX
    CALL $read_matrix

@entry:


    CALL $clear_term
    LEA SI, matrix_1
    CALL $log_matrix

    LEA DX, zerostr
    CALL $println

    LEA DX, prg_opts_1_prompt
    CALL $println
    LEA DX, prg_opts_2_prompt
    CALL $println
    LEA DX, prg_opts_3_prompt
    CALL $println
    LEA DX, prg_opts_4_prompt
    CALL $println
    LEA DX, prg_opts_5_prompt
    CALL $println
    LEA DX, prg_opts_6_prompt

    ; i fkn love Sh.K

    CALL $println
    LEA DX, prg_opts_7_prompt
    CALL $println

    PUSH AX
    CALL $getc
    MOV DL, AL
    POP AX

    SUB DL, 30H

    CMP DL, 0H
    JE @entry

@opt_1:
    CMP DL, 1H
    JNE @opt_2:
    CALL $add_matrix
    JMP @entry

@opt_2:
    CMP DL, 2H
    JNE @opt_3
    CALL $sub_matrix
    JMP @entry

@opt_3:
    CMP DL, 3H
    JNE @opt_4
    CALL $transpose_matrix
    JMP @entry

@opt_4:
    CMP DL, 4H
    JNE @opt_5
    CALL $mult_matrix_scalar
    JMP @entry

@opt_5:

    CMP DL, 5H
    JNE @opt_6
    CALL $mult_matrix
    JMP @entry

@opt_6:

    CMP DL, 6H
    JNE @opt_7
    CALL $determinant
    JMP @entry

@opt_7:

    CMP DL, 7H
    JE @stop

    JMP @entry

@stop:
    MOV AX, 4C00H
    INT 21H
main ENDP

; I: AL = number of matrix rows
;    AH = number of matrix columns
$add_matrix PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI

    CALL $clear_term

    LEA DI, matrix_2
    CALL $read_matrix
    LEA SI, matrix_1

    XOR CH, CH
    MOV CL, AL

@addition_start:
    PUSH AX
    PUSH CX

    XOR CH, CH
    MOV CL, AH

@addition_row:
    MOV AX, [SI]
    MOV DX, [DI]
    ADD AX, DX
    MOV [SI], AX

    INC SI
    INC SI
    INC DI
    INC DI

    LOOP @addition_row
    POP CX
    POP AX
    LOOP @addition_start

@addition_end:


    POP DI
    POP SI
    POP DX
    POP CX
    POP AX
    RET
$add_matrix ENDP


; I: AL = number of matrix rows
;    AH = number of matrix columns
$sub_matrix PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI

    CALL $clear_term

    LEA DI, matrix_2
    CALL $read_matrix
    LEA SI, matrix_1

    XOR CH, CH
    MOV CL, AL

@sub_start:
    PUSH AX
    PUSH CX

    XOR CH, CH
    MOV CL, AH

@sub_row:
    MOV AX, [SI]
    MOV DX, [DI]
    SUB AX, DX
    MOV [SI], AX

    INC SI
    INC SI
    INC DI
    INC DI

    LOOP @sub_row
    POP CX
    POP AX
    LOOP @sub_start

@sub_end:

    POP DI
    POP SI
    POP DX
    POP CX
    POP AX
    RET
$sub_matrix ENDP


; I: AL = number of src matrix rows
;    AH = number of src matrix columns
; O: AL and AH are reverted (transposed)
$transpose_matrix PROC
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI

    LEA SI, matrix_1
    LEA DI, matrix_2

    XOR CH, CH
    MOV CL, AL

@transpose_start:
    PUSH CX

    XOR CH, CH
    MOV CL, AH

    ; M2[j][i] = M1[i][j]
@transpose_inner:
    MOV DX, [SI]
    MOV [DI], DX

    ; M1[i][j + 1]
    INC SI
    INC SI

    ; M2[j + 1][i], Add row
    XOR DH, DH
    MOV DL, AL
    ADD DI, DX
    ADD DI, DX

    LOOP @transpose_inner
    POP CX

    ; M2[0][row - cl + 1]
    LEA DI, matrix_2
    XOR DH, DH
    MOV DL, AL
    SUB DL, CL
    INC DL
    ADD DI, DX
    ADD DI, DX

    loop @transpose_start

@transpose_end:

    ; Transpose dimensions
    MOV DL, AL
    MOV AL, AH
    MOV AH, DL

    LEA SI, matrix_2
    LEA DI, matrix_1
    CALL $move_matrix

    POP DI
    POP SI
    POP DX
    POP CX
    RET
$transpose_matrix ENDP


; I: AL = number of src matrix rows
;    AH = number of src matrix columns
; O: AL = unchanged
;    AH = number of result matrix columns
$mult_matrix PROC
    PUSH DX
    PUSH DI

    PUSH AX

    CALL $clear_term
    MOV AL, AH
    XOR AH, AH
    LEA DI, matrix_2
    CALL $read_matrix

    XOR DL, DL
    MOV DH, AH           ; AL = row2, DH = col2
    POP AX               ; AL = row1, AH = col1


    LEA SI, matrix_1
    LEA DI, matrix_2
    LEA BX, matrix_3

    XOR CH, CH
    MOV CL, AL

@mult_start:
    PUSH AX
    PUSH CX
    PUSH DX


    XOR CH, CH
    MOV CL, DH

@mult_outer:
    PUSH AX
    PUSH CX
    PUSH DX

    XOR CH, CH
    MOV CL, AH

    ; M3[i][j] += M1[i][k] * M2[k][j]
    ; i = row1 = AL
    ; j = col2 = DH
    ; k = col1 = AH
@mult_inner:

    PUSH DX
    MOV AX, [SI]
    MOV DX, [DI]
    MUL DX
    POP DX

    ADD [BX], AX

    ; SI = M1[i][k + 1]
    INC SI
    INC SI

    ; DI = M2[k + 1][j], Add col2
    PUSH DX
    MOV DL, DH
    XOR DH, DH
    ADD DI, DX
    ADD DI, DX
    POP DX

    LOOP @mult_inner
    POP DX
    POP CX
    POP AX

    ; SI = M1[i][0]
    PUSH AX
    MOV AL, AH
    XOR AH, AH
    SUB SI, AX
    SUB SI, AX
    POP AX

    LEA DI, matrix_2

    ; DI = M2[0][col2 - j + 1]
    PUSH DX
    MOV DL, DH
    XOR DH, DH
    SUB DL, CL
    INC DL

    ADD DI, DX
    ADD DI, DX
    POP DX

    ; BX = M3[i][j + 1]
    INC BX
    INC BX
    LOOP @mult_outer

    POP DX
    POP CX
    POP AX

    ; SI = M1[i + 1][0], Add col1
    ; BX = M3[i + 1][0], Add col2
    LEA SI, matrix_1
    LEA DI, matrix_2
    LEA BX, matrix_3

    PUSH AX
    MOV AL, AH
    XOR AH, AH
    ADD SI, AX
    ADD SI, AX
    POP AX

    PUSH DX
    MOV DL, DH
    XOR DH, DH
    ADD BX, DX
    ADD BX, DX
    POP DX

    LOOP @mult_start

@mult_end:

    LEA SI, matrix_3
    LEA DI, matrix_1
    MOV AH, DH
    CALL $move_matrix

    POP DI
    POP DX
    RET
$mult_matrix ENDP


; I: AL = number of matrix rows
;    AH = number of matrix columns
$mult_matrix_scalar PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI

    CALL $clear_term
    LEA DX, scalar_data_prompt
    CALL $println

    LEA SI, input_buffer
    LEA DI, num_buffer
    MOV CX, 1
    CALL $read_num

    LEA BX, matrix_1
    MOV DX, [DI]

    XOR CH, CH
    MOV CL, AL

@mult_scalar_start:
    PUSH AX
    PUSH CX

    MOV CL, AH

@mult_scalar_row:
    MOV AX, [BX]
    PUSH DX
    MUL DX
    POP DX
    MOV [BX], AX

    INC BX
    INC BX

    LOOP @mult_scalar_row
    POP CX
    POP AX
    LOOP @mult_scalar_start

@mult_scalar_end:

    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
$mult_matrix_scalar ENDP


; I: AL = number of matrix rows
;    AH = number of matrix cols
;    (ONLY 2x2 and 3x3)
$determinant PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    CALL $clear_term

    CMP AL, AH
    JNE @det_err
    CMP AL, 2
    JE @det2x2
    CMP AL, 3
    JE @det3x3

@det_err:
    LEA DX, matrix_det_dim_err
    CALL $println
    LEA DX, enter_any_prompt
    CALL $println
    CALL $getc
    JMP @det_end

@det2x2:
    LEA SI, matrix_1
    MOV AX, [SI]
    MUL WORD PTR[SI + 6]
    MOV BX, AX
    MOV AX, [SI + 2]
    MUL WORD PTR[SI + 4]
    SUB BX, AX
    MOV AX, BX
    JMp @det_print

@det3x3:
    LEA SI, matrix_1
    XOR BX, BX

    MOV AX, [SI]
    MUL WORD PTR[SI + 8]
    MUL WORD PTR[SI + 16]
    ADD BX, AX
    MOV AX, [SI + 2]
    MUL WORD PTR[SI + 10]
    MUL WORD PTR[SI + 12]
    ADD BX, AX
    MOV AX, [SI + 4]
    MUL WORD PTR[SI + 6]
    MUL WORD PTR[SI + 14]
    ADD BX, AX

    MOV AX, [SI + 4]
    MUL WORD PTR[SI + 8]
    MUL WORD PTR[SI + 12]
    SUB BX, AX
    MOV AX, [SI]
    MUL WORD PTR[SI + 10]
    MUL WORD PTR[SI + 14]
    SUB BX, AX
    MOV AX, [SI + 2]
    MUL WORD PTR[SI + 6]
    MUL WORD PTR[SI + 16]
    SUB BX, AX

    MOV AX, BX

@det_print:

    CALL $print_num
    LEA DX, zerostr
    CALL $println
    LEA DX, enter_any_prompt
    CALL $println
    CALL $getc

@det_end:


    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
$determinant ENDP


; I: SI = ptr to src matrix
;    DI = ptr to dest matrix
;    AL = number of matrix rows
;    AH = number of matrix columns
$move_matrix PROC
    PUSH AX
    PUSH CX

    XOR CH, CH
    MOV CL, AL

@move_start:
    PUSH AX
    PUSH CX

    XOR CH, CH
    MOV CL, AH
@move_row:
    MOV AX, [SI]
    MOV [DI], AX

    INC SI
    INC SI
    INC DI
    INC DI

    LOOP @move_row
    POP CX
    POP AX
    LOOP @move_start

@move_end:

    POP CX
    POP AX
    RET
$move_matrix ENDP


; I: DL = byte to print
$putc PROC
    PUSH AX
    MOV AH, 02H
    INT 21H
    POP AX
    RET
$putc ENDP



; I: DX = ptr to $ terminated string
$print PROC
    PUSH AX
    MOV AH, 09H
    INT 21H
    POP AX
    RET
$print ENDP

; I: DX = ptr to $ terminated string
$println PROC
    CALL $print
    PUSH DX
    PUSH AX
    LEA DX, newline
    MOV AH, 09H
    INT 21H
    POP AX
    POP DX
    RET
$println ENDP

; I: AX = number to be printed
$print_num PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    LEA SI, format_buffer
    XOR DX, DX
    XOR CX, CX

@num_to_ascii:

    TEST AX, AX
    JNs @positive_num
    NOT AX
    INC AX
    MOV [SI], '-'
    INC SI

@positive_num:

    CMP AX, 10
    JL @lt10

@gt10:
    MOV BX, 10
    DIV BX
    ADD DL, '0'
    MOV [SI], DL
    INC SI
    INC CX
    JMP @num_to_ascii

@lt10:
    ADD AL, '0'
    MOV [SI], AL
    MOV [SI + 1], '$'

@reverse_l1:
    CMP CX, 0
    JLE @rev_done_l1:

    MOV BX, SI
    SUB BX, CX

    MOV AL, [SI]
    MOV AH, [BX]
    MOV [SI], AH
    MOV [BX], AL

    DEC SI
    DEC CX
    DEC CX
    JMP @reverse_l1

@rev_done_l1:

    LEA DX, format_buffer
    CALL $print

    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
$print_num ENDP


; I: DX = ptr to buffer len
;    DX+1 = ptr to read chars
;    DX+2 = ptr to actual input buffer
; O: DI = ptr to formatted buffer
;    CX = buffer len
$process_input PROC
    PUSH AX
    PUSH BX
    PUSH DI

    MOV BX, DX
    XOR CX, CX
    MOV CL, [BX + 1]
@mvchar:
    MOV AL, BYTE PTR[BX + 2]
    MOV [DI], AL
    INC BX
    INC DI
    LOOP @mvchar
    MOV [DI], '$'

    XOR CH, CH

    MOV BX, DX
    MOV CL, [BX + 1]

    POP DI
    POP BX
    POP AX
    RET
$process_input ENDP

; I: SI = ptr to input buf
;    CX = buf len
; O: DI = ptr to dest nums buffer (word buffer)
;    CX = count of parsed nums
$process_nums PROC
    PUSH SI
    PUSH DI
    PUSH AX
    PUSH BX
    PUSH DX

    XOR AX, AX
    XOR BX, BX
    XOR DX, DX

@uminus:
    MOV BL, BYTE PTR[SI]
    CMP BL, 02DH
    PUSHF
    JNE @numstart
    INC SI

@numstart:
    MOV BL, BYTE PTR[SI]
@range_check:
    CMP BL, 30H
    JB @numend
    CMP BL, 39H
    JA @numend

    PUSH BX
    ; Multiply AX by 10, also preserve DX
    MOV BX, 10
    PUSH DX
    MUL BX
    POP DX
    POP BX
@ascii_to_num:
    SUB BL, 30H
    ADD AX, BX
    INC SI
    LOOP @numstart

@numend:
    POPF
    JNE @not_uminus
    NOT AX
    INC AX

@not_uminus:

    MOV [DI], AX
    INC DX
    XOR AX, AX
    INC DI
    INC DI
    INC SI

    ; Cannot use loop cos prev loop can
    ; incremenent to zero and make here a
    ; forever loop!


    DEC CX
    CMP CX, 0
    JNS @uminus

    MOV CX, DX

    POP DX
    POP BX
    POP AX
    POP DI
    POP SI
    RET
$process_nums ENDP

; O: AL = byte read
$getc PROC
    MOV AH, 1
    INT 21H
    RET
$getc ENDP

; I: DX = ptr to input buffer
$read PROC
    PUSH AX
    MOV AH, 0Ah
    INT 21h
    POP AX

    PUSH DX
    LEA DX, zerostr
    CALL $println
    POP DX

    REt
$read ENDP

; I: CX = count of numbers to read
;    SI = ptr to buffer len
;    SI+1 = ptr to read chars
;    SI+2 = ptr to actual input buffer
;    DI = dest nums buffer (word buffer)
; O: CF = nonzero for failure
$read_num PROC
    PUSH AX
    PUSH DX

    MOV DX, SI
    CALL $read

    PUSH CX
    PUSH DI

    MOV DX, SI
    LEA DI, format_buffer
    CALL $process_input
    LEA SI, format_buffer
    
    POP DI

    CALL $process_nums
    MOV AX, CX

    POP CX
    POP DX

    CMP AX, CX
    JZ @valid
    STC
    POP AX
    RET
@valid:
    CLC
    POP AX
    RET
$read_num ENDP

; I: DI = ptr to matrix buffer
;    if AX = 0 then dimensions will be taken from user
;    if AL != 0 but AH = 0 then only column count will be taken from user
;    AL = forced row count
;    AH = forced column count
; O: AL = number of rows (0 if invalid input)
;    AH = number of columns
$read_matrix PROC
    PUSH CX
    PUSH DX
@fetch_matrix_dim:
    XOR CX, CX

    CMP AH, 0
    JNZ @fetch_matrix_data

    CMP AL, 0
    JNZ @fetch_matrix_column_only

    LEA DX, matrix_dim_prompt
    CALL $println

    PUSH DI
    LEA SI, input_buffer
    LEA DI, num_buffer
    MOV CX, 2
    CALL $read_num
    MOV AL, [DI]
    MOV AH, [DI + 2]
    POP DI

    JMP @fetch_matrix_data

@fetch_matrix_column_only:

    LEA DX, matrix_col_prompt
    CALL $println

    PUSH DI
    LEA SI, input_buffer
    LEA DI, num_buffer
    MOV CX, 1
    CALL $read_num
    MOV AH, [DI]
    POP DI

@fetch_matrix_data:
    MOV CL, AL
    PUSH DI

    LEA DX, matrix_data_prompt
    CALL $println

@read_row:
    PUSH CX;

    LEA SI, input_buffer
    MOV CL, AH;
    CALL $read_num

    PUSH BX
    XOR BX, BX
    MOV BL, AH
    ADD DI, BX
    ADD DI, BX
    POP BX

    POP CX;

    LOOP @read_row

    POP DI

    POP DX
    POP CX
    RET
$read_matrix ENDP


$clear_term PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

@clr_scr:
    MOV AH,06H	;clear screen instruction
    MOV AL,00H	;number of lines to scroll
    MOV BH,0FH	;display attribute - colors
    MOV CH,00D	;start row
    MOV CL,00D	;start col
    MOV DH,24D	;end of row
    MOV DL,79D	;end of col
    INT 10H		;BIOS interrupt

@mv_cursor:

    MOV AH,02H	;move cursor Instruction
    MOV BH,0H	;Page 0
    MOV DH,0D	;row
    MOV DL,0D	;column
    INT 10H

    POP DX
    POP CX
    POP BX
    POP AX
    RET
$clear_term ENDP

; I: SI = ptr to matrix (word buffer)
;    AL = number of rows
;    AH = number of columns
$log_matrix PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI

    XOR CH, CH
    MOV CL, AL

@log_start:
    PUSH CX
    PUSH AX

    MOV CL, AH
    MOV DL, '['
    CALL $putc

@log_row:
    MOV ax, [si]
    LEA di, conv_buffer
    CALL $itoa
    LEA dx, conv_buffer
    CALL $print

    INC SI
    INC SI
    CMP CX, 2
    JNAE @last_elem
@not_last_elem:
    MOV dl, ','
    CALL $putc
    MOV dl, ' '
    CALL $putc
    LOOP @log_row
@last_elem:
    MOV DL, ']'
    CALL $putc
    LEA DX, zerostr
    CALL $println

    POP AX
    POP CX
    LOOP @log_start

    POP DI
    POP SI
    POP DX
    POP CX
    POP AX
    RET
$log_matrix ENDP

; I: DI = ptr to string buffer
;    AX = number to be converted
$itoa PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH DI

    XOR CX, CX
    XOR DX, DX


@sign_check_l1:
    TEST AX, AX
    JNS @loopdig
    NOT AX
    INC AX
    MOV [DI], '-'
    INC DI

@loopdig:
    CMP AX, 10
    JAE @more_than_10
    ADD AL, '0'
    MOV [DI], AL
    INC CX
    MOV [DI+1], '$'     ; TERMINATE STR
    JMP @reverse

@more_than_10:

    MOV BX, 10
    XOR DX, DX
    DIV BX

    ADD DL, '0'
    MOV [DI], DL
    INC DI
    INC CX

    JMP @loopdig
@reverse:


    CMP CX, 1
    JLE @rev_done
    MOV BX, DI
    SUB BX, CX
    INC BX
    MOV AL, [DI]
    MOV AH, [BX]
    MOV [DI], AH
    MOV [BX], AL
    DEC DI
    DEC CX
    DEC CX
    JMP @reverse

@rev_done:

    POP DI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
$itoa ENDP

end main


