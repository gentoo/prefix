# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/selinux-policy.eclass,v 1.16 2006/05/16 02:01:02 pebenito Exp $

# Eclass for installing SELinux policy, and optionally
# reloading the policy

inherit eutils

HOMEPAGE="http://www.gentoo.org/proj/en/hardened/selinux/"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
S="${WORKDIR}/${PN/selinux-}"

IUSE=""

RDEPEND=">=sec-policy/selinux-base-policy-20030729"

selinux-policy_src_compile() {
	cd ${S}

	[ -z "${POLICYDIR}" ] && POLICYDIR="/etc/security/selinux/src/policy"
	SAVENAME="`date +%Y%m%d%H%M`-${PN}.tar.bz2"
	SAVEDIR="`echo "${POLICYDIR}" | cut -d/ -f6`"

	einfo "Backup of policy source is \"${SAVENAME}\"."
	debug-print "POLICYDIR is \"${POLICYDIR}\""
	debug-print "SAVEDIR is \"${SAVEDIR}\""

	# create a backup of the current policy
	tar -C /etc/security/selinux/src --exclude tmp \
		--exclude policy.conf -jcf ${SAVENAME} ${SAVEDIR}/
}

selinux-policy_src_install() {
	cd ${S}

	insinto /etc/security/selinux/src/policy-backup
	doins *-${PN}.tar.bz2

	if [ -n "${TEFILES}" ]; then
		debug-print "TEFILES is \"${TEFILES}\""
		insinto ${POLICYDIR}/domains/program
		doins ${TEFILES} || die
	fi

	if [ -n "${TEMISC}" ]; then
		debug-print "TEMISC is \"${TEMISC}\""
		insinto ${POLICYDIR}/domains/misc
		doins ${TEMISC} || die
	fi

	if [ -n "${FCFILES}" ]; then
		debug-print "FCFILES is \"${FCFILES}\""
		insinto ${POLICYDIR}/file_contexts/program
		doins ${FCFILES} || die
	fi

	if [ -n "${FCMISC}" ]; then
		debug-print "FCMISC is \"${FCMISC}\""
		insinto ${POLICYDIR}/file_contexts/misc
		doins ${FCMISC} || die
	fi

	if [ -n "${MACROS}" ]; then
		debug-print "MACROS is \"${MACROS}\""
		insinto ${POLICYDIR}/macros/program
		doins ${MACROS} || die
	fi
}

selinux-policy_pkg_postinst() {
	if has "loadpolicy" $FEATURES ; then
		if [ -x /usr/bin/checkpolicy -a -x /usr/sbin/load_policy -a -x /usr/sbin/setfiles ]; then
			# only do this if all tools are installed

			ebegin "Automatically loading policy"
			make -C ${POLICYDIR} load
			eend $?

			ebegin "Regenerating file contexts"
			[ -f ${POLICYDIR}/file_contexts/file_contexts ] && \
				rm -f ${POLICYDIR}/file_contexts/file_contexts
			make -C ${POLICYDIR} file_contexts/file_contexts &> /dev/null

			# do a test relabel to make sure file
			# contexts work (doesnt change any labels)
			echo "/etc/passwd" | /usr/sbin/setfiles \
				${POLICYDIR}/file_contexts/file_contexts -sqn
			eend $?
		fi
	else
		echo
		echo
		eerror "Policy has not been loaded.  It is strongly suggested"
		eerror "that the policy be loaded before continuing!!"
		echo
		einfo "Automatic policy loading can be enabled by adding"
		einfo "\"loadpolicy\" to the FEATURES in make.conf."
		echo
		echo
		ebeep 4
		epause 4
	fi
}

EXPORT_FUNCTIONS src_compile src_install pkg_postinst
