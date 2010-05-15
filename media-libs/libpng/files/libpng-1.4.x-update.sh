#!/bin/bash

echo "Try revdep-rebuild first."
echo "This script will rename -lpng12 and libpng12.la to -lpng14 and libpng14.la"
echo "in your system libdir libtool .la files without asking permission."

[[ -d /usr/lib64 ]] && lib_suffix=64

libdir=/usr/lib${lib_suffix}

find ${libdir} -name '*.la' | xargs sed -i -e '/^dependency_libs/s:-lpng12:-lpng14:'
find ${libdir} -name '*.la' | xargs sed -i -e '/^dependency_libs/s:libpng12.la:libpng14.la:'

# WTFPL-2
