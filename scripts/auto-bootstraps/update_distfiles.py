#!/usr/bin/env python3

import hashlib
import os
import sys

distfilessrc='./distfiles'

def hash_file(f):
    hsh = hashlib.new('sha1')
    with open(f, 'rb') as fle:
        hsh.update(fle.read())
    return hsh.hexdigest()

with os.scandir(path=sys.argv[1]) as it:
    for f in it:
        if not f.is_file() or f.name.startswith('.'):
            continue
        srcfile = os.path.join(sys.argv[1], f.name)
        h = hash_file(srcfile)
        distname = os.path.join(distfilessrc,
                f.name + "@" + h).lower()
        if os.path.exists(distname):
            print("DUP %s" % distname.split('/')[-1])
            os.remove(srcfile)
            os.link(distname, srcfile, follow_symlinks=False)
        else:
            print("NEW %s" % distname.split('/')[-1])
            os.link(srcfile, distname)
