# ash — A Minimal x86-64 Assembly Shell

A tiny static shell written in pure NASM assembly for Linux. 

> Expect this README to chenge. I'm going to rewrite it in my usual style later.

## Features

- **8.6 KB** static binary (stripped)
- Prompt (`ash> `)
- Executes programs with full path
- Multiple arguments support
- `exit` builtin to quit
- Pure x86-64 Linux syscalls (`write`, `read`, `fork`, `execve`, `wait4`, `exit`)

## Build

```bash
nix develop   # or install nasm + binutils manually
```
```bash
nasm -f elf64 ash.asm -o ash.o
```
```bash
ld ash.o -o ash
```
```bash
strip ash
```

## Usage

```bash
./ash
```
```bash
ash> /run/current-system/sw/bin/ls
ash> /run/current-system/sw/bin/echo hello world
ash> exit
```

**Warning**: You have to type in the full path to your programs. These here are 
the paths on my NixOS system. Depending on your system, the paths might differ.
check with `which<program>` for the path.

Single-command pipe:
```bash
echo "/run/current-system/sw/bin/echo hello" | ./ash
```

## Requirements

- Linux x86-64
- NASM assembler
- GNU ld (binutils)

## Detailed explanation, because why not?
- `global _start` just makes the `_start` symbol visible to the linker, so it nows where to begin
    - You can think of it as the `main()` entry point equivalent in C 

- Then comes the `section .data`. This holds initialized data
    - values that already exist when the program starts, like the shell Prompt

- `prompt db "ash> "` stores five bytes that make up our prompt
    - `db` mean **define byte**. It places the specified bytes into memory

- `prompt_len equ $ - prompt` defines a constant(unmutable) equal to the current assembly position (`$`) minus the adress of `prompt`
    - So it basically calculates the length of `prompt`

- `err_msg db "exec failed", 10` stores the error message like the prompt
- `20` is the ASCII line-feed byte, like `\n` in many other, high level, languages

And now we get to `section .bss`
- `.bss` reserves space for data that doesn't need explicit initial values in the executable

- `resb 256` reserves 256 bytes for command input
-  `resq 32` reserves 32 quadwords -> a quadword is 8 bytes in 64-bit assembly

So the memory becomes:
256 bytes `input` -> the command the user types
256 bytes `argv`  -> Up to 32, eigh-byte argument-pointer slots

`argv` needs 256, becuase it is an array of pointers. In x86_64 Assembly, each pointer is 8-bytes.

- All the real executable instructions live in `section .text`

`_start` and `main_loop` mark adresses in the code, They are not instructions themselves

- In the main loop, you can find the section that writes the prompt:
```
mov rax, 1
mov rdi, 1 
mov rsi, prompt
mov rdx, prompt_len
syscall 
```

- `mov rax, 1` Selects Linux's `write` system call. On x86_64 linux, syscall 1 is `write`
- `mov rdi, 1` Sets the first argument to `1`, standard output
    `0` is standard input, `1` is standard output and `2` standard error

- `mov rsi, prompt` sets the second argument to the adress of the bytes containing `"ash>`

## License

MIT License — see [LICENSE](LICENSE)
