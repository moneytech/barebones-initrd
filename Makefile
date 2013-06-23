QEMU=qemu-system-x86_64
QEMU_MEM_MB=96

QEMU_OPTS=-m $(QEMU_MEM_MB) -s -cdrom image.iso -boot order=d

GRUB_ARCH=i386

tree_files = vmlinuz-3.2.0-4-amd64 initrd.img

all:	image.iso

clean:
	rm -f image.iso build *~ helloworld initrd.img
	rm -rf tree initrd

tree:	$(tree_files) menu.lst
	rm -rf tree
	mkdir -p tree/boot
	cp $(tree_files) tree/boot
	mkdir -p tree/boot/grub
	cp grub/$(GRUB_ARCH)-pc/stage2_eltorito tree/boot/grub
	cp menu.lst tree/boot/grub

initrd.img: initrd
	(cd initrd; find . -type f | cpio --quiet -R 0:0 -o -H newc) | gzip -c > $@

initrd: helloworld
	rm -rf initrd
	mkdir -p initrd
	cp helloworld initrd/init

helloworld: helloworld.c
	gcc -static -o $@ $<
	strip $@

GENISOIMAGE=genisoimage
image.iso: tree
	$(GENISOIMAGE) \
		-R -b boot/grub/stage2_eltorito \
		-no-emul-boot \
		-boot-load-size 4 \
		-boot-info-table \
		-o image.iso tree

run:	image.iso
	$(QEMU) $(QEMU_OPTS) -monitor stdio

textrun: image.iso
#	Don't forget to change menu.lst to include console=ttyS0 on the kernel command line
	$(QEMU) $(QEMU_OPTS) -nographic

stoprun: image.iso
	$(QEMU) $(QEMU_OPTS) -S -monitor stdio
