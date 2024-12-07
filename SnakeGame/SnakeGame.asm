section .data
frontBuffer     db 80 * 25 dup(' ')
width           dd 80
height          dd 25
formatStringC   db "%c", 0
formatStringS   db "%s", 0
menuString      db "Player Game 'D' Key Press!", 0
enterString     db 10, 0
millseconds     dq 100 
consoleHandle   dq 0
snakeHeadPos    dd 0
direction       dw 0
gameEnd         dd 0
wkeyCode        equ 0x57          
akeyCode        equ 0x41    
skeyCode        equ 0x53    
dkeyCode        equ 0x44      
command         db "cls", 0
heapHandle      dq 0
snake           dq 0
snakeLength     dd 3

preyPos         dd 0

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
extern srand
extern rand
extern SetConsoleCursorInfo
extern SetConsoleCursorPosition
extern GetLastError
extern system
extern GetAsyncKeyState
extern GetProcessHeap
extern HeapAlloc
extern HeapFree
main:
   push    rbp
   mov     rbp, rsp
   sub     rsp, 32            
   and     rsp, -16           

   xor     rcx, rcx
   call    time
   mov     rbx, rax
   mov     rcx, rbx
   call    srand 
   mov     eax, 1 
   mov     dword [gameEnd], eax
   ; 힙 초기화
   call    GetProcessHeap
   mov     [heapHandle], rax
   mov     rcx, [heapHandle]
   xor     rdx, rdx
   mov     r8, 1024
   call    HeapAlloc
   mov     [snake], rax
   mov     word [direction], 3
      
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

            
MAIN_GAME_LOOP:
    cmp     dword [gameEnd], dword 1
    jne     GAME_LOOP

MENU_LOOP:
   lea      rcx, [command]
   call     system
  
   xor      rcx, rcx
   lea      rcx, [menuString]
   call     printf
  
   xor      rcx, rcx
   call     fflush
   
D_KEY_RE_INPUT:
   mov      rcx, 1
   sub      rsp, 32
   call     Sleep
   add      rsp, 32

   sub      rsp, 32  
   mov      ecx, dkeyCode
   call     GetAsyncKeyState
   add      rsp, 32  
       
   test     rax, rax
   jz       D_KEY_RE_INPUT
   
   xor      rcx, rcx
   lea      rcx, [command]
   call     system
   mov      dword [gameEnd], dword 0
   ; 플레이어 좌표 초기화
   call    playerInit
   call    randomPrey
GAME_LOOP:
   call     update
   call     redner
   
   cmp      dword [gameEnd], dword 1
   je       MENU_LOOP
   
   mov      rcx, [millseconds]
   sub      rsp, 32
   call     Sleep
   add      rsp, 32
   jmp      GAME_LOOP
      
GAME_END:
   mov      rcx, [heapHandle]
   xor      rdx, rdx
   mov      r8,  [snake]
   call     HeapFree
   
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
   xor      rcx, rcx
   mov      cx, word [direction]
   mov      word [rbp - 4], cx
   mov      word [rbp - 6], 0
   mov      word [rbp - 8], 0 
    
   test    rax, rax
   jz      W_NOT_PRESSED
   
   cmp     word [rbp - 4],  2
   je      W_NOT_PRESSED 
   
   mov     word [rbp - 4], 0 ; UP      
            
W_NOT_PRESSED:
   
   sub      rsp, 32  
   mov      ecx, akeyCode
   call     GetAsyncKeyState
   add      rsp, 32
   
   test     rax, rax
   jz       A_NOT_PRESSED
   
   cmp     word [rbp - 4],  3
   je      A_NOT_PRESSED 
   
   mov      word   [rbp - 4], 1 ; LEFT
       
A_NOT_PRESSED:   

   sub      rsp, 32  
   mov      ecx, skeyCode
   call     GetAsyncKeyState
   add      rsp, 32
   
   test     rax, rax
   jz       S_NOT_PRESSED
   
   cmp     word [rbp - 4],  0
   je      S_NOT_PRESSED 
   
   mov      word   [rbp - 4], 2 ; DWON

S_NOT_PRESSED:
   
   sub      rsp, 32  
   mov      ecx, dkeyCode
   call     GetAsyncKeyState
   add      rsp, 32
   
   test     rax, rax
   jz       D_NOT_PRESSED
   
   cmp     word [rbp - 4],  1
   je      D_NOT_PRESSED 
   
   mov      word   [rbp - 4], 3 ; RIGHT
     
D_NOT_PRESSED:
   cmp      word [rbp - 4], word 0
   je       UP_MOVE
   cmp      word [rbp - 4], word 1
   je       LEFT_MOVE
   cmp      word [rbp - 4], word 2
   je       DWON_MOVE
   cmp      word [rbp - 4], word 3
   je       RIGHT_MOVE
   
