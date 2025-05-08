; boot.asm
[bits 16]
[org 0x7c00] 

jmp start

%macro print 1 
  push si
  mov si, %1 
  
%%print_loop:
  lodsb
  cmp al, 0
  je %%done
  mov ah, 0x0E 
  mov bh, 0x00 
  int 0x10 

  jmp %%print_loop
%%done:
  pop si
%endmacro

%macro CRLF 0 
  ; Carriage Return
  mov al, 0x0D
  mov ah, 0x0E
  int 0x10

  ; Line Feed
  mov al, 0x0A
  mov ah, 0x0E
  int 0x10
%endmacro

%macro hextoascii 0
  push eax
  push edx 

  cmp dl, 9 
  jbe %%is_digit
  add dl, 55 
  jmp %%done

%%is_digit:
  add dl, 48
%%done:
  mov ah, 0x0E 
  mov al, dl 
  int 0x10 

  pop edx
  pop eax
%endmacro

%macro debug 0 ; Register eAX, eCX, eBx..
  push ebx
  push ecx
  push edx

  mov ebx, 28
%%lloop:
  mov edx, eax
  mov cl, bl
  shr edx, cl
  and edx, 0xF ; Nibble Mask
  
  hextoascii

  sub ebx, 4
  cmp ebx, -4  
  jne %%lloop 
%%done:
  pop edx
  pop ecx
  pop ebx
%endmacro

%macro memory 0 
  mov si, buffer
  xor ebx, ebx
  mov eax, 0xE820
  mov edx, 0x534D4150 ; SMAP = 534x534D4150
  mov ecx, 24
  int 0x15
%endmacro
  

data:
  msg db 'Bootloader Loaded Successfully',0 
  buffer times 24 db 0


start:
  ; Create Stack Segment
  mov ax, 0x9000
  mov ss, ax
  mov sp, 0xFFFF

  ; Create Data Segment
  mov ax, 0x0000
  mov ds, ax

  print msg
  CRLF
  memory
  debug

;move_to_safety:
  ; Move to 0x9000:0000 to prevent BIOS clobbering
done:
 cli 
 hlt
 times 510 - ($ - $$) db 0 
 dw 0xAA55
