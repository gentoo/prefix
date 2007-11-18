# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-plugins/enigmail/enigmail-0.95.5-r1.ebuild,v 1.4 2007/11/16 15:31:38 armin76 Exp $

EAPI="prefix"

unset ALLOWED_FLAGS  # stupid extra-functions.sh ... bug 49179
WANT_AUTOCONF=2.1
inherit flag-o-matic toolchain-funcs eutils nsplugins mozcoreconf mozextension makeedit multilib autotools

LANGS="de el es-ES nb-NO pt-BR zh-CN"
SHORTLANGS="ca-AD cs-CZ es-ES fi-FI fr-FR hu-HU it-IT ja-JP nb-NO pl-PL pt-PT ru-RU sl-SI sv-SE tr-TR zh-TW"

EMVER=${PV}
TBVER="2.0.0.9"
TBPATCH="2.0.0.9-patches-0.1"

DESCRIPTION="GnuPG encryption plugin for thunderbird."
HOMEPAGE="http://enigmail.mozdev.org"
SRC_URI="http://releases.mozilla.org/pub/mozilla.org/thunderbird/releases/${TBVER}/source/thunderbird-${TBVER}-source.tar.bz2
	mirror://gentoo/mozilla-thunderbird-${TBPATCH}.tar.bz2
	http://www.mozilla-enigmail.org/downloads/src/enigmail-${EMVER}.tar.gz"

KEYWORDS="~amd64 ~ia64 ~x86"
SLOT="0"
LICENSE="MPL-1.1 GPL-2"
IUSE=""

for X in ${LANGS} ; do
	SRC_URI="${SRC_URI} linguas_${X/-/_}? ( http://dev.gentooexperimental.org/~armin76/dist/${P}-xpi/${PN}-${X}-${PV}.xpi )"
	IUSE="${IUSE} linguas_${X/-/_}"
done
# ( mirror://gentoo/${PN}-${X}-0.9x.xpi )"

for X in ${SHORTLANGS} ; do
	SRC_URI="${SRC_URI} linguas_${X%%-*}? ( http://dev.gentooexperimental.org/~armin76/dist/${P}-xpi/${PN}-${X}-${PV}.xpi )"
	IUSE="${IUSE} linguas_${X%%-*}"
done
#( mirror://gentoo/${PN}-${X}-0.9x.xpi )"

DEPEND=">=mail-client/mozilla-thunderbird-${TBVER}"
RDEPEND="${DEPEND}
	>=app-crypt/gnupg-1.4.7
	>=www-client/mozilla-launcher-1.56"

S=${WORKDIR}/mozilla

# Needed by src_compile() and src_install().
# Would do in pkg_setup but that loses the export attribute, they
# become pure shell variables.
export BUILD_OFFICIAL=1
export MOZILLA_OFFICIAL=1
export MOZ_CO_PROJECT=mail

