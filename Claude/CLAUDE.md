# Git commit rules
- Always pull first before commit
- Never add "Co-Authored-By" lines to commit messages
- Always push to remote after committing
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
