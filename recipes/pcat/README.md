# PC/AT

PC-compatible machines need no introduction. They are one of the most popular
machines of all time. Collapse OS has a 8086 assembler and has boot code
allowing it to run on a PC/AT-compatible machine, using BIOS interrupts in
real mode. Collapse OS always runs in real mode.

In this recipe, we will compile Collapse OS and write it to a USB drive that
is bootable on a modern PC-compatible machine.

## Gathering parts

* A modern PC-compatible machine that can boot from a USB drive.
* A USB drive
* qemu for emulation

## Build the binary

Running `make` in this folder with yield:

* mbr.bin: a 512 byte binary that goes at the beginning of the disk
* os.bin: 8086 Collapse OS binary
* disk.bin: a concatenation of the above, with `blkfs` appended to it starting at
            `0x2000`.

`disk.bin` is what goes on the drive.

This binary has `BLK` and `AT-XY` support, which means you have disk I/Os and
can run `VE`.

## Emulation

You can run the built binary in qemu using `make emul`.

## Running on a modern PC

First, copy `disk.bin` onto your USB drive. For example, on an OpenBSD machine,
it could look like:

    doas dd if=disk.bin of=/dev/sd1c

Your USB drive is now BIOS-bootable. Boot your computer and enter your BIOS
setup to make sure that "legacy boot" (non-EFI boot, that is, BIOS boot) is
enabled. Configure your boot device priority to ensure that the USB drive has
a chance to boot.

Reboot, you have Collapse OS. Boot is of course instantaneous (we're not used
to this with modern software...).
