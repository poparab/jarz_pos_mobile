#!/usr/bin/env bash
# Build the OSRM routing dataset. Run this in WSL, NOT on a server.
#
# WHY NOT ON THE SERVER
# osrm-extract peaks around 4.7 GB of RAM. Production has 3.8 GB in total and
# staging 1.9 GB, both already running the ERP stack. Preprocessing there is
# how you OOM a live system. The servers only ever run osrm-routed against the
# finished files, which with --mmap holds about 25-30 MB resident.
#
# WHY A CLIPPED EXTRACT
# Full Egypt processes to ~2.6 GB of artifacts. A box around the populated
# north covers 2,970 of the corpus's 2,972 doors (99.93%) — the two it misses
# are single cafes in Saint Catherine and Hurghada, which no Cairo day route
# would include and which degrade to a straight-line estimate rather than
# failing. BBOX is west,south,east,north.
#
# AFTERWARDS
#   pwsh scripts/setup_osrm.ps1 -Environment staging    -Algorithm mld -Mmap
#   pwsh scripts/setup_osrm.ps1 -Environment production -Algorithm mld -Mmap
set -euo pipefail

WORK="${OSRM_WORK:-$HOME/osrm-build}"
IMAGE="ghcr.io/project-osrm/osrm-backend:latest"
REGION_URL="https://download.geofabrik.de/africa/egypt-latest.osm.pbf"
SRC="egypt-latest.osm.pbf"
OUT="${OSRM_DATASET:-jarz-north}"
BBOX="${OSRM_BBOX:-28.00,28.90,33.00,31.90}"

mkdir -p "$WORK"
cd "$WORK"

echo "=== image ==="
docker pull -q "$IMAGE"

echo "=== source extract ==="
if [ ! -f "$SRC" ]; then
  curl -fSL -o "$SRC" "$REGION_URL"
fi
# Geofabrik publishes a checksum beside every extract. Verifying it is the
# difference between "we downloaded a file" and "we have the map we think".
curl -fsSL "${REGION_URL}.md5" -o "${SRC}.md5.expected" || true
if [ -s "${SRC}.md5.expected" ]; then
  if md5sum -c "${SRC}.md5.expected" >/dev/null 2>&1; then
    echo "  checksum OK"
  else
    echo "!! checksum MISMATCH for $SRC - refusing to build on it" >&2
    exit 1
  fi
fi
ls -lh "$SRC" | awk '{print "  " $9 " " $5}'

echo "=== clip to $BBOX ==="
if ! command -v osmium >/dev/null 2>&1; then
  sudo apt-get update -qq && sudo apt-get install -y -qq osmium-tool
fi
osmium extract --bbox "$BBOX" --strategy complete_ways \
  --overwrite -o "${OUT}.osm.pbf" "$SRC"
ls -lh "${OUT}.osm.pbf" | awk '{print "  " $9 " " $5}'

echo "=== osrm-extract / partition / customize (MLD) ==="
rm -f ${OUT}.osrm*
docker run --rm -t -v "$WORK:/data" "$IMAGE" osrm-extract   -p /opt/car.lua "/data/${OUT}.osm.pbf" 2>&1 | tail -2
docker run --rm -t -v "$WORK:/data" "$IMAGE" osrm-partition "/data/${OUT}.osrm" 2>&1 | tail -1
docker run --rm -t -v "$WORK:/data" "$IMAGE" osrm-customize "/data/${OUT}.osrm" 2>&1 | tail -1

# The container writes as root; the upload runs as the WSL user and cannot
# read root-owned files.
sudo chown -R "$(id -u):$(id -g)" "$WORK" 2>/dev/null || true

echo "=== artifacts ==="
du -ch $(ls -1 ${OUT}.osrm* | grep -vE '\.(ebg|enw)$') | tail -1 | sed 's/^/  shipped set: /'
echo "  (.ebg and .enw are extract-time intermediates and are not shipped)"
echo "OSRM_BUILD_OK"
