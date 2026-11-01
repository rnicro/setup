#!/bin/sh

cd ~
mkdir -p .config/tofi/
cd .config/
mkdir foot/
mkdir velotype/
cd ..
mkdir Downloads/
mkdir Notes
mkdir Pictures
aria2c https://github.com/rnicro/setup/raw/refs/heads/main/config -d .config/tofi
aria2c https://github.com/rnicro/setup/raw/refs/heads/main/tofi-status.sh -d .config/tofi
aria2c https://github.com/rnicro/setup/raw/refs/heads/main/foot.ini -d .config/foot
aria2c https://github.com/rnicro/setup/raw/refs/heads/main/.history -d .config/velotype
aria2c https://github.com/rnicro/setup/raw/refs/heads/main/config.toml -d .config/velotype
aria2c https://github.com/rnicro/setup/raw/refs/heads/main/.bash_profile
aria2c https://github.com/rnicro/setup/raw/refs/heads/main/.bash_profile
aria2c https://github.com/rnicro/setup/raw/refs/heads/main/start-dwl.sh
aria2c https://github.com/rnicro/setup/raw/refs/heads/main/dwl.tar
tar xf dwl.tar
rm dwl.tar