UP_MOVE:
   mov     word [rbp - 6], 0 ; nextX
   mov     word [rbp - 8], -1 ; nextY
   jmp     MOVE_END
LEFT_MOVE:
   mov      word   [rbp - 6], -1 ; nextX
   mov      word   [rbp - 8], 0 ; nextY
   jmp     MOVE_END
DWON_MOVE:
   mov      word   [rbp - 6], 0 ; nextX
   mov      word   [rbp - 8], 1 ; nextY
   jmp     MOVE_END
RIGHT_MOVE:
   mov      word   [rbp - 6], 1 ; nextX
   mov      word   [rbp - 8], 0 ; nextY
   jmp     MOVE_END

MOVE_END:

   mov     ax, word [rbp - 4]
   mov     word [direction], ax

   ; 여기서 충돌 체크 (벽인지, 먹이인지, 자기 꼬리인지)
   xor      rax, rax
   mov      rcx, [snake]
   mov      ax, word [rbp - 6]
   add      ax, word [rcx]
   
   mov      bx, word [rbp - 8]
   add      bx, word [rcx + 2]
   
   cmp      ax, 0
   je       To_END  ; 벽에 닿았음 나중에는 사망 처리
   
   cmp      ax, 79 
   je       To_END  ; 벽에 닿았음 나중에는 사망 처리
   
   cmp      bx, 0
   je       To_END ; 벽에 닿았음 나중에는 사망 처리
   
   cmp      bx, 24
   je       To_END ; 벽에 닿았음 나중에는 사망 처리
      
   cmp      ax, word [preyPos]
   jne      PREY_PASS
    
   cmp      bx, word [preyPos + 2]   
   jne      PREY_PASS
   
   ; 먹이를 먹은거니깐 길이 1 증가
   xor      rcx, rcx
   xor      rdx, rdx
   mov      edx, [snakeLength]
   dec      edx         ; 꼬리 인덱스 구하기
   shl      edx, 2
   mov      rcx, [snake]
   add      rcx, rdx
   
   ; 현재 방향의 반대 값으로 꼬리 생성 (왼쪽이면->오른쪽, 오른쪽->왼쪽, 위->아래, 아래->위)
   cmp      word   [rbp - 4], 0
   jne      NOT_UP
   mov      ax, word [rcx]
   mov      bx, word [rcx+2]
   inc      bx
   add      rcx, 4
   mov      word [rcx], ax
   mov      word [rcx + 2], bx
   xor      rax, rax
   mov      eax, [snakeLength]
   inc      eax
   mov      dword [snakeLength], eax
   
   jmp      PREY_SPAWN
NOT_UP:
   
   cmp      word   [rbp - 4], 1
   jne      NOT_LEFT
   mov      ax, word [rcx]
   mov      bx, word [rcx+2]
   inc      ax
   add      rcx, 4
   mov      word [rcx], ax
   mov      word [rcx + 2], bx
   xor      rax, rax
   mov      eax, [snakeLength]
   inc      eax
   mov      dword [snakeLength], eax
   
   jmp      PREY_SPAWN
   
NOT_LEFT:
   
   cmp      word   [rbp - 4], 2
   jne      NOT_DWON
   mov      ax, word [rcx]
   mov      bx, word [rcx+2]
   dec      bx
   add      rcx, 4
   mov      word [rcx], ax
   mov      word [rcx + 2], bx
   xor      rax, rax
   mov      eax, [snakeLength]
   inc      eax
   mov      dword [snakeLength], eax
   
   jmp      PREY_SPAWN
   
NOT_DWON:
   cmp      word   [rbp - 4], 3
   jne      PREY_PASS
   mov      ax, word [rcx]
   mov      bx, word [rcx+2]
   dec      ax
   add      rcx, 4
   mov      word [rcx], ax
   mov      word [rcx + 2], bx
   xor      rax, rax
   mov      eax, [snakeLength]
   inc      eax
   mov      dword [snakeLength], eax
 
   jmp      PREY_SPAWN
   
PREY_SPAWN:
    call randomPrey

PREY_PASS:
   ; 플레이어 위치 버퍼에 반영
   mov      dword [rbp-28], 0
TEMP_FOR_LOOP1:
   xor      rax, rax
   xor      rbx, rbx
   xor      rdx, rdx
   mov      edx, dword [rbp-28]
   shl      edx, 2
   mov      rcx, [snake]
   add      rcx, rdx
   mov      ax, word [rcx + 2]
   imul     ax, [width]
   mov      bx, word [rcx]
   add      rax, rbx
   mov      byte [frontBuffer + rax], ' '
   add      dword [rbp - 28], 1
   mov      edx, dword [snakeLength]
   cmp      dword [rbp - 28], edx
   jne      TEMP_FOR_LOOP1       
   
   mov       dword [rbp - 14], dword 0 ; prevPos
   mov       dword [rbp - 18], dword 0 ; nextPos
   mov       dword [rbp - 24], dword 0 ; 인덱스
   
   mov      rcx,   [snake]
   mov      ax, word [rcx]
   mov      bx, word [rcx + 2]
   mov      word  [rbp - 14], ax
   mov      word  [rbp - 16], bx    ; prevPos 세팅
   
   xor      rax, rax
   xor      rbx, rbx
   
   mov      rcx, [snake]
   mov      ax, word [rcx]
   add      ax, word [rbp - 6]
   mov      [rbp - 18], word ax
   mov      bx, word [rcx + 2]
   add      bx, word [rbp - 8]
   mov      [rbp - 20], word  bx     ; nextPos 세팅
   
