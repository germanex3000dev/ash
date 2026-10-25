global _start

section .data
  prompt db "ash> "
  prompt_len equ $ - prompt
  err_msg db "exec failed", 10
  err_len equ $ - err_msg

section .bss
  input resb 256
  argv resq 32

section .text
_start:
main_loop:
  ; write prompt
  mov rax, 1
  mov rdi, 1
  mov rsi, prompt
  mov rdx, prompt_len
  syscall

  ; read line
  mov rax, 0
  mov rdi, 0
  mov rsi, input
  mov rdx, 255
  syscall

  test rax, rax
  jle exit_shell

  ; null-terminate (replace newline)
  mov byte [rsi + rax - 1], 0

  ; check for "exit"
  mov rdi, input
  mov rsi, exit_str
  mov rcx, 4
  repe cmpsb
  je exit_shell

  ; parse args: split on spaces
  mov rdi, input
  mov rsi, argv
  mov rcx, 31
.parse_loop:
  cmp byte [rdi], 0
  je .parse_done
  cmp byte [rdi], ' '
  je .skip_space
  mov [rsi], rdi
  add rsi, 8
  dec rcx
  jz .parse_done
.find_end:
  inc rdi
  cmp byte [rdi], 0
  je .parse_done
  cmp byte [rdi], ' '
  jne .find_end
  mov byte [rdi], 0
.skip_space:
  inc rdi
  jmp .parse_loop
.parse_done:
  mov qword [rsi], 0

  ; fork
  mov rax, 57
  syscall
  test rax, rax
  jz child

  ; parent: wait
  mov rdi, rax
  mov rax, 61
  xor rsi, rsi
  xor rdx, rdx
  xor r10, r10
  syscall
  jmp main_loop

child:
  mov rdi, [rel argv]
  mov rsi, argv
  mov rdx, 0
  mov rax, 59
  syscall

  mov rax, 1
  mov rdi, 2
  mov rsi, err_msg
  mov rdx, err_len
  syscall
  mov rax, 60
  mov rdi, 1
  syscall

exit_shell:
  mov rax, 60
  xor rdi, rdi
  syscall

section .rodata
  exit_str db "exit"