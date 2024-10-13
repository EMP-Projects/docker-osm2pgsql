#!/bin/sh

if [ $# -ne 6 ]
then
    echo "Uso: $0 PGHOST PGPORT PGUSER PGPWD PGDB"
    exit
fi 

# assegna i valori degli argomenti alle variabili
PGHOST=$1
PGPORT=$2
PGUSER=$3
PGPWD=$4
PGDB=$5

echo DATADIR="${DATADIR:="/osm"}"
echo PBF="${PBF:=$DATADIR/italy-latest.osm.pbf}"

echo URLOSM="https://download.geofabrik.de/europe/italy-latest.osm.pbf"

if [[ -f "$PBF" ]]; then
    echo "Using local file at $PBF"
else
    echo "$PBF File not found, downloading..."
    exec wget -O "${PBF}" https://download.geofabrik.de/europe/italy-latest.osm.pbf 
    exec chmod 777 "${PBF}"
fi

if psql --no-password -h "$PGHOST" -U "$PGUSER" -d "$PGDATABASE" -p 5433 -c "select * from osm2pgsql_properties;"; then
    echo "Updating."
    osm2pgsql-replication update \
        -v \
        -H "$PGHOST" \
        -d "$PGDATABASE" \
        -U "$PGUSER" \
        -P 5433 \
        -- -j -S /usr/local/share/osm2pgsql/custom.style -x
else
    echo "Database not ready, need to initialize. Creating extensions ..."

    # psql --no-password -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$PGDATABASE" -p 5433 -c "CREATE EXTENSION IF NOT EXISTS postgis;"
    # psql --no-password -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$PGDATABASE" -p 5433 -c "CREATE EXTENSION IF NOT EXISTS hstore;"
    # psql --no-password -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$PGDATABASE" -p 5433 -c "CREATE EXTENSION IF NOT EXISTS pgrouting;"
    # psql --no-password -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$PGDATABASE" -p 5433 -c "CREATE EXTENSION IF NOT EXISTS postgis_raster;"
    # psql --no-password -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$PGDATABASE" -p 5433 -c "CREATE EXTENSION IF NOT EXISTS postgis_topology WITH SCHEMA topology;"
    
    echo "Extensions created. Initialize osm2pgsql ..."

    osm2pgsql -v \
        -j \
        -c \
        -s \
        -C 4000 \
        -x \
        -S /usr/local/share/osm2pgsql/custom.style \
        -H "$PGHOST" \
        -d "$PGDATABASE" \
        -U "$PGUSER" \
        -P "$PGPORT" \
        "$PBF"

    osm2pgsql-replication init \
        -H "$PGHOST" \
        -d "$PGDATABASE" \
        -U "$PGUSER" \
        -P "$PGPORT" \
        --osm-file "$PBF"
fi