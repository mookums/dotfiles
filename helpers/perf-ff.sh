#!/bin/bash

perf record -g -F max --call-graph dwarf $@
