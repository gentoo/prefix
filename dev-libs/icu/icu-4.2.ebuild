# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/icu/icu-4.2.ebuild,v 1.1 2009/05/12 15:22:41 arfrever Exp $

EAPI="2"

inherit eutils versionator autotools

DESCRIPTION="International Components for Unicode"
HOMEPAGE="http://www.icu-project.org/ http://ibm.com/software/globalization/icu/"

BASEURI="http://download.icu-project.org/files/${PN}4c/${PV}"
DOCS_PV="$(get_version_component_range 1-2)"
DOCS_BASEURI="http://download.icu-project.org/files/${PN}4c/${DOCS_PV}"
DOCS_PV="${DOCS_PV/./_}"
SRCPKG="${PN}4c-${PV//./_}-src.tgz"
APIDOCS="${PN}4c-${DOCS_PV}-docs.zip"

SRC_URI="${BASEURI}/${SRCPKG}
	doc? ( ${DOCS_BASEURI}/${APIDOCS} )"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~ppc-aix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE="debug doc examples"

DEPEND="doc? ( app-arch/unzip )"
RDEPEND=""

S="${WORKDIR}/${PN}/source"

src_unpack() {
	unpack ${SRCPKG}
	if use doc; then
		mkdir apidocs
		pushd apidocs > /dev/null
		unpack ${APIDOCS}
		popd > /dev/null
	fi
}

src_prepare() {
	# Do not hardcode used CFLAGS, LDFLAGS etc. into icu-config
	# Bug 202059
	# http://bugs.icu-project.org/trac/ticket/6102
	for x in ARFLAGS CFLAGS CPPFLAGS CXXFLAGS FFLAGS LDFLAGS; do
		sed -i -e "/^${x} =.*/s:@${x}@::" "config/Makefile.inc.in" || die "sed failed"
	done

	# for correct install_names
	epatch "${FILESDIR}"/${PN}-3.8.1-darwin.patch
}

src_configure() {
	econf \
		--enable-static \
		$(use_enable debug) \
		$(use_enable examples samples)
}

src_compile() {
	# Darwin needs an object index
	emake ARFLAGS="sr" || die
}

src_test() {
	emake check || die "emake check failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	dohtml ../readme.html
	dodoc ../unicode-license.txt
	if use doc; then
		insinto /usr/share/doc/${PF}/html/apidocs
		doins -r "${WORKDIR}"/apidocs/*
	fi
}
