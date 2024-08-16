# Osm2PgSql Docker image

Osm2pgsql is an Open Source tool for importing OpenStreetMap (OSM) data into a PostgreSQL/PostGIS database. It is an essential part of many rendering toolchains, the Nominatim geocoder, and other applications that process OpenStreetMap data.

## Build image

To create image run docker build like this:

```bash
docker build -t ecosensor/osm2pgsql:latest -f osm2pgsql/Dockerfile ./osm2pgsql
```

## Run image 

To run image in docker-compose along with a dedicated postgis instance:

```yaml
osm2pg-db:
    container_name: osm2pg-db
    image: postgis/postgis:16-3.4
    profiles: ["all", "db", "be", "stack"]
    environment:
      POSTGRES_HOST_AUTH_METHOD: md5
      PGPORT: 5433
      POSTGRES_DB: ${POSTGRES_OSM_DB}
      POSTGRES_USER: ${POSTGRES_OSM_USER}
      POSTGRES_PASSWORD: ${POSTGRES_OSM_PASS}
      POSTGRES_INITDB_ARGS: "-c shared_buffers=1GB -c work_mem=50MB -c maintenance_work_mem=10GB -c autovacuum_work_mem=2GB -c wal_level=minimal -c checkpoint_completion_target=0.9 -c max_wal_senders=0 -c random_page_cost=1.0"
    ports:
      - ${POSTGRES_OSM_PORT}:5433
    healthcheck:
      test: "PGPASSWORD=${POSTGRES_OSM_PASS} pg_isready -h 127.0.0.1 -U ${POSTGRES_OSM_USER} -d ${POSTGRES_OSM_DB} -p 5433"
      interval: 1m30s
      timeout: 10s
      retries: 3
      start_period: 1m
    restart: on-failure
    networks:
      - ecosensor-network
    volumes:
      - ./osm-data/db:/var/lib/postgresql
  
  osm2pgsql:
    container_name: osm2pgsql
    image: ecosensor/osm2pgsql:latest
    profiles: ["all", "db", "be", "osm", "stack"]
    env_file:
      - .env.osm2pgsql
    depends_on:
      ecosensor-osm2pg-db:
        condition: service_healthy
    restart: always
    environment:
      PGHOST: ecosensor-osm2pg-db
      PGDATABASE: ${POSTGRES_OSM_DB}
      PGUSER: ${POSTGRES_OSM_USER}
      PGPASSWORD: ${POSTGRES_OSM_PASS}
      PGPORT: ${POSTGRES_OSM_PORT}
    volumes:
      - ./osm-data/osm:/osm
```
