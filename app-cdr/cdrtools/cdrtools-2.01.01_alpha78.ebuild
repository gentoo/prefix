# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-cdr/cdrtools/cdrtools-2.01.01_alpha78.ebuild,v 1.2 2010/04/27 20:27:26 billie Exp $

EAPI=2

inherit multilib eutils toolchain-funcs flag-o-matic

DESCRIPTION="A set of tools for CD/DVD reading and recording, including cdrecord"
HOMEPAGE="http://cdrecord.berlios.de/private/cdrecord.html"
if [[ ${PV%_alpha*} == ${PV} ]]; then
SRC_URI="ftp://ftp.berlios.de/pub/cdrecord/${P}.tar.bz2"
else
SRC_URI="ftp://ftp.berlios.de/pub/cdrecord/alpha/${P/_alpha/a}.tar.bz2"
fi

LICENSE="GPL-2 LGPL-2.1 CDDL-Schily"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="acl unicode"

DEPEND="acl? ( virtual/acl )
	!app-cdr/dvdrtools
	!app-cdr/cdrkit"
RDEPEND="${DEPEND}"

S=${WORKDIR}/${P/_alpha[0-9][0-9]}

src_prepare() {
	# Remove profiled make files.
	rm -f $(find . -name '*_p.mk') || die "rm profiled"

	# Adjusting hardcoded paths.
	sed -i -e 's:opt/schily:usr:' \
		$(find ./ -type f -name \*.[0-9ch] -exec grep -l 'opt/schily' '{}' '+') \
		|| die "sed opt/schily"

	sed -i -e "s:\(^INSDIR=\t\tshare/doc/\):\1${PF}/:" \
		$(find ./ -type f -exec grep -l 'INSDIR.\+doc' '{}' '+') \
		|| die "sed doc"

	# Respect libdir.
	sed -i -e "s:\(^INSDIR=\t\t\)lib:\1$(get_libdir):" \
		$(find ./ -type f -exec grep -l '^INSDIR.\+lib\(/siconv\)\?$' '{}' '+') \
		|| die "sed multilib"

	sed -i -e 's:include\t\t.*rules.lib::' \
		$(find ./ -type f -exec grep -l '^include.\+rules\.lib' '{}' '+') \
		|| die "sed rules"

	# Respect CC/CXX variables.
	cd "${S}"/RULES
	local tcCC=$(tc-getCC)
	local tcCXX=$(tc-getCXX)
	sed -i -e "/cc-config.sh/s|\$(C_ARCH:%64=%) \$(CCOM_DEF)|${tcCC} ${tcCC}|" \
		rules1.top || die "sed rules1.top"
	sed -i -e "/^\(CC\|DYNLD\|LDCC\|MKDEP\)/s|gcc|${tcCC}|" \
		-e "/^\(CC++\|DYNLDC++\|LDCC++\|MKC++DEP\)/s|g++|${tcCXX}|" \
		cc-gcc.rul || die "sed cc-gcc.rul"
	sed -i -e "s|^#CONFFLAGS +=\t-cc=\$(XCC_COM)$|CONFFLAGS +=\t-cc=${tcCC}|g" \
		rules.cnf || die "sed rules.cnf"

	# Create additional symlinks needed for some archs.
	local t
	for t in ppc64 s390x; do
		ln -s i586-linux-cc.rul ${t}-linux-cc.rul || die
		ln -s i586-linux-gcc.rul ${t}-linux-gcc.rul || die
	done

	# Schily make setup.
	cd "${S}"/DEFAULTS
local os="linux"
	[[ ${CHOST} == *-darwin* ]] && os="mac-os10"

	sed -i \
		-e "s:/opt/schily:/usr:g" \
		-e "s:/usr/src/linux/include::g" \
		-e "/RUNPATH/ c\RUNPATH= " \
		-e "s:bin:root:g" \
		Defaults.${os} || die "sed Schily make setup"
}

src_configure() { : ; }

src_compile() {
	if use unicode; then
		local flags="$(test-flags -finput-charset=ISO-8859-1 -fexec-charset=UTF-8)"
		if [[ -n ${flags} ]]; then
			append-flags ${flags}
		else
			ewarn "Your compiler does not support the options required to build"
			ewarn "cdrtools with unicode in USE. unicode flag will be ignored."
		fi
	fi

	if ! use acl; then
		CFLAGS="${CFLAGS} -DNO_ACL"
	fi

	# If not built with -j1, "sometimes" cdda2wav will not be built. Bug?
	emake -j1 CC="$(tc-getCC)" CPPOPTX="${CPPFLAGS}" COPTX="${CFLAGS}" \
		LDOPTX="${LDFLAGS}" LINKMODE="dynamic" \
		GMAKE_NOWARN="true" || die "emake"
}

src_install() {
	# If not built with -j1, "sometimes" manpages are not installed. Bug?
	emake -j1 INS_BASE="${ED}/usr/" INS_RBASE="${ED}" MANDIR="share/man" \
		LINKMODE="dynamic" GMAKE_NOWARN="true" install || die "emake install"

	# These symlinks are for compat with cdrkit.
	dosym schily /usr/include/scsilib || die "dosym scsilib"
	dosym ../scg /usr/include/schily/scg || die "dosym scg"

	dodoc ABOUT Changelog* CONTRIBUTING PORTING README.linux-shm READMEs/README.linux \
		|| die "dodoc"

	cd "${S}"/cdda2wav
	docinto cdda2wav
	dodoc Changelog FAQ Frontends HOWTOUSE NEEDED README THANKS TODO \
		|| die "dodoc cdda2wav"

	cd "${S}"/mkisofs
	docinto mkisofs
	dodoc ChangeLog* TODO || die "dodoc mkisofs"
}

pkg_postinst() {
	if [[ ${CHOST} == *-darwin* ]] ; then
		einfo
		einfo "Darwin/OS X use the following device names:"
		einfo
		einfo "CD burners: (probably) ./cdrecord dev=IOCompactDiscServices"
		einfo
		einfo "DVD burners: (probably) ./cdrecord dev=IODVDServices"
		einfo
	fi
}
