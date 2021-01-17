#!/usr/bin/env bash

sudo podman exec -u web -w /home/web/ -it zig.run sh -l

