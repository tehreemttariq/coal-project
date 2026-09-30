[org 0x0100]
jmp start
art db "                  ____  _               ____                   ",0Dh,0Ah
    db "                 |  _ \(_)_ __   __ _  |  _ \ ___  _ __   __ _  ",0Dh,0Ah
    db "                 | |_) | | '_ \ / _` | | |_) / _ \| '_ \ / _` | ",0Dh,0Ah
    db "                 |  __/| | | | | (_| | |  __/ (_) | | | | (_| | ",0Dh,0Ah
    db "                 |_|   |_|_| |_|\__, | |_|   \___/|_| |_|\__, | ",0Dh,0Ah
    db "                                |___/                    |___/ ",0Dh,0Ah,"$"

endart db "      /\_/\  /\_/\  /\_/\  /\_/\  /\_/\  /\_/\  /\_/\  /\_/\  /\_/\  /\_/\ ",0Dh,0Ah
    db "     ( o.o )( o.o )( o.o )( o.o )( o.o )( o.o )( o.o )( o.o )( o.o )( o.o )",0Dh,0Ah
    db "      > ^ <  > ^ <  > ^ <  > ^ <  > ^ <  > ^ <  > ^ <  > ^ <  > ^ <  > ^ < ",0Dh,0Ah
    db "      /\_/\      ____                         ___                    /\_/\ ",0Dh,0Ah
    db "     ( o.o )    / ___| __ _ _ __ ___   ___   / _ \__   _____ _ __   ( o.o )",0Dh,0Ah
    db "      > ^ <    | |  _ / _` | '_ ` _ \ / _ \ | | | \ \ / / _ \ '__|   > ^ < ",0Dh,0Ah
    db "      /\_/\    | |_| | (_| | | | | | |  __/ | |_| |\ V /  __/ |      /\_/\ ",0Dh,0Ah
    db "     ( o.o )    \____|\__,_|_| |_| |_|\___|  \___/  \_/ \___|_|     ( o.o )",0Dh,0Ah
    db "      > ^ <                                                          > ^ < ",0Dh,0Ah
    db "      /\_/\  /\_/\  /\_/\  /\_/\  /\_/\  /\_/\  /\_/\  /\_/\  /\_/\  /\_/\ ",0Dh,0Ah
    db "     ( o.o )( o.o )( o.o )( o.o )( o.o )( o.o )( o.o )( o.o )( o.o )( o.o )",0Dh,0Ah
    db "      > ^ <  > ^ <  > ^ <  > ^ <  > ^ <  > ^ <  > ^ <  > ^ <  > ^ <  > ^ < ",0Dh,0Ah,"$"

msg1: db 'Press ENTER to start or ESC to exit', 0
msg2: db 'Press ENTER to restart or ESC to exit', 0
random: dw 0xAAAA

player1_text: db 'PLAYER 1',0
player2_text: db 'PLAYER 2',0

score_text: db'SCORE: ',0

p1won: db 'PLAYER 1 WON THE GAME  :)',0
p2won: db 'PLAYER 2 WON THE GAME  :)',0
tie: db 'NOBODY WON THE GAME :(',0

paddle1: dw 5
paddle2: dw 15

score1: dw 0
score2: dw 0
scoreheader1: db 'P1 Score: '
scoreheader2: db 'P2 Score: '

ballrow: dw 11
ballcol: dw 38
balldirrow: dw -1
balldircol: dw 1
oldposition: dw 0

tick: dw 0
delay: dw 1
oldtimer: dd 0
gameover: dw 0
;---------------------------------------
clrscr: 
	push es
	pusha
	push di

	mov ax, 0xb800
	mov es, ax 
	xor di, di 
	mov ax, 0x7020 
	mov cx, 2000

	cld 
	rep stosw

	pop di
	popa
	pop es
	ret
;---------------------------------------
printstr:
    	push bp
    	mov bp,sp

    	mov ax,0xb800
    	mov es,ax

    	mov si,[bp+8]   ;string passed

    	mov al,[bp+6]   ;row
    	mov bl,80
    	mul bl
    	add ax,[bp+4]   ;col
    	shl ax,1
    	mov di,ax

    	mov ah,[bp+10]     ;red on white, no blinking
next:
    	mov al,[si]
    	mov [es:di], ax
    	add di,2
    	inc si
    	cmp byte [si], 0
    	jne next
    	pop bp
    	ret 8
;---------------------------------------
draw_text:
	push bp
	mov bp, sp
	pusha
	
	mov ah, 02h
	mov bh, 0       ; page 0
	mov bl, 0x71
	mov dh, 1       ; row
	mov dl, 0       ; column
	int 10h
	    
	mov dx, [bp+4]     ; DS:DX points to string
    	mov ah, 09h     ; DOS print string function
	int 21h
	
	popa
	pop bp
	ret
