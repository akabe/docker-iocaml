#!/bin/sh

sudo chown -hR opam:opam /notebooks
opam config exec -- "$@"
