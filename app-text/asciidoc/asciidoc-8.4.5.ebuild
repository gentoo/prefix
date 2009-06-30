# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/asciidoc/asciidoc-8.4.5.ebuild,v 1.2 2009/06/27 08:23:15 patrick Exp $

EAPI="2"

DESCRIPTION="A text document format for writing short documents, articles, books and UNIX man pages"
HOMEPAGE="http://www.methods.co.nz/asciidoc/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="examples vim-syntax doc"

DEPEND=">=virtual/python-2.4
		~app-text/docbook-xml-dtd-4.5
		app-text/docbook-xsl-stylesheets
		dev-libs/libxslt
		media-gfx/graphviz"
RDEPEND="~app-text/docbook-xml-dtd-4.5"

src_prepare(){
	if ! use vim-syntax; then
		sed -i -e '/^install/s/install-vim//' Makefile.in
	else
		sed -i\
			-e '/^vimdir/s:@sysconfdir@/vim:'"${EPREFIX}"'/usr/share/vim/vimfiles:' \
			-e 's:/etc/vim::' \
			Makefile.in
	fi

	sed -i -e 's/fop.sh/fop/' a2x
	
	# Prefix only
	sed -i -e "s:^CONF_DIR=.*:CONF_DIR='${EPREFIX}/etc/asciidoc':" \
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
