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

which npm
if [ $? = "0" ] ; then
    npm install prettier
    npm install markdown-to-medium
fi

which go
if [ $? = "0" ] ; then
    go get -u github.com/mackerelio/mkr
    go get -u github.com/tcnksm/ghr
fi

if (which pip) ; then
    PIP=pip
else
    PIP=pip3
fi

${PIP} install --user gcalcli
${PIP} install --user numpy
${PIP} install --user git+https://github.com/evertrol/mpyfit.git#egg=mpyfit
# ${PIP} install --user pyfits astropy ipython sympy git+https://github.com/rcbrgs/tuna

cargo install skim
cargo install mdbook

set +e
if ! (which revive) ; then
    go get -u github.com/mgechev/revive
fi

curl -LO https://storage.googleapis.com/kubernetes-helm/helm-v2.9.1-linux-amd64.tar.gz
mv -v ./linux-amd64/helm ${GOPATH}/bin/
rm -rfv ./linux-amd64 ./helm-v2.9.1-linux-amd64.tar.gz

# Nerd Fonts installation
mkdir -pv ${HOME}/.fonts/nerd-fonts
cd ${HOME}/.fonts/nerd-fonts
curl -LO https://github.com/ryanoasis/nerd-fonts/releases/download/v2.0.0/FiraCode.zip
fc-cache -f -v
