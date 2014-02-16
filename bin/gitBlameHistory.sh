#!/bin/bash
f=$1
shift
{ git log --pretty=format:%H -- "$f"; echo; } | {
  while read hash; do
    echo "--- $hash"
    git blame $@ $hash -- "$f" | sed 's/^/  /'
  done
}
