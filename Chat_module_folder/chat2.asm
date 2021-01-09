.model HUGE


.data

	first_cursor_x_chat2 db 0
	first_cursor_y_chat2 db 1
    VALUE_TO_SEND db ?
    is_enter db ?
    is_esc db 0
    is_scroll db ?
    VALUE db ?


    second_cursor_x_chat2 db 0
	second_cursor_y_chat2 db 14
     Second_Player_Name  DB '16','?','Second_Player_Name$'
    First_Player_Name  DB '16','?','First_Player_Name$'
    close_message     DB '----------------------------to end chatting press ESC---------------------------$'

.code

;description
main PROC far

    mov ax,@data
    mov ds,ax
    MOV ES,AX

   call far ptr chat_module_2
    

main ENDP

;description
chat_module_2 PROC
    

 mov ah,0
    mov al,3
    int 10h


    mov ah,2 
    mov dl,first_cursor_x_chat2
    mov dh,first_cursor_y_chat2
    int 10h


     mov di, offset First_Player_Name
    add di,2
    call far ptr print_string_chat_module_first_player2

    mov di, offset Second_Player_Name
    add di,2
    call far ptr print_string_chat_module_second_player2


    call far ptr initializing2
    call far ptr draw_line2
    call far ptr print_close_message2
    WHILE1_chat_module_2:
     mov ah,2 
    mov dl,first_cursor_x_chat2
    mov dh,first_cursor_y_chat2
    int 10h
    call far ptr READ_FROM_KEYBOARD2
    call far ptr RECEIVE_VALUE2
    cmp is_esc,1
    je end_chat_module_2
    jmp WHILE1_chat_module_2

    end_chat_module_2:
    ret
chat_module_2 ENDP
print_close_message2 PROC
    mov dl,0
    mov dh,24d
    mov di,offset close_message
    print_close_message_loop2:
    mov ah,2 
    int 10h 
     mov al,[di]
    cmp al,'$'
    je print_close_message_ret2
    mov ah,09h
     mov al,[di]
     mov bh,0
     mov bl,0fh ;white color
     mov cx,1
    int 10h
    inc di 
    inc dl
    jmp print_close_message_loop2
    print_close_message_ret2:
    ret

print_close_message2 ENDP

print_string_chat_module_first_player2 PROC
    mov dl,0
    mov dh,0
    print_string_chat_module_loop2:
     mov ah,2 
    
    int 10h
    mov al,[di]
    cmp al,'$'
    je ret_print_string_chat_module2    

     mov ah,09h
     mov al,[di]
     mov bh,0
     mov bl,0fh ;white color
     mov cx,1
    int 10h
    inc di 
    inc dl
    jmp print_string_chat_module_loop2
    ret_print_string_chat_module2:
     mov ah,09h
     mov al,':'
     mov bh,0
     mov bl,0fh ;white color
     mov cx,1
    int 10h

    ret
print_string_chat_module_first_player2 ENDP

print_string_chat_module_second_player2 PROC
    mov dl,0
    mov dh,13d
    print_string_chat_module_loop_second2:
     mov ah,2 
    
    int 10h
    mov al,[di]
    cmp al,'$'
    je ret_print_string_chat_module_second2  

     mov ah,09h
     mov al,[di]
     mov bh,0
     mov bl,0fh ;white color
     mov cx,1
    int 10h
    inc di 
    inc dl
    jmp print_string_chat_module_loop_second2
    ret_print_string_chat_module_second2:
     mov ah,09h
     mov al,':'
     mov bh,0
     mov bl,0fh ;white color
     mov cx,1
    int 10h

    ret
print_string_chat_module_second_player2 ENDP

initializing2 PROC                 ;;GOOD PROC
    ;Set Divisor Latch Access Bit
    mov dx,3fbh ; Line Control Register
    mov al,10000000b ;Set Divisor Latch Access Bit
    out dx,al ;Out it

    ; Set LSB byte of the Baud Rate Divisor Latch register.
    mov dx,3f8h
    mov al,0ch
    out dx,al

    ; Set MSB byte of the Baud Rate Divisor Latch register.
    mov dx,3f9h
    mov al,00h
    out dx,al

    ; Set port configuration
    mov dx,3fbh
    mov al,00011011b
    ; 0:Access to Receiver buffer, Transmitter buffer
    ; 0:Set Break disabled
    ; 011:Even Parity
    ; 0:One Stop Bit
    ; 11:8bits
    out dx,al
    ret  
