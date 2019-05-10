[![Build Status](https://travis-ci.org/kontax/aur-pkg-build.svg?branch=master)](https://travis-ci.org/kontax/aur-pkg-build)

# AUR Pkg Build
This container is used in conjunction with the [Repo Build Service](https://www.github.com/kontax/repo-build-service) to automatically build packages from the Arch Linux user repository, and store them in an S3 bucket. Notifications are sent via [Pushover](https://pushover.net) on completion or failure, and the database is sync'd automatically.

## Usage
For further usage instructions see [Repo Build Service](https://www.github.com/kontax/repo-build-service).
