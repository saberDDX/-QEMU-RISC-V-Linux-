#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/env.sh"
# Sequential component builds bound total parallelism to JOBS (default 4).
for target in newlib qemu firmware uboot kernel busybox; do
 echo "Building $target; log: $OUT/logs/$target.log"
 "$PROJECT_DIR/scripts/build-$target.sh" > "$OUT/logs/$target.log" 2>&1
done
"$PROJECT_DIR/scripts/make-images.sh" custom > "$OUT/logs/images.log" 2>&1
echo 'Images built. Run scripts/run.sh and verify the target console.'
