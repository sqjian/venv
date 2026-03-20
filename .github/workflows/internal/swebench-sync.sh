#!/usr/bin/env bash

set -euo pipefail

mapfile -t images < .github/workflows/internal/swebench-images.txt

total=${#images[@]}
batch=${BATCH:?}
batch_size=$(( (total + 9) / 10 ))
start=$(( batch * batch_size ))
end=$(( start + batch_size ))
if (( end > total )); then end=$total; fi

echo "Batch ${batch}: syncing images ${start} to $((end - 1)) of ${total}"

for (( i=start; i<end; i++ )); do
  img="${images[$i]}"
  echo "[$((i+1))/${total}] Syncing swebench/${img} ..."
  skopeo copy "docker://swebench/${img}" \
    "docker://registry.cn-hangzhou.aliyuncs.com/vsc-github/${img}" \
    --dest-creds="${DEST_CREDS}" || echo "WARN: failed to sync ${img}, continuing..."
done
