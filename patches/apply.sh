#!/bin/bash
#
# SPDX-License-Identifier: Apache-2.0
#
# apply.sh <rom> [android tree]: commit the patches in patches/<rom>/<project path>/ onto the synced projects,
# in name order. A patch whose Change-Id a recent commit of the project already carries was applied before and
# is skipped; one that is already in the sources without it (merged upstream, under another Change-Id) is
# skipped and named, to be deleted here. Anything else that does not apply stops the run. Run it after every
# repo sync, which drops these commits again.
set -euo pipefail
rom=${1:?usage: apply.sh <rom> [android tree]}
here=$(cd "$(dirname "$0")" && pwd)
top=$(cd "${2:-$here/../../../..}" && pwd)
dir=$here/$rom
[ -d "$dir" ] || { echo "apply.sh: no patches for $rom" >&2; exit 1; }

applied=0 skipped=0
while IFS= read -r patch; do
    rel=${patch#"$dir"/}
    project=${rel%/*}
    subject=$(awk '/^Subject: /{ s = $0; while ((getline l) > 0 && l ~ /^[ \t]/) s = s l; print s; exit }' "$patch" |
        sed 's/^Subject: \(\[PATCH[^]]*\] \)\{0,1\}//')
    change=$(sed -n 's/^Change-Id: //p' "$patch" | tail -1)
    git=(git -C "$top/$project" -c user.name=Betterr -c user.email=51264180+Star-caorui@users.noreply.github.com)
    [ -d "$top/$project" ] || { echo "apply.sh: $project is not in $top" >&2; exit 1; }
    # grep reads it all: with -q it would stop at the match and fail git log on the pipe (pipefail)
    if [ -n "$change" ] && "${git[@]}" log -50 --format=%B | grep -x "Change-Id: $change" > /dev/null; then
        echo "applied before: $project: $subject"
        skipped=$((skipped + 1))
    elif "${git[@]}" apply --check --reverse "$patch" 2>/dev/null; then
        echo "already in the sources, delete $rel: $project: $subject"
        skipped=$((skipped + 1))
    elif "${git[@]}" am --quiet --3way "$patch"; then
        echo "applied: $project: $subject"
        applied=$((applied + 1))
    else
        "${git[@]}" am --abort 2>/dev/null || true
        echo "apply.sh: $rel does not apply to $project" >&2
        exit 1
    fi
done < <(find "$dir" -name '*.patch' | sort)
echo "apply.sh: $applied applied, $skipped skipped"
