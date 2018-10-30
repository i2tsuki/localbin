#!/bin/sh

set -ex

# Enable basic sound output via pulseaudio
# Run "pacmd list-sinks | grep -e 'name:' -e 'index'" to find your QEMU_PA_SINK
export QEMU_AUDIO_DRV="pa"
export QEMU_PA_SINK="alsa_output.pci-0000_00_1f.3.analog-stereo"
export WORKDIR="${HOME}/qemu"
# export QEMU_PA_SOURCE=input

export GVT_G_DEVICE="$(find /sys/bus/pci/devices/0000:00:02.0/mdev_supported_types/i915-GVTg_V5_2/devices -type l | head -n 1)"
if [ -z "${GVT_G_DEVICE}" ] ; then
    exit 1
fi

# Start QEMU
qemu-system-x86_64 -enable-kvm \
                   -m 6144M \
                   -smp cores=2,threads=2,sockets=1,maxcpus=4 \
                   -cpu host,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time \
                   -machine type=pc,accel=kvm,kernel_irqchip=on \
                   -global PIIX4_PM.disable_s3=1 \
                   -global PIIX4_PM.disable_s4=1 \
                   -name "windows-gvt-g" \
                   -soundhw hda \
                   -usb \
                   -vnc :1 \
                   -device usb-tablet \
                   -display gtk,gl=on \
                   -k en-us \
                   -bios /usr/share/seabios/bios.bin \
                   -drive file=${WORKDIR}/windows.qcow2,format=qcow2,l2-cache-size=8M,if=virtio,aio=native,cache.direct=on \
                   -vga none \
                   -device vfio-pci,sysfsdev=${GVT_G_DEVICE},x-igd-opregion=on,display=on \
                   -nic user,model=virtio-net-pci,smb=${HOME}/Downloads,smbserver=10.0.2.4 \
                   -chardev spicevmc,id=vdagent,name=vdagent -device virtio-serial-pci -device virtserialport,chardev=vdagent,name=com.redhat.spice.0

# -display egl-headless,gl=on -spice gl=off,port=5910,disable-ticketing \
