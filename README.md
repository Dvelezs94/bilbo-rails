# Bilbo

This Readme shows how to run Bilbo locally, utilizing docker and docker compose


# Prerequisites

- Linux / MacOS
- Docker
- Docker Compose

## Start

1. Download Code by doing `git clone git@gitlab.com:bilboapp/bilbo-rails.git`
2. Move to the directory `cd bilbo-rails`
3. Grant permissons to user `usermod -a -G docker $USER` (reboot if necessary)
3. Export PATH for bilbo CLI `bash bilbo path`
4. Start project `bilbo start`

## Stop

1. `bilbo stop`

## Help

1. `bilbo help`
