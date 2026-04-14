# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working
with code in this repository.

## Project Overview

nono-claude wraps Claude Code inside a
[nono](https://github.com/always-further/nono) kernel-level security
sandbox.
It enforces a default-deny filesystem policy: Claude can only access the
current working directory and explicitly allowed paths.

## Build System

This project uses [Makes](https://github.com/makeplus/makes).
All dependencies (nono, Claude Code, gh, jq) are installed automatically
under `./local/` — nothing is installed globally.
The Makes system is cloned into `./makes/` on first run.

Key Makefile targets:
- `make claude-nono` — launches Claude Code inside the nono sandbox
- `make shell cmd='<command>'` — run a command with project dependencies
  on PATH
- `make clean` — remove `makes/` and `local/` directories

## Architecture

The project is small — a shell script, a Makefile, and config files:

- `bin/nono-claude` — main entry point bash script; handles `--pull`,
  `--init`, and normal launch; assembles nono options from global and
  per-project config, then delegates to `make claude-nono`
- `Makefile` — includes Makes modules (`claude.mk`, `shell.mk`,
  `clean.mk`); passes nono and claude options via environment variables
- `.rc` — shell-agnostic (bash/zsh/fish) setup script that sets
  `NONO_CLAUDE_ROOT` and adds `bin/` to PATH
- `share/NONO-GLOBAL-OPTS.txt` — default global nono options (template
  copied to repo root on first run)
- `share/NONO-OPTS.txt` — default per-project nono options (template)

## Per-Project Configuration

`nono-claude --init` creates a per-project config directory under
`claude/<absolute-path>/` within this repo.
It stores project-specific `NONO-OPTS.txt` and can hold the project's
`CLAUDE.md` (moved from the project directory).

## Environment Variables

- `NONO_CLAUDE_ROOT` — must be set (via `source .rc`) before running
- `NONO_CLAUDE_OPTS` — extra nono options passed at invocation time
- `CLAUDE_MODEL` — override the Claude model
- `CLAUDE_MODE` — tool permission level (`readonly`, `edit`, `full`)