TEMP_FOR_LOOP2:
   xor     rdx, rdx
   mov     edx, [rbp - 24]     ; Index
   shl     edx, 2
   mov     rcx, [snake]        
   add     rcx, rdx 
   mov     ax, word [rcx]          ; prevPos 저장
   mov     word [rbp - 14], ax
   mov     ax, word [rcx + 2]
   mov     word [rbp - 16], ax

   mov     ax, word [rbp - 18]     ; nowPos 갱신
   mov     word [rcx], ax
   mov     ax, word [rbp - 20]
   mov     word [rcx + 2], ax

   mov     ax, word [rbp - 14]     ; nextPos 갱신
   mov     word [rbp - 18], ax
   mov     ax, word [rbp - 16]
   mov     word [rbp - 20], ax 
    
   xor     rdx, rdx    
   mov     edx, dword [snakeLength]
   add     dword [rbp - 24], 1
   cmp     dword [rbp - 24], edx
   jne     TEMP_FOR_LOOP2       


   mov      dword [rbp-28], 0
TEMP_FOR_LOOP3:
   xor      rax, rax
   xor      rbx, rbx
   xor      rdx, rdx
   mov      edx, dword [rbp-28]
   shl      edx, 2
   mov      rcx, [snake]
   add      rcx, rdx
   mov      ax, word [rcx + 2]
   imul     ax, [width]
   mov      bx, word [rcx]
   add      rax, rbx
   mov      byte [frontBuffer + rax], 'O'
   add      dword [rbp - 28], 1
   mov      edx, dword [snakeLength]
   cmp      dword [rbp - 28], edx
   jne      TEMP_FOR_LOOP3     

NOT_UPDATE:   
   mov      rsp, rbp
   pop      rbp
   ret
   
To_END:
   mov      eax, 1
   mov      dword [gameEnd], eax
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
   
   xor      rax, rax
   mov      ax, word [preyPos]
   mov      word [coord], ax  
   mov      ax, word [preyPos + 2]   
   mov      word [coord+2], ax   
   mov      rcx, [consoleHandle]
   movzx    eax, word [coord]    
   movzx    ebx, word [coord+2] 
   shl      ebx, 16             
   or       eax, ebx             
   mov      edx, eax           
   call     SetConsoleCursorPosition
   
   mov      rdx, '$'
   lea      rcx, [formatStringC]
   call     printf
   
   xor      rcx, rcx
   sub      rsp, 32
   call     fflush
   add      rsp, 32

   mov      rsp, rbp
   pop      rbp
   ret
   
randomPrey:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32
    
RE_XPOS:
    call    rand
    xor     rcx, rcx 
    mov     ecx, dword [width]
    xor     rdx, rdx
    div     ecx
    
    cmp     rdx, 0
    je      RE_XPOS

    cmp     rdx, 79
    je      RE_XPOS
    mov     word [preyPos], word dx  
    
RE_YPOS:
    xor     rax, rax
    call    rand
    xor     rcx, rcx
    mov     ecx, dword [height]
    xor     rdx, rdx
    div     ecx
    
    cmp     rdx, 0 
    je      RE_YPOS
    
    cmp     rdx, 24
    je      RE_YPOS
    mov     word [preyPos + 2], word dx            
    mov     rsp, rbp
    pop     rbp
    ret
    
    
playerInit:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32
       
    xor      rax, rax
    xor      rbx, rbx
    xor      rdx, rdx
    mov      eax, [width]
    imul     eax, [height]
       
TEMP_FOR_LOOP4:
    mov      byte [frontBuffer + edx], ' '
    inc      edx
    cmp      eax, edx
    jne      TEMP_FOR_LOOP4      
    
   ; 플레이어 좌표 초기화
   xor     rax, rax
   mov     dword [snakeLength], 3   
   mov     rcx, [snake]
   mov     [rcx], word 5
   mov     [rcx + 2], word 5
   add     rcx, 4
   mov     [rcx], word 4
   mov     [rcx + 2], word 5
   add     rcx, 4
   mov     [rcx], word 3
   mov     [rcx + 2], word 5
    
    mov     rsp, rbp
    pop     rbp
    ret