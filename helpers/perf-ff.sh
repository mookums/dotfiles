#!/bin/bash

perf record -g -F $1 --call-graph dwarf "${@:2}"
