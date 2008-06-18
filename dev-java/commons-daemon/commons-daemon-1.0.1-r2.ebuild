# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/commons-daemon/commons-daemon-1.0.1-r2.ebuild,v 1.5 2007/11/25 12:06:34 nelchael Exp $

EAPI="prefix"

WANT_AUTOCONF=2.5
inherit java-pkg-2 java-ant-2 eutils autotools

DESCRIPTION="Tools to allow java programs to run as unix daemons"
SRC_URI="mirror://apache/jakarta/commons/daemon/source/daemon-${PV}.tar.gz"
HOMEPAGE="http://jakarta.apache.org/commons/daemon/"

LICENSE="Apache-1.1"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="doc examples source"

DEPEND=">=virtual/jdk-1.4
	dev-java/ant-core
	source? ( app-arch/zip )"
RDEPEND=">=virtual/jre-1.4"

S=${WORKDIR}/daemon-${PV}

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Submitted upstream to http://bugs.gentoo.org/show_bug.cgi?id=132563
	epatch "${FILESDIR}/1.0.1-as-needed.patch"

	# Fix fbsd building, from upstream svn, #157381
	epatch "${FILESDIR}/1.0.1-fbsd.patch"

	# https://issues.apache.org/jira/browse/DAEMON-93
	epatch "${FILESDIR}/1.0.1-capabilities-non-root.patch"

	# Already in trunk
	epatch "${FILESDIR}/1.0.1-execve-self.patch"

	cd "${S}/src/native/unix"
	sed -e "s/powerpc/powerpc|powerpc64/g" -i support/apsupport.m4
	eautoconf
}

src_compile() {
	# compile native stuff
	cd "${S}/src/native/unix"
	econf || die "configure failed"
	emake || die "make failed"

	# compile java stuff
	cd "${S}"
	eant jar $(use_doc)
}

src_install() {
	dobin src/native/unix/jsvc
	java-pkg_dojar dist/${PN}.jar

	dodoc README RELEASE-NOTES.txt *.html
	use doc && java-pkg_dohtml -r dist/docs/*
	if use examples; then
		dodir /usr/share/doc/${PF}/examples
		cp -R src/samples/* "${ED}/usr/share/doc/${PF}/examples"
	fi
	use source && java-pkg_dosrc src/java/* src/native/unix/native
}
