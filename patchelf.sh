#!/bin/bash

patchelf --replace-needed libstdc++.so.6 ./glibc/libstdc++.so.6 ./toolchain/riscv-as
patchelf --replace-needed libm.so.6 ./glibc/libm.so.6 ./toolchain/riscv-as
patchelf --replace-needed libgcc_s.so.1 ./glibc/libgcc_s.so.1 ./toolchain/riscv-as
patchelf --replace-needed libc.so.6 ./glibc/libc.so.6 ./toolchain/riscv-as
patchelf --set-interpreter ./glibc/ld-linux-x86-64.so.2 ./toolchain/riscv-as

patchelf --replace-needed libm.so.6 ./glibc/libm.so.6 ./toolchain/gnalc
patchelf --replace-needed libstdc++.so.6 ./glibc/libstdc++.so.6 ./toolchain/gnalc
patchelf --replace-needed libgcc_s.so.1 ./glibc/libgcc_s.so.1 ./toolchain/gnalc
patchelf --replace-needed libc.so.6 ./glibc/libc.so.6 ./toolchain/gnalc
patchelf --set-interpreter ./glibc/ld-linux-x86-64.so.2 ./toolchain/gnalc

patchelf --replace-needed libm.so.6 ./glibc/libm.so.6 ./toolchain/linker
patchelf --replace-needed libstdc++.so.6 ./glibc/libstdc++.so.6 ./toolchain/linker
patchelf --replace-needed libgcc_s.so.1 ./glibc/libgcc_s.so.1 ./toolchain/linker
patchelf --replace-needed libc.so.6 ./glibc/libc.so.6 ./toolchain/linker
patchelf --set-interpreter ./glibc/ld-linux-x86-64.so.2 ./toolchain/linker
