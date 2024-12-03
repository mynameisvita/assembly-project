section .data
frontBuffer     db 80 * 25 dup(' ')
width           dd 80
height          dd 25
formatStringC   db "%c", 0
formatStringS   db "%s", 0
enterString     db 10, 0
millseconds     dq 33 
consoleHandle   dq 0
snakeHeadPos    dd 0

wkeyCode       equ 0x57          
akeyCode       equ 0x41    
skeyCode       equ 0x53    
dkeyCode       equ 0x44      

cursorInfo:
   dd 1 
   dd 0 

section .bss
align 4  
coord:
    resw 1  
    resw 1  

section .text
global main
extern printf
extern ExitProcess
extern GetStdHandle
extern fflush
extern Sleep
extern time
extern SetConsoleCursorInfo
extern SetConsoleCursorPosition
extern GetLastError
extern system
extern GetAsyncKeyState

main:
   push    rbp
   mov     rbp, rsp
   sub     rsp, 32            
   and     rsp, -16           

   ; 플레이어 좌표 초기화
   xor     rax, rax
   mov     ax,   5
   mov     word [snakeHeadPos], ax
   mov     word [snakeHeadPos+2], ax

   mov     ecx, -11
   sub     rsp, 32            
   call    GetStdHandle
   add     rsp, 32            
   mov     [consoleHandle], rax
   
   mov     rcx, rax          
   lea     rdx, [cursorInfo]  
   sub     rsp, 32            
   call    SetConsoleCursorInfo
   add     rsp, 32           
   
GAME_LOOP:
   call     update
   call     redner
   mov      rcx, [millseconds]
   sub      rsp, 32
   call     Sleep
   add      rsp, 32
   jmp      GAME_LOOP
   xor      rcx, rcx
   call     ExitProcess
   ret


update:
   push     rbp
   mov      rbp, rsp
   sub      rsp, 40
   
   sub      rsp, 32  
   mov      ecx, wkeyCode
   call     GetAsyncKeyState
   add      rsp, 32
   
   test    rax, rax
   jz      W_NOT_PRESSED
   mov     word [rbp - 4], 0 ; UP   
   mov     word [rbp - 6], 0 ; nextX
   mov     word [rbp - 8], -1 ; nextY
            
W_NOT_PRESSED:
   
   sub      rsp, 32  
   mov      ecx, akeyCode
   call     GetAsyncKeyState
   add      rsp, 32
   
   test     rax, rax
   jz       A_NOT_PRESSED
   mov      word   [rbp - 4], 1 ; LEFT
   mov      word   [rbp - 6], -1 ; nextX
   mov      word   [rbp - 8], 0 ; nextY
       
A_NOT_PRESSED:   

   sub      rsp, 32  
   mov      ecx, skeyCode
   call     GetAsyncKeyState
   add      rsp, 32
   
   test     rax, rax
   jz       S_NOT_PRESSED
   mov      word   [rbp - 4], 2 ; DWON
   mov      word   [rbp - 6], 0 ; nextX
   mov      word   [rbp - 8], 1 ; nextY

S_NOT_PRESSED:
   
   sub      rsp, 32  
   mov      ecx, dkeyCode
   call     GetAsyncKeyState
   add      rsp, 32
   
   test     rax, rax
   jz       D_NOT_PRESSED
   mov      word   [rbp - 4], 3 ; RIGHT
   mov      word   [rbp - 6], 1 ; nextX
   mov      word   [rbp - 8], 0 ; nextY
   
D_NOT_PRESSED:

   ; 플레이어 좌표 변경
   xor      rax, rax
   xor      rbx, rbx
   mov      bx, word [snakeHeadPos]
   add      bx, [rbp-6]
   mov      word [snakeHeadPos], bx
   mov      ax, word [snakeHeadPos+2]     
   add      ax, [rbp-8]
   mov      word [snakeHeadPos+2], ax

  
   ; 플레이어 위치 버퍼에 반영
   xor      rax, rax
   xor      rbx, rbx
   mov      bx, word [snakeHeadPos]
   mov      ax, word [snakeHeadPos+2]
   imul     eax, [width]
   add      eax, ebx
   
   mov      byte [frontBuffer + eax], 'O'
   
   mov      rsp, rbp
   pop      rbp
   ret


redner:
   push     rbp
   mov      rbp, rsp
   sub      rsp, 160

   mov      word [coord], 0     
   mov      word [coord+2], 0   
   mov      rcx, [consoleHandle]
   movzx    eax, word [coord]    
   movzx    ebx, word [coord+2] 
   shl      ebx, 16             
   or       eax, ebx             
   mov      edx, eax           
   call     SetConsoleCursorPosition
   mov      dword [rbp - 8], 0

HEIGHT_LOOP:
   mov      dword [rbp - 4], 0

WIDTH_LOOP:
   mov      eax, [rbp - 8]
   imul     eax, [width]
   add      eax, [rbp - 4]

   mov      ebx, [rbp - 8]
   cmp      ebx, 0
   je       IS_WALL

   mov      ebx, [rbp - 8]
   cmp      ebx, 24
   je       IS_WALL

   mov      ebx, [rbp - 4]
   cmp      ebx, 0
   je       IS_WALL

   mov      ebx, [rbp - 4]
   cmp      ebx, 79
   je       IS_WALL

   jmp      IS_NOT_WALL
IS_WALL:
   mov      byte [frontBuffer + eax], '#'

IS_NOT_WALL:
   mov      rdx, [frontBuffer + eax]
   lea      rcx, [formatStringC]
   sub      rsp, 32
   call     printf
   add      rsp, 32

   mov      eax, [rbp - 4]
   inc      eax
   mov      [rbp - 4], eax
   cmp      eax, [width]
   jl       WIDTH_LOOP

   lea      rcx, [formatStringS]
   lea      rdx, [enterString]
   sub      rsp, 32
   call     printf
   add      rsp, 32

   mov      eax, [rbp - 8]
   inc      eax
   mov      [rbp - 8], eax
   cmp      eax, [height]
   jl       HEIGHT_LOOP

   xor      rcx, rcx
   sub      rsp, 32
   call     fflush
   add      rsp, 32

   mov      rsp, rbp
   pop      rbp
   ret