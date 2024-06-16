#!/usr/bin/env python3

import os
import glob
import re
import time
import html
from functools import cmp_to_key

resultsdir='./results'

deprecated_archs = (
        'i386-apple-darwin9',
        'x86_64-pc-cygwin',
        'i386-pc-solaris2.11',
        'sparc-sun-solaris2.10',
        'sparcv9-sun-solaris2.10',
        'sparc-sun-solaris2.11',
        'sparcv9-sun-solaris2.11',
        'x86_64-apple-darwin19',
        'x86_64-apple-darwin20',
        'x86_64-apple-darwin21',
        'x86_64-apple-darwin22',
        'arm64-apple-darwin21',
        'arm64-apple-darwin22',
        'x86_64-pc-linux-centos8.3',
        'x86_64-pc-linux-ubuntu16.04',
        'x86_64-rap-linux-ubuntu16.04',
        'x86_64-rap-linux-ubuntu18.04',
)

def find_last_stage(d):
    """
    Returns the last stage worked on.
    Bootstraps define explicitly stages 1, 2 and 3, we define some more
    on top of those as follows:
      0 - bootstrap didn't even start (?!?) or unknown status
      1 - stage 1 failed
      2 - stage 2 failed
      3 - stage 3 failed
      4 - emerge -e world failed
      5 - finished successfully
    """

    def stage_success(stagelog):
        with open(stagelog, 'rb') as f:
            line = f.readlines()[-1]
            res = re.match(r'^\* stage[123] successfully finished',
                    line.decode('utf-8', 'ignore'))
            return res is not None

    if not os.path.exists(os.path.join(d, '.stage1-finished')):
        log = os.path.join(d, 'stage1.log')
        if not os.path.exists(log):
            return 0 # nothing exists, assume not started
        if not stage_success(log):
            return 1

    if not os.path.exists(os.path.join(d, '.stage2-finished')):
        log = os.path.join(d, 'stage2.log')
        if not os.path.exists(log) or not stage_success(log):
            return 2 # stage1 was success, so 2 must have failed

    if not os.path.exists(os.path.join(d, '.stage3-finished')):
        log = os.path.join(d, 'stage3.log')
        if not os.path.exists(log) or not stage_success(log):
            return 3 # stage2 was success, so 3 must have failed

    # if stage 3 was success, we went onto emerge -e system, if that
    # failed, portage would have left a build.log behind
    logs = glob.glob(d + "/portage/*/*/temp/build.log")
    if len(logs) > 0:
        return 4

    # ok, so it must have been all good then
    return 5

def get_err_reason(arch, dte, err):
    rdir = os.path.join(resultsdir, arch, '%d' % dte)

    if err == 0:
        return "bootstrap failed to start"
    if err >= 1 and err <= 3:
        stagelog = os.path.join(rdir, 'stage%d.log' % err)
        if os.path.exists(stagelog):
            line = None
            with open(stagelog, 'rb') as f:
                errexp = re.compile(r'^( \* (ERROR:|Fetch failed for)|emerge: there are no) ')
                for line in f:
                    line = line.decode('utf-8', 'ignore')
                    res = errexp.match(line)
                    if res:
                        break
            if not line:
                return '<a href="%s/stage%d.log">stage %d</a> failed' % \
                        (os.path.join(arch, '%d' % dte), err, err)
            m = re.fullmatch(
                    r'(\* ERROR: )([a-z-]+/[a-zA-Z0-9._-]+)(::gentoo.* failed.*)',
                    line.strip())
            if m:
                return '<a href="%s/stage%d.log">stage %d</a> failed<br />' % \
                        (os.path.join(arch, '%d' % dte), err, err) + \
                        '%s<a href="%s/temp/build.log">%s</a>%s' % \
                        (html.escape(m.group(1)), \
                        os.path.join(arch, '%d' % dte, "portage", m.group(2)), \
                        html.escape(m.group(2)), html.escape(m.group(3)))
            else:
                return '<a href="%s/stage%d.log">stage %d</a> failed<br />%s' % \
                            (os.path.join(arch, '%d' % dte), err, err, \
                             html.escape(line))
        else:
            return 'stage %d did not start' % err
    if err == 4:
        msg = "'emerge -e system' failed while emerging"
        logs = glob.glob(rdir + "/portage/*/*/temp/build.log")
        for log in logs:
            cat, pkg = log.split('/')[-4:-2]
            msg = msg + ' <a href="%s/temp/build.log">%s/%s</a>' % \
                    (os.path.join(arch, '%d' % dte, "portage", cat, pkg), \
                     cat, pkg)
        return msg

