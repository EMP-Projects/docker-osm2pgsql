#!/bin/sh

echo DATADIR="${DATADIR:="~/osm"}"
echo PBF="${PBF:=$DATADIR/italy-latest.osm.pbf}"

echo URLOSM="https://download.geofabrik.de/europe/italy-latest.osm.pbf"

if [[ -f "$PBF" ]]; then
    echo "Using local file at $PBF"
else
    echo "$PBF File not found, downloading..."
    exec wget -O "${PBF}" https://download.geofabrik.de/europe/italy-latest.osm.pbf 
    exec chmod 777 "${PBF}"
fi

if psql --no-password -h "$PGHOST" -U "$PGUSER" -d "$PGDB" -p 5433 -c "select * from osm2pgsql_properties;"; then
    echo "Updating."
    osm2pgsql-replication update \
        -v \
        -H "$PGHOST" \
        -d "$PGDB" \
        -U "$PGUSER" \
        -P 5433 \
        -- -j -S ~/scripts/custom.style -x
else
    echo "Extensions created. Initialize osm2pgsql ..."

    osm2pgsql -v \
        -j \
        -c \
        -s \
        -C 4000 \
        -x \
        -S ~/scripts/custom.style \
        -H "$PGHOST" \
        -d "$PGDB" \
        -U "$PGUSER" \
        -P "$PGPORT" \
        "$PBF"

    osm2pgsql-replication init \
        -H "$PGHOST" \
        -d "$PGDB" \
        -U "$PGUSER" \
        -P "$PGPORT" \
        --osm-file "$PBF"
fi