#!/usr/bin/env bash
# install.sh — install the quilt-precommit hook in the current repo
#
# Usage: 
#   /path/to/quilt-precommit/install.sh

set -e
HOOK_SRC="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"

# Check we're in a git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "error: not in a git repo"
    exit 1
fi

GIT_DIR=$(git rev-parse --git-dir)

# Copy the hook files
mkdir -p "$GIT_DIR/hooks/quilt-precommit"
cp -r "$HOOK_SRC"/* "$GIT_DIR/hooks/quilt-precommit/"
chmod +x "$GIT_DIR/hooks/quilt-precommit/pre-commit"

# Symlink the hook
ln -sf "quilt-precommit/pre-commit" "$GIT_DIR/hooks/pre-commit"

echo "installed: $GIT_DIR/hooks/pre-commit -> quilt-precommit/pre-commit"
