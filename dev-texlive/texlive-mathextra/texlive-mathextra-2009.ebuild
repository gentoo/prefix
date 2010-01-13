# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-texlive/texlive-mathextra/texlive-mathextra-2009.ebuild,v 1.1 2010/01/11 03:31:41 aballier Exp $

TEXLIVE_MODULE_CONTENTS="12many amstex boldtensors bosisio ccfonts commath concmath concrete extarrows extpfeil faktor ionumbers isomath mathcomp mattens mhequ multiobjective nath proba shuffle statex2 stex stmaryrd subsupscripts susy syllogism synproof tablor tensor tex-ewd thmbox turnstile venn yhmath collection-mathextra
"
TEXLIVE_MODULE_DOC_CONTENTS="12many.doc amstex.doc boldtensors.doc bosisio.doc ccfonts.doc commath.doc concmath.doc concrete.doc extarrows.doc extpfeil.doc faktor.doc ionumbers.doc isomath.doc mathcomp.doc mattens.doc mhequ.doc multiobjective.doc nath.doc proba.doc shuffle.doc stex.doc stmaryrd.doc subsupscripts.doc susy.doc syllogism.doc synproof.doc tablor.doc tensor.doc tex-ewd.doc thmbox.doc turnstile.doc venn.doc yhmath.doc "
TEXLIVE_MODULE_SRC_CONTENTS="12many.source bosisio.source ccfonts.source concmath.source extpfeil.source faktor.source ionumbers.source mathcomp.source mattens.source multiobjective.source proba.source shuffle.source stex.source stmaryrd.source tensor.source thmbox.source turnstile.source yhmath.source "
inherit texlive-module
DESCRIPTION="TeXLive Advanced math typesetting"

LICENSE="GPL-2 as-is BSD freedist GPL-1 LGPL-2 LPPL-1.3 public-domain TeX "
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""
DEPEND=">=dev-texlive/texlive-fontsrecommended-2009
>=dev-texlive/texlive-latex-2009
"
RDEPEND="${DEPEND} "
