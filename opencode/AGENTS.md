# Global OpenCode Instructions

## Git commit rules

- When the user asks to commit, push, or commit-and-push changes, use the `commit` skill.

## PDF visual data extraction

- When verifying data that comes from PDF diagrams, schematics, pinouts, tables, package drawings, or other visual layouts, render the relevant PDF pages with `pdftoppm` and inspect the rendered images visually. Do not rely on PDF text extraction alone for visual data.
- Prefer high-resolution PNG output, for example:
  - `pdftoppm -png -r 300 -f <first-page> -l <last-page> "input.pdf" "output-prefix"`
- Use rendered images to cross-check extracted values before updating source files, especially pin numbers, connector mappings, signal names, package orientation, and power/ground pins.
- Note in verification/audit comments when values were visually verified from `pdftoppm`-rendered pages.
