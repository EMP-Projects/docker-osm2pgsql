FROM docker.io/python:3.8-alpine AS builder

RUN apk --no-cache add \
    git \
    cmake \
    make \
    g++ \
    nlohmann-json \
    postgresql-dev \
    boost-dev \
    expat-dev \
    bzip2-dev \
    zlib-dev \
    libpq \
    proj-dev \
    lua5.3-dev \
    luajit-dev \
    potrace-dev \
    wget \
    opencv-dev \
    postgresql-client

RUN git clone -b 1.10.0 https://github.com/osm2pgsql-dev/osm2pgsql.git
WORKDIR osm2pgsql

RUN mkdir build
WORKDIR build
RUN cmake -D WITH_LUAJIT=ON ..
RUN make
RUN make install
RUN make install-gen

RUN apk add --no-cache python3 py3-pip
RUN python3 -m venv /venv
ENV PATH="/venv/bin:$PATH"
RUN pip install osmium psycopg2

FROM docker.io/python:3.8-alpine

RUN apk --no-cache add \
    nlohmann-json \
    boost \
    expat \
    bzip2 \
    zlib \
    libpq \
    proj \
    lua5.3 \
    luajit \
    potrace \
    opencv \
    lz4-libs \
    postgresql-client

COPY --from=builder /usr/local/bin/osm2pgsql* /usr/local/bin/
COPY --from=builder /usr/local/share/osm2pgsql/*.style /usr/local/share/osm2pgsql/
COPY ./custom.style /usr/local/share/osm2pgsql/

COPY --from=builder /venv /venv
ENV PATH="/venv/bin:$PATH"

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]