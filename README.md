# ash — A Minimal x86-64 Assembly Shell

A tiny static shell written in pure NASM assembly for Linux. No libc, no dependencies.

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

## License

MIT License — see [LICENSE](LICENSE)
