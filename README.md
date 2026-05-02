# x86 Bootloader

A minimal x86 bootloader written in 16-bit real mode assembly using NASM.

---

## What is a bootloader?

When you turn a computer on, the BIOS scans connected drives looking for a boot
device. It reads the first 512 bytes of each drive and checks if the last 2 bytes
are `0x55AA`, which is the boot signature. If found, it loads those 512 bytes into memory
at address `0x7C00` and hands execution over to them.

Growing up with a Windows computer, it was interesting to learn how this happens under the hood, explaining why installing Windows required booting from a flash drive in the first place.

---

## How does this bootloader work?

This bootloader prints a message to the screen entirely through BIOS interrupt calls,
with no operating system involved. Here is what happens:

- Clears the screen using `int 0x10`
- Moves the cursor to position `(0, 0)`
- Loops through a null-terminated string stored in the boot sector itself,
  printing each character via the BIOS teletype function (`AH=0x0E`),
  until it hits the null terminator `0x00`
- Halts the processor with `cli` and `hlt`

The string lives directly in the 512-byte boot sector in memory — there is no heap,
no OS, no file system. Everything is packed into those 512 bytes.

---

## How to run

**Requirements:** [NASM](https://www.nasm.us/), [QEMU](https://www.qemu.org/)

Assemble the source:
```bash
nasm -f bin boot.asm -o boot.bin
```

Run in terminal:
```bash
qemu-system-x86_64 -nographic -drive format=raw,file=boot.bin,index=0,media=disk
```
Exit with `Ctrl+A` then `X`.

Run with a GUI window:
```bash
qemu-system-x86_64 -drive format=raw,file=boot.bin,index=0,media=disk
```

---

## What I learned

- How the BIOS boot process works: boot signatures, the load address,
  and the 512-byte constraint
- How x86 real mode works and how memory is addressed through segment registers
- How to use BIOS interrupt calls to do things like clear the screen and print
  characters, without any OS
- How assembly calling conventions work at a low level — stack frames, saving and
  restoring registers, passing arguments

---

## Context

This project builds on LC-3 assembly from ECE 120 and ECE 220, specifically concepts like
registers, memory addressing, the stack, and subroutine calling conventions. Moving from LC-3 
to x86 meant working with a real architecture, real hardware behavior, and no simulator to help debug.

This also serves as preparation for ECE 391 (Computer Systems Programming), which works with the
RISC-V instruction set. Understanding how the processor behaves before an OS loads eases my transition
from ECE 385 (Digital System Laboratory), which was primarily concerned with building hardware, into systems-level programming. 

---

## Reference

Adapted from [Writing a Tiny x86 Bootloader](https://joebergeron.io/posts/post_two.html)
by Joe Bergeron.