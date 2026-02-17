New-Item -ItemType SymbolicLink -Force -Path "$HOME\.claude\CLAUDE.md" -Target "$PSScriptRoot\Claude\CLAUDE.md"

New-Item -ItemType SymbolicLink -Force -Path "$HOME\.claude\settings.json" -Target "$PSScriptRoot\settings.json"

New-Item -ItemType SymbolicLink -Force -Path "$HOME\.claude\skills" -Target "$PSScriptRoot\Claude\skills"
