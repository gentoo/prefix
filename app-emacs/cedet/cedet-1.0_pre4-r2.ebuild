# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emacs/cedet/cedet-1.0_pre4-r2.ebuild,v 1.7 2008/01/23 10:14:36 armin76 Exp $

EAPI="prefix"

inherit elisp eutils versionator

MY_PV=$(delete_version_separator 2)
DESCRIPTION="CEDET: Collection of Emacs Development Tools"
HOMEPAGE="http://cedet.sourceforge.net/"
SRC_URI="mirror://sourceforge/cedet/${PN}-${MY_PV}.tar.gz"

LICENSE="GPL-2 FDL-1.1"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos ~sparc-solaris"
IUSE=""

DEPEND="!app-emacs/semantic
	!app-emacs/eieio
	!app-emacs/speedbar"

S="${WORKDIR}/${PN}-${MY_PV}"

SITEFILE=60${PN}-gentoo.el

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/1.0_pre3-eieio-tests-gentoo.patch" # bug 124598
	epatch "${FILESDIR}/1.0_pre4-semantic-build.patch" # bugs 183205/191341
}

src_compile() {
	emake -j1 EMACS="${EPREFIX}"/usr/bin/emacs || die "emake failed"
}

src_install() {
	find "${S}" -type f -print | while read target; do
		local directory=$(dirname ${target}) file=$(basename ${target})
		local sub_directory=$(echo ${directory} | sed "s%^${S}/*%%;s/^$/./")
		case $file in
			*~ | Makefile | *.texi | *-script | PRERELEASE_CHECKLIST \
				| Project.ede | IMPLICIT_TARGETS)
				;;
			ChangeLog | README | AUTHORS | *NEWS | INSTALL)
				docinto ${sub_directory}
				dodoc ${target}
				;;
			*.png)
				insinto /usr/share/doc/${PF}/${sub_directory}
				doins ${target}
				;;
			*.el | *.elc)
				insinto ${SITELISP}/${PN}/${sub_directory}
				doins ${target}
				;;
			*.info*)
				doinfo ${target}
				;;
			*)
				insinto ${SITELISP}/${PN}/${sub_directory}
				doins ${target}
				echo ${target} >>"${S}/IMPLICIT_TARGETS"
				;;
		esac
	done

	elisp-site-file-install "${FILESDIR}/${SITEFILE}"
}
