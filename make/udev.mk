###########################################################
#
# udev
#
###########################################################

# You must replace "udev" and "UDEV" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# UDEV_VERSION, UDEV_SITE and UDEV_SOURCE define
# the upstream location of the source code for the package.
# UDEV_DIR is the directory which is created when the source
# archive is unpacked.
# UDEV_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
# Please make sure that you add a description, and that you
# list all your packages' dependencies, seperated by commas.
# 
# If you list yourself as MAINTAINER, please give a valid email
# address, and indicate your irc nick if it cannot be easily deduced
# from your name or email address.  If you leave MAINTAINER set to
# "NSLU2 Linux" other developers will feel free to edit.
#
UDEV_SITE=http://archive.ubuntu.com/ubuntu/pool/main/u/udev
UDEV_VERSION=175
UDEV_SOURCE=udev_$(UDEV_VERSION).orig.tar.gz
UDEV_DIR=udev-$(UDEV_VERSION)
UDEV_UNZIP=zcat
UDEV_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
UDEV_DESCRIPTION=udev - dynamic device management.
LIBUDEV_DESCRIPTION=libudev provides a set of functions for accessing the udev database and querying sysfs.
LIBGUDEV_DESCRIPTION=GObject-based wrapper library for libudev
UDEV_SECTION=utility
LIBUDEV_SECTION=lib
LIBGUDEV_SECTION=lib
UDEV_PRIORITY=optional
UDEV_DEPENDS=usbutils
LIBUDEV_DEPENDS=
LIBGUDEV_DEPENDS=glib
UDEV_SUGGESTS=
UDEV_CONFLICTS=

#
# UDEV_IPK_VERSION should be incremented when the ipk changes.
#
UDEV_IPK_VERSION=1

#
# UDEV_CONFFILES should be a list of user-editable files
UDEV_CONFFILES=/opt/etc/udev/udev.conf

#
# UDEV_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#UDEV_PATCHES=$(UDEV_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
UDEV_CPPFLAGS=
UDEV_LDFLAGS=

#
# UDEV_BUILD_DIR is the directory in which the build is done.
# UDEV_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# UDEV_IPK_DIR is the directory in which the ipk is built.
# UDEV_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
UDEV_BUILD_DIR=$(BUILD_DIR)/udev
UDEV_SOURCE_DIR=$(SOURCE_DIR)/udev

UDEV_IPK_DIR=$(BUILD_DIR)/udev-$(UDEV_VERSION)-ipk
UDEV_IPK=$(BUILD_DIR)/udev_$(UDEV_VERSION)-$(UDEV_IPK_VERSION)_$(TARGET_ARCH).ipk

LIBUDEV_IPK_DIR=$(BUILD_DIR)/libudev-$(UDEV_VERSION)-ipk
LIBUDEV_IPK=$(BUILD_DIR)/libudev_$(UDEV_VERSION)-$(UDEV_IPK_VERSION)_$(TARGET_ARCH).ipk

