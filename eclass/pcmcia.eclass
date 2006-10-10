# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/pcmcia.eclass,v 1.11 2006/05/18 15:54:05 halcy0n Exp $

# pcmcia.eclass - This eclass facilities writing ebuilds for driver packages
# that may need to build against the pcmcia-cs drivers, depending on kernel
# support, pcmcia-cs version installed, etc.

# It also ensures that any fixes need for pcmcia-cs configuration, driver
# compilation, etc can be located in one spot and be consistent among all
# driver packages

# Author - Peter Johanson <latexer@gentoo.org>

# Variables - You may safely use PCMCIA_SOURCE_DIR and PCMCIA_VERSION in ebuilds
# if this information is needed. These will be blank if kernel PCMCIA support
# is detected.

# Functions - pcmcia_src_unpack unpacks and patches as needed the pcmcia-cs
# sources in ${WORKDIR}/${PCMCIA_SOURCE_DIR} and set the two variables.

# pcmcia_configure will configure the pcmcia-cs sources if that is needed

inherit eutils

DESCRIPTION="eclass for drivers that may build against pcmcia-cs"
IUSE="pcmcia"

# Be VERY careful when pumping the PCMCIA_BASE_VERSION. May require remaking some patches, etc
# Ugly, but portage doesn't like more dynamics SRC_URIs.

PCMCIA_BASE_VERSION="pcmcia-cs-3.2.5"
PATCH_TO_3_2_6="pcmcia-cs-3.2.5-3.2.6.diff.gz"
PATCH_TO_3_2_7="pcmcia-cs-3.2.5-3.2.7.diff.gz"

SRC_URI="pcmcia?	( mirror://sourceforge/pcmcia-cs/${PCMCIA_BASE_VERSION}.tar.gz \
			http://dev.gentoo.org/~latexer/files/patches/${PCMCIA_BASE_VERSION}-module-init-tools.diff.gz
			http://dev.gentoo.org/~latexer/files/patches/${PCMCIA_BASE_VERSION}-SMP-fix.diff.gz
			http://dev.gentoo.org/~latexer/files/patches/${PATCH_TO_3_2_6} \
			http://dev.gentoo.org/~latexer/files/patches/${PATCH_TO_3_2_7} )"

# This shouldn't be needed, as it fixes pcmcia-cs *compilation* on new benh
# kernel's, but it's here to remind me in case it does become an issue
#ppc? ( http://dev.gentoo.org/~latexer/files/patches/${PCMCIA_BASE_VERSION}-ppc-fix.diff.gz ) )

DEPEND="pcmcia? ( >=sys-apps/${PCMCIA_BASE_VERSION} )"

pcmcia_src_unpack() {
	# So while the two eclasses exist side-by-side and also the ebuilds inherit
	# both we need to check for PCMCIA_SOURCE_DIR, and if we find it, then we
	# bail out and assume pcmcia.eclass is working on it.
	[[ -n ${PCMCIA_SOURCE_DIR} ]] && return 1

	cd ${WORKDIR}
	if use pcmcia ; then
		if egrep '^CONFIG_PCMCIA=[ym]' /usr/src/linux/.config >&/dev/null
		then
			# Sadly, we still need to download these sources in SRC_URI
			# til portage can handle more dynamic SRC_URIs
			einfo "Kernel PCMCIA detected. Skipping external pcmcia-cs sources."
			PCMCIA_VERSION=""
			PCMCIA_SOURCE_DIR=""
		else
			PCMCIA_SOURCE_DIR="${WORKDIR}/${PCMCIA_BASE_VERSION}"

			# We unpack the base version, figure out what is installed, then
			# patch up to that version. Ugly hack to avoid messy SRC_URIs
			unpack ${PCMCIA_BASE_VERSION}.tar.gz
			cd ${PCMCIA_SOURCE_DIR}
			epatch ${DISTDIR}/${PCMCIA_BASE_VERSION}-module-init-tools.diff.gz
			epatch ${DISTDIR}/${PCMCIA_BASE_VERSION}-SMP-fix.diff.gz
			PCMCIA_CS_EBUILD=(/var/db/pkg/sys-apps/pcmcia-cs-*/pcmcia-cs-*.ebuild) ## use bash globbing
			if [ ! -f "${PCMCIA_CS_EBUILD}" ]; then
				die "ERROR: pcmcia-cs ebuild (${PCMCIA_CS_EBUILD}) not found - are you sure pcmcia-cs is installed?"
			fi
			PCMCIA_CS_VER="${PCMCIA_CS_EBUILD##*/}" ## -> pcmcia-cs-VER.ebuild
			PCMCIA_CS_VER="${PCMCIA_CS_VER/pcmcia-cs-/}" ## strip 'pcmcia-cs-'
			PCMCIA_CS_VER="${PCMCIA_CS_VER/.ebuild/}" ## strip '.ebuild'
			if [ "${PCMCIA_CS_VER/-*/}" = "3.2.7" ]; then
				PCMCIA_VERSION=${PCMCIA_CS_VER}
				einfo "Using pcmcia-cs-3.2.7"
				epatch ${DISTDIR}/${PATCH_3_2_7}
			elif [ "${PCMCIA_CS_VER/-*/}" = "3.2.6" ]; then
				PCMCIA_VERSION=${PCMCIA_CS_VER}
				einfo "Using pcmcia-cs-3.2.6"
				epatch ${DISTDIR}/${PATCH_3_2_6}
			else
				PCMCIA_VERSION="${PCMCIA_BASE_VERSION}"
				einfo "Using ${PCMCIA_BASE_VERSION}"
			fi
		fi
	fi
	cd ${S}
}

# Call this if you need the package configured for building to work
pcmcia_configure()
{
	if use pcmcia ; then
		if ! egrep '^CONFIG_PCMCIA=[ym]' /usr/src/linux/.config >&/dev/null
		then
			cd ${PCMCIA_SOURCE_DIR}
			local myarch

			# pcmcia-cs expects "i386" not "x86"
			case "${ARCH}" in
				x86) myarch="i386" ;;
				*) myarch="${ARCH}" ;;
			esac

			#use $CFLAGS for user tools, but standard kernel optimizations for
			#the kernel modules (for compatibility)
			./Configure -n \
				--target=${D} \
				--srctree \
				--kernel=/usr/src/linux \
				--kflags="-Wall -Wstrict-prototypes -O2 -fomit-frame-pointer" \
				--arch="${myarch}" \
				--uflags="${CFLAGS}" || die "failed configuring pcmcia-cs"
		fi
	fi
	cd ${S}
}

EXPORT_FUNCTIONS src_unpack