;---------------------------------------
draw_table:
    	pusha
    	push es
    	push si
    	push di

    	mov ax,0xb800
    	mov es,ax
	mov di, 0
	mov ax, 0x7904
	mov cx, 80
	cld
	rep stosw

	mov di, 3840
	mov cx, 80
	cld
	rep stosw

	mov dx, 1294
    	mov ax,0x3D20 

    	push dx
    	mov cx, 13
    	mov di, dx
complete_table:
    	push cx
    	push di

    	mov cx, 65
	cld
    	rep stosw

    	pop di
    	pop cx

    	add di, 160
    	loop complete_table
    	pop dx

    	mov ax,0x3fb0
    	mov di, dx
    	mov cx, 65
	cld
    	rep stosw

    	mov di, dx
    	add di, 2080
    	mov cx, 65
	cld
    	rep stosw

    	mov di, dx
    	mov cx, 13
Left_shade:
    	mov [es:di], ax
    	add di, 160
    	loop Left_shade

    	mov di, dx
    	add di, 130
    	mov cx, 14
Right_shade:
    	mov [es:di], ax
    	add di, 160
    	loop Right_shade

    	mov di, dx
    	add di, 64
    	mov cx, 13
Center_line:
    	mov [es:di], ax
    	add di,160
    	loop Center_line

    	mov di,dx
    	add di, 1124
    	mov ax, 0x7908
    	mov cx, 4
pad1:
    	mov [es:di], ax
    	add di,160
    	loop pad1

    	mov di, dx
    	add di, 446
    	mov ax, 0x7508
    	mov cx, 4
pad2:
    	mov [es:di], ax
    	add di,160
    	loop pad2

    	mov di,dx         ;heart symbol
    	add di, 584
    	mov ax, 0x3403
    	mov [es:di], ax
    	add di, 2
    	mov [es:di], ax
    	add di, 160
        mov [es:di], ax
        sub di, 2
        mov [es:di], ax

    	pop di
    	pop si
    	pop es
    	popa
    	ret
;---------------------------------------
drawborders:
	push es
	pusha
	push di
	
	mov ax, 0xb800
	mov es, ax
	xor di, di
	xor si, si
	
	mov cx, 80
	mov ah, 0x7E
	mov al, 0xB0
	cld
	rep stosw
	mov cx, 80
	mov di, 3840
	cld
	rep stosw

	mov di, 160
	mov cx, 80
	mov ax, 0x79F0
	cld
	rep stosw
	mov di, 3680
	mov cx, 80
	mov ax, 0x79F0
	cld
	rep stosw
	call drawcentre
	
	pop es
	popa
	pop di
	ret
;---------------------------------------
drawcentre:
	push es
	push di
	push si
	pusha

	mov ax, 0xb800
	mov es, ax
	xor di, di
	
	mov di, 236
	add di, 160
	mov cx, 21
	mov ax, 0x7EB3
centre:
	mov word[es:di], ax
	mov si, di
	add si, 2
	mov word[es:si], ax
	add di, 160
	loop centre

	popa
	pop si
	pop di
	pop es
	ret	
;---------------------------------------
drawplayers:
	push es
	pusha
	push di
	push si
	
	mov ax, 0xb800
	mov es, ax
	xor di, di
	xor si, si
	
	mov di, 322
	mov ax, 0x7020
	mov cx, 21
clrp1:
	mov word[es:di], ax
	add di, 160
	loop clrp1

	mov di, 476
	mov ax, 0x7020
	mov cx, 21
clrp2:
	mov word[es:di], ax
	add di, 160
	loop clrp2
	
	mov cx, 5
	mov ax, [paddle1]
	mov bx, 160
	mul bx
	add ax, 2
	mov di, ax

	mov ax, [paddle2]
	mov bx, 160
	mul bx
	add ax, 156
	mov si, ax

	mov ax, 0x7C08
paddle1draw:
	mov word[es:di], ax
	add di, 160
	loop paddle1draw

	mov cx, 5
	mov ah, 0x73
paddle2draw:
	mov word[es:si], ax
	add si, 160
	loop paddle2draw

	pop si
	pop di
	popa
	pop es
	ret
;--------------------------------------
printnum:
	push bp
	mov bp, sp
	push es
	pusha
	push di

	mov ax, 0xb800
	mov es, ax
	mov ax, [bp+6]
	mov bx, 10
	mov cx, 0
nextdigit: 
	mov dx, 0 
	div bx 
	add dl, 0x30 
	push dx 
	inc cx 
	cmp ax, 0 
	jnz nextdigit 
	mov di, [bp+4]
nextpos: 
	pop dx 
	mov dh,[bp+8]
	mov [es:di], dx
	add di, 2 
	loop nextpos 
	pop di
	popa
	pop es
	pop bp
	ret 6