def analyse_arch(d):
    last_fail = None
    last_succ = None
    fail_state = None
    with os.scandir(d) as it:
        for f in sorted(it, key=lambda x: (x.is_dir(), x.name), reverse=True):
            if not f.is_dir(follow_symlinks=False):
                continue
            date = int(f.name)
            res = find_last_stage(os.path.join(d, f.name))
            if res == 5:
                if not last_succ:
                    last_succ = date
            elif not last_fail:
                last_fail = date
                fail_state = res
            if last_succ and last_fail:
                break

    return (last_fail, fail_state, last_succ)

archs = {}
with os.scandir(resultsdir) as it:
    for f in sorted(it, key=lambda x: (x.is_dir(), x.name)):
        if not f.is_dir(follow_symlinks=False):
            continue
        arch = f.name
        fail, state, suc = analyse_arch(os.path.join(resultsdir, arch))

        infos = {}
        for d in [ fail, suc ]:
            elapsedtime = None
            haslssl = False
            snapshot = None
            darwingcc = False

            elapsedf = os.path.join(resultsdir, arch, "%s" % d, "elapsedtime")
            if os.path.exists(elapsedf):
                with open(elapsedf, 'rb') as f:
                    l = f.readline()
                    if l != '':
                        elapsedtime = int(l)

            mconf = os.path.join(resultsdir, arch, "%s" % d, "make.conf")
            conffiles = []
            if os.path.isdir(mconf):
                with os.scandir(mconf) as it:
                    for f in it:
                        if f.is_file():
                            conffiles += [ f.name ]
            else:
                conffiles = [ mconf ]
            for mconf in conffiles:
                if os.path.exists(mconf):
                    with open(mconf, 'rb') as f:
                        l = [x.decode('utf-8', 'ignore') for x in f.readlines()]
                        l = list(filter(lambda x: 'USE=' in x, l))
                        for x in l:
                            if 'libressl' in x:
                                haslssl = True

            mconf = os.path.join(resultsdir, arch, "%s" % d, "stage1.log")
            if os.path.exists(mconf):
                with open(mconf, 'rb') as f:
                    l = [x.decode('utf-8', 'ignore') for x in f.readlines()]
                    for x in l:
                        if 'Fetching ' in x:
                            if 'portage-latest.tar.bz2' in x:
                                snapshot = 'latest'
                            elif re.search(r'(prefix-overlay|portage)-\d{8}\.tar\.bz2', x) is not None:
                                snapshot = x.split('.')[0].split('-')[-1]
                        elif 'total size is' in x:
                            snapshot = 'rsync'
                        elif 'Darwin with GCC toolchain' in x:
                            darwingcc = True

            infos[d] = {
                    'elapsedtime': elapsedtime,
                    'libressl': haslssl,
                    'snapshot': snapshot,
                    'darwingcc': darwingcc
            }

        archs[arch] = (fail, state, suc, infos)
        if not suc:
            color = '\033[1;31m'  # red
        elif fail and suc < fail:
            color = '\033[1;33m'  # yellow
        else:
            color = '\033[1;32m'  # green
        endc = '\033[0m'
        print("%s%30s: suc %8s  fail %8s%s" % (color, arch, suc, fail, endc))

def archSort(l, r):
    """
    Sort by os, vendor, cpu
    """
    lcpu, lvendor, los = l.split('-', 2)
    losname = re.split('[0-9]', los, 1)[0]
    losver = los.split(losname, 1)[1]
    rcpu, rvendor, ros = r.split('-', 2)
    rosname = re.split('[0-9]', ros, 1)[0]
    rosver = ros.split(rosname, 1)[1]

    if losname > rosname:
        return 1
    if losname < rosname:
        return -1
    if float(losver) > float(rosver):
        return 1
    if float(losver) < float(rosver):
        return -1
    if lvendor > rvendor:
        return 1
    if lvendor < rvendor:
        return -1
    if lcpu > rcpu:
        return 1
    if lcpu < rcpu:
        return -1
    return 0

