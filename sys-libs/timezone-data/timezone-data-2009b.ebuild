# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/timezone-data/timezone-data-2009b.ebuild,v 1.7 2009/03/20 16:19:35 armin76 Exp $

inherit eutils toolchain-funcs flag-o-matic

code_ver=${PV}
data_ver=${PV}
DESCRIPTION="Timezone data (/usr/share/zoneinfo) and utilities (tzselect/zic/zdump)"
HOMEPAGE="ftp://elsie.nci.nih.gov/pub/"
SRC_URI="ftp://elsie.nci.nih.gov/pub/tzdata${data_ver}.tar.gz
	ftp://elsie.nci.nih.gov/pub/tzcode${code_ver}.tar.gz
	mirror://gentoo/tzdata${data_ver}.tar.gz
	mirror://gentoo/tzcode${code_ver}.tar.gz"

LICENSE="BSD public-domain"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE="nls elibc_FreeBSD elibc_glibc"

RDEPEND="!<sys-libs/glibc-2.3.5"

S=${WORKDIR}

src_unpack() {
	unpack ${A}
	epatch "${FILESDIR}"/${PN}-2008h-makefile.patch
	tc-is-cross-compiler && cp -pR "${S}" "${S}"-native
}

src_compile() {
	local LDLIBS
	tc-export CC
	use elibc_FreeBSD && append-flags -DSTD_INSPIRED #138251
	if use nls ; then
		use elibc_glibc || LDLIBS="${LDLIBS} -lintl" #154181
		export NLS=1
	else
		export NLS=0
	fi
	# Makefile uses LBLIBS for the libs (which defaults to LDFLAGS)
	# But it also uses LFLAGS where it expects the real LDFLAGS
	emake \
		LDLIBS="${LDLIBS}" \
		|| die "emake failed"
	if tc-is-cross-compiler ; then
		emake -C "${S}"-native \
			CC=$(tc-getBUILD_CC) \
			CFLAGS="${BUILD_CFLAGS}" \
			LDFLAGS="${BUILD_LDFLAGS}" \
			LDLIBS="${LDLIBS}" \
			zic || die
	fi
}

src_install() {
	local zic=""
	tc-is-cross-compiler && zic="zic=${S}-native/zic"
	emake install ${zic} DESTDIR="${D}${EPREFIX}" || die
	rm -rf "${ED}"/usr/share/zoneinfo-leaps
	dodoc README Theory
	dohtml *.htm *.jpg
}

pkg_config() {
	# make sure the /etc/localtime file does not get stale #127899
	local tz src

	if has_version '<sys-apps/baselayout-2' ; then
		src="/etc/conf.d/clock"
		tz=$(unset TIMEZONE ; source "${EROOT}"/etc/conf.d/clock ; echo ${TIMEZONE-FOOKABLOIE})
	else
		src="/etc/timezone"
		if [[ -e ${EROOT}/etc/timezone ]] ; then
			tz=$(<"${EROOT}"/etc/timezone)
		else
			tz="FOOKABLOIE"
		fi
	fi
	[[ -z ${tz} ]] && return 0

	if [[ ${tz} == "FOOKABLOIE" ]] ; then
		elog "You do not have TIMEZONE set in ${src}."

		if [[ ! -e ${EROOT}/etc/localtime ]] ; then
			cp -f "${EROOT}"/usr/share/zoneinfo/Factory "${EROOT}"/etc/localtime
			elog "Setting /etc/localtime to Factory."
		else
			elog "Skipping auto-update of /etc/localtime."
		fi
		return 0
	fi

	if [[ ! -e ${EROOT}/usr/share/zoneinfo/${tz} ]] ; then
		elog "You have an invalid TIMEZONE setting in ${EPREFIX}${src}"
		elog "Your ${EPREFIX}/etc/localtime has been reset to Factory; enjoy!"
		tz="Factory"
	fi
	einfo "Updating ${EPREFIX}/etc/localtime with ${EPREFIX}/usr/share/zoneinfo/${tz}"
	[[ -L ${EROOT}/etc/localtime ]] && rm -f "${EROOT}"/etc/localtime
	cp -f "${EROOT}"/usr/share/zoneinfo/"${tz}" "${EROOT}"/etc/localtime
}

pkg_postinst() {
	pkg_config
}
