section .data
frontBuffer db 80 * 25 dup(' ')
backBfufer db 80 * 25 dup(' ')
width dd 80
height dd 25
formatStringC db "%c", 0
formatStringS db "%s", 0
enterString db 10, 0
millseconds dq 16 ; 프레임 1초에 33ms 대기는 30FPS
cls_cmd db "cls", 0

cursorInfo:
   dd 1 ; dwSize (커서 크기, 1-100)
   dd 0 ; bVisible (0 = 숨김, 1 = 보임)

section .text
global main
extern printf
extern ExitProcess
extern GetStdHandle
extern fflush
extern Sleep
extern time
extern SetConsoleCursorInfo
extern GetLastError
extern system

main:
   push    rbp
   mov     rbp, rsp
   sub     rsp, 32             ; Windows API 용 섀도우 스페이스
   and     rsp, -16           ; 16바이트 스택 정렬

   ; GetStdHandle 호출
   mov     ecx, -11
   sub     rsp, 32            ; 섀도우 스페이스
   call    GetStdHandle
   add     rsp, 32            ; 스택 복구

   ; SetConsoleCursorInfo 호출
   mov     rcx, rax           ; 핸들
   lea     rdx, [cursorInfo]  ; 커서 정보
   sub     rsp, 32            ; 섀도우 스페이스
   call    SetConsoleCursorInfo
   add     rsp, 32            ; 스택 복구

GAME_LOOP:
   mov byte [frontBuffer + 100], 'b'
   call redner
   mov rcx, [millseconds]
   sub rsp, 32
   call Sleep
   add rsp, 32
   mov rcx, cls_cmd
   sub rsp, 32
   call system
   add rsp, 32
   jmp GAME_LOOP

   xor rcx, rcx
   call ExitProcess
   ret

redner:
   push rbp
   mov rbp, rsp
   sub rsp, 160

   mov dword [rbp - 8], 0

HEIGHT_LOOP:
   mov dword [rbp - 4], 0

WIDTH_LOOP:
   mov eax, [rbp - 8]
   imul eax, [width]
   add eax, [rbp - 4]

   mov ebx, [rbp - 8]
   cmp ebx, 0
   je IS_WALL

   mov ebx, [rbp - 8]
   cmp ebx, 24
   je IS_WALL

   mov ebx, [rbp - 4]
   cmp ebx, 0
   je IS_WALL

   mov ebx, [rbp - 4]
   cmp ebx, 79
   je IS_WALL

   jmp IS_NOT_WALL
IS_WALL:
   mov byte [frontBuffer + eax], '#'

IS_NOT_WALL:
   mov rdx, [frontBuffer + eax]
   lea rcx, [formatStringC]
   sub rsp, 32
   call printf
   add rsp, 32

   mov eax, [rbp - 4]
   inc eax
   mov [rbp - 4], eax
   cmp eax, [width]
   jl WIDTH_LOOP

   lea rcx, [formatStringS]
   lea rdx, [enterString]
   sub rsp, 32
   call printf
   add rsp, 32

   mov eax, [rbp - 8]
   inc eax
   mov [rbp - 8], eax
   cmp eax, [height]
   jl HEIGHT_LOOP

   xor rcx, rcx
   sub rsp, 32
   call fflush
   add rsp, 32

   mov rsp, rbp
   pop rbp
   ret