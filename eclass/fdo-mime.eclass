# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/fdo-mime.eclass,v 1.5 2006/06/20 12:18:27 foser Exp $

# Author:
# foser <foser@gentoo.org>

# utility eclass to update the desktop mime info as laid out in the freedesktop specs & implementations
# <references here>


# Updates the desktop database
# Generates a list of mimetypes linked to applications that can handle them

fdo-mime_desktop_database_update() {

	if [ -x ${ROOT}/usr/bin/update-desktop-database ]
	then
		einfo "Updating desktop mime database ..."
		${ROOT}/usr/bin/update-desktop-database -q ${ROOT}/usr/share/applications
	fi

}

# Update the mime database
# Creates a general list of mime types from several sources

fdo-mime_mime_database_update() {

	if [ -x ${ROOT}/usr/bin/update-mime-database ]
	then
		einfo "Updating shared mime info database ..."
		${ROOT}/usr/bin/update-mime-database ${ROOT}/usr/share/mime
	fi

}
