#!/usr/bin/env bash

find eclass -name "eupdate.updates" -exec ./approve.sh '{}' \;
find . -name "eupdate.updates" -exec ./approve.sh '{}' \;
