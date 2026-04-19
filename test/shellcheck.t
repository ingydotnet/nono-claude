#!/usr/bin/env bash

source test/init

shellcheck "$ROOT/bin/nono-claude"
pass "shellcheck bin/nono-claude"

done-testing
