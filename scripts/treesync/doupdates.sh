#!/usr/bin/env bash

find profiles -name "eupdate.updates" -exec ./approve.sh '{}' \;
( export PTREEDIR=$(pwd -P) && cd profiles && eupdate ChangeLog categories info_pkgs info_vars license_groups package.mask thirdpartymirrors profiles.desc use.desc use.local.desc && sed -i -e 's/^#prefix#//' -e '/^[^#].*default-.*$/s/^/#/' profiles.desc && $SHELL )
find eclass -name "eupdate.updates" -exec ./approve.sh '{}' \;
find licenses -name "eupdate.updates" -exec ./approve.sh '{}' \;
find . -name "eupdate.updates" -exec ./approve.sh '{}' \;
