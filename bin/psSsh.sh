#!/bin/bash

# find broken ssh-connections

ps aux | grep '[0-9]\+:[0-9]\+[[:space:]]\+\w+\+[[:space:]]\+ssh'

