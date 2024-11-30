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
global main

section .data
    format_int db "%d", 0
    int_input  dd 0
    welcomeMsg db '-----------------------', 10, '|      Text RPG        |', 10, '-----------------------', 10, 0
    playerSelectMsg db 'Your job Select!', 10, '1. warrior, 2. archer, 3. wizard', 10, 0
    inputMsg db 'You selected: %d', 10, 0  
    reSelectMsg db 'It`s a wrong choice. Please select a value between 1 and 3', 10, 0
    warrior db 'warrior', 0
    archer db 'archer', 0
    wizard db 'wizard' ,0
    slime db 'SLIME', 0
    skeleton db 'SKELETON', 0
    zombie db 'ZOMBIE' ,0
    selectJobInfoMsg db '-----------------------',10, 'You have chosen to be a %s!!', 10, '-----------------------', 10, 'Your Spec', 10, 0 
    specJobInfoMsg db 'Hp: %d', 10, 'Attack: %d', 10, 0
    playerStateInfo dq 0
    monsterStateInfo dq 0
    monsterSpawnInfoMsg db '-----------------------', 10, 'Warning Monster Spawn! >> %s', 10, '-----------------------', 10, 0
    heapHandle dq 0
    playerAttackMsg db 'Player Attack: %d >> Monster Hp: %d', 10, 0
    monsterAttackMsg db 'Monster Attack: %d >> Player Hp: %d', 10, 0
    playerDieMsg db 'Player Die...', 10, 0
    
section .text
main:
    mov     rbp, rsp                  
    push    rbp
    sub     rsp, 160                 

    lea     rdi, [rbp - 160]          
    mov     rcx, 20                  
    mov     rax, 0                   
    rep     stosq

    call    GetProcessHeap    
    mov     [heapHandle], rax   
    mov     rcx, [heapHandle]
    xor     rdx, rdx
    mov     r8, 256
    call    HeapAlloc
    mov     [playerStateInfo], rax    

    xor     rcx, rcx                 
    call    time
    mov     [rsp + 16], rax          
    mov     rcx, [rsp + 16]           
    call    srand

    lea     rcx, [welcomeMsg]
    xor     rax, rax
    call    printf

    xor     rcx, rcx
    call    fflush
    
RE_GAME:
    lea     rcx, [playerSelectMsg]
    xor     rax, rax
    call    printf

    xor     rcx, rcx
    call    fflush

    jmp     USER_INPUT

RE_SELECT:
    lea     rcx, [reSelectMsg]
    xor     rax, rax
    call    printf

    xor     rcx, rcx
    call    fflush

USER_INPUT:
    lea     rcx, [format_int]
    lea     rdx, [rsp + 8]
    call    scanf

    mov     eax, [rsp + 8]
    cmp     eax, 1
    jl      RE_SELECT

    mov     eax, [rsp + 8]
    cmp     eax, 3
    jg      RE_SELECT
    
    mov     ecx, [rsp + 8]
    push    rcx
    call    printSpec
    pop     rcx
    
    call    rand
    push    rax    
 
    call    monsterSpawn
    pop     rax
   
    call    battle
    jmp     RE_GAME
      
    mov     rcx, [heapHandle]
    xor     rdx, rdx
    mov     r8, [playerStateInfo]
    call    HeapFree
      
    mov     rcx, [heapHandle]
    xor     rdx, rdx
    mov     r8, [monsterStateInfo]
    call    HeapFree
      
    xor     rcx, rcx
    mov     rsp, rbp
    pop     rbp
    
    call    ExitProcess
    ret     

printSpec:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32          
    mov     eax, [rbp + 16]
    
    cmp     eax, 1
    je      WARRIOR_PRINT
    
    cmp     eax, 2
    je      ARCHER_PRINT
    
    cmp     eax, 3
    je      WIZARD_PRINT
    
WARRIOR_PRINT:
    lea     rcx, [selectJobInfoMsg]
    lea     rdx, [warrior]
    xor     rax, rax
    call    printf
        
    xor     rcx, rcx
    call    fflush    
    mov     rax, [playerStateInfo]
    mov     dword [rax], 200   
    mov     dword [rax + 4], 30 
    
    jmp STAT_PRINT

ARCHER_PRINT:
    lea     rcx, [selectJobInfoMsg]
    lea     rdx, [archer]
    xor     rax, rax
    call    printf
        
    xor     rcx, rcx
    call    fflush   
        
    mov     rax, [playerStateInfo]
    mov     dword [rax], 150    
    mov     dword [rax + 4], 60 
        
    jmp STAT_PRINT
    
