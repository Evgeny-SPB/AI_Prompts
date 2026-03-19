---
name: verify-driver
description: Verify a flash/target driver's registers, constants, bit definitions, and logic against official vendor documentation. Use when user wants to check a driver against datasheets or reference manuals.
---

Perform a comprehensive verification of the specified flash/target driver files against official vendor documentation (reference manuals, CMSIS headers, datasheets). If no specific files are given, verify all modified (staged + unstaged) driver files shown by `git diff` and `git status`.

## Verification procedure

### Step 1: Identify the target files and chip family

Read the `.h` and `.cpp` files to determine:
- Which chip family (e.g., STM32F3, STM32G0, MKE04, etc.)
- Which vendor reference manual applies
- What peripherals/registers are used

### Step 2: Launch parallel verification agents

Launch **all applicable agents simultaneously** (in a single message) to maximize speed:

#### Agent A — Register addresses and bit definitions

Search the internet for the official reference manual and CMSIS headers for the chip family. Verify **every** constant in the header file:

- Peripheral base addresses
- Register offsets (every register used)
- Bit definitions (every bit constant — name, position, and meaning)
- Unlock key sequences
- Flash/memory characteristics: start address, page/sector sizes, programming width
- Option byte base address and size
- RDP/protection level byte values
- Any other chip-specific constants (OTP base, bank boundaries, etc.)

For each constant, report: code value, official value, and CORRECT/WRONG verdict. Cite the source (reference manual section, CMSIS header name, datasheet table).

#### Agent B — Programming sequences and logic

Search the internet for the official reference manual and ST Standard Peripheral Library / HAL source code. Verify the **logic** of every operation in the `.cpp` file:

- Flash unlock/lock sequences
- Error flag clearing (write-1-to-clear bits, correct mask)
- Mass erase sequence (register write order, required bits)
- Page/sector erase sequence (register write order, address register usage)
- Flash programming sequence (PG bit, write width, wait BSY)
- Option byte unlock sequence
- Option byte erase sequence (OPTER + STRT, required companion bits like OPTWRE)
- Option byte programming sequence (OPTPG, write width)
- Option byte reload mechanism (OBL_LAUNCH or reset)
- RDP level reading logic (which OBR bits, how decoded)
- Wait/busy polling (correct BSY bit, error mask)

Compare each sequence against the reference manual procedure and the SPL/HAL implementation. Report any deviations.

#### Agent C — Thumb/assembly stub verification (only if a binary stub exists)

If the header contains an embedded machine code stub (a `constexpr uint8_t stub[]` array), verify:

- **Every opcode**: decode each instruction pair against the ARM Architecture Reference Manual (ARMv7-M for Cortex-M3/M4, ARMv6-M for Cortex-M0/M0+). Confirm the little-endian byte encoding matches the commented mnemonic.
- **Branch targets**: for every branch instruction (B, BEQ, BNE, etc.), compute the target address using the correct formula (`target = instruction_address + 4 + SignExtend(imm) * 2`) and verify it lands on the intended label.
- **PC-relative loads**: for every `LDR Rn, [PC, #imm]`, compute the effective address (`Align(PC+4, 4) + imm`) and verify it points to the correct literal pool entry.
- **Literal pool values**: verify each 32-bit literal matches the corresponding register address from Agent A.
- **Error mask in stub**: verify the immediate value used for error checking (e.g., `0x14` for PGERR|WRPERR) matches the bit definitions from the header.
- **Total byte count**: count all bytes and verify it matches the `STUB_SIZE` / `sizeof(stub)` and the comment.

#### Agent D — SRAM and memory layout (only if a flash loader stub exists)

Search the internet for datasheets of **all variants** in the chip family. Verify:

- SRAM base address
- Minimum SRAM size across all variants in the family (check official linker scripts from STM32Cube/vendor SDK repos for confirmation — these are authoritative)
- Whether CCM-RAM or other non-contiguous SRAM exists and its address
- That the stub layout (stub code + config struct + data buffer + stack) fits within the minimum SRAM without overlaps
- Memory region boundaries: stub end < config start < buffer start < SRAM top
- Flash size register address

### Step 3: Double-check any issues found

If any agent reports a potential error or discrepancy, **do not report it as final**. Instead, launch a dedicated follow-up agent to re-verify that specific issue using a **different internet source** (e.g., if the original check used a CMSIS header, the follow-up should fetch the reference manual PDF or an independent HAL/SPL source, or vice versa). Only report an issue as confirmed after at least two independent sources agree.

### Step 4: Compile results

After all agents complete (including any follow-up double-checks), compile a single structured report with these sections:

1. **Register Addresses** — table with constant, code value, official value, verdict
2. **Bit Definitions** — table with constant, bit position, official name, verdict
3. **Unlock Keys & Constants** — table
4. **Flash Characteristics** — table
5. **Programming Sequences** — list each operation with verdict
6. **Thumb Stub** (if applicable) — opcode table + branch target table
7. **SRAM Layout** (if applicable) — table with region, address range, size, verdict
8. **Issues Found** — list any errors or concerns, with specific line numbers

## Rules

1. **Every constant must be checked** — do not skip any register, bit, or address.
2. **Cite sources** — reference manual number (e.g., RM0316), CMSIS header name, or datasheet number for each verification.
3. **Use internet search** — do not rely solely on training data. Fetch current CMSIS headers from GitHub and reference manual content from ST/vendor websites.
4. **Cross-reference multiple sources** when there is any ambiguity (e.g., CMSIS header + reference manual + SPL/HAL source).
5. **Flag any discrepancy** even if minor (e.g., naming differences like WRPERR vs WRPRTERR between families).
6. **Do NOT edit any files** — this is a read-only verification. Report findings for the user to act on.
7. **Check consistency** between `.h` and `.cpp` — ensure the `.cpp` uses the constants correctly (e.g., doesn't use a raw `0x04` where `SR_PGERR` should be used).
8. **Double-check every issue** — if any verification agent flags something as WRONG or suspicious, launch a follow-up agent to re-verify against a different independent internet source before reporting it as confirmed. Never report a single-source finding as a confirmed error.
