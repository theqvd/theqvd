import subprocess
import types
import re
import os
import time

def sanity():
    if 'demo' != os.getenv ('OS_USERNAME'):
        raise Exception, "environment variable OS_USERNAME not set, please run 'source ~/devstack/openrc demo demo'"
    if 'demo' != os.getenv ('OS_TENANT_NAME'):
        raise Exception, "environment variable OS_TENANT_NAME not set, please run 'source ~/devstack/openrc demo demo'"

def test_is_local():
    return 'TEST_IS_LOCAL' in os.environ

def run_cmd(cmd):
    p = subprocess.Popen (['sh', '-c', cmd], stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    out, err = p.communicate()
    if type(out) is types.StringType:
        out=out.decode('utf8')
    if type(err) is types.StringType:
        err=err.decode('utf8')
    out = re.compile ("stty: standard input: Invalid argument\n").sub ('', out)
    out = re.compile ("stty: standard input: Inappropriate ioctl for device\n").sub ('', out)
    print "# %s\n%s\n\n" % (cmd, out)
    return out

def run_cmd_in_vm(ip, cmd):
    if test_is_local():
        return run_cmd (cmd)
    else:
        return run_cmd ('ssh -o StrictHostKeyChecking=no -q root@%s %s' % (ip, cmd))

def run_cmd_in_vm_t(ip, cmd):
    if test_is_local():
        return run_cmd (cmd)
    else:
        return run_cmd ('ssh -o StrictHostKeyChecking=no -qt root@%s %s' % (ip, cmd))

def run_qvd_admin(ip, cmd):
    prefix=''
    if test_is_local():
        prefix = '/usr/lib/qvd/bin/perl -Mlib::glob=../ext/*/lib ../ext/QVD-Admin/bin/qvd-admin.pl'
    else:
        prefix = '/usr/lib/qvd/bin/qvd-admin.pl'
    return run_cmd_in_vm (ip, '%s %s' % (prefix, cmd))

def os_vm_id2ip(os_vm_id):
    output = run_cmd ('nova show ' + os_vm_id)
    match = re.search ('\| +private network +\| +(\S+)', output)
    if not match:
        raise Exception, "private network field absent in 'nova show' output for os_vm_id '%s'" % os_vm_id
    return match.group(1)

def detect_distro(os_vm_ip):
    ## SuSE-brand seems to take some time to appear (!) when --os-full-reset is set to 1, so let's poll for it
    for i in range(10):
        output = run_cmd_in_vm (os_vm_ip, 'ls /etc/SuSE-brand')
        match = re.search ('^/etc/SuSE-brand', output)
        if match:
            ## todo: further nailing down of flavour/version
            return 'suse'

        output = run_cmd_in_vm (os_vm_ip, 'ls /etc/debian_version')
        match = re.search ('^/etc/debian_version', output)
        if match:
            ## todo: further nailing down of flavour/version
            return 'debian'

        time.sleep (6)

    raise Exception, "couldn't figure out what distribution is installed in %s" % os_vm_ip

