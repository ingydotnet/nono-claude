M := $(NONO_CLAUDE_ROOT)/makes
export MAKES_LOCAL_DIR := $(NONO_CLAUDE_ROOT)/local

$(shell [ -d $M ] || (git clone -q https://github.com/makeplus/makes $M))

include $M/init.mk
include $M/claude.mk
include $M/ys.mk

-include config.mk

CLAUDE-OPTS += $(NONO_CLAUDE_OPTS_CLAUDE)
CLAUDE-NONO-OPTS += $(NONO_CLAUDE_OPTS_NONO)

include $M/perl.mk
include $M/bpan.mk
include $M/shellcheck.mk
include $M/shell.mk
include $M/clean.mk

MAKES-CLEAN += config.mk
MAKES-REALCLEAN += local makes

test ?= test/*.t
v ?=

unexport PERL5OPT PERL5LIB


ys: $(YS)
	@echo $<

test: $(PERL) $(BPAN) $(SHELLCHECK)
	prove$(if $(v), -v,) $(test)
