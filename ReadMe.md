# nono-claude

Run [Claude Code](https://github.com/anthropics/claude-code) inside a
[nono](https://github.com/always-further/nono) security sandbox.

## Description

nono-claude wraps Claude Code with strict, kernel-level filesystem and
resource controls.
Claude can only access the current working directory and a small set of
explicitly allowed paths — everything else is blocked by default.


## How It Works

nono is a Rust-based security sandbox that enforces a default-deny
filesystem policy.
nono-claude configures it with options that grant:

- **Read/write** — current working directory
- **Read-only** — nono-claude repo, system binaries, `/proc`
- **Network** — allowed
- **Everything else** — blocked

When Claude tries to access a forbidden path, nono returns a clear
permission-denied error at the kernel level.

Configuration is assembled from two layers, each with an options file
and a Makefile include:

1. **Global** — `NONO-OPTS.txt` and `NONO.mk` in the repo root
   (copied from `share/` on first run)
2. **Per-project** — `NONO-OPTS.txt` and `NONO.mk` under
   `config/<absolute-path>/` (created automatically on first run in
   each project)

The `NONO-OPTS.txt` files control nono sandbox permissions (filesystem
access, network, credentials).
The `NONO.mk` files control
[Makes](https://github.com/makeplus/makes) dependencies (Node.js,
Python, etc.) that should be available inside the sandbox.


## Prerequisites

- Linux or macOS
- bash, zsh, or fish
- git, curl

All other dependencies (nono, Claude Code, gh, jq) are installed
automatically under `./local/` by the
[Makes](https://github.com/makeplus/makes) build system — nothing is
installed globally.


## Setup

```bash
git clone https://github.com/ingy/nono-claude
source /path/to/nono-claude/.rc
```

Sourcing `.rc` sets `NONO_CLAUDE_ROOT` and adds
`$NONO_CLAUDE_ROOT/bin` to your `PATH`.
Add the `source` line to your shell profile to make it permanent.

You also need either `ANTHROPIC_API_KEY` set in your environment or
an active `claude auth login` session.


## Usage

Navigate to any project directory and run:

```bash
nono-claude
```

Claude Code starts inside the sandbox, scoped to that directory.

Do **not** run `nono-claude` from your home directory — this is
intentionally prevented to avoid exposing your entire home tree.

Any extra arguments are passed through to Claude Code:

```bash
nono-claude --model sonnet
```

### Commands

| Command | Description |
|---|---|
| `nono-claude` | Launch Claude Code in the sandbox |
| `nono-claude --config` | Print paths to per-project config files |
| `nono-claude --claude-md` | Move an untracked `CLAUDE.md` into config and symlink it back |
| `nono-claude --update` | Pull the latest nono-claude and re-bootstrap dependencies |

### Per-project configuration

On first launch in any project directory, nono-claude creates a config
directory at `config/<absolute-path>/` within the nono-claude repo.
Two template files are copied there:

- `NONO-OPTS.txt` — nono sandbox options for this project
- `NONO.mk` — Makes dependencies for this project

Edit these files to customize the sandbox for each project.
Run `nono-claude --config` to print the file paths.
To open all config files side by side in one step:

```bash
vim -O $(nono-claude --config)
```

### Managing CLAUDE.md

If your project has a `CLAUDE.md` that is not tracked by git, you can
move it into the nono-claude config directory:

```bash
nono-claude --claude-md
```

This moves the file and creates a symlink in its place, so Claude Code
still finds it.
This is useful for keeping project instructions out of the project
repo.

### Updating nono-claude

```bash
nono-claude --update
```

This pulls the latest changes from the repo and removes the `makes/`
and `local/` directories so they are re-bootstrapped on next run.


## Configuration

### Environment variables

| Variable | Description |
|---|---|
| `NONO_CLAUDE_ROOT` | Set automatically by sourcing `.rc` |
| `CLAUDE_MODEL` | Override the Claude model |
| `CLAUDE_MODE` | Tool permission level (`readonly`, `edit`, `full`) |
| `NONO_CLAUDE_OPTS` | Extra nono options passed at invocation time |

### Sandbox options (NONO-OPTS.txt)

The template files in `share/` document all available nono options
including filesystem access, network restrictions, credential
injection, GPU access, and rollback support.
Edit your global `NONO-OPTS.txt` (repo root, applies to all
projects) or per-project `NONO-OPTS.txt` (under `config/`) to
customize the sandbox.

Lines starting with `#` are comments and ignored.

### Dependencies (NONO.mk)

To make additional tools available inside the sandbox, uncomment the
relevant `include` lines in `NONO.mk`.
For example, to add Node.js:

```makefile
include $(MAKES)/node.mk
CLAUDE-NONO-DEPS += $(NODE)
```

The global `NONO.mk` (repo root) applies to all projects.
Per-project `NONO.mk` files add project-specific dependencies.

### Inline overrides

To grant Claude access to additional paths for a single session:

```bash
NONO_CLAUDE_OPTS="--allow /path/to/data --read /other/path" \
  nono-claude
```


## License

MIT License.
See [License](License) for details.

Copyright 2026 - Ingy dot Net
