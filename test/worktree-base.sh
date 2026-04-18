#!/usr/bin/env bash

# Tests that get-project-base returns a stable path across git worktrees
# of the same repo (issue #1).

set -euo pipefail

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
root=$(cd "$here/.." && pwd -P)

# Source the script without running main.
# shellcheck disable=SC1091
source "$root/bin/nono-claude"

tmp=$(mktemp -d)
trap 'rm -fr "$tmp"' EXIT

fail=0

assert-eq() {
  local label=$1 expected=$2 actual=$3
  if [[ $expected == "$actual" ]]; then
    echo "ok - $label"
  else
    echo "FAIL - $label"
    echo "  expected: $expected"
    echo "  actual:   $actual"
    fail=1
  fi
}

# Case 1: outside any git repo, falls back to pwd -P.
# GIT_CEILING_DIRECTORIES stops git from walking above $tmp, so a tmp
# dir that happens to live inside another repo (e.g. when TMPDIR lives
# inside a checkout) does not leak into the result.
plain=$tmp/plain
mkdir -p "$plain"
actual=$(cd "$plain" && GIT_CEILING_DIRECTORIES=$tmp get-project-base)
assert-eq "outside git repo -> pwd -P" "$plain" "$actual"

# Case 2: main worktree of a regular repo.
main_wt=$tmp/main
mkdir -p "$main_wt"
(
  cd "$main_wt"
  git init -q -b main
  git -c user.email=t@t -c user.name=t commit -q --allow-empty -m init
)
actual=$(cd "$main_wt" && get-project-base)
assert-eq "main worktree -> main path" "$main_wt" "$actual"

# Case 3: linked worktree of the same repo.
feat_wt=$tmp/feat
(cd "$main_wt" && git worktree add -q "$feat_wt" -b feat)
actual=$(cd "$feat_wt" && get-project-base)
assert-eq "linked worktree -> main path" "$main_wt" "$actual"

# Case 4: linked worktree of a bare repo.
bare=$tmp/bare.git
git init -q --bare -b main "$bare"
# Need a commit in the bare repo for worktree add to work.
seed=$tmp/seed
git clone -q "$bare" "$seed" 2>/dev/null
(cd "$seed" && git -c user.email=t@t -c user.name=t commit -q --allow-empty -m init && git push -q origin main)
bare_wt=$tmp/bare-wt
(cd "$bare" && git worktree add -q "$bare_wt" main)
actual=$(cd "$bare_wt" && get-project-base)
assert-eq "bare-repo worktree -> bare repo path" "$bare" "$actual"

# Case 5: subdirectory of main worktree still resolves to main worktree.
mkdir -p "$main_wt/sub/dir"
actual=$(cd "$main_wt/sub/dir" && get-project-base)
assert-eq "subdir of worktree -> main path" "$main_wt" "$actual"

# End-to-end: setup's $config_dir from the main and linked worktrees
# must agree and must use the main worktree's path. This catches
# regressions where get-project-base is correct but config_dir is wired
# to the wrong variable.
fake_root=$tmp/nono-root
mkdir -p "$fake_root/share"
cp "$root/share/NONO.mk" "$fake_root/share/"
touch "$fake_root/Makefile"
export NONO_CLAUDE_ROOT=$fake_root

get-config-dir() {
  bash -c 'source "$1"; setup; echo "$config_dir"' _ "$root/bin/nono-claude"
}
main_cfg=$(cd "$main_wt" && get-config-dir)
feat_cfg=$(cd "$feat_wt" && get-config-dir)

# Case 6: config_dir matches across worktrees.
assert-eq "config_dir matches across worktrees" "$main_cfg" "$feat_cfg"

# Case 7: config_dir uses main worktree identity, not the linked worktree.
assert-eq "config_dir uses main worktree path" \
  "$fake_root/config${main_wt}" "$main_cfg"

exit $fail
