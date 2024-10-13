#!/bin/bash

sudo apt update
sudo apt -y install git cmake make g++ libboost-dev libbz2-dev zlib1g-dev libpq-dev libproj-dev \
    lua5.3 liblua5.3-dev libgeos-dev libgeos++-dev libprotobuf-c-dev \
    libosmpbf-dev libgdal-dev libjson-c-dev libpng-dev libtiff-dev \
    libicu-dev libxml2-dev libzip-dev liblua5.3-dev libluajit-5.1-dev \
    libprotobuf-c-dev libgeos-dev libgeos++-dev libgdal-dev libjson-c-dev \
    libpng-dev libtiff-dev libicu-dev libproj-dev libxml2-dev libzip-dev \
    python3 python3-pip python3-venv nlohmann-json \
    boost expat bzip2 zlib libpq proj lua5.3 luajit potrace opencv lz4-libs 

git clone git clone -b 1.10.0 https://github.com/osm2pgsql-dev/osm2pgsql.git $HOME/osm2pgsql
cd $HOME/osm2pgsql
mkdir build
cd build
sudo make
sudo make install
sudo make install-gen

# installa le librerie per la compilazione di osm2pgsql
python3 -m venv /venv
export PATH="/venv/bin:$PATH"
pip install osmium psycopg2
