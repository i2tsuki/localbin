#!/bin/sh
set -eu

cd "$(dirname $(readlink -f $0))"

EXCLUDE="\.git|\.gitignore|Makefile|LICENSE|.install.sh"

mkdir -p ${HOME}/.local/bin

# Remove installed symlink without function
for i in $(find ${HOME}/.local/bin -maxdepth 1 -mindepth 1 -type l)
do
    [ -f "$(readlink $i)" ] && continue
    rm -fv $i
done

# flamegraph
/usr/bin/curl -LO https://raw.githubusercontent.com/brendangregg/FlameGraph/master/flamegraph.pl
chmod -v +x ./flamegraph.pl

# Install scripts as a symlink
for i in $(find . -maxdepth 1 -mindepth 1 -type f | egrep -v ${EXCLUDE})
do
    ln -sfv $(readlink -f $i) ${HOME}/.local/bin
done

# Install scripts in secrets as a symlink
for i in $(find ./secrets -maxdepth 1 -mindepth 1 -type f | egrep -v ${EXCLUDE})
do
    ln -sfv $(readlink -f $i) ${HOME}/.local/bin
done

cargo install skim
