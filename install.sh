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

cd ${HOME}
which npm
if [ $? = "0" ] ; then
    npm install prettier
    npm install js-beautify
    npm install markdown-to-medium
    npm install yarn
    npm install aws-cdk
    npm install typescript
    npm install tsc
    npm install tslint
    npm install tslint-config-prettier
    npm install ts-node
    npm install htpasswd
    npm install p3x-onenote
fi
cd ${OLDPWD}

which go
if [ $? = "0" ] ; then
    go get -u github.com/tcnksm/ghr
    go get -u github.com/FiloSottile/mkcert
    go get -u github.com/direnv/direnv
fi

if (which pip3) ; then
    PIP="pip3 -q"
else
    exit 1
fi

${PIP} install --user gcalcli
${PIP} install --user numpy
${PIP} install --user git+https://github.com/evertrol/mpyfit.git#egg=mpyfit
${PIP} install --user docker-compose
${PIP} install --user flake8
${PIP} install --user black
${PIP} install --user awscli
${PIP} install --user ec2instanceconnectcli-latest.tar.gz
# ${PIP} install --user pyfits astropy ipython sympy git+https://github.com/rcbrgs/tuna

cargo install skim
cargo install mdbook

# Nerd Fonts installation
mkdir -pv ${HOME}/.fonts/nerd-fonts
cd ${HOME}/.fonts/nerd-fonts
curl -LO https://github.com/ryanoasis/nerd-fonts/releases/download/v2.0.0/FiraCode.zip
fc-cache -f -v