initializing2 ENDP

 ;description
draw_line2 PROC                        ;;GOOD PROC 
 	mov ax,0b800h ;text mode 
	mov DI,1920     ; each row 80 column each one 2 bits 80*2*12
	mov es,ax
    mov ah,0fh    ; black background
	mov al,2Dh    ; '-'
	mov cx,80
	rep stosw
    ret
draw_line2 ENDP



; SEND_VALUE PROC                                 ;; GOOD PROC

; ;Check that Transmitter Holding Register is Empty
; mov dx , 3FDH ; Line Status Register
; AGAIN: In al , dx ;Read Line Status
; test al , 00100000b
; JZ AGAIN ;Not empty
; ;If empty put the VALUE in Transmit data register
; mov dx , 3F8H ; Transmit data register
; mov al,VALUE_TO_SEND
; out dx , al
; RET
; SEND_VALUE ENDP


PRINT_RECEIVED2 PROC
    
   

        ;get_key_pressed:
            ; mov ah,0
            ; int 16h
            ;mov VALUE,al  ; holds the char required to be sent
            mov al,VALUE

            ;check if key pressed is enter key
            call far ptr check_enter2
            cmp is_enter,1
            jz here2_print
        
            ;CALL   SEND_VALUE
            ;set cursor
            mov ah,2 
            mov bh,0
            mov dl,first_cursor_x_chat2
            mov dh,first_cursor_y_chat2
            int 10h

            mov ah,09h
            mov al,VALUE
            mov bh,0
            mov bl,0fh ;white color
            mov cx,1
            int 10h
           
            call far ptr get_new_position2
            here2_print:
            mov is_enter,0
            mov di, offset First_Player_Name
            add di,2
            call far ptr print_string_chat_module_first_player2
            call far ptr print_close_message2
            ret

PRINT_RECEIVED2 ENDP


RECEIVE_VALUE2 PROC                            ;; GOOD PROC
;Check that Data is Ready
mov dx , 3FDH ; Line Status Register
 in al , dx
test al , 1
JZ END_RECEIVE_VALUE2 ;Not Ready
;If Ready read the VALUE in Receive data register
mov dx , 03F8H
in al , dx
mov VALUE , al

cmp al,1Bh
jne continue_receive_value2
mov is_esc,1
continue_receive_value2:
CALL  PRINT_RECEIVED2

END_RECEIVE_VALUE2:
ret
RECEIVE_VALUE2 ENDP

check_enter2 PROC
    cmp al,0dh
    jnz end_enter2
    ; cmp first_cursor_y_chat2,11
    ; jz 
    enter_action2:
        cmp first_cursor_y_chat2,11
        jz call_scroll12
        inc first_cursor_y_chat2
        mov first_cursor_x_chat2,0
        jmp continue2_enter
        call_scroll12:
            call far ptr check_scroll2
        continue2_enter:
        mov is_enter,1
        mov ah,2 
        mov bh,0
        mov dl,first_cursor_x_chat2
        mov dh,first_cursor_y_chat2
        int 10h
    end_enter2:        
    ret
check_enter2 ENDP
;description

get_new_position2 PROC
    cmp first_cursor_x_chat2,75
    jz new_line2 
       inc first_cursor_x_chat2      
       jmp return2_new_pos
    new_line2:
      cmp first_cursor_y_chat2,11d
      jz call_scroll2
      inc first_cursor_y_chat2            ; move to new line
      mov first_cursor_x_chat2,0
      jmp return2_new_pos
      call_scroll2:
         call far ptr check_scroll2
       return2_new_pos:  
    ret
get_new_position2 ENDP


 ;description
check_scroll2 PROC
    mov ax,0601h
    mov bh,00
    mov ch,0
	mov cl,0
	mov dh,11
	mov dl,79
    int 10h
    call far ptr update_line2
    mov first_cursor_x_chat2,0
    MOV first_cursor_y_chat2,11
    ret
check_scroll2 ENDP

;description
update_line2 PROC
    mov ax,0b800h
	mov di,1760   ; each row 80 column each one 2 bits 80*2*11
	mov es,ax
	mov ah,07h
	mov al,20h
	mov cx,80  ;
	rep stosw
;draw separator
    call far ptr draw_line2
   
    ret
update_line2 ENDP



