$configDir = Join-Path $HOME ".config\opencode"

New-Item -ItemType Directory -Force -Path $configDir | Out-Null

New-Item -ItemType SymbolicLink -Force -Path (Join-Path $configDir "AGENTS.md") -Target (Join-Path $PSScriptRoot "opencode\AGENTS.md")

New-Item -ItemType SymbolicLink -Force -Path (Join-Path $configDir "skills") -Target (Join-Path $PSScriptRoot "opencode\skills")