LIBGUDEV_IPK_DIR=$(BUILD_DIR)/libgudev-$(UDEV_VERSION)-ipk
LIBGUDEV_IPK=$(BUILD_DIR)/libgudev_$(UDEV_VERSION)-$(UDEV_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: udev-source udev-unpack udev udev-stage udev-ipk udev-clean udev-dirclean udev-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(UDEV_SOURCE):
	$(WGET) -P $(@D) $(UDEV_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
udev-source: $(DL_DIR)/$(UDEV_SOURCE) $(UDEV_PATCHES)

#
# This target unpacks the source code in the build directory.
# If the source archive is not .tar.gz or .tar.bz2, then you will need
# to change the commands here.  Patches to the source code are also
# applied in this target as required.
#
# This target also configures the build within the build directory.
# Flags such as LDFLAGS and CPPFLAGS should be passed into configure
# and NOT $(MAKE) below.  Passing it to configure causes configure to
# correctly BUILD the Makefile with the right paths, where passing it
# to Make causes it to override the default search paths of the compiler.
#
# If the compilation of the package requires other packages to be staged
# first, then do that first (e.g. "$(MAKE) <bar>-stage <baz>-stage").
#
# If the package uses  GNU libtool, you should invoke $(PATCH_LIBTOOL) as
# shown below to make various patches to it.
#
$(UDEV_BUILD_DIR)/.configured: $(DL_DIR)/$(UDEV_SOURCE) $(UDEV_PATCHES) make/udev.mk
	$(MAKE) glib-stage usbutils-stage
	rm -rf $(BUILD_DIR)/$(UDEV_DIR) $(@D)
	$(UDEV_UNZIP) $(DL_DIR)/$(UDEV_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(UDEV_PATCHES)" ; \
		then cat $(UDEV_PATCHES) | \
		patch -d $(BUILD_DIR)/$(UDEV_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(UDEV_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(UDEV_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(UDEV_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(UDEV_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
		--disable-introspection \
		--with-pci-ids-path=/opt/share/misc/pci.ids \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

udev-unpack: $(UDEV_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(UDEV_BUILD_DIR)/.built: $(UDEV_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
udev: $(UDEV_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(UDEV_BUILD_DIR)/.staged: $(UDEV_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(addprefix $(STAGING_LIB_DIR)/, libgudev-1.0.la libudev.la)
	sed -i -e '/^prefix=/s|=.*|=$(STAGING_PREFIX)|' $(addprefix \
		$(STAGING_LIB_DIR)/pkgconfig/, libudev.pc gudev-1.0.pc)
	touch $@

udev-stage: $(UDEV_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/udev
#
$(UDEV_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: udev" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(UDEV_PRIORITY)" >>$@
	@echo "Section: $(UDEV_SECTION)" >>$@
	@echo "Version: $(UDEV_VERSION)-$(UDEV_IPK_VERSION)" >>$@
	@echo "Maintainer: $(UDEV_MAINTAINER)" >>$@
	@echo "Source: $(UDEV_SITE)/$(UDEV_SOURCE)" >>$@
	@echo "Description: $(UDEV_DESCRIPTION)" >>$@
	@echo "Depends: $(UDEV_DEPENDS)" >>$@
	@echo "Suggests: $(UDEV_SUGGESTS)" >>$@
	@echo "Conflicts: $(UDEV_CONFLICTS)" >>$@

$(LIBUDEV_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libudev" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(UDEV_PRIORITY)" >>$@
	@echo "Section: $(LIBUDEV_SECTION)" >>$@
	@echo "Version: $(UDEV_VERSION)-$(UDEV_IPK_VERSION)" >>$@
	@echo "Maintainer: $(UDEV_MAINTAINER)" >>$@
	@echo "Source: $(UDEV_SITE)/$(UDEV_SOURCE)" >>$@
	@echo "Description: $(LIBUDEV_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBUDEV_DEPENDS)" >>$@
	@echo "Suggests: $(LIBUDEV_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBUDEV_CONFLICTS)" >>$@

$(LIBGUDEV_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libgudev" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(UDEV_PRIORITY)" >>$@
	@echo "Section: $(LIBGUDEV_SECTION)" >>$@
	@echo "Version: $(UDEV_VERSION)-$(UDEV_IPK_VERSION)" >>$@
	@echo "Maintainer: $(UDEV_MAINTAINER)" >>$@
	@echo "Source: $(UDEV_SITE)/$(UDEV_SOURCE)" >>$@
	@echo "Description: $(LIBGUDEV_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBGUDEV_DEPENDS)" >>$@
	@echo "Suggests: $(LIBGUDEV_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBGUDEV_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(UDEV_IPK_DIR)/opt/sbin or $(UDEV_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(UDEV_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(UDEV_IPK_DIR)/opt/etc/udev/...
# Documentation files should be installed in $(UDEV_IPK_DIR)/opt/doc/udev/...
# Daemon startup scripts should be installed in $(UDEV_IPK_DIR)/opt/etc/init.d/S??udev
#
# You may need to patch your application to make it use these locations.
#
$(UDEV_IPK) $(LIBUDEV_IPK) $(LIBGUDEV_IPK): $(UDEV_BUILD_DIR)/.built
	rm -rf $(UDEV_IPK_DIR) $(BUILD_DIR)/udev_*_$(TARGET_ARCH).ipk \
		$(LIBUDEV_IPK_DIR) $(BUILD_DIR)/libudev_*_$(TARGET_ARCH).ipk \
		$(LIBGUDEV_IPK_DIR) $(BUILD_DIR)/libgudev_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(UDEV_BUILD_DIR) DESTDIR=$(UDEV_IPK_DIR) install-strip
	rm -f $(UDEV_IPK_DIR)/opt/lib/*.la
	install -d $(LIBUDEV_IPK_DIR)/opt $(LIBGUDEV_IPK_DIR)/opt/lib/pkgconfig
	mv -f $(UDEV_IPK_DIR)/opt/lib $(LIBUDEV_IPK_DIR)/opt
	mv -f $(LIBUDEV_IPK_DIR)/opt/lib/libgudev-1.0.* $(LIBGUDEV_IPK_DIR)/opt/lib
	mv -f $(LIBUDEV_IPK_DIR)/opt/lib/pkgconfig/gudev-1.0.pc $(LIBGUDEV_IPK_DIR)/opt/lib/pkgconfig
#	install -d $(UDEV_IPK_DIR)/opt/etc/
#	install -m 644 $(UDEV_SOURCE_DIR)/udev.conf $(UDEV_IPK_DIR)/opt/etc/udev.conf
#	install -d $(UDEV_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(UDEV_SOURCE_DIR)/rc.udev $(UDEV_IPK_DIR)/opt/etc/init.d/SXXudev
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(UDEV_IPK_DIR)/opt/etc/init.d/SXXudev
	$(MAKE) $(UDEV_IPK_DIR)/CONTROL/control
#	install -m 755 $(UDEV_SOURCE_DIR)/postinst $(UDEV_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(UDEV_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(UDEV_SOURCE_DIR)/prerm $(UDEV_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(UDEV_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(UDEV_IPK_DIR)/CONTROL/postinst $(UDEV_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(UDEV_CONFFILES) | sed -e 's/ /\n/g' > $(UDEV_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(UDEV_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(UDEV_IPK_DIR)
	$(MAKE) $(LIBUDEV_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBUDEV_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIBUDEV_IPK_DIR)
	$(MAKE) $(LIBGUDEV_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBGUDEV_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIBGUDEV_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
udev-ipk: $(UDEV_IPK) $(LIBUDEV_IPK) $(LIBGUDEV_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
udev-clean:
	rm -f $(UDEV_BUILD_DIR)/.built
	-$(MAKE) -C $(UDEV_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
udev-dirclean:
	rm -rf $(BUILD_DIR)/$(UDEV_DIR) $(UDEV_BUILD_DIR) \
		$(UDEV_IPK_DIR) $(UDEV_IPK) \
		$(LIBUDEV_IPK_DIR) $(LIBUDEV_IPK) \
		$(LIBGUDEV_IPK_DIR) $(LIBGUDEV_IPK)
#
#
# Some sanity check for the package.
#
udev-check: $(UDEV_IPK) $(LIBUDEV_IPK) $(LIBGUDEV_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^