WIZARD_PRINT:
    lea     rcx, [selectJobInfoMsg]
    lea     rdx, [wizard]
    xor     rax, rax
    call    printf
        
    xor     rcx, rcx
    call    fflush   
        
    mov     rax, [playerStateInfo]
    mov     dword [rax], 100    
    mov     dword [rax + 4], 90 
    
    jmp STAT_PRINT

STAT_PRINT:
    lea     rcx, [specJobInfoMsg]
    mov     rax, [playerStateInfo]
    mov     rdx, [rax]
    mov     r8,  [rax + 4] 
    xor     rax, rax
    call    printf
        
    xor     rcx, rcx
    call    fflush       
        
    mov     rsp, rbp       
    pop     rbp
    ret
        
monsterSpawn:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32          
    mov     rax, [rbp + 16]
    mov     ecx, 3
    div     ecx
    add     rdx, 1
    mov     [rbp - 8], rdx 
    mov     rcx, [heapHandle]
    xor     rdx, rdx
    mov     r8, 256
    call    HeapAlloc
    mov     [monsterStateInfo], rax    
    mov     rdx, [rbp - 8]
    cmp     rdx, 1
    je      SLIME_SPAWN
    
    cmp     rdx, 2
    je      SKELETON_SPAWN
    
    cmp     rdx, 3
    je      ZOMBIE_SPAWN
    
SLIME_SPAWN:
    mov     rax, [monsterStateInfo]
    mov     dword [rax], 100
    mov     dword [rax + 4], 5
    
    lea     rcx, [monsterSpawnInfoMsg]
    lea     rdx, [slime]
    xor     rax, rax
    call    printf
        
    xor     rcx, rcx
    call    fflush  
    
    jmp     MONSTER_SPAWN_END
    
SKELETON_SPAWN:
    mov     rax, [monsterStateInfo]
    mov     dword [rax], 50
    mov     dword [rax + 4], 30
    
    lea     rcx, [monsterSpawnInfoMsg]
    lea     rdx, [skeleton]
    xor     rax, rax
    call    printf
        
    xor     rcx, rcx
    call    fflush  
    
    jmp     MONSTER_SPAWN_END
    
ZOMBIE_SPAWN:
    mov     rax, [monsterStateInfo]
    mov     dword [rax], 250
    mov     dword [rax + 4], 15
    
    lea     rcx, [monsterSpawnInfoMsg]
    lea     rdx, [zombie]
    xor     rax, rax
    call    printf
        
    xor     rcx, rcx
    call    fflush  
    
    jmp     MONSTER_SPAWN_END
    
   
MONSTER_SPAWN_END:
    mov     rsp, rbp       
    pop     rbp
    ret

        
battle:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32          
    
BATTLE_MAIN:
    mov     rax, [playerStateInfo]
    mov     edx, [rax + 4]  
    mov     rax, [monsterStateInfo]
    sub     [rax], edx
    mov     r8d, [rax]
    mov     eax, r8d
    mov     [rbp - 8], eax
    cmp     eax, 0
    jg      MONSTER_HP_PASS
    mov     r8d, 0
        
MONSTER_HP_PASS:
    lea     rcx, [playerAttackMsg]
    call    printf
    
    xor     rcx, rcx
    call    fflush
    
    mov     eax, [rbp - 8]
    cmp     eax, 0
    jle     RE_MONSTER_SPAWN
    
    mov     rax, [monsterStateInfo]
    mov     edx, [rax + 4] 
    
    mov     rax, [playerStateInfo]
    sub     [rax], edx
    mov     r8d, [rax]
    mov     eax, r8d
    
    
    cmp     eax, 0
    jg      PLAYER_HP_PASS
    mov     r8d, 0

PLAYER_HP_PASS:
    lea     rcx, [monsterAttackMsg]
    call    printf
    
    xor     rcx, rcx
    call    fflush
    
    mov     eax, [playerStateInfo]
    mov     ebx, [eax]
    
    mov     ecx, [monsterStateInfo]
    mov     edx, [ecx]
    mov     rax , 0
    cmp     edx, 0
    jle     RE_MONSTER_SPAWN
    
    cmp     ebx, 0
    jle     BATTLE_END
    
    jmp     BATTLE_MAIN
    
RE_MONSTER_SPAWN:
    call    rand
    push    rax    
    call    monsterSpawn
    pop     rax
    jmp     BATTLE_MAIN
    
BATTLE_END:
    lea     rcx, [playerDieMsg]
    call    printf
    
    xor     rcx, rcx
    call    fflush

    mov     rsp, rbp       
    pop     rbp
    
    ret