# Makes dependencies for this project's nono-claude session.
#
# Uncomment the includes you need.
# See https://github.com/makeplus/makes for available modules.

### Install Node.js (needed by some MCP plugins):
# include $(MAKES)/node.mk
# CLAUDE-NONO-OPTS += \
#   --read-file ~/.npmrc \
#   --allow node_modules \

### Install Python with virtualenv:
# include $(MAKES)/python.mk
# CLAUDE-NONO-OPTS += \
#   --read ~/.local/lib \
#   --read-file ~/.pip/pip.conf \
#
# Custom Python venv setup command (set before the include):
# PYTHON-VENV-SETUP := pip install -r requirements.txt

# CLAUDE-NONO-DEPS += $(NODE) $(PYTHON)


# --- Network ---
# Block all outbound network (offline build):
# CLAUDE-NONO-OPTS += --block-net
#
# Allow only specific domains for this project:
# CLAUDE-NONO-OPTS += --allow-domain registry.npmjs.org
# CLAUDE-NONO-OPTS += --allow-domain pypi.org
# CLAUDE-NONO-OPTS += --allow-domain crates.io
#
# Allow dev server ports:
# CLAUDE-NONO-OPTS += --listen-port 3000
# CLAUDE-NONO-OPTS += --open-port 5173

# --- Credentials ---
# CLAUDE-NONO-OPTS += --credential github
# CLAUDE-NONO-OPTS += --env-credential <key_name>

# --- Rollback ---
# Enable atomic rollback for this project:
# CLAUDE-NONO-OPTS += --rollback
# CLAUDE-NONO-OPTS += --rollback-exclude node_modules
# CLAUDE-NONO-OPTS += --rollback-exclude .venv
# CLAUDE-NONO-OPTS += --rollback-exclude target
