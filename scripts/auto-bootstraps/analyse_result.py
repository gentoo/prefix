#!/usr/bin/env python3

import os
import glob
import re
import time
import html

resultsdir='./results'

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
                    res = errexp.match(line.decode('utf-8', 'ignore'))
                    if res:
                        break
            if not line:
                return '<a href="%s/stage%d.log">stage %d</a> failed' % \
                        (os.path.join(arch, '%d' % dte), err, err)
            return '<a href="%s/stage%d.log">stage %d</a> failed<br />%s' % \
                        (os.path.join(arch, '%d' % dte), err, err, \
                         html.escape(line.decode('utf-8', 'ignore')))
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

        elapsedtime = None
        if suc:
            elapsedf = os.path.join(resultsdir, arch, "%s" % suc, "elapsedtime")
            if os.path.exists(elapsedf):
                with open(elapsedf, 'rb') as f:
                    l = f.readline()
                    if l is not '':
                        elapsedtime = int(l)

        archs[arch] = (fail, state, suc, elapsedtime)
        if not suc:
            color = '\033[1;31m'  # red
        elif fail and suc < fail:
            color = '\033[1;33m'  # yellow
        else:
            color = '\033[1;32m'  # green
        endc = '\033[0m'
        print("%s%24s: suc %8s  fail %8s%s" % (color, arch, suc, fail, endc))

sarchs = sorted(archs, key=lambda a: '-'.join(a.split('-')[::-1]))

# generate html edition
with open(os.path.join(resultsdir, 'index.html'), "w") as h:
    h.write("<html>")
    h.write("<head><title>Gentoo Prefix bootstrap results</title></head>")
    h.write("<body>")
    h.write("<h2>Gentoo Prefix bootstraps</h2>")
    h.write('<table border="1px">')
    h.write("<th>architecture</th>")
    h.write("<th>last successful run</th><th>last failed run</th>")
    h.write("<th>failure</th>")
    for arch in sarchs:
        fail, errcode, suc, et = archs[arch]
        if not suc:
            state = 'red'
        elif fail and suc < fail:
            state = 'orange'
        else:
            state = 'limegreen'

        h.write('<tr>')

        h.write('<td bgcolor="%s" nowrap="nowrap">' % state)
        h.write(arch)
        h.write("</td>")

        h.write("<td>")
        if suc:
            etxt = ''
            if et:
                if et > 86400:
                    etxt = ' (%.1f days)' % (et / 86400)
                elif et > 3600:
                    etxt = ' (%.1f hours)' % (et / 3600)
                else:
                    etxt = ' (%d minutes)' % (et / 60)
            h.write('<a href="%s/%s">%s</a>%s' % (arch, suc, suc, etxt))
        else:
            h.write('<i>never</i>')
        h.write("</td>")

        h.write("<td>")
        if fail:
            h.write('<a href="%s/%s">%s</a>' % (arch, fail, fail))
        else:
            h.write('<i>never</i>')
        h.write("</td>")

        h.write("<td>")
        if fail and (not suc or fail > suc):
            h.write(get_err_reason(arch, fail, errcode))
        h.write("</td>")

        h.write("</tr>")
    h.write("</table>")
    now = time.strftime('%Y-%m-%d %H:%M', time.gmtime())
    h.write("<p><i>generated: %s</i></p>" % now) 
    h.write("<p>See also <a href='https://dev.azure.com/12719821/12719821/_build?definitionId=6'>awesomebytes</a>")
    h.write(" and <a href='https://dev.azure.com/gentoo-prefix/ci-builds/_build/'>Azure Gentoo Prefix CI pipelines</a></p>")
    h.write("</body>")
    h.write("</html>")
