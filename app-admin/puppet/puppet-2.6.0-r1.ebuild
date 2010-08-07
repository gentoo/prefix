# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/puppet/puppet-2.6.0-r1.ebuild,v 1.1 2010/08/01 01:12:12 matsuu Exp $

EAPI="2"
USE_RUBY="ruby18"

RUBY_FAKEGEM_TASK_DOC=""
RUBY_FAKEGEM_TASK_TEST="unit"
RUBY_FAKEGEM_EXTRADOC="CHANGELOG* README*"

inherit elisp-common eutils ruby-fakegem

DESCRIPTION="A system automation and configuration management software"
HOMEPAGE="http://puppetlabs.com/"

LICENSE="GPL-2"
SLOT="0"
IUSE="augeas emacs ldap rrdtool shadow vim-syntax"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~x86-solaris"

RESTRICT="test"

ruby_add_rdepend ">=dev-ruby/facter-1.5.1"
ruby_add_rdepend augeas dev-ruby/ruby-augeas
ruby_add_rdepend ldap dev-ruby/ruby-ldap
#ruby_add_rdepend rrdtool ">=net-analyzer/rrdtool-1.2.23[ruby]"
ruby_add_rdepend shadow dev-ruby/ruby-shadow

DEPEND="${DEPEND}
	emacs? ( virtual/emacs )"
RDEPEND="${RDEPEND}
	emacs? ( virtual/emacs )
	rrdtool? ( >=net-analyzer/rrdtool-1.2.23[ruby] )
	>=app-portage/eix-0.18.0"

for _ruby in ${USE_RUBY}; do
	DEPEND="${DEPEND} ruby_targets_${_ruby}? ( $(ruby_implementation_depend $_ruby)[ssl] )"
done

SITEFILE="50${PN}-mode-gentoo.el"

pkg_setup() {
	enewgroup puppet
	enewuser puppet -1 -1 /var/lib/puppet puppet
}

all_ruby_compile() {
	all_fakegem_compile

	if use emacs ; then
		elisp-compile ext/emacs/puppet-mode.el || die "elisp-compile failed"
	fi
}

each_fakegem_install() {
	${RUBY} install.rb --destdir="${D}" install || die
}

all_ruby_install() {
	all_fakegem_install

	newinitd "${FILESDIR}"/puppetmaster.init puppetmaster || die
	doconfd conf/gentoo/conf.d/puppetmaster || die
	newinitd "${FILESDIR}"/puppet.init puppet || die
	doconfd conf/gentoo/conf.d/puppet || die

	# Initial configuration files
	keepdir /etc/puppet/manifests || die
	insinto /etc/puppet
	doins conf/gentoo/puppet/* || die
	doins conf/auth.conf || die

	# Location of log and data files
	keepdir /var/run/puppet || die
	keepdir /var/log/puppet || die
	keepdir /var/lib/puppet/ssl || die
	keepdir /var/lib/puppet/files || die
	use prefix || fowners -R puppet:puppet /var/{run,log,lib}/puppet || die

	if use emacs ; then
		elisp-install ${PN} ext/emacs/puppet-mode.el* || die "elisp-install failed"
		elisp-site-file-install "${FILESDIR}/${SITEFILE}" || die
	fi

	if use ldap ; then
		insinto /etc/openldap/schema; doins ext/ldap/puppet.schema || die
	fi

	if use vim-syntax ; then
		insinto /usr/share/vim/vimfiles/syntax; doins ext/vim/syntax/puppet.vim || die
		insinto /usr/share/vim/vimfiles/ftdetect; doins	ext/vim/ftdetect/puppet.vim || die
	fi

	# ext and examples files
	for f in $(find ext examples -type f) ; do
		docinto "$(dirname ${f})"; dodoc "${f}" || die
	done
	docinto conf; dodoc conf/namespaceauth.conf || die
}

pkg_postinst() {
	elog
	elog "Please, *don't* include the --ask option in EMERGE_EXTRA_OPTS as this could"
	elog "cause puppet to hang while installing packages."
	elog
	elog "Puppet uses eix to get information about currently installed packages,"
	elog "so please keep the eix metadata cache updated so puppet is able to properly"
	elog "handle package installations."
	elog
	elog "Currently puppet only supports adding and removing services to the default"
	elog "runlevel, if you want to add/remove a service from another runlevel you may"
	elog "do so using symlinking."
	elog

	if [ \
		-f "${EROOT}/etc/puppet/puppetd.conf" -o \
		-f "${EROOT}/etc/puppet/puppetmaster.conf" -o \
		-f "${EROOT}/etc/puppet/puppetca.conf" \
	] ; then
		elog
		elog "Please remove deprecated config files."
		elog "	/etc/puppet/puppetca.conf"
		elog "	/etc/puppet/puppetd.conf"
		elog "	/etc/puppet/puppetmasterd.conf"
		elog
	fi

	use emacs && elisp-site-regen
}

pkg_postrm() {
	use emacs && elisp-site-regen
}
