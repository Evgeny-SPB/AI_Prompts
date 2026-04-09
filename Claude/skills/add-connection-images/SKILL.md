---
name: add-connection-images
description: Add SWD/JTAG/BDM connection pin diagrams to a system_targets JSON file using MCU datasheets. Use when user wants to add connectionImages or pinout data to a target database JSON file.
---

# Add Connection Images to System Targets JSON

Add `connection_bases` and per-device `connectionImages` to a target family JSON file in `backend_cpp/system_targets/`. Pin data is extracted from MCU datasheets and visually verified.

## Arguments

The user provides the target JSON filename (e.g., `STM32G0.json`, `MKE04Z.json`) or family name.

## Workflow

### Step 1: Read the target JSON and identify sub-families

1. Read the target JSON file from `backend_cpp/system_targets/`
2. Check if `connection_bases` and `connectionImages` already exist — if so, inform the user and ask whether to update or skip
3. Identify the **programmer type** from the `"prog"` field:
   - `"ST-Link"` → SWD protocol (SWDIO, SWCLK, RST, VDD, GND)
   - `"USBDM"` → BDM protocol (BKGD, RST, VDD, GND)
   - Other → ask the user what protocol/signals to use
4. Extract all unique sub-family prefixes from `t_name` fields in devices (e.g., `STM32G030`, `STM32G031`, `MKE02Z`)
5. Note which `t_name` entries use `x` as a pin-count wildcard — these need connectionImages for ALL package variants

### Step 2: Identify SWD/debug pin names for this MCU family

For **ST-Link / SWD** (ARM Cortex-M):
- **SWDIO**: typically `PA13` on STM32, `PTA4` on Kinetis
- **SWCLK**: typically `PA14` on STM32, `PTC4` on Kinetis
- **RST**: `NRST` on STM32, `PTA5/RESET` on Kinetis
- **VDD/GND**: power pins

Determine the correct MCU pin names for the specific family. Check the CLAUDE.md or existing similar families for reference.

### Step 3: Find datasheets

1. Search `target_controller_pdf/` recursively for PDFs matching the family name (case-insensitive)
2. For each PDF found, extract the title from page 1 using PyMuPDF:
   ```python
   import fitz
   doc = fitz.open(path)
   text = doc[0].get_text()
   # First 1-2 lines contain the part number coverage
   ```
3. Build a mapping: sub-family → datasheet file
4. **If any sub-families are missing datasheets**: list the missing ones and ask the user to download them. Stop and wait. Do NOT proceed with incomplete data — pin assignments must be verified from authoritative sources.

### Step 4: Extract pin data from datasheets

Use PyMuPDF table extraction to get pin assignments programmatically:

```python
import fitz

doc = fitz.open(datasheet_path)
for pg_num in range(25, min(doc.page_count, 60)):
    page = doc[pg_num]
    tables = page.find_tables()
    for table in tables:
        data = table.extract()
        for row in data:
            row_str = ' '.join(str(c) for c in row if c)
            # Search for SWD pin names (PA13, PA14, NRST, VDD, VSS, etc.)
            if any(k in row_str for k in target_pins):
                # Extract pin numbers per package column
```

**Critical**: First extract the **column headers** (package names like LQFP32, TSSOP20, UFQFPN28, etc.) from the table header rows. Map each numeric column to its package. Skip WLCSP and UFBGA columns (matrix coordinates, not useful for programmer wiring).

For each datasheet, extract:
- Pin numbers for each debug signal (SWDIO, SWCLK, RST) per package
- Pin numbers for VDD and VSS per package
- Available packages for that sub-family

### Step 5: Visually verify pin assignments

**MANDATORY per project rules**: Never trust PDF text extraction alone for pin data.

1. Render key pin diagram pages to PNG using PyMuPDF:
   ```python
   mat = fitz.Matrix(3.0, 3.0)  # 3x zoom for readability
   pix = page.get_pixmap(matrix=mat)
   pix.save(f'/tmp/pins/{name}_p{pg+1}.png')
   ```
2. Use the Read tool to view the PNG images
3. Visually confirm that the extracted pin numbers match the diagrams for at least:
   - The smallest LQFP package
   - The largest LQFP package
   - Any unusual packages (SO8N, QFN)
4. Verify pin numbers are **consistent across sub-families** for the same package type

### Step 6: Build the connection_bases and connectionImages

1. Create one `connection_bases` entry per unique package type. Use lowercase keys (e.g., `lqfp32`, `tssop20`, `so8n`, `ufqfpn28`)
2. Each entry has:
   ```json
   {
     "package": "LQFP",
     "pinCount": 32,
     "connections": [
       {"pin": 24, "mcuPin": "PA13",       "progPin": "SWDIO"},
       {"pin": 25, "mcuPin": "PA14-BOOT0", "progPin": "SWCLK"},
       {"pin": 6,  "mcuPin": "NRST",       "progPin": "RST"},
       {"pin": 4,  "mcuPin": "VDD/VDDA",   "progPin": "VDD"},
       {"pin": 5,  "mcuPin": "VSS/VSSA",   "progPin": "GND"}
     ],
     "comment": "LQFP32 (7x7mm). SWD debug connection"
   }
   ```
3. Add `connectionImages` array to each device entry, listing the package base names that sub-family comes in
4. If UFQFPN32/48 share pin numbering with LQFP32/48 (common in STM32), note this in the comment rather than creating duplicate entries

### Step 7: Write the JSON and validate

1. Add or update the `_verified` field documenting:
   - Date of verification
   - Datasheet document numbers and revisions used
   - What was verified (pin tables + visual diagrams)
   - Any notable findings
2. Add `connection_bases` section between `device_bases` and `devices`
3. Add `connectionImages` to each device entry
4. Validate the JSON:
   ```python
   import json
   data = json.load(open(filepath))
   bases = data['connection_bases']
   for dev in data['devices']:
       for ref in dev.get('connectionImages', []):
           assert ref in bases, f"{dev['t_name']} references unknown base '{ref}'"
   ```

## Package type mapping

Use these `"package"` values in connection_bases:

| Physical package | `"package"` value |
|-----------------|-------------------|
| LQFP (any pin count) | `"LQFP"` |
| TSSOP | `"TSSOP"` |
| SO8N / SOIC | `"SOIC"` |
| UFQFPN / QFN | `"QFN"` |
| PSDIP / DIP | `"PSDIP"` |

## progPin values by protocol

**SWD (ST-Link for ARM Cortex-M)**:
`SWDIO`, `SWCLK`, `RST`, `VDD`, `GND`

**BDM (USBDM for HCS08/HCS12)**:
`BKGD`, `RST`, `VDD`, `GND`

**JTAG (for DSC)**:
`TDI`, `TDO`, `TMS`, `TCLK`, `RST`, `VDD`, `GND`

**Serial/UART (TGSN for Renesas/NEC)**:
`TOOL0`, `RX`, `RESET`, `VDD`, `GND`, `LOG_0`, `LOG_1`, `FLMD0`

## Important rules

- **100% accuracy is mandatory** — this data is used by repair technicians on real hardware
- **Never guess pin numbers** — always extract from datasheets
- **Never proceed with missing datasheets** — ask the user to provide them first
- **Visually verify** at least 2-3 packages per family against rendered pin diagrams
- **Cross-check consistency** — same package must have same SWD pin numbers across all sub-families in the family
- Pin assignments for WLCSP and BGA packages should be **excluded** (balls underneath, not useful for programmer wiring)
- When a QFN and LQFP share pin numbering (e.g., "LQFP32 / UFQFPN32" column in datasheet), note in the comment field rather than creating a separate entry
