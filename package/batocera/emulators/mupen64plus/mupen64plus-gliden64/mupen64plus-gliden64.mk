################################################################################
#
# mupen64plus video GLIDEN64
#
################################################################################
# Version.: Commits on Apr 23, 2019
MUPEN64PLUS_GLIDEN64_VERSION = cd76b93000fa7451a18816d4d300ca92078a2b90
MUPEN64PLUS_GLIDEN64_SITE = $(call github,gonetz,GLideN64,$(MUPEN64PLUS_GLIDEN64_VERSION))
MUPEN64PLUS_GLIDEN64_LICENSE = GPLv2
MUPEN64PLUS_GLIDEN64_DEPENDENCIES = sdl2 alsa-lib mupen64plus-core
MUPEN64PLUS_GLIDEN64_CONF_OPTS = -DMUPENPLUSAPI=On
MUPEN64PLUS_GLIDEN64_SUBDIR = /src/

ifeq ($(BR2_PACKAGE_RPI_USERLAND),y)
	MUPEN64PLUS_GLIDEN64_DEPENDENCIES += rpi-userland
	MUPEN64PLUS_GLIDEN64_CONF_OPTS += -DRPI=ON
endif

ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_S905)$(BR2_PACKAGE_BATOCERA_TARGET_S912)$(BR2_PACKAGE_BATOCERA_TARGET_C2)$(BR2_PACKAGE_BATOCERA_TARGET_XU4)$(BR2_PACKAGE_BATOCERA_TARGET_LEGACYXU4)$(BR2_PACKAGE_BATOCERA_TARGET_ROCKPRO64)$(BR2_PACKAGE_BATOCERA_TARGET_ODROIDN2),y)
       MUPEN64PLUS_GLIDEN64_CONF_OPTS += -DGLES2=ON
endif

define MUPEN64PLUS_GLIDEN64_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/recalbox/configs/mupen64/
	mkdir -p $(TARGET_DIR)/usr/share/mupen64plus/
	$(INSTALL) -D $(@D)/src/plugin/Release/mupen64plus-video-GLideN64.so \
		$(TARGET_DIR)/usr/lib/mupen64plus/mupen64plus-video-gliden64.so
	$(INSTALL) -D $(@D)/ini/* \
		$(TARGET_DIR)/usr/share/mupen64plus/
	$(INSTALL) -D $(@D)/ini/* \
		$(TARGET_DIR)/recalbox/configs/mupen64/
endef

define MUPEN64PLUS_GLIDEN64_PRE_CONFIGURE_FIXUP
	chmod +x $(@D)/src/getRevision.sh
	sh $(@D)/src/getRevision.sh
	$(SED) 's|/opt/vc/include|$(STAGING_DIR)/usr/include|g' $(@D)/src/CMakeLists.txt
	$(SED) 's|/opt/vc/lib|$(STAGING_DIR)/usr/lib|g' $(@D)/src/CMakeLists.txt

endef

MUPEN64PLUS_GLIDEN64_PRE_CONFIGURE_HOOKS += MUPEN64PLUS_GLIDEN64_PRE_CONFIGURE_FIXUP


$(eval $(cmake-package))


