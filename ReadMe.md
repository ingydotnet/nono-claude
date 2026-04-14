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

Sandbox options are assembled from two layers:

1. **Global options** — `NONO-GLOBAL-OPTS.txt` in the repo root
   (copied from `share/` on first run)
2. **Per-project options** — `config/<absolute-path>/NONO-OPTS.txt`
   (created by `nono-claude --config`)


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

### Per-project configuration

```bash
nono-claude --config
```

This creates a per-project config directory under
`config/<absolute-path>/` within the nono-claude repo.
It copies the default `NONO-OPTS.txt` template there and symlinks it
into your project directory.

If your project has a `CLAUDE.md` that is not tracked by git, it will
be moved into the config directory and symlinked back.

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

### Sandbox options files

The template files in `share/` document all available nono options
including filesystem access, network restrictions, credential
injection, GPU access, and rollback support.
Edit your `NONO-GLOBAL-OPTS.txt` (all projects) or per-project
`NONO-OPTS.txt` to customize the sandbox.

Lines starting with `#` are comments and ignored.

### Adding sandbox permissions

To grant Claude access to additional paths inline:

```bash
NONO_CLAUDE_OPTS="--allow /path/to/data --read /other/path" \
  nono-claude
```


## License

MIT License.
See [License](License) for details.

Copyright (c) 2025-2026 Ingy döt Net.
