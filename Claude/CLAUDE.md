# Git commit rules
- Always pull first before commit
- Never add "Co-Authored-By" lines to commit messages
- Always push to remote after committing
- Always run git commands from the repository root directory (not from a subdirectory) to avoid missing submodule pointer updates or other tracked files outside the working directory
- To find the git root, run `git rev-parse --show-toplevel` — do NOT assume the current working directory is the git root
- Before committing, check for unstaged/untracked files with git status
  - If there are junk files: either add them to .gitignore or remove them
  - Never leave junk files uncommitted or unignored
- Always use `git add .` to stage all changes - never add individual files (adding individual files creates inconsistencies when files are edited manually)
- If a submodule is modified, commit and push it first (following the same commit rules) before committing the main project
- Commit message style: short summary line (what was done), then blank line, then bullet-point details of specific changes
- Example:
  ```
  Add static assertions for protocol structure sizes (64-bit migration)

  Ensures binary protocol compatibility across 32-bit and 64-bit builds:
  - dev_data: 64 bytes
  - BaudRate: 1 byte
  - CommunicationMode: 1 byte
  - MultiProgCommand: 1 byte
  ```

# Check logic command
- When the user asks to "check logic", review all staged and unstaged changes (git diff and git diff --cached). Look for errors and verify logic of modified code.
- If git status shows a modified submodule, enter that submodule directory and do the same: review its staged and unstaged changes and verify their logic
- Focus on correctness, potential bugs, edge cases, and unintended side effects
- Verify that file headers are consistent with the new changes

# Coding style: bit definitions
- Define bit constants using `constexpr uint32_t` inside a namespace (not `#define` macros or enums)
- Use `(1UL << N)` shift expressions, not raw hex values
- Name bits with a `_BIT` suffix in UPPER_SNAKE_CASE
- Align values with spaces for readability
- Add a short inline comment for each bit explaining its meaning
- Add a `// Description` comment line above the namespace
- Example:
  ```cpp
  // My module status event group bits
  namespace my_status {
      constexpr uint32_t ACTIVE_BIT   = (1UL << 0);  // system active
      constexpr uint32_t ERROR_BIT    = (1UL << 1);  // error detected
      constexpr uint32_t READY_BIT    = (1UL << 2);  // ready for operation
  }
  ```
