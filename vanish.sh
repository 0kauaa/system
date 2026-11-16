#!/bin/bash

nix-env --delete-generations old
nixos-rebuild boot
