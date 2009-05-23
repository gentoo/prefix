# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/asciidoc/asciidoc-8.4.4.ebuild,v 1.1 2009/05/22 22:10:56 patrick Exp $

DESCRIPTION="A text document format for writing short documents, articles, books and UNIX man pages"
HOMEPAGE="http://www.methods.co.nz/asciidoc/"
SRC_URI="http://www.methods.co.nz/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="examples vim-syntax doc"

DEPEND=">=virtual/python-2.4
		app-text/docbook-xsl-stylesheets
		dev-libs/libxslt
		media-gfx/graphviz"

src_unpack() {
	unpack ${A}

	cd "${S}"
	if ! use vim-syntax; then
		sed -i -e '/^install/s/install-vim//' Makefile.in
	else
		sed -i\
			-e '/^vimdir/s:@sysconfdir@/vim:'"${EPREFIX}"'/usr/share/vim/vimfiles:' \
			-e 's:/etc/vim::' \
			Makefile.in
	fi

	sed -i -e 's/fop.sh/fop/' a2x

	sed -i -e "s:^CONF_DIR =.*:CONF_DIR='${EPREFIX}/etc/asciidoc':" \
		"${S}/asciidoc.py" || die
}

src_install() {
	dodir /usr/bin

	use vim-syntax && dodir /usr/share/vim/vimfiles

	emake DESTDIR="${D}" install || die "install failed"

	if use examples; then
		# This is a symlink to a directory
		rm -f examples/website/images
		cp -Rf images examples/website

		insinto /usr/share/doc/${PF}
		doins -r examples
	fi

	# HTML pages (with their sources)
	if use doc; then
		dohtml -r doc/*
		insinto /usr/share/doc/${PF}/html
		doins doc/*.txt
	fi

	# Misc. documentation
	dodoc BUGS CHANGELOG README
	dodoc docbook-xsl/asciidoc-docbook-xsl.txt
}

pkg_preinst() {
	# Clean any symlinks in /etc possibly installed by previous versions
	if [ -d "${EROOT}etc/asciidoc" ]; then
		einfo "Cleaning old symlinks under /etc/asciidoc"
		for entry in $(find "${EROOT}etc/asciidoc" -type l); do
			rm -f $entry
		done
	fi
}
