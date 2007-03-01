# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/app-shells/bash-completion/bash-completion-20060301-r2.ebuild,v 1.1 2006/11/22 14:54:21 agriffis Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Programmable Completion for bash"
HOMEPAGE="http://www.caliban.org/bash/index.shtml#completion"
SRC_URI="http://www.caliban.org/files/bash/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"
IUSE=""

DEPEND=""
RDEPEND="app-admin/eselect
	|| (
		>=app-shells/bash-2.05a
		app-shells/zsh
	)"
PDEPEND="app-shells/gentoo-bashcomp"

S="${WORKDIR}/${PN/-/_}"

src_unpack() {
	unpack ${A}
	cd ${S}
	EPATCH_SUFFIX="diff" epatch ${FILESDIR}/20050721
	EPATCH_SUFFIX="diff" epatch ${FILESDIR}/${PV}
}

src_install() {
	# split /etc/bash_completion into three parts:
	# 1. /usr/share/bash-completion/.pre    -- hidden from eselect
	# 2. /usr/share/bash-completion/default -- eselectable
	# 3. /usr/share/bash-completion/.post   -- hidden from eselect
	dodir /usr/share/bash-completion
	awk -v D="$ED" '
		BEGIN { out=".pre" }
		/^# A lot of the following one-liners/ { out="base" }
		/^# source completion directory/ { out="" }
		/^unset -f have/ { out=".post" }
		out != "" { print > D"/usr/share/bash-completion/"out }' \
		bash_completion || die "failed to split bash_completion"

	exeinto /etc/profile.d
	doexe ${FILESDIR}/bash-completion.sh || die "failed to install profile.d"

	# dev-util/subversion provides an extremely superior completion
	# fails rm contrib/subversion
	insinto /usr/share/bash-completion
	doins contrib/* || die "failed to install contrib completions"

	dodoc Changelog README
}

pkg_preinst() {
	# This file is now being installed as bash-completion.sh, so rename it
	# first.  That allows CONFIG_PROTECT to kick in properly
	if [[ -f ${EROOT}/etc/profile.d/bash-completion && \
		! -f ${EROOT}/etc/profile.d/bash-completion.sh ]]
	then
		mv ${EROOT}/etc/profile.d/bash-completion{,.sh}
	fi
}

pkg_postinst() {
	einfo
	einfo "Versions of bash-completion prior to 20060301-r1 required each user to"
	einfo "explicitly source /etc/profile.d/bash-completion in ~/.bashrc.  This"
	einfo "was kludgy and inconsistent with the completion modules which are"
	einfo "enabled with eselect bashcomp.  Now any user can enable the base"
	einfo "completions without editing their .bashrc by running"
	einfo
	einfo "    eselect bashcomp enable base"
	einfo
	einfo "The system administrator can also be enable this globally with"
	einfo
	einfo "    eselect bashcomp enable --global base"
	einfo
	einfo "Additional completion functions can also be enabled or"
	einfo "disabled using eselect's bashcomp module."
	einfo

	if has_version 'app-shells/zsh' ; then
		einfo "If you are interested in using the provided bash completion functions with"
		einfo "zsh, valuable tips on the effective use of bashcompinit are available:"
		einfo "  http://www.zsh.org/mla/workers/2003/msg00046.html"
		einfo "  http://zshwiki.org/ZshSwitchingTo"
		einfo
	fi
}
