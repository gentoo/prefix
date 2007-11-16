#!/usr/bin/env bash

find profiles -name "eupdate.updates" -exec ./approve.sh '{}' \;
find eclass -name "eupdate.updates" -exec ./approve.sh '{}' \;
find licenses -name "eupdate.updates" -exec ./approve.sh '{}' \;
find . -name "eupdate.updates" -exec ./approve.sh '{}' \;