sarchs = sorted(archs, key=cmp_to_key(archSort))

def gentags(infos):
    tags = ''
    if infos.get('libressl', None):
        tags = tags + '''
<span style="border-radius: 5px; background-color: purple; color: white;
display: inline-block; font-size: x-small; padding: 3px 4px; text-transform: uppercase !important;">libressl</span>
'''

    if infos.get('darwingcc', False):
        tags = tags + '''
<span style="border-radius: 5px; background-color: darkgreen; color: white; display: inline-block; font-size: x-small; padding: 3px 4px; text-transform: uppercase !important;">GCC</span>
'''

    snap = infos.get('snapshot', None)
    if snap:
        tags = tags + '''
<span style="border-radius: 5px; background-color: darkblue; color: white;
display: inline-block; font-size: x-small; padding: 3px 4px; text-transform: uppercase !important;">''' + snap + '''</span>
'''

    return tags

# generate html edition
deprecated_count = 0
with open(os.path.join(resultsdir, 'index.html'), "w") as h:
    h.write("<html>")
    h.write("<head>")
    h.write("<meta charset='UTF-8'>")
    h.write("<title>Gentoo Prefix bootstrap results</title>")
    h.write("</head>")
    h.write("<body>")
    h.write("<h2>Gentoo Prefix bootstraps</h2>")
    h.write('<table border="1px">')
    h.write("<th>architecture</th>")
    h.write("<th>last successful run</th><th>last failed run</th>")
    h.write("<th>failure</th>")
    for arch in sarchs:
        fail, errcode, suc, infos = archs[arch]
        if not suc:
            state = 'red'
        elif fail and suc < fail:
            state = 'orange'
        else:
            state = 'limegreen'

        if arch in deprecated_archs:
            deprecated_count = deprecated_count + 1
            h.write('<tr id="deprecated_%d" style="display: none;">' % deprecated_count)
        else:
            h.write('<tr>')

        h.write('<td bgcolor="%s" nowrap="nowrap">' % state)
        h.write(arch)
        h.write("</td>")

        h.write("<td>")
        if suc:
            tags = gentags(infos[suc])
            etxt = ''
            et = infos[suc].get('elapsedtime', None)
            if et:
                if et > 86400:
                    etxt = ' (%.1f days)' % (et / 86400)
                elif et > 3600:
                    etxt = ' (%.1f hours)' % (et / 3600)
                else:
                    etxt = ' (%d minutes)' % (et / 60)
            h.write('<a href="%s/%s">%s</a>%s%s' % (arch, suc, suc, etxt, tags))
        else:
            h.write('<i>never</i>')
        h.write("</td>")

        h.write("<td>")
        if fail:
            tags = gentags(infos[fail])
            h.write('<a href="%s/%s">%s</a>%s' % (arch, fail, fail, tags))
        else:
            h.write('<i>never</i>')
        h.write("</td>")

        h.write("<td>")
        if fail and (not suc or fail > suc):
            h.write(get_err_reason(arch, fail, errcode))
        h.write("</td>")

        h.write("</tr>")
    h.write("</table>")
    h.write('''
<script type="text/javascript"><!--
    function toggle_hidden(id) {
        var e = document.getElementById(id);
        if (!e)
            return;
        if (e.style.display == 'none')
            e.style.display = 'table-row';
        else
            e.style.display = 'none';
    }
    function toggle_all() {
''')
    for i in range(deprecated_count):
        h.write("toggle_hidden('deprecated_%d');" % (i + 1))
    h.write('''
    }
    //-->
</script>''')
    h.write("<a href='#' onclick='toggle_all();'>toggle visibility for %d deprecated arches</a>" % deprecated_count)
    now = time.strftime('%Y-%m-%dT%H:%MZ', time.gmtime())
    h.write("<p><i>generated: %s</i></p>" % now) 
    h.write("<p>See also <a href='https://dev.azure.com/12719821/12719821/_build?definitionId=6'>awesomebytes</a>")
    h.write(" and <a href='https://dev.azure.com/gentoo-prefix/ci-builds/_build/'>Azure Gentoo Prefix CI pipelines</a></p>")
    h.write("</body>")
    h.write("</html>")
