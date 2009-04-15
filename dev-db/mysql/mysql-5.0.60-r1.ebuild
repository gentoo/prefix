# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-db/mysql/mysql-5.0.60-r1.ebuild,v 1.8 2008/11/14 09:42:28 robbat2 Exp $

MY_EXTRAS_VER="20080601"
SERVER_URI="http://mirror.provenscaling.com/mysql/enterprise/source/5.0/${P}.tar.gz"

inherit toolchain-funcs mysql
# only to make repoman happy. it is really set in the eclass
IUSE="$IUSE"

# REMEMBER: also update eclass/mysql*.eclass before committing!
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos"

# When MY_EXTRAS is bumped, the index should be revised to exclude these.
EPATCH_EXCLUDE=''

# Please do not add a naive src_unpack to this ebuild
# If you want to add a single patch, copy the ebuild to an overlay
# and create your own mysql-extras tarball, looking at 000_index.txt

src_unpack() {
	mysql_src_unpack
	cd "${S}"
	epatch "${FILESDIR}"/${P}-darwin-bool.patch
}

src_test() {
	make check || die "make check failed"
	if ! use "minimal" ; then
		if [[ $UID -eq 0 ]]; then
			die "Testing with FEATURES=-userpriv is no longer supported by upstream. Tests MUST be run as non-root."
		fi
		cd "${S}"
		einfo ">>> Test phase [test]: ${CATEGORY}/${PF}"
		local retstatus1
		local retstatus2
		local t
		addpredict /this-dir-does-not-exist/t9.MYI

		# Ensure that parallel runs don't die
		export MTR_BUILD_THREAD="$((${RANDOM} % 100))"

		# archive_gis really sucks a lot, but it's only relevant for the
		# USE=extraengines case
		case ${PV} in
			5.0.42)
			mysql_disable_test "archive_gis" "Totally broken in 5.0.42"
			;;

			5.0.44|5.0.45|5.0.46|5.0.48|5.0.5[0-6]*)
			[ "$(tc-endian)" == "big" ] && \
			mysql_disable_test \
				"archive_gis" \
				"Broken in 5.0.44-56 on big-endian boxes only"
			;;
		esac

		# This was a slight testcase breakage when the read_only security issue
		# was fixed.
		case ${PV} in
			5.0.54|5.0.51*)
			mysql_disable_test \
				"read_only" \
				"Broken in 5.0.51-54, output in wrong order"
			;;
		esac

		# Ditto to read_only
		[ "${PV}" == "5.0.51a" ] && \
			mysql_disable_test \
				"view" \
				"Broken in 5.0.51, output in wrong order"

		# x86-specific, OOM issue with some subselects on low memory servers
		[ "${PV}" == "5.0.54" ] && \
			[ "${ARCH/x86}" != "${ARCH}" ] && \
			mysql_disable_test \
				"subselect" \
				"Testcase needs tuning on x86 for oom condition"

		# Broke with the YaSSL security issue that didn't affect Gentoo.
		[ "${PV}" == "5.0.56" ] && \
			for t in openssl_1 rpl_openssl rpl_ssl ssl \
				ssl_8k_key ssl_compress ssl_connect ; do \
				mysql_disable_test \
					"$t" \
					"OpenSSL tests broken on 5.0.56"
			done

		# create directories because mysqladmin might right out of order
		mkdir -p "${S}"/mysql-test/var-{ps,ns}{,/log}

		# We run the test protocols seperately
		make -j1 test-ns force="--force --vardir=${S}/mysql-test/var-ns"
		retstatus1=$?
		[[ $retstatus1 -eq 0 ]] || eerror "test-ns failed"

		make -j1 test-ps force="--force --vardir=${S}/mysql-test/var-ps"
		retstatus2=$?
		[[ $retstatus2 -eq 0 ]] || eerror "test-ps failed"

		# Cleanup is important for these testcases.
		pkill -9 -f "${S}/ndb" 2>/dev/null
		pkill -9 -f "${S}/sql" 2>/dev/null
		[[ $retstatus1 -eq 0 ]] || die "test-ns failed"
		[[ $retstatus2 -eq 0 ]] || die "test-ps failed"
		einfo "Tests successfully completed"
	else
		einfo "Skipping server tests due to minimal build."
	fi
}
