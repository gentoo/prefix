# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-shells/bash-completion/bash-completion-20081219-r1.ebuild,v 1.9 2009/03/18 08:05:23 josejx Exp $

EAPI="prefix 2"

inherit prefix

DESCRIPTION="Programmable Completion for bash"
HOMEPAGE="http://bash-completion.alioth.debian.org/"
#SRC_URI="mirror://debian/pool/main/b/${PN}/${PN}_${PV}.tar.gz"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~m68k-mint"
IUSE=""

DEPEND=""
RDEPEND="app-admin/eselect
	|| (
		>=app-shells/bash-2.05a
		app-shells/zsh
	)"
PDEPEND="app-shells/gentoo-bashcomp"

S=${WORKDIR}/${PN}

src_prepare() {
	# bug #111681 & bug 254814
	sed -i -e "/^complete.* xine /d" \
		-e '0,/gz|bz2/s//gz|bz2|lzma/' bash_completion || die "sed failed"
	# bug 146726
	rm contrib/svk || die "rm failed"
	# bug 259818
	rm contrib/hg || die "rm failed"
}

src_install() {
	# split /etc/bash_completion into three parts:
	# 1. /usr/share/bash-completion/.pre    -- hidden from eselect
	# 2. /usr/share/bash-completion/base -- eselectable
	# 3. /usr/share/bash-completion/.post   -- hidden from eselect
	dodir /usr/share/bash-completion || die "dodir failed"

	eprefixify bash_completion

	awk -v D="$ED" '
		BEGIN { out=".pre" }
		/^# A lot of the following one-liners/ { out="base" }
		/^# source completion directory/ { out="" }
		/^unset -f have/ { out=".post" }
		out != "" { print > D"/usr/share/bash-completion/"out }' \
		bash_completion || die "failed to split bash_completion"

	exeinto /etc/profile.d
	cp "${FILESDIR}"/bash-completion.sh "${T}"/bash-completion.sh ||
	die "cannot copy '${FILESDIR}/bash-completion.sh' to '${T}'"
	eprefixify "${T}"/bash-completion.sh
	doexe "${T}"/bash-completion.sh \
		|| die "failed to install profile.d"

	insinto /usr/share/bash-completion
	doins contrib/* || die "failed to install contrib completions"

	dodoc debian/changelog README TODO
}

pkg_preinst() {
	# This file is now being installed as bash-completion.sh, so rename it
	# first.  That allows CONFIG_PROTECT to kick in properly
	if [[ -f ${EROOT}/etc/profile.d/bash-completion && \
		! -f ${EROOT}/etc/profile.d/bash-completion.sh ]]
	then
		mv "${EROOT}"/etc/profile.d/bash-completion{,.sh}
	fi
}

pkg_postinst() {
	elog
	elog "Versions of bash-completion prior to 20060301-r1 required each user to"
	elog "explicitly source /etc/profile.d/bash-completion in ~/.bashrc.  This"
	elog "was inconsistent with the completion modules which are"
	elog "enabled with eselect bashcomp.  Now any user can enable the base"
	elog "completions without editing their .bashrc by running"
	elog
	elog "    eselect bashcomp enable base"
	elog
	elog "The system administrator can also be enable this globally with"
	elog
	elog "    eselect bashcomp enable --global base"
	elog
	elog "Additional completion functions can also be enabled or"
	elog "disabled using eselect's bashcomp module."
	elog
	elog "If you use non-login shells you still need to source"
	elog "/etc/profile.d/bash-completion.sh in your ~/.bashrc."
	elog "Note this is bash-completion.sh, not bash-completion. Lots of people"
	elog "overlook this"
	elog

	if has_version 'app-shells/zsh' ; then
		elog "If you are interested in using the provided bash completion functions with"
		elog "zsh, valuable tips on the effective use of bashcompinit are available:"
		elog "  http://www.zsh.org/mla/workers/2003/msg00046.html"
		#elog "  http://zshwiki.org/ZshSwitchingTo" (doesn't exist)
		elog
	fi
}
