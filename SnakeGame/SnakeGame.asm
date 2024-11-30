section .text
extern GetProcessHeap
extern HeapAlloc
extern HeapFree
extern printf
extern ExitProcess
extern fflush
extern scanf
extern srand            
extern rand             
extern time
extern Sleep
global main

section .data
    millseconds dq 1000                 ; 프레임 1초에 33ms 대기는 30FPS
    gameEndFlag db 0                    ; 게임이 끝났는지, 아닌지 체크하는 Flag
    testMsg     db 'Hello World', 10, 0 ; 테스트
    ; Snake Game
section .text
main:
    mov     rbp, rsp                  
    push    rbp
    sub     rsp, 160                 

    lea     rdi, [rbp - 160]          
    mov     rcx, 20                  
    mov     rax, 0                   
    rep     stosq
   
GAME_LOOP:     
    lea     rcx, [testMsg]
    xor     rax, rax
    call    printf
    
    xor     rcx, rcx
    call    fflush
    
    mov     rcx, [millseconds]
    call    Sleep
    jmp     GAME_LOOP
        
    xor     rcx, rcx
    mov     rsp, rbp
    pop     rbp
    
    call    ExitProcess
    ret