; Code starting, defining basical stuff.

[org 0x7c00]            ; Indicates that code must be located at 0x7c00 memory adress
[bits 16]               ; Defines that this code is wroten on 16 bits

; Creating primal registers
mov [MAIN_DISK], dl     ; Save primary disk

mov bp, 0x1000
mov sp, bp              ; Stack located at 0x1000

mov dl, [MAIN_DISK]     ; Save primary disk, again
mov ah, 0x02            ; Reads the disk
mov al, 0x01            ; Number of sectors to read, in this case, 1
mov ch, 0x00            ; Number of cylinder, in this case, 0
mov dh, 0x00            ; Number of head, in this case, 0
mov cl, 0x02            ; Number of sector, in this case, 2
mov bx, 0x8000          ; Save everything on adress 0x8000
int 0x13                ; Call BIOS

; Printing characters
mov bx, PROMPT          ; Loads the value PROMPT into memory, as "b"
call print_string       ; Calls print_string
mov bx, JUMP_LINE       ; Loads the value JUMP_LINE into memory, as "b"
call print_string       ; Calls print_string
mov bx, PRIMPT          ; Loads the value PRIMPT into memory, as "b"
call print_string       ; Calls print_string

jmp $                   ; Jump to the actual memory address

; Drivers
keyboard_driver:
    pusha               ; Save all registers
    in al, 0x60         ; Read in register "al" the port 60
    test al, 0x80
    jnz .end            ; If the value in port 80 is not zero, it ends
    mov bl, al          ; Else, the value will be moved to bl
    xor bh, bh          ; Returns 0
    mov al, [cs:bx + keymap] ; Segments bx, adding the content of keymap. Happy compiler.
    cmp al, 13          ; Compares "al" and return code
    je .enter           ; Checks if enter is executed
    mov bl, [WORD_SIZE]
    mop [WRD+bx], al
    inc bx
    mov [WORD_SIZE], bl
    mov ah, 0x0e
    int 0x10
.end:
    mov al, 0x61
    out 0x20, al
    popa
    iret                ; Returns
.enter:
    mov bx, WRD
    mov cl, [WORD_SIZE]
    mov dx, [HANDLER]

keymap:
    %include "src/bootloader/keymap.inc"

; Functions
print_string:
    pusha               ; Save all registers to the stack
    xor si, si          ; Si = 0
.loop:
    mov al, byte [bx+si]; Tells the video services to print the byte plus the value of "s"
    inc si              ; Increments "s" by one
    cmp al, 0           ; Compares al and 0
    je .end             ; Calls function .end
    call print_char     ; Calls the function print_char
    jmp .loop           ; Loops the function "loop"
.end:
    popa                ; Deletes all registers in the stack
    ret                 ; Return

print_char:
    push ax             ; Save the value of the register "a"
    mov ah, 0x0e        ; Tells the video services to print the character "a"
    int 0x10            ; Calls BIOS interruption
    pop ax              ; Delete the value of the register "a"
    ret                 ; Return

WRD: times 64 db 0      ; A command maximium will have 64 characters
WORD_SIZE: db 0         ; The current ongoing command
MAIN_DISK: db 0         ; Reserve a byte for MAIN_DISK giving it the value of 0
PROMPT: db 'Boada 0-(^_^)-0 <3',0
PRIMPT: db 'Boada 0-(^_^)-0 <3',0
JUMP_LINE: db 0x0a, 0xd ; Reserves memory space for JUMP_LINE, so it can actually jump of line
times 510-($-$$) db 0   ; Fills everything else with 0s
dw 0xaa55               ; Writes (literally defines the word) the boot signature.
