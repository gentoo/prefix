# Copyright 2006-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/app-dicts/myspell-en/myspell-en-20060316.ebuild,v 1.13 2008/01/06 15:23:49 ranger Exp $

EAPI="prefix"

MYSPELL_SPELLING_DICTIONARIES=(
"en,AU,en_AU,English (Australia),en_AU.zip"
"en,BZ,en_GB,English (Belize),en_GB.zip"
"en,CA,en_CA,English (Canada),en_CA.zip"
"en,IE,en_GB,English (Ireland),en_GB.zip"
"en,JM,en_GB,English (Jamaica),en_GB.zip"
"en,NZ,en_NZ,English (New Zealand),en_NZ.zip"
"en,PH,en_GB,English (Philippines),en_GB.zip"
"en,GB,en_GB,English (United Kingdom),en_GB.zip"
"en,US,en_US,English (United States),en_US.zip"
"en,ZA,en_GB,English (South Africa),en_GB.zip"
"en,TT,en_GB,English (Trinidad and Tobago),en_GB.zip"
"en,ZW,en_GB,English (Zimbabwe),en_GB.zip"
)

MYSPELL_HYPHENATION_DICTIONARIES=(
"en,AU,hyph_en_GB,English (Australia),hyph_en_GB.zip"
"en,BZ,hyph_en_GB,English (Belize),hyph_en_GB.zip"
"en,CA,hyph_en_GB,English (Canada),hyph_en_GB.zip"
"en,IE,hyph_en_GB,English (Ireland),hyph_en_GB.zip"
"en,JM,hyph_en_GB,English (Jamaica),hyph_en_GB.zip"
"en,NZ,hyph_en_GB,English (New Zealand),hyph_en_GB.zip"
"en,PH,hyph_en_GB,English (Philippines),hyph_en_GB.zip"
"en,ZA,hyph_en_GB,English (South Africa),hyph_en_GB.zip"
"en,TT,hyph_en_GB,English (Trinidad and Tobago),hyph_en_GB.zip"
"en,GB,hyph_en_GB,English (United Kingdom),hyph_en_GB.zip"
"en,US,hyph_en_US,English (United States),hyph_en_US.zip"
"en,ZW,hyph_en_GB,English (Zimbabwe),hyph_en_GB.zip"
)

MYSPELL_THESAURUS_DICTIONARIES=(
"en,AU,th_en_US,English (Australia),thes_en_US.zip"
"en,BZ,th_en_US,English (Belize),thes_en_US.zip"
"en,CA,th_en_US,English (Canada),thes_en_US.zip"
"en,IE,th_en_US,English (Ireland),thes_en_US.zip"
"en,JM,th_en_US,English (Jamaica),thes_en_US.zip"
"en,NZ,th_en_US,English (New Zealand),thes_en_US.zip"
"en,PH,th_en_US,English (Philippines),thes_en_US.zip"
"en,ZA,th_en_US,English (South Africa),thes_en_US.zip"
"en,TT,th_en_US,English (Trinidad and Tobago),thes_en_US.zip"
"en,GB,th_en_US,English (United Kingdom),thes_en_US.zip"
"en,US,th_en_US,English (United States),thes_en_US.zip"
"en,ZW,th_en_US,English (Zimbabwe),thes_en_US.zip"
)

inherit myspell

DESCRIPTION="English dictionaries for myspell/hunspell"
LICENSE="LGPL-2.1 myspell-en_CA-KevinAtkinson WordNet-1.6 myspell-ispell-GeoffKuenning myspell-en_CA-JRossBeresford"
HOMEPAGE="http://lingucomponent.openoffice.org/"

KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