draw_line_written2 PROC                        ;;GOOD PROC 
 	mov ax,0b800h ;text mode 
	mov DI,1920     ; each row 80 column each one 2 bits 80*2*12
	mov es,ax
    mov ah,0fh    ; black background
	mov al,2Dh    ; '-'
	mov cx,80
	rep stosw
    ret
draw_line_written2 ENDP


update_line_written2 PROC
    mov ax,0b800h
	mov di,1760   ; each row 80 column each one 2 bits 80*2*11
	mov es,ax
	mov ah,07h
	mov al,20h
	mov cx,80  ;
	rep stosw
;draw separator
    call far ptr draw_line_written2
   
    ret
update_line_written2 ENDP




check_scroll_written2 PROC
    mov ax,0601h
    mov bh,00
    mov ch,13d
	mov cl,0
	mov dh,23d
	mov dl,79
    int 10h
    call far ptr update_line_written2
    mov second_cursor_x_chat2,0
    MOV second_cursor_y_chat2,23d
    ret
check_scroll_written2 ENDP



check_enter_written2 PROC
    cmp al,0dh
    jnz end_enter_written2
    ; cmp first_cursor_y_chat2,11
    ; jz 
   ; enter_action:
        cmp second_cursor_y_chat2,23
        jz call_scroll1_written2
        inc second_cursor_y_chat2
        mov second_cursor_x_chat2,0
        jmp continue_check_enter_written2
        call_scroll1_written2:
            call far ptr check_scroll_written2
        continue_check_enter_written2:
        mov is_enter,1
        mov ah,2 
        mov bh,0
        mov dl,second_cursor_x_chat2
        mov dh,second_cursor_y_chat2
        int 10h
    end_enter_written2:        
    ret
check_enter_written2 ENDP
;description


get_new_position_written2 PROC
    cmp second_cursor_x_chat2,75
    jz new_line_written2
       inc second_cursor_x_chat2      
       jmp end_get_new_position_written2
    new_line_written2:
      cmp second_cursor_y_chat2,23d
      jz call_scroll_written2
      inc second_cursor_y_chat2            ; move to new line
      mov second_cursor_x_chat2,0
      jmp end_get_new_position_written2
      call_scroll_written2:
         call far ptr check_scroll_written2
       end_get_new_position_written2:  
    ret
get_new_position_written2 ENDP



PRINT_WRITTEN2 PROC
    
   

       
            mov al,VALUE_TO_SEND

            ;check if key pressed is enter key
            call far ptr check_enter_written2
            cmp is_enter,1
            jz here_written2
        
            ;CALL   SEND_VALUE
            ;set cursor
            mov ah,2 
            mov bh,0
            mov dl,second_cursor_x_chat2
            mov dh,second_cursor_y_chat2
            int 10h

            mov ah,09h
            mov al,VALUE_TO_SEND
            mov bh,0
            mov bl,0fh ;white color
            mov cx,1
            int 10h
           
            call far ptr get_new_position_written2
            here_written2:
            mov is_enter,0
            mov di, offset Second_Player_Name
            add di,2
            call far ptr print_string_chat_module_second_player2
            call far ptr print_close_message2
            ret

PRINT_WRITTEN2 ENDP





SEND_VALUE2 PROC                                 ;; GOOD PROC

;Check that Transmitter Holding Register is Empty
mov dx , 3FDH ; Line Status Register
AGAIN: In al , dx ;Read Line Status
test al , 00100000b
JZ AGAIN ;Not empty
;If empty put the VALUE in Transmit data register
mov dx , 3F8H ; Transmit data register
mov al,VALUE_TO_SEND
out dx , al
RET
SEND_VALUE2 ENDP


READ_FROM_KEYBOARD2 PROC
    MOV AH,1
    INT 16H
    JZ NO_KEY_PRESSED
    MOV AH,0 
    INT 16H
    MOV VALUE_TO_SEND,AL

    cmp al,1Bh 
    jne continue_read_from_keyboard
    mov is_esc,1

    continue_read_from_keyboard:
    CALL   SEND_VALUE2
    CALL PRINT_WRITTEN2
    JMP END_READ_FROM_KEYBOARD2
    NO_KEY_PRESSED:
    MOV VALUE_TO_SEND,0
    END_READ_FROM_KEYBOARD2:
    
RET
READ_FROM_KEYBOARD2 ENDP



END main