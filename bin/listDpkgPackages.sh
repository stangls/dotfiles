#!/bin/bash
dpkg --get-selections | awk '!/deinstall|purge|hold/ {print $1}'
