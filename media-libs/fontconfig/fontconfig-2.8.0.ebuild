# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/fontconfig/fontconfig-2.8.0.ebuild,v 1.9 2010/05/13 15:48:04 jer Exp $

EAPI="2"

inherit autotools eutils libtool toolchain-funcs flag-o-matic

DESCRIPTION="A library for configuring and customizing font access"
HOMEPAGE="http://fontconfig.org/"
SRC_URI="http://fontconfig.org/release/${P}.tar.gz"

LICENSE="MIT"
SLOT="1.0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE="doc"

# Purposefully dropped the xml USE flag and libxml2 support.  Expat is the
# default and used by every distro.  See bug #283191.

RDEPEND=">=media-libs/freetype-2.2.1
	>=dev-libs/expat-1.95.3"
DEPEND="
	dev-util/pkgconfig
	doc? (
		app-text/docbook-sgml-utils[jadetex]
		=app-text/docbook-sgml-dtd-3.1*
	)"
PDEPEND="!x86-winnt? (
		app-admin/eselect-fontconfig
		media-fonts/corefonts
	)"
# *some* fonts are needed by nearly every gui application. corefonts satisfies
# this. In Gentoo Prefix, there is no fonts automatically pulled in by X, etc.
# So we must install them here. (bug #235553)

src_prepare() {
	epatch "${FILESDIR}"/${PN}-2.7.1-latin-reorder.patch	# 130466
	epatch "${FILESDIR}"/${PN}-2.3.2-docbook.patch			# 310157

	if [[ ${CHOST} == *-winnt* ]] ; then
		epatch "${FILESDIR}"/${PN}-2.6.0-winnt.patch
		#eautoreconf
	fi

	eautoreconf

	# Needed to get a sane .so versioning on fbsd, please dont drop
	# If you have to run eautoreconf, you can also leave the elibtoolize call as
	# it will be a no-op.
	elibtoolize
}

src_configure() {
	local myconf

	# harvest some font locations, such that users can benefit from the
	# host OS's installed fonts
	case ${CHOST} in
		*-darwin*)
			addfonts=",/Library/Fonts,/System/Library/Fonts"
		;;
		*-solaris*)
			[[ -d /usr/X/lib/X11/fonts/TrueType ]] && \
				addfonts=",/usr/X/lib/X11/fonts/TrueType"
			[[ -d /usr/X/lib/X11/fonts/Type1 ]] && \
				addfonts="${addfonts},/usr/X/lib/X11/fonts/Type1"
		;;
		*-linux-gnu)
			[[ -d /usr/share/fonts ]] && \
				addfonts=",/usr/share/fonts"
		;;
	esac

	if tc-is-cross-compiler; then
		myconf="--with-arch=${ARCH}"
		replace-flags -mtune=* -DMTUNE_CENSORED
		replace-flags -march=* -DMARCH_CENSORED
	fi
	econf \
		$(use_enable doc docs) \
		$(use_enable doc docbook) \
		--localstatedir="${EPREFIX}"/var \
		--with-default-fonts="${EPREFIX}"/usr/share/fonts \
		--with-add-fonts="${EPREFIX}/usr/local/share/fonts${addfonts}" \
		${myconf} || die
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install"
	emake DESTDIR="${D}" -C doc install-man || die "emake install-man"

	#fc-lang directory contains language coverage datafiles
	#which are needed to test the coverage of fonts.
	insinto /usr/share/fc-lang
	doins fc-lang/*.orth

	insinto /etc/fonts
	doins "${S}"/fonts.conf

	dodoc doc/fontconfig-user.{txt,pdf}
	dodoc AUTHORS ChangeLog README

	if [[ -e ${ED}usr/share/doc/fontconfig/ ]];  then
		mv "${ED}"usr/share/doc/fontconfig/* "${ED}"/usr/share/doc/${P}
		rm -rf "${ED}"usr/share/doc/fontconfig
	fi

	# Changes should be made to /etc/fonts/local.conf, and as we had
	# too much problems with broken fonts.conf, we force update it ...
	# <azarah@gentoo.org> (11 Dec 2002)
	echo 'CONFIG_PROTECT_MASK="/etc/fonts/fonts.conf"' > "${T}"/37fontconfig
	doenvd "${T}"/37fontconfig

	# As of fontconfig 2.7, everything sticks their noses in here.
	dodir /etc/sandbox.d
	echo 'SANDBOX_PREDICT="/var/cache/fontconfig"' > "${ED}"/etc/sandbox.d/37fontconfig
}

pkg_preinst() {
	# Bug #193476
	# /etc/fonts/conf.d/ contains symlinks to ../conf.avail/ to include various
	# config files.  If we install as-is, we'll blow away user settings.
	ebegin "Syncing fontconfig configuration to system"
	if [[ -e ${EROOT}/etc/fonts/conf.d ]]; then
		for file in "${EROOT}"/etc/fonts/conf.avail/*; do
			f=${file##*/}
			if [[ -L ${EROOT}/etc/fonts/conf.d/${f} ]]; then
				[[ -f ${ED}etc/fonts/conf.avail/${f} ]] \
					&& ln -sf ../conf.avail/"${f}" "${ED}"etc/fonts/conf.d/ &>/dev/null
			else
				[[ -f ${ED}etc/fonts/conf.avail/${f} ]] \
					&& rm "${ED}"etc/fonts/conf.d/"${f}" &>/dev/null
			fi
		done
	fi
	eend $?
}

pkg_postinst() {
	einfo "Cleaning broken symlinks in "${EROOT}"etc/fonts/conf.d/"
	find -L "${EROOT}"etc/fonts/conf.d/ -type l -delete

	echo
	ewarn "Please make fontconfig configuration changes using \`eselect fontconfig\`"
	ewarn "Any changes made to /etc/fonts/fonts.conf will be overwritten."
	ewarn
	ewarn "If you need to reset your configuration to upstream defaults, delete"
	ewarn "the directory ${EROOT}etc/fonts/conf.d/ and re-emerge fontconfig."
	echo

	if [[ ${ROOT} = / ]]; then
		ebegin "Creating global font cache"
		"${EPREFIX}"/usr/bin/fc-cache -srf
		eend $?
	fi
}
