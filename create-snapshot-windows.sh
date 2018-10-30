#!/bin/sh

set -eu

CREATEPOINT="$(date +%Y%m%dT%H00)"
WORKDIR="${HOME}/qemu"

qemu-img snapshot -c ${CREATEPOINT} ${WORKDIR}/windows.qcow2
qemu-img snapshot -l ${WORKDIR}/windows.qcow2
