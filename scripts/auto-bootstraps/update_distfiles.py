#!/usr/bin/env python3

import hashlib
import os
import sys

distfilessrc='./distfiles'

def hash_file(f):
    hsh = hashlib.sha1()
    with open(f, 'rb') as fle:
        hsh.update(fle.read())
    return hsh.hexdigest()

for path in sys.argv[1:]:
    print("processing %s" % path)
    with os.scandir(path=path) as it:
        for f in it:
            if not f.is_file() or f.name.startswith('.'):
                continue
            # ensure this live snapshot never ends up in a mirror
            if (f.name.startswith('portage-latest.tar.'):
                continue
            srcfile = os.path.join(path, f.name)
            h = hash_file(srcfile)
            distname = os.path.join(distfilessrc,
                    f.name + "@" + h).lower()
            isnew = False
            if os.path.exists(distname):
                print("DUP %s" % distname.split('/')[-1])
                os.remove(srcfile)
                os.link(distname, srcfile, follow_symlinks=False)
            else:
                print("NEW %s" % distname.split('/')[-1])
                os.link(srcfile, distname)
                isnew = True

            # generate a name match for distfiles serving along the
            # specification from gentoo-dev ML 18 Oct 2019 15:41:32 +0200
            # 4c7465824f1fb69924c826f6bbe3ee73afa08ec8.camel@gentoo.org
            blh = hashlib.blake2b(bytes(f.name.encode('us-ascii'))).hexdigest()
            trgpth = os.path.join(distfilessrc, 'public', blh[:2], f.name);
            if isnew or not os.path.exists(trgpth):
                if os.path.exists(trgpth):
                    os.remove(trgpth)
                os.makedirs(os.path.join(distfilessrc, 'public', blh[:2]),
                        exist_ok=True)
                os.link(distname, trgpth);
