global _start

section .data
  prompt db "ash> "
  prompt_len equ $ - prompt

  exit_cmd db "exit", 10
  exit_len equ $ - exit_cmd

section .bss
  input resb 256

section .text 
_start:

main_loop:
  ; This writes the Prompt to the terminal via stdout (sys_call 1)
  mov rax, 1
  mov rdi, 1
  mov rsi, prompt
  mov rdx, prompt_len
  syscall 

  ; Read the actual input from user (sys_call again)
  mov rax, 0
  mov rdi, 0
  mov rsi, input
  mov rdx, 256
  syscall

  ; Exit if EOF or read erro
  test rax, rax
  jle exit_shell

  ; Compare the input with 'exit'
  cmp rax, exit_len
  jne main_loop

  mov rsi, input
  mov rdi, exit_cmd
  mov rcx, exit_len
  repe cmpsb
  je exit_shell

  jmp main_loop

exit_shell:
  mov rax, 60
  xor rdi, rdi
  syscall
