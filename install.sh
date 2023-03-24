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

# gh
curl -LO https://github.com/cli/cli/releases/download/v2.5.1/gh_2.5.1_linux_amd64.tar.gz
tar xf ./gh_2.5.1_linux_amd64.tar.gz
install ./gh_2.5.1_linux_amd64/bin/gh ${HOME}/.local/bin/gh

# flamegraph
/usr/bin/curl -LO https://raw.githubusercontent.com/brendangregg/FlameGraph/master/flamegraph.pl
chmod -v +x ./flamegraph.pl

# Install scripts as symlinks
for i in $(find . -maxdepth 1 -mindepth 1 -type f | egrep -v ${EXCLUDE})
do
    ln -sfv $(readlink -f $i) ${HOME}/.local/bin
done

# Install scripts under `secrets/`` as symlinks
for i in $(find ./secrets -maxdepth 1 -mindepth 1 -type f | egrep -v ${EXCLUDE})
do
    ln -sfv $(readlink -f $i) ${HOME}/.local/bin
done

cd ${HOME}
which npm
if [ $? = "0" ] ; then
    npm install prettier
    npm install yarn
    npm install aws-cdk
    npm install typescript
    npm install tsc
    npm install tslint
    npm install tslint-config-prettier
    npm install ts-node
    npm install htpasswd
fi
cd ${OLDPWD}

which go
if [ $? = "0" ] ; then
    go install github.com/direnv/direnv@latest
    go install github.com/gofireflyio/aiac@latest
fi

PIP="pip3 -q"

${PIP} install --user numpy
${PIP} install --user git+https://github.com/evertrol/mpyfit.git#egg=mpyfit
${PIP} install --user flake8
${PIP} install --user black
${PIP} install --user jsbeautifier
${PIP} install --user mypy

which sk || cargo install skim
which mdbook || cargo install mdbook

# Nerd Fonts installation
mkdir -pv ${HOME}/.fonts/nerd-fonts
cd ${HOME}/.fonts/nerd-fonts
curl -LO https://github.com/ryanoasis/nerd-fonts/releases/download/v2.0.0/FiraCode.zip
fc-cache -f -v
