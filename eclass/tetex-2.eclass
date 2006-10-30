# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/tetex-2.eclass,v 1.6 2006/02/01 19:49:49 ehmsen Exp $
#
# Author: Jaromir Malenko <malenko@email.cz>
# Author: Mamoru KOMACHI <usata@gentoo.org>
# Author: Martin Ehmsen <ehmsen@gentoo.org>
# Author: Alexandre Buisse <nattfodd@gentoo.org>
#
# A generic eclass to install tetex 2.0.x distributions.

inherit tetex

EXPORT_FUNCTIONS src_unpack src_install

tetex-2_src_unpack() {

	tetex_src_unpack

	cd ${S}/texmf

	unpack ${TETEX_TEXMF_SRC}

	# create update script
	cat >${T}/texmf-update<<'EOF'
#!/bin/bash
#
# Utility to update Gentoo teTeX distribution configuration files
#

PATH=/bin:/usr/bin

for conf in texmf.cnf fmtutil.cnf updmap.cfg
do
	if [ -d "/etc/texmf/${conf/.*/.d}" ]
	then
		echo "Generating /etc/texmf/web2c/${conf} from /etc/texmf/${conf/.*/.d} ..."
		cat /etc/texmf/${conf/.*/.d}/* > "/etc/texmf/web2c/${conf}"
	fi
done

# configure
echo "Configuring teTeX ..."
mktexlsr &>/dev/null
texconfig init &>/dev/null
texconfig confall &>/dev/null
texconfig font rw &>/dev/null
texconfig font vardir /var/cache/fonts &>/dev/null
texconfig font options varfonts &>/dev/null
updmap &>/dev/null

# generate
echo "Generating format files ..."
fmtutil --missing &>/dev/null
echo
echo "Use 'texconfig font ro' to disable font generation for users"
echo
EOF

	# fix up misplaced listings.sty in the 2.0.2 archive.
	# this should be fixed in the next release <obz@gentoo.org>
	mv source/latex/listings/listings.sty tex/latex/listings/ || die

	# need to fix up the hyperref driver, see bug #31967
	sed -i -e "/providecommand/s/hdvips/hypertex/" \
		${S}/texmf/tex/latex/config/hyperref.cfg || die
}

tetex-2_src_install() {

	tetex_src_install

	# bug #47004
	insinto /usr/share/texmf/tex/latex/a0poster
	doins ${S}/texmf/source/latex/a0poster/a0poster.cls || die
	doins ${S}/texmf/source/latex/a0poster/a0size.sty || die

	rm -f ${ED}/usr/bin/texi2html
	rm -f ${ED}/usr/share/man/man1/texi2html.1

	# bug #112164
	has_version 'sys-apps/texinfo' && rm -f ${ED}/usr/bin/texi2pdf

	dodir /etc/env.d/
	echo 'CONFIG_PROTECT="/usr/share/texmf/tex/generic/config/ /usr/share/texmf/tex/platex/config/ /usr/share/texmf/dvips/config/ /usr/share/texmf/dvipdfm/config/ /usr/share/texmf/xdvi/"' > ${ED}/etc/env.d/98tetex

	#fix for texlinks
	local src dst
	sed -e '/^#/d' -e '/^$/d' -e 's/^ *//' \
		${ED}/usr/share/texmf/web2c/fmtutil.cnf > ${T}/fmtutil.cnf || die
	while read l; do
		dst=/usr/bin/`echo $l | awk '{ print $1 }'`
		src=/usr/bin/`echo $l | awk '{ print $2 }'`
		if [ ! -f ${ED}$dst -a "$dst" != "$src" ] ; then
			einfo "Making symlinks from $src to $dst"
			dosym $src $dst
		fi
	done < ${T}/fmtutil.cnf
}
