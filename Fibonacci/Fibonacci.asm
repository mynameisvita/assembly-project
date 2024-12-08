section .text
global main
extern printf
extern fflush
extern ExitProcess

main:
    mov     rbp, rsp
    xor     rax, rax
    
    ; F(n) = F(n-1) + F(n-2) (N>=2)
    mov     rax, 15 ; F(15)를 구해보자
    mov     rdx, rax
    push    rax
    call    Fibonacci
    pop     rax
    
    mov     rax, rcx
    xor     rcx, rcx
    lea     rcx, [msg]
    mov     r8, rax
    
    xor     rax, rax
    call    printf      
    
    xor     rcx, rcx
    call    fflush
   
    add     rsp, 8
    call    ExitProcess  
    ret
    
Fibonacci:
    push    rbp 
    mov     rbp, rsp
    mov     rax, [rbp + 16] ;매개변수 가져오기
    
    ; 만약에 현재 값이 0 이면 
    cmp     rax, 0 
    je      END_FALG0
    
    ; 만약에 현재 값이 1 이면
    cmp     rax, 1
    je      END_FALG1
    
    sub     rsp, 32 ; 지역변수 4개 할당
    mov     rbx, rax
    sub     rbx, 1
    mov     qword [rbp -  8],  rbx
    sub     rbx, 1
    mov     qword [rbp - 16],  rbx
    mov     qword [rbp - 24],  0
    mov     qword [rbp - 32],  0
    
    mov     eax, dword [rbp - 16]
    push    rax
    call    Fibonacci
    pop     rax
    mov     [rbp - 24], rcx
    
    xor     rax, rax
    xor     rcx, rcx
    
    mov     eax, dword [rbp - 8]
    push    rax
    call    Fibonacci
    pop     rax
    mov     [rbp - 32], rcx
    
    xor     rcx, rcx
    xor     rbx, rbx
    
    add     rbx, [rbp-24]
    add     rbx, [rbp-32]
    mov     rcx, rbx
    
    add     rsp, 32 ; 지역변수 4개 할당 해제 
    pop     rbp
    ret
    
END_FALG0:
    mov     ecx, 0
    
    pop     rbp
    ret
    
END_FALG1:
    mov     ecx, 1
    
    pop rbp
    ret
    
section .data
    msg db "F(%d) = %d", 0 