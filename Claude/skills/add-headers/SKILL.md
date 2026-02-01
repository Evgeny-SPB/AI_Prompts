---
name: add-headers
description: Add or replace Kuraga Tech file headers on .h and .cpp files. Use when user wants to add proper headers to source files.
---

Add or replace file headers in the specified files using the standard Kuraga Tech header style.

## Header style for `.h` files

```
/**
 ******************************************************************************
 * @file           : <filename>.h
 * @brief          : <brief description>
 * @author         : Kuraga Team
 ******************************************************************************
 * @attention
 *
 * Copyright (c) 2026 Kuraga Tech.
 * All rights reserved.
 *
 ******************************************************************************
 * @details
 *
 * <detailed description of the module>
 *
 * Features:
 * - <feature 1>
 * - <feature 2>
 * ...
 *
 * Usage Example:
 * ```cpp
 * <usage example code>
 * ```
 *
 ******************************************************************************
 */
```

## Header style for `.cpp` files

```
/**
 ******************************************************************************
 * @file           : <filename>.cpp
 * @brief          : <brief description>
 * @author         : Kuraga Team
 ******************************************************************************
 * @attention
 *
 * Copyright (c) 2026 Kuraga Tech.
 * All rights reserved.
 *
 ******************************************************************************
 */
```

## Rules

1. The `@file` tag MUST match the actual filename exactly.
2. The `@brief` should be a concise one-line description of what the file does.
3. The `@author` is always `Kuraga Team`.
4. The copyright year is always current year.
5. `.h` files MUST include a `@details` section with:
   - A description of the module
   - A features list
   - Usage examples using triple-backtick cpp code blocks
6. `.cpp` files do NOT include a `@details` section.
7. Include guards in `.h` files must use the filename in uppercase with underscores (e.g., `kt_modbus.h` -> `KT_MODBUS_H`). Fix any mismatched guards.
8. If a file already has a header/comment block at the top, replace it. Preserve all code below the header.
9. Derive the `@brief` and `@details` content by reading and understanding the existing code in the file.
