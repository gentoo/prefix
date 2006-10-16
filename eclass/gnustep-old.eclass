# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/gnustep-old.eclass,v 1.10 2006/10/14 20:27:21 swegener Exp $


DESCRIPTION="Based on the gnustep eclass."

DEPEND="gnustep-base/gnustep-make
	gnustep-base/gnustep-base
	sys-devel/gcc
	virtual/libc"
RDEPEND="virtual/libc"

getsourcedir() {
	if [ ! -d "${S}" ] ; then
		if [ -d "${WORKDIR}/${PN}" ] ; then
			S="${WORKDIR}/${PN}"
		elif [ -d "${WORKDIR}/${P}" ] ; then
			S="${WORKDIR}/${P}"
		else
			die "Cannot find source directory!"
		fi
	fi
}

need-gnustep-gui() {
	if [ "$1" ] ; then
		DEPEND="${DEPEND} >=gnustep-base/gnustep-gui-$1"
		RDEPEND="${RDEPEND} >=gnustep-base/gnustep-back-$1"
	else
		DEPEND="${DEPEND} gnustep-base/gnustep-gui"
		RDEPEND="${RDEPEND} gnustep-base/gnustep-back"
	fi
}

egnustepmake() {
	getsourcedir

	addwrite /root/GNUstep/Defaults/.GNUstepDefaults.lck
	addpredict /root/GNUstep

	cd ${S}

	if [ -f /usr/GNUstep/System/Makefiles/GNUstep.sh ] ; then
		. /usr/GNUstep/System/Makefiles/GNUstep.sh
	else
		die "gnustep-make not installed!"
	fi

	mkdir -p $TMP/fakehome/GNUstep

	if [ -x configure ] ; then
		if [ -z "$*" ] ; then
			./configure \
				HOME=$TMP/fakehome \
				GNUSTEP_USER_ROOT=$TMP/fakehome/GNUstep \
				|| die "configure failed"
		else
			./configure \
				HOME=$TMP/fakehome \
				GNUSTEP_USER_ROOT=$TMP/fakehome/GNUstep \
				$* || die "configure failed (options: $*)"
		fi
	fi

	if [ "${GNUSTEPBACK_XFT}" != "2" ] ; then
		if [ "${PN}" = "gnustep-back" ] ; then
			if [ ! -f "/usr/X11R6/include/X11/Xft1/Xft.h" ]; then
				sed "s,^#define HAVE_XFT.*,#undef HAVE_XFT,g" config.h > config.h.new
				sed "s,^#define HAVE_UTF8.*,#undef HAVE_UTF8,g" config.h.new > config.h
				sed "s,^WITH_XFT=.*,WITH_XFT=no," config.make > config.make.new
				sed "s,-lXft,," config.make.new > config.make
			fi
		fi
	fi

	if [ -f ./[mM]akefile -o -f ./GNUmakefile ] ; then
		make \
			HOME=$TMP/fakehome \
			GNUSTEP_USER_ROOT=$TMP/fakehome/GNUstep \
			|| die "emake failed"
	else
		die "no Makefile found"
	fi
	return 0
}

egnustepinstall() {
	getsourcedir

	addwrite /root/GNUstep/Defaults/.GNUstepDefaults.lck
	addpredict /root/GNUstep

	cd ${S}

	if [ -f /usr/GNUstep/System/Makefiles/GNUstep.sh ] ; then
		source /usr/GNUstep/System/Makefiles/GNUstep.sh
	else
		die "gnustep-make not installed!"
	fi

	mkdir -p $TMP/fakehome/GNUstep

	if [ -f ./[mM]akefile -o -f ./GNUmakefile ] ; then
		# To be or not to be evil?
		# Should all the roots point at GNUSTEP_SYSTEM_ROOT to force
		# install?
		# GNUSTEP_USER_ROOT must be GNUSTEP_SYSTEM_ROOT, some malformed
		# Makefiles install there.
		if [ "${PN}" = "gnustep-base" ] || [ "${PN}" = "gnustep-gui" ] || [ "${PN}" = "gnustep-back" ] ; then
			# for some reason, they need less tending to...
			make \
				GNUSTEP_USER_ROOT=$TMP/fakehome/GNUstep \
				HOME=$TMP/fakehome \
				GNUSTEP_INSTALLATION_DIR=${D}${GNUSTEP_SYSTEM_ROOT} \
				INSTALL_ROOT_DIR=${D} \
				install || die "einstall failed"
		else
			make \
				GNUSTEP_USER_ROOT=$TMP/fakehome/GNUstep \
				HOME=$TMP/fakehome \
				GNUSTEP_INSTALLATION_DIR=${D}${GNUSTEP_SYSTEM_ROOT} \
				INSTALL_ROOT_DIR=${D} \
				GNUSTEP_LOCAL_ROOT=${D}${GNUSTEP_LOCAL_ROOT} \
				GNUSTEP_NETWORK_ROOT=${D}${GNUSTEP_NETWORK_ROOT} \
				GNUSTEP_SYSTEM_ROOT=${D}${GNUSTEP_SYSTEM_ROOT} \
				GNUSTEP_USER_ROOT=${D}${GNUSTEP_SYSTEM_ROOT} \
				install || die "einstall failed"
		fi
	else
		die "no Makefile found"
	fi
	return 0
}

gnustep-old_src_compile() {
	egnustepmake || die
}

gnustep-old_src_install() {
	egnustepinstall || die
}

EXPORT_FUNCTIONS src_compile src_install
