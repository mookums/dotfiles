#!/usr/bin/env bash

case $1 in
    "perf" )
        perf record -g -F $2 --call-graph dwarf "${@:3}"
        ;;
    "cache" )
        perf stat -B -e cache-references,cache-misses,cycles,instructions,branches,faults,migrations "${@:2}"
        ;;
    *)
        echo "perf or cache"
        ;;
esac
