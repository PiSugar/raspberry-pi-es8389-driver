obj-m := snd-soc-es8389.o
snd-soc-es8389-objs := es8389.o

KDIR ?= /lib/modules/$(shell uname -r)/build
PWD  := $(shell pwd)

all:
	$(MAKE) -C $(KDIR) M=$(PWD) modules

clean:
	$(MAKE) -C $(KDIR) M=$(PWD) clean

install: all
	sudo install -m 644 snd-soc-es8389.ko \
		/lib/modules/$(shell uname -r)/kernel/sound/soc/codecs/
	sudo depmod -a
