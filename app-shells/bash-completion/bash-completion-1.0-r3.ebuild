# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-shells/bash-completion/bash-completion-1.0-r3.ebuild,v 1.9 2009/05/31 18:22:46 ranger Exp $

EAPI="2"

inherit eutils

DESCRIPTION="Programmable Completion for bash"
HOMEPAGE="http://bash-completion.alioth.debian.org/"
SRC_URI="mirror://debian/pool/main/b/bash-completion/${PN}_${PV}.orig.tar.gz ->
bash-completion-1.0.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux"
IUSE=""

DEPEND=""
RDEPEND="app-admin/eselect
	|| (
		>=app-shells/bash-2.05a
		app-shells/zsh
	)
	sys-apps/miscfiles
	!<=games-misc/cowsay-3.03-r1"
PDEPEND="app-shells/gentoo-bashcomp"

src_prepare() {
	epatch "${FILESDIR}/${PN}-1.0-gentoo.patch"
	epatch "${FILESDIR}/${PN}-1.0-bash4.patch"
}

src_install() {
	emake DESTDIR="${D}" install || die

	# Upstream will soon be splitting this for us.
	# split /etc/bash_completion into three parts:
	# 1. /usr/share/bash-completion/.pre    -- hidden from eselect
	# 2. /usr/share/bash-completion/base -- eselectable
	# 3. /usr/share/bash-completion/.post   -- hidden from eselect
	dodir /usr/share/bash-completion
	awk -v D="$ED" '
	BEGIN { out=".pre" }
	/^# A lot of the following one-liners/ { out="base" }
	/^# start of section containing completion functions called by other functions/ { out=".pre" }
	/^# start of section containing completion functions for bash built-ins/ { out="base" }
	/^# source completion directory/ { out="" }
	/^unset -f have/ { out=".post" }
	out != "" { print > D"/usr/share/bash-completion/"out }' \
	bash_completion || die "failed to split bash_completion"

	dodir /etc/profile.d
	cp bash_completion.sh "${ED}/etc/profile.d/bash-completion.sh" \
		|| die "cp failed"

	dodoc AUTHORS CHANGES README TODO || die "dodocs failes"

	# bug 146726
	rm "${ED}/etc/bash_completion.d/svk" || die "rm failed"

	# Upstream provides no easy way to move modules. sigh
	dodir /usr/share/bash-completion
	mv "${ED}"/etc/bash_completion.d/* "${ED}/usr/share/bash-completion/" \
		|| die "installation failed to move files"
	# cleanup the mess
	rm -r "${ED}"/etc/bash_completion{,.d} || die "rm failed"
}

pkg_postinst() {
	elog "Any user can enable the base completions without editing their"
	elog ".bashrc by running:"
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

	if has_version 'app-shells/zsh' ; then
		elog "If you are interested in using the provided bash completion functions with"
		elog "zsh, valuable tips on the effective use of bashcompinit are available:"
		elog "  http://www.zsh.org/mla/workers/2003/msg00046.html"
		#elog "  http://zshwiki.org/ZshSwitchingTo" (doesn't exist)
		elog
	fi
}
