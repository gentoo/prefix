# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/jruby/jruby-1.0.3.ebuild,v 1.1 2007/12/17 13:58:17 caleb Exp $

EAPI="prefix"

JAVA_PKG_IUSE="doc source test"
inherit eutils java-pkg-2 java-ant-2

DESCRIPTION="Java based ruby interpreter implementation"
HOMEPAGE="http://jruby.codehaus.org/"
SRC_URI="http://dist.codehaus.org/${PN}/${PN}-src-${PV}.tar.gz"

LICENSE="|| ( CPL-1.0 GPL-2 LGPL-2.1 )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE="bsf"

COMMON_DEPEND=">=dev-java/jline-0.9.91
	=dev-java/asm-2.2*
	dev-java/backport-util-concurrent"
RDEPEND=">=virtual/jre-1.4
	${COMMON_DEPEND}"

DEPEND=">=virtual/jdk-1.4
	bsf? ( >=dev-java/bsf-2.3 )
	test? (
		=dev-java/junit-3*
		dev-java/ant-junit
		dev-java/ant-trax
	)
	${COMMON_DEPEND}"
PDEPEND="dev-ruby/rubygems
	>=dev-ruby/rake-0.7.3
	>=dev-ruby/rspec-1.0.4"

RUBY_HOME=/usr/share/${PN}/lib/ruby
SITE_RUBY=${RUBY_HOME}/site_ruby
GEMS=${RUBY_HOME}/gems

pkg_setup() {
	java-pkg-2_pkg_setup

	if [[ -d ${SITE_RUBY} && ! -L ${SITE_RUBY} ]]; then
		ewarn "dev-java/jruby now uses dev-lang/ruby's site_ruby directory by creating symlinks."
		ewarn "${SITE_RUBY} is a directory right now, which will cause problems when being merged onto the filesystem."
	fi
	if [[ -d ${GEMS} && ! -L ${GEMS} ]]; then
		ewarn "dev-java/jruby now uses dev-lang/ruby's gems directory by creating symlinks."
		ewarn "${GEMS} is a directory right now, which will cause problems when being merged onto the filesystem."
	fi

	# only use javac, see http://jira.codehaus.org/browse/JRUBY-675
	java-pkg_force-compiler javac
}

src_unpack() {
	unpack ${A}
	cd "${S}"
	# prevents /root/.jruby being created at build time with
	# FEATURES="-userpriv"
	# see http://bugs.gentoo.org/show_bug.cgi?id=170058
	epatch "${FILESDIR}"/${PN}-0.9.8-sandbox.patch
	# search only lib, kills jdk1.4+ property which we set manually
	java-ant_ignore-system-classes

	cd "${S}"/lib
	rm -v *.jar || die

	java-pkg_jar-from --build-only ant-core ant.jar
	java-pkg_jar-from asm-2.2 asm.jar
	java-pkg_jar-from asm-2.2 asm-commons.jar
	java-pkg_jar-from jline
	java-pkg_jar-from backport-util-concurrent
	use test && java-pkg_jar-from --build-only junit

	# build-only because it's just BSF adapter classes and won't be used
	# unless invoked from bsf itself, so no need to pollute classpath
	if use bsf; then
		java-pkg_jar-from --build-only bsf-2.3
	else
		cd "${S}"
		# testcases depending on bsf
		rm test/org/jruby/test/TestAdoptedThreading.java || die
		rm test/org/jruby/javasupport/test/TestBSF.java || die
		sed -i -e '/TestBSF.class/d' \
			test/org/jruby/javasupport/test/JavaSupportTestSuite.java || die
		sed -i -e '/TestAdoptedThreading.class/d' \
			test/org/jruby/test/MainTestSuite.java || die
	fi
}

src_compile() {
	eant jar $(use_doc create-apidocs) -Djruby.home="${T}"/.jruby -Djdk1.4+=true
}

src_test() {
	# needs bsf's runtime deps to work
	use bsf && java-pkg_jar-from --into lib --with-dependencies bsf-2.3
	ANT_TASKS="ant-junit ant-trax" eant test -Djdk1.4+=true
}

src_install() {
	java-pkg_dojar lib/${PN}.jar

	dodoc README docs/{*.txt,README.*,BeanScriptingFramework} || die
	dohtml docs/getting_involved.html || die

	if use doc; then
		java-pkg_dojavadoc docs/api
	fi
	use source && java-pkg_dosrc src/org
	java-pkg_dolauncher ${PN} \
		--main 'org.jruby.Main' \
		--java_args "-Djruby.base=${EPREFIX}/usr/share/jruby -Djruby.home=${EPREFIX}/usr/share/jruby -Djruby.lib=${EPREFIX}/usr/share/jruby/lib -Djruby.script=jruby -Djruby.shell=${EPREFIX}/bin/bash"
	dobin "${S}"/bin/jirb

	dodir "/usr/share/${PN}/lib"
	insinto "/usr/share/${PN}/lib"
	doins -r "${S}/lib/ruby"

	# Share gems with regular ruby
	rm -r "${ED}"/usr/share/${PN}/lib/ruby/gems || die
	dosym /usr/lib/ruby/gems /usr/share/${PN}/lib/ruby/gems || die

	# Share site_ruby with regular ruby
	rm -r "${ED}"/usr/share/${PN}/lib/ruby/site_ruby || die
	dosym /usr/lib/ruby/site_ruby /usr/share/${PN}/lib/ruby/site_ruby || die
}

pkg_preinst() {
	local bad_directory=0

	if [[ -d ${SITE_RUBY} && ! -L ${SITE_RUBY} ]]; then
		eerror "${SITE_RUBY} is a directory. Please move this directory out of the way, and then emerge --resume."
		bad_directory=1
	fi

	if [[ -d ${GEMS} && ! -L ${GEMS} ]]; then
		eerror "${GEMS} is a directory. Please move this directory out of the way, and then emerge --resume."
		bad_directory=1
	fi

	if [[ ! ${bad_directory} ]]; then
		die "Please address the above errors, then emerge --resume."
	fi
}