;--------------------------------------
drawscore:
	push es
	push ax
	push cx
	push di

	mov ax, 0xb800
	mov es, ax
	
	mov di, 2
	mov si, scoreheader1
	mov cx, 10
	mov ah, 0x71
	cld
nextch:
	lodsb
	stosw
	loop nextch

        push 0x71        ; color
	push word[score1]
	push di
	call printnum

	mov di, 136
	mov si, scoreheader2
	mov cx, 10
nextch2:
	lodsb
	stosw
	loop nextch2

        push 0x71         ; color
	push word[score2]
	push di
	call printnum
	
	pop di
	pop cx
	pop ax
	pop es
	ret 
;---------------------------------------
inputs:
	push ax

	mov ah, 0x01
	int 16h
	jz inputdone

	mov ah, 0
	int 16h
	
	cmp ah, 0x01   ; Check for ESC key to exit
	je setexit
	
	cmp al, 'w'   ;player 1 movement keys
	je movep1up
	cmp al, 'W'
	je movep1up
	cmp al, 's'
	je movep1down
	cmp al, 'S'
	je movep1down

	cmp ah, 0x48 	; Player 2 movement keys
	je movep2up
	cmp ah, 0x50
	je movep2down
	jmp inputdone
setexit:
	mov word[gameover], 1
	jmp inputdone

movep1up:
	cmp word[paddle1], 2
	jle inputdone
	dec word[paddle1]
	call drawplayers
	jmp inputdone
movep1down:
	cmp word[paddle1], 18
	jge inputdone
	inc word[paddle1]
	call drawplayers
	jmp inputdone
movep2up:
	cmp word[paddle2], 2
	jle inputdone
	dec word[paddle2]
	call drawplayers
	jmp inputdone
movep2down:
	cmp word[paddle2], 18
	jge inputdone
	inc word[paddle2]
	call drawplayers
	jmp inputdone
inputdone:
	pop ax
	ret
;---------------------------------------
drawball:
	push es
	push di
	pusha

	mov ax, 0xb800
	mov es, ax
	
	mov ax, [ballrow]   ;ballrow
	mov bx, 80
	mul bx
	add ax, [ballcol]  ;ballcol
	shl ax, 1
	mov di, ax

	mov ax, 0x7509
	mov [es:di], ax

	mov word[oldposition], di
	
	popa
	pop di
	pop es
	ret
;---------------------------------------
eraseball:
	push es
	push di
	pusha

	mov ax, 0xb800
	mov es, ax
	xor di, di
	
	mov di, [oldposition]
	mov ax, 0x7020

	mov [es:di], ax
	call drawcentre

	popa
	pop di
	pop es
	ret
;---------------------------------------
bounceball:
	pusha
	call eraseball
	
	mov ax, [ballrow]
	mov bx, [balldirrow]
	add ax, bx
	mov [ballrow], ax

	mov ax, [ballcol]
	mov bx, [balldircol]
	add ax, bx
	mov [ballcol], ax

	mov ax, [ballrow]
	cmp ax, 2
	jl godown
	cmp ax, 22
	jg goup
	jmp checksides	
godown:
	mov word[ballrow], 2
	mov word[balldirrow], 1
	jmp checksides
goup:
	mov word[ballrow], 22
	mov word[balldirrow], -1
checksides:
	mov ax, [ballcol]
	cmp ax, 0
	je p2scores
	cmp ax, 79
	je p1scores
checkpaddles:
	mov ax, [ballcol]
	cmp ax, 1
	jle checkright
	cmp ax, 77
	jge checkleft
	jmp draw
checkright:
	mov dx, [paddle1]
	sub dx, 1
	mov bx, [ballrow]
	cmp bx, dx
	jb p2scores
	add dx, 6
	cmp bx, dx
	ja p2scores
	
	mov word[ballcol], 3
	mov word[balldircol], 1
	jmp draw
checkleft:
	mov dx, [paddle2]
	sub dx, 1
	mov bx, [ballrow]
	cmp bx, dx
	jb p1scores
	add dx, 6
	cmp bx, dx
	ja p1scores
	
	mov word[ballcol], 76
	mov word[balldircol], -1
	jmp draw
p1scores:
	add word[score1], 1
	cmp word[score1], 10
	jb resetball
	cmp word[score1], 10
	je endgame	
p2scores:
	add word[score2], 1
	cmp word[score2], 10
	je endgame
resetball:
        call rand
        mov bx, 24
        xor dx, dx
        div bx
        add dx, 2
        mov [ballrow], dx

        mov word [ballcol], 39

        mov ax, [random]
        shr ax,1
        jc go_left

        mov word [balldirrow], 1
        mov word [balldircol], -1
        mov word[random],ax
        jmp dir_done
