################################################################################
#
# batocera.linux System
#
################################################################################

BATOCERA_SYSTEM_SOURCE=

BATOCERA_SYSTEM_VERSION = 5.23-dev
BATOCERA_SYSTEM_DATE_TIME = $(shell date "+%Y/%m/%d %H:%M") 
BATOCERA_SYSTEM_DEPENDENCIES = tzdata

ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_RPI3),y)
	BATOCERA_SYSTEM_ARCH=rpi3
	BATOCERA_SYSTEM_BATOCERA_CONF=rpi3
	BATOCERA_SYSTEM_SUBDIR=rpi-firmware
else ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_ROCKPRO64),y)
        BATOCERA_SYSTEM_ARCH=rockpro64
        BATOCERA_SYSTEM_BATOCERA_CONF=rockpro64
        BATOCERA_SYSTEM_SUBDIR=
else ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_ODROIDN2),y)
        BATOCERA_SYSTEM_ARCH=odroidn2
        BATOCERA_SYSTEM_BATOCERA_CONF=odroidn2
        BATOCERA_SYSTEM_SUBDIR=
else ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_XU4),y)
	BATOCERA_SYSTEM_ARCH=odroidxu4
	BATOCERA_SYSTEM_BATOCERA_CONF=xu4
	BATOCERA_SYSTEM_SUBDIR=
else ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_LEGACYXU4),y)
	BATOCERA_SYSTEM_ARCH=odroidxu4
	BATOCERA_SYSTEM_BATOCERA_CONF=xu4
	BATOCERA_SYSTEM_SUBDIR=
else ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_C2),y)
	BATOCERA_SYSTEM_ARCH=odroidc2
	BATOCERA_SYSTEM_BATOCERA_CONF=c2
else ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_S905),y)
	BATOCERA_SYSTEM_ARCH=s905
	BATOCERA_SYSTEM_BATOCERA_CONF=s905
else ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_S912),y)
        BATOCERA_SYSTEM_ARCH=s912
        BATOCERA_SYSTEM_BATOCERA_CONF=s912
else ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_X86),y)
	BATOCERA_SYSTEM_ARCH=x86
	BATOCERA_SYSTEM_BATOCERA_CONF=x86
	BATOCERA_SYSTEM_SUBDIR=
else ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_X86_64),y)
	BATOCERA_SYSTEM_ARCH=x86_64
	BATOCERA_SYSTEM_BATOCERA_CONF=x86_64
	BATOCERA_SYSTEM_SUBDIR=
else ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_RPI2),y)
	BATOCERA_SYSTEM_ARCH=rpi2
	BATOCERA_SYSTEM_BATOCERA_CONF=rpi2
	BATOCERA_SYSTEM_SUBDIR=rpi-firmware
else ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_RPI1),y)
	BATOCERA_SYSTEM_ARCH=rpi1
	BATOCERA_SYSTEM_BATOCERA_CONF=rpi1
	BATOCERA_SYSTEM_SUBDIR=rpi-firmware
else
        BATOCERA_SYSTEM_ARCH=unknown
        BATOCERA_SYSTEM_BATOCERA_CONF=unknown
        BATOCERA_SYSTEM_SUBDIR=
endif

define BATOCERA_SYSTEM_INSTALL_TARGET_CMDS

	# version/arch
	mkdir -p $(TARGET_DIR)/usr/share/batocera
	echo -n "$(BATOCERA_SYSTEM_ARCH)" > $(TARGET_DIR)/usr/share/batocera/batocera.arch
	echo $(BATOCERA_SYSTEM_VERSION) $(BATOCERA_SYSTEM_DATE_TIME) > $(TARGET_DIR)/usr/share/batocera/batocera.version

	# datainit
	mkdir -p $(TARGET_DIR)/usr/share/batocera/datainit/system
	cp package/batocera/core/batocera-system/$(BATOCERA_SYSTEM_BATOCERA_CONF)/batocera.conf $(TARGET_DIR)/usr/share/batocera/datainit/system

	# batocera-boot.conf
        $(INSTALL) -D -m 0644 package/batocera/core/batocera-system/batocera-boot.conf $(BINARIES_DIR)/$(BATOCERA_SYSTEM_SUBDIR)/batocera-boot.conf

	# mounts
	mkdir -p $(TARGET_DIR)/boot $(TARGET_DIR)/overlay $(TARGET_DIR)/userdata
endef

$(eval $(generic-package))
