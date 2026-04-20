#!/usr/bin/env bash

# Tests that get-project-base returns a stable path across git worktrees
# of the same repo (issue #1).

source test/init

# Source the script without running main.
# shellcheck disable=SC1091
source "$ROOT/bin/nono-claude"

tmp=$(mktemp -d)
trap 'rm -fr "$tmp"' EXIT

# Case 1: outside any git repo, falls back to pwd -P.
plain=$tmp/plain
mkdir -p "$plain"
actual=$(cd "$plain" && GIT_CEILING_DIRECTORIES=$tmp get-project-base)
is "$actual" "$plain" \
  "outside git repo -> pwd -P"

# Case 2: main worktree of a regular repo.
main_wt=$tmp/main
mkdir -p "$main_wt"
(
  cd "$main_wt"
  git init -q -b main
  git -c user.email=t@t -c user.name=t commit -q --allow-empty -m init
)
actual=$(cd "$main_wt" && get-project-base)
is "$actual" "$main_wt" \
  "main worktree -> main path"

# Case 3: linked worktree of the same repo.
feat_wt=$tmp/feat
(cd "$main_wt" && git worktree add -q "$feat_wt" -b feat)
actual=$(cd "$feat_wt" && get-project-base)
is "$actual" "$main_wt" \
  "linked worktree -> main path"

# Case 4: linked worktree of a bare repo.
bare=$tmp/bare.git
git init -q --bare -b main "$bare"
seed=$tmp/seed
git clone -q "$bare" "$seed" 2>/dev/null
(cd "$seed" && git -c user.email=t@t -c user.name=t commit -q --allow-empty -m init && git push -q origin main)
bare_wt=$tmp/bare-wt
(cd "$bare" && git worktree add -q "$bare_wt" main)
actual=$(cd "$bare_wt" && get-project-base)
is "$actual" "$bare" \
  "bare-repo worktree -> bare repo path"

# Case 5: subdirectory of main worktree still resolves to main worktree.
mkdir -p "$main_wt/sub/dir"
actual=$(cd "$main_wt/sub/dir" && get-project-base)
is "$actual" "$main_wt" \
  "subdir of worktree -> main path"

# End-to-end: setup's $config_dir from the main and linked worktrees
# must agree and must use the main worktree's path.
fake_root=$tmp/nono-root
mkdir -p "$fake_root/share"
cp "$ROOT/share/nono.yaml" "$fake_root/share/"
touch "$fake_root/Makefile"
export NONO_CLAUDE_ROOT=$fake_root

get-config-dir() {
  bash -c 'source "$1"; setup; echo "$config_dir"' _ "$ROOT/bin/nono-claude"
}
main_cfg=$(cd "$main_wt" && get-config-dir)
feat_cfg=$(cd "$feat_wt" && get-config-dir)

# Case 6: config_dir matches across worktrees.
is "$feat_cfg" "$main_cfg" \
  "config_dir matches across worktrees"

# Case 7: config_dir uses main worktree identity, not the linked worktree.
is "$main_cfg" "$fake_root/config${main_wt}" \
  "config_dir uses main worktree path"

done-testing
