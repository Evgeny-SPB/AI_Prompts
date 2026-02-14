# Git commit rules
- Always pull first before commit
- Never add "Co-Authored-By" lines to commit messages
- Always push to remote after committing
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
- When the user asks to "check logic", review all staged and unstaged changes (git diff and git diff --cached) and verify the logic of the modified code
- If git status shows a modified submodule, enter that submodule directory and do the same: review its staged and unstaged changes and verify their logic
- Focus on correctness, potential bugs, edge cases, and unintended side effects
- Verify that file headers are consistent with the new changes
