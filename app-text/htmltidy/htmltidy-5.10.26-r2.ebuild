# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/htmltidy/htmltidy-5.10.26-r2.ebuild,v 1.12 2007/06/26 01:44:05 mr_bones_ Exp $

EAPI="prefix"

WANT_AUTOMAKE=1.5
WANT_AUTOCONF=2.5

inherit eutils autotools

# Convert gentoo version number x.y.z to date xyz for
# tidy's source numbering by date
parts=(${PV//./ })
dates=$(printf "%02d%02d%02d" ${parts[0]} ${parts[1]} ${parts[2]})
MY_P=tidy_src_${dates}
S=${WORKDIR}/tidy

DESCRIPTION="Tidy the layout and correct errors in HTML and XML documents"
HOMEPAGE="http://tidy.sourceforge.net/"
SRC_URI="http://tidy.sourceforge.net/src/${MY_P}.tgz
	http://tidy.sourceforge.net/docs/tidy_docs_051020.tgz
	mirror://gentoo/${P}-doc.tar.bz2
	xml? ( http://www.cise.ufl.edu/~ppadala/tidy/html2db.tar.gz )"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="debug doc xml"

DEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	# Required to setup the source dist for autotools
	einfo "Setting up autotools for source build"
	export WANT_AUTOMAKE=1.5 WANT_AUTOCONF=2.5
	"${EPREFIX}"/bin/sh ./build/gnuauto/setup.sh > /dev/null

	# Stop tidy from appending -O2 to our CFLAGS
	epatch ${FILESDIR}/htmltidy-5.10.26-strip-O2-flag.patch || die

	if use xml ; then
		# Apply the docbook patch to tidy sources
		epatch ${FILESDIR}/05-${PN}-docbook.patch || die

		# And the null -> NULL patch to html2db sources
		EPATCH_OPTS="-d ${WORKDIR}" epatch ${FILESDIR}/03-html2db-null.patch || die

		# Point to the tidy source in the html2db Makefile
		sed -e "/TIDYDIR\=/s:\.\.:${S}:" \
			   -e "/LIBDIR\=/s:lib:src\/\.libs\/:" \
			   ${WORKDIR}/html2db/Makefile > ${T}/Makefile &&
		mv ${T}/Makefile ${WORKDIR}/html2db/Makefile || die "sed Makefile failed"
	fi
}

src_compile() {
	export WANT_AUTOMAKE=1.5 WANT_AUTOCONF=2.5
	econf `use_enable debug` || die
	emake || die

	if use xml ; then
		cd ${WORKDIR}/html2db
		emake || die
	fi
}

src_install() {
	make DESTDIR=${D} install || die
	use xml && dobin ${WORKDIR}/html2db/html2db

	cd ${S}/htmldoc
	# It seems the manual page installation in the Makefile's
	# is commented out, so we need to install manually
	# for the moment. Please check this on updates.
	# mv man_page.txt tidy.1
	# doman tidy.1
	#
	# Update:
	# Now the man page is provided as an xsl file, which
	# we can't use until htmltidy is merged.
	# I have generated the man page and quickref which is on
	# the mirrors. (bug #132429)
	doman "${WORKDIR}/${P}-doc/tidy.1"

	# Install basic html documentation
	dohtml *.html *.css *.gif "${WORKDIR}/${P}-doc/quickref.html"

	# If use 'doc' is set, then we also want to install the
	# api documentation
	use doc && dohtml -r api
}
