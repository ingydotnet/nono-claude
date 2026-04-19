M := $(NONO_CLAUDE_ROOT)/makes
export MAKES_LOCAL_DIR := $(NONO_CLAUDE_ROOT)/local

$(shell [ -d $M ] || (git clone -q https://github.com/makeplus/makes $M))

include $M/init.mk
include $M/claude.mk

NONO-GLOBAL-MK := $(NONO_CLAUDE_ROOT)/NONO.mk
-include $(NONO-GLOBAL-MK)

NONO-PROJECT-MK := $(NONO_CLAUDE_ROOT)/config/$(CURDIR)/NONO.mk
-include $(NONO-PROJECT-MK)

include $M/shell.mk
include $M/clean.mk

CLAUDE-OPTS += $(NONO_CLAUDE_OPTS_CLAUDE)
CLAUDE-NONO-OPTS += $(NONO_CLAUDE_OPTS_NONO)