go_left:
        mov word [balldirrow], -1
        mov word [balldircol], 1
        mov word[random],ax
dir_done:
    	call drawball
    	call drawscore
    	jmp exitcall
draw:
	call drawball
	call drawscore
exitcall:
	popa
	ret
endgame:
	mov word[gameover], 1
	popa
	ret
;---------------------------------------
rand:
    	mov ah, 0
    	int 1Ah              ; BIOS timer tick
    	xor ax, ax
    	add ax, dx           ; use low word of tick
    	add ax, cx           ; mix high word
    	rol ax, 3            ; rotate bits for extra mixing
    	ret
;---------------------------------------
timerinterrupt:
      pusha
      push bp
      push ds
      push es

      push cs
      pop ds

      cmp word [gameover], 1
      je finish

      inc word [tick]

      mov ax, [tick]
      xor dx, dx
      mov bx, [delay]
      div bx
      cmp dx, 0
      jne finish

      call bounceball
finish:
      pop es
      pop ds
      pop bp
      popa

      jmp far [cs:oldtimer]
;---------------------------------------
gaming:
      call inputs
      cmp word [gameover], 1
      jne gaming
      ret
;---------------------------------------
hooking:
      mov ah, 0x01
      mov cx, 0x2000
      int 0x10

      xor ax, ax
      mov es, ax

      mov ax, [es:8*4]        ; current timer ISR offset
      mov dx, [es:8*4+2]      ; current timer ISR segment
      mov word [oldtimer], ax
      mov word [oldtimer+2], dx

      mov ax, timerinterrupt
      cli
      mov [es:8*4], ax
      mov [es:8*4+2], cs
      sti
      ret
;---------------------------------------
unhooking:
      xor ax, ax
      mov es, ax
      push ds
      lds si, [oldtimer]
      cli
      mov [es:8*4], si
      mov [es:8*4+2], ds
      sti
      pop ds
      jmp terminate
;---------------------------------------
exit:
      	call clrscr
	push endart
      	call draw_text

      	push 0xf4         ; color 
      	push msg2
      	push 22
      	push 22
      	call printstr

      	push 0x31         ; color 
      	push player1_text
      	push 14
      	push 18
      	call printstr

      	push 0x31         ; color 
      	push score_text
      	push 16
      	push 18
      	call printstr

      	push 0x31         ; color
      	push word[score1]
      	push 2608
      	call printnum

      	push 0x31         ; color 
      	push player2_text
      	push 14
      	push 52
      	call printstr

      	push 0x31         ; color 
      	push score_text
      	push 16
      	push 52
      	call printstr
      
      	push 0x31         ; color 
      	push word[score2]
      	push 2676
      	call printnum
	push ax
	push bx

     	mov ax, [score1]
     	mov bx, [score2]
     	cmp ax, bx
     	ja p1
     	jb p2

      	push 0x31         ; color 
      	push tie
      	push 18
      	push 28
      	call printstr
      	jmp win_message_end
p2:
      	push 0x31         ; color 
      	push p2won
      	push 18
      	push 26
      	call printstr
      	jmp win_message_end
p1:
      	push 0x31         ; color 
      	push p1won
      	push 18
      	push 26
      	call printstr
win_message_end:
	pop bx
	pop ax
wait_for_key:
      	mov ah, 0
      	int 0x16

      	cmp al, 27            ; ESC
      	je end

      	cmp al, 13            ; Enter
      	je restart_game

      	jmp wait_for_key
restart_game:
      	mov word [paddle1], 5
      	mov word [paddle2], 15
      	mov word [score1], 0
      	mov word [score2], 0
      	mov word [ballrow], 11
      	mov word [ballcol], 38
      	mov word [balldirrow], -1
      	mov word [balldircol], 1
      	mov word [oldposition], 0
      	mov word [tick], 0
      	mov word [delay], 1
      	mov word [gameover], 0
      	mov word [random],0xAAAA
      	jmp game
end:
      	call unhooking
;---------------------------------------
start:
coverpage:
      	call clrscr
      	call draw_table
	push art
      	call draw_text
	mov ah, 01h
	mov ch, 20h   ; hide cursor
	mov cl, 00h   ; end scan line
	int 10h

      	push 0xf4         ; color 
      	push msg1
      	push 22
      	push 22
      	call printstr
wait_:
      	mov ah, 0
      	int 0x16

      	cmp al, 27
      	je terminate

      	cmp al, 13
      	je hook
      	jmp wait_
hook:
      	call hooking
game:
      	call clrscr
      	call drawborders
      	call drawplayers
      	call drawball
      	call drawscore
      	call gaming
      	jmp exit
;---------------------------------------
terminate:
      	call clrscr
      	mov ah, 0x01    ;cursor view
      	mov cx, 0x0607
      	int 10h

      	mov ax, 0x4C00
      	int 21h