#!/usr/bin/env sh
echo "Branch: $(git rev-parse --abbrev-ref HEAD)"
echo
echo "Last commit:"
git log -1 --oneline
echo
echo "Changed files:"
git status --short