linguas() {
	linguas=
	local LANG
	for LANG in ${LINGUAS}; do
		if hasq ${LANG} en en_US; then
			hasq en ${linguas} || \
				linguas="${linguas:+"${linguas} "}en"
			continue
		elif hasq ${LANG} ${LANGS//-/_}; then
			hasq ${LANG//_/-} ${linguas} || \
				linguas="${linguas:+"${linguas} "}${LANG//_/-}"
			continue
		else
			local SLANG
			for SLANG in ${SHORTLANGS}; do
				if [[ ${LANG} == ${SLANG%%-*} ]]; then
					hasq ${SLANG} ${linguas} || \
						linguas="${linguas:+"${linguas} "}${SLANG}"
					continue 2
				fi
			done
		fi
		ewarn "Sorry, but ${PN} does not support the ${LANG} LINGUA"
	done
}

src_unpack() {
	unpack thunderbird-${TBVER}-source.tar.bz2 mozilla-thunderbird-${TBPATCH}.tar.bz2 || die "unpack failed"

	linguas
	for X in ${linguas}; do
		[[ ${X} != en ]] && xpi_unpack ${PN}-${X}-${PV}.xpi
	done

	cd ${S} || die "cd failed"

	# Apply our patches
	cd "${S}" || die "cd failed"
	EPATCH_SUFFIX="patch" \
	EPATCH_FORCE="yes" \
	epatch "${WORKDIR}"/patch

	# Unpack the enigmail plugin
	cd ${S}/mailnews/extensions || die
	unpack enigmail-${EMVER}.tar.gz
	cd ${S}/mailnews/extensions/enigmail || die "cd failed"
	makemake2

	cd ${S}

	# Use the right theme for thunderbird #45609
	sed -i -ne '/^enigmail-skin.jar:$/ { :x; n; /^\t/bx; }; p' mailnews/extensions/enigmail/ui/jar.mn

	# Fix installation of enigmail.js
	epatch ${FILESDIR}/70_enigmail-fix.patch
	# Make replytolist work with >0.95.0
	epatch ${FILESDIR}/0.95.0-replytolist.patch

	eautoreconf || die "failed running autoreconf"
}

src_compile() {
	declare MOZILLA_FIVE_HOME=/usr/$(get_libdir)/mozilla-thunderbird

	####################################
	#
	# mozconfig, CFLAGS and CXXFLAGS setup
	#
	####################################

	mozconfig_init

	# tb-specific settings
	mozconfig_annotate '' \
		--with-system-nspr \
		--with-system-nss \
		--with-default-mozilla-five-home="${EPREFIX}"${MOZILLA_FIVE_HOME} \
		--with-user-appdir=.thunderbird

	# Finalize and report settings
	mozconfig_final

	# hardened GCC uses -fstack-protector-all by default, and this breaks
	# thunderbird
	gcc-specs-ssp && append-flags -fno-stack-protector-all
	replace-flags -fstack-protector-all -fstack-protector

	####################################
	#
	#  Configure and build Thunderbird
	#
	####################################

	econf  || die "econf failed"

	# This removes extraneous CFLAGS from the Makefiles to reduce RAM
	# requirements while compiling
	edit_makefiles

	# Doesn't like to build with CHOST-specific commands.
	MY_CC=$(tc-getCC)
	MY_CXX=$(tc-getCXX)

	# Only build the parts necessary to support building enigmail
	emake CC=$MY_CC CXX=$MY_CXX -j1 export || die "make export failed"
	emake CC=$MY_CC CXX=$MY_CXX -C modules/libreg || die "make modules/libreg failed"
	emake CC=$MY_CC CXX=$MY_CXX -C xpcom/string || die "make xpcom/string failed"
	emake CC=$MY_CC CXX=$MY_CXX -C xpcom || die "make xpcom failed"
	emake CC=$MY_CC CXX=$MY_CXX -C xpcom/obsolete || die "make xpcom/obsolete failed"

	# Build the enigmail plugin
	einfo "Building Enigmail plugin..."
	emake CC=$MY_CC CXX=$MY_CXX -C ${S}/mailnews/extensions/enigmail || die "make enigmail failed"

	# Package the enigmail plugin; this may be the easiest way to collect the
	# necessary files
	emake CC=$MY_CC CXX=$MY_CXX -j1 -C ${S}/mailnews/extensions/enigmail xpi || die "make xpi failed"
}

src_install() {
	declare MOZILLA_FIVE_HOME=/usr/$(get_libdir)/mozilla-thunderbird
	declare emid

	cd ${T}
	unzip ${S}/dist/bin/*.xpi install.rdf
	emid=$(sed -n '/<em:id>/!d; s/.*\({.*}\).*/\1/; p; q' install.rdf)

	dodir ${MOZILLA_FIVE_HOME}/extensions/${emid}
	cd ${ED}${MOZILLA_FIVE_HOME}/extensions/${emid}
	unzip ${S}/dist/bin/*.xpi

	# Fix module to work with 2.0.0.*

	# these files will be picked up by mozilla-launcher -register
	dodir ${MOZILLA_FIVE_HOME}/{chrome,extensions}.d
	insinto ${MOZILLA_FIVE_HOME}/chrome.d
	newins ${S}/dist/bin/chrome/installed-chrome.txt ${PN}
	echo "extension,${emid}" > ${ED}${MOZILLA_FIVE_HOME}/extensions.d/${PN}

	linguas
	for X in ${linguas}; do
		[[ ${X} != en ]] && xpi_install ${WORKDIR}/${PN}-${X}-${PV}
	done
}
