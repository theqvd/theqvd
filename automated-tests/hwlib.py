import re
import os
import time
from hwlib_common import *
from hwlib_debian import *
from hwlib_suse import *

regex_di_list_1 = '%d +%s +\S+ +%d-%s'
regex_di_list_2 = '^1\s+1\s+\S+\s+1-\S+\s+\S+\s*$'                                   #1  1   2013-05-07-000 1-demo-ubuntu-12.04-desktop.i386.tar.gz 2013-05-07-000               
regex_di_list_3 = '^%s\s+1\s+\S+\s+%s-ls\s+\S+\s+.*default'                          #%d  1   2013-05-07-001 %d-ls                                    2013-05-07-001, default, head
regex_di_list_4 = '^%s\s+1\s+\S+\s+%s-ls\s+\S+\s+.*head'                             #%d  1   2013-05-07-001 %d-ls                                    2013-05-07-001, default, head
regex_di_list_5 = '^1\s+1\s+\S+\s+1-\S+\s+\S+\s+.*default'                           #1  1   2013-05-07-000 1-demo-ubuntu-12.04-desktop.i386.tar.gz 2013-05-07-000, default, head
regex_di_list_6 = '^1\s+1\s+\S+\s+1-\S+\s+\S+\s+.*head'                              #1  1   2013-05-07-000 1-demo-ubuntu-12.04-desktop.i386.tar.gz 2013-05-07-000, default, head
regex_vm_list_1 = '%s +%s +%s +\d+\.\d+\.\d+\.\d+ +.* stopped +disconnected'      ## without realuser
regex_vm_list_2 = '%s +%s +%s +- +\d+\.\d+\.\d+\.\d+ +.* stopped +disconnected'   ## with realuser
regex_vm_list_3 = '^ *[0-9]+ +.* (\S+) +(?:disconnected|connecting|connected)'    ## I got a feeling this regex could be improved...
regex_vm_list_4 = '.* (\S+) +disconnected'
regex_vm_list_5 = '%s\s+%s .* running\s+connected'
regex_vm_list_6 = ' %s\s+%s .* running\s+disconnected'
regex_vm_list_7 = ' %s\s+\S+\s+\S+\s+(\S+) .* running'                               #'5 sess_kept sess_kept_user - 10.69.255.253 testosf default 2013-10-24-000 - stopped disconnected 0 - -'

def os_cleanup(os_vm_name, os_img_name):
    for os_vm_id in re.findall ('[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}', run_cmd('nova list --name %s' % os_vm_name)):
        run_cmd ('nova delete ' + os_vm_id)        
    for os_img_id in re.findall ('[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}', run_cmd('glance image-list --name %s' % os_img_name)):
        run_cmd ('glance image-delete ' + os_img_id)        
    run_cmd('rm -f /opt/stack/data/glance/cache/invalid/*')

def os_quick_cleanup(os_vm_id):
    os_vm_ip = os_vm_id2ip (os_vm_id)
    distro = detect_distro (os_vm_ip)
    if 'debian' == distro: return os_quick_cleanup_debian(os_vm_ip)
    if 'suse'   == distro: return os_quick_cleanup_suse(os_vm_ip)
    raise Exception, "unknown distro '%s'" % distro

def os_glance_image(img_file, img_name):
    img_list = run_cmd ('glance image-list --name %s' % img_name)
    if re.search ('[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12} +\| +%s' % img_name, img_list):
        raise Exception, "An image with name '%s' already exists" % img_name
    run_cmd ('glance image-create --name %s --disk-format qcow2 --container-format bare --file %s' % (img_name, img_file))
    img_list = run_cmd ('glance image-list')
    match = re.search ('([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}) +\| +%s' % img_name, img_list)
    if not match:
        raise Exception, "No image with name '%s' found after creating it" % img_name
    os_img_id = match.group(1)
    time.sleep (25)      ## creating the image puts some load in the node and the following 'nova boot' fails, so wait a bit for the load to go back down
    run_cmd ('glance image-update %s --property hw_disk_bus=ide' % (os_img_id))
    return os_img_id

def os_nova_boot(os_img_id, os_vm_name):
    status = ''
    output = run_cmd ('nova boot --flavor 2 --image %s %s' % (os_img_id, os_vm_name))
    match = re.search ('\| +id +\| ([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})', output)
    if not match:
        raise Exception, "'nova boot' failed"
    os_vm_id = match.group(1)
    for i in range (50):
        time.sleep(8)
        output = run_cmd ('nova show %s |grep -w status' % os_vm_id)
        match = re.search ('\| +status +\| +([A-Z]*)', output)
        if not match:
            raise Exception, "'nova show' failed"
        status = match.group(1)
        if 'BUILD' != status:
            break
    if 'ACTIVE' != status:
        raise Exception, "status of server isn't 'ACTIVE' but '%s'" % status
    time.sleep (20)
    return os_vm_id


def set_install_pkgs_1(distro, pkgs):
    print "in set_install_pkgs_1"
    if 'debian' == distro: return set_install_pkgs_ubuntu_1 (pkgs)
    if 'suse'   == distro: return set_install_pkgs_suse_1 (pkgs)
    raise Exception, "unknown distro '%s'" % distro

def set_install_pkgs_2(distro, pkgs):
    print "in set_install_pkgs_2"
    if 'debian' == distro: return set_install_pkgs_ubuntu_2 (pkgs)
    if 'suse'   == distro: return set_install_pkgs_suse_2 (pkgs)
    raise Exception, "unknown distro '%s'" % distro

def set_all_pkgs(distro, pkgs):
    print "in set_all_pkgs"
    if 'debian' == distro: return set_all_pkgs_ubuntu (pkgs)
    if 'suse'   == distro: return set_all_pkgs_suse (pkgs)
    raise Exception, "unknown distro '%s'" % distro

def qvd_install_1(os_vm_ip, distro, qvd_host_name, qvd_host_ip, sources_list):
    ssh_ls = 0
    for i in range(10):
        time.sleep(6)
        output = run_cmd_in_vm (os_vm_ip, 'ls /')
        match = re.search ('bin.*boot.*dev.*etc.*root.*usr.*var', output, re.S)
        if match:
            ssh_ls = 1
            break
    if not ssh_ls:
        raise Exception, "couldn't ssh into host and run a measly ls"

    if 'debian' == distro: return qvd_install_1_debian(os_vm_ip, qvd_host_name, qvd_host_ip, sources_list)
    if 'suse'   == distro: return qvd_install_1_suse(os_vm_ip, qvd_host_name, qvd_host_ip, sources_list)
    raise Exception, "unknown distro '%s'" % distro

def upload_gui_tests(ip):
    run_cmd ('scp -o StrictHostKeyChecking=no -q /home/stack/rf/x11-gui-test.pl root@%s:/root' % ip)
    run_cmd_in_vm (ip, 'chmod 755 /root/x11-gui-test.pl')

def qvd_install_2(os_vm_ip, distro):
    if 'debian' == distro: return qvd_install_2_debian(os_vm_ip)
    if 'suse'   == distro: return qvd_install_2_suse(os_vm_ip)
    raise Exception, "unknown distro '%s'" % distro

def qvd_setup_db(os_vm_ip, distro, qvd_host_ip):
    if 'debian' == distro:
        pgsql_conf = '/etc/postgresql/*/main/postgresql.conf'
        pghba_conf = '/etc/postgresql/*/main/pg_hba.conf'
    elif 'suse' == distro:
        pgsql_conf = '/var/lib/pgsql/data/postgresql.conf'
        pghba_conf = '/var/lib/pgsql/data/pg_hba.conf'
    else:
        raise Exception, "unknown distro '%s'" % distro

    if not test_is_local():
        output = run_cmd_in_vm (os_vm_ip, 'su - postgres -c \\""(echo anee*z5ui2Sh;echo anee*z5ui2Sh) |createuser --no-superuser --no-createdb --no-createrole --login -P qvd"\\"')
        match = re.search ('already exists', output)
        if match:
            raise Exception, "couldn't create postgresql user: already exists"
        match = re.search ('Passwords didn\'t match.', output)
        if match:
            raise Exception, "couldn't create postgresql user: passwords didn't match"
        match = re.search ('Enter it again:', output)
        if not match:
            raise Exception, "couldn't create postgresql user"
    
        output = run_cmd_in_vm (os_vm_ip, 'su - postgres -c \\""createdb -O qvd qvddb"\\"')
        if output != '':
            raise Exception, "couldn't create database"
    
        output = run_cmd_in_vm (os_vm_ip, 'sed -i -e \\""/listen_addresses = /s/.*/listen_addresses = \'*\'/; /default_transaction_isolation = /s/.*/default_transaction_isolation = \'serializable\'/"\\" %s' % pgsql_conf)
        if output != '':
            raise Exception, "couldn't edit postgresql.conf"
        ## we could do further checks here
    
        output = run_cmd_in_vm (os_vm_ip, 'bash -c \\""echo \'host qvddb qvd %s/24 md5\' >>%s"\\"' % (qvd_host_ip, pghba_conf))
        if output != '':
            raise Exception, "couldn't edit pg_hba.conf"
        ## we could do further checks here
    
    output = run_cmd_in_vm (os_vm_ip, '/etc/init.d/postgresql restart')
    match = re.search ('(?s)Restarting PostgreSQL \S+ database server.*done', output)
    if not match:
        match = re.search ('Shutting down PostgreSQL.*done.*Starting PostgreSQL.*done', output, re.S)
        if not match:
            raise Exception, "couldn't restart postgresql"
    
    if test_is_local():
        output = run_cmd_in_vm (os_vm_ip, '/usr/lib/qvd/bin/perl -Mlib::glob=../ext/*/lib /home/vagrant/ext/QVD-DB/bin/qvd-deploy-db.pl --force')
    else:
        output = run_cmd_in_vm (os_vm_ip, '/usr/lib/qvd/bin/qvd-deploy-db.pl')
    error_lines = output.split ("\n")
    error_lines = [i for i in error_lines if len(i)]
    error_lines = [i for i in error_lines if not re.match('NOTICE:  table "[^"]+" does not exist, skipping', i)]
    error_lines = [i for i in error_lines if not re.match('NOTICE:  CREATE TABLE / (?:PRIMARY KEY|UNIQUE) will create implicit index "[^"]+" for table "[^"]+"', i)]
    error_lines = [i for i in error_lines if not re.match('NOTICE:  CREATE TABLE will create implicit sequence "[^"]+" for serial column "[^"]+"', i)]
    if error_lines:
        print (error_lines)
        raise Exception, "qvd-deploy-db.pl returned unexpected output"

def qvd_setup_ssl(os_vm_ip):
    output = ''
    if test_is_local():
        output = run_cmd_in_vm (os_vm_ip, '/usr/bin/openssl genrsa 1024 > /tmp/server-private-key.pem')
    else:
        output = run_cmd_in_vm (os_vm_ip, 'bash -c \\""openssl genrsa 1024 >/tmp/server-private-key.pem"\\"')
    if not re.search ('e is \d+ \(0x[0-9a-f]+\)', output):
        raise Exception, 'openssl genrsa failed'

    if test_is_local():
        output = run_cmd_in_vm (os_vm_ip, '(echo ES; echo Madrid; echo Madrid; echo "Qindel Group"; echo "QVD Team"; echo qvd.qindel.com; echo qvd@qindel.com) |openssl req -new -x509 -nodes -sha1 -days 60 -key /tmp/server-private-key.pem >/tmp/server-certificate.pem')
    else:
        output = run_cmd_in_vm (os_vm_ip, 'bash -c \\""(echo ES; echo Madrid; echo Madrid; echo \'Qindel Group\'; echo \'QVD Team\'; echo qvd.qindel.com; echo qvd@qindel.com) |openssl req -new -x509 -nodes -sha1 -days 60 -key /tmp/server-private-key.pem >/tmp/server-certificate.pem"\\"')
    if not re.search ('Email Address \[\]:', output):
        raise Exception, 'openssl req failed'

    output = run_qvd_admin (os_vm_ip, 'config ssl key=/tmp/server-private-key.pem cert=/tmp/server-certificate.pem')
    if not re.search ('SSL certificate, private key, ca and crl set\.', output):
        raise Exception, 'config ssl failed'

def qvd_setup_ldap_auth(os_vm_ip, ldap_base, ldap_binddn, ldap_filter, ldap_host, ldap_scope):
    if ldap_base:
        output = run_qvd_admin (os_vm_ip, 'config set auth.ldap.base=%s' % ldap_base)
        if output != '':
            raise Exception, 'config set failed'
    if ldap_binddn:
        output = run_qvd_admin (os_vm_ip, 'config set auth.ldap.binddn=%s' % ldap_binddn)
        if output != '':
            raise Exception, 'config set failed'
    if ldap_filter:
        output = run_qvd_admin (os_vm_ip, 'config set \\""auth.ldap.filter=%s"\\"' % ldap_filter)
        if output != '':
            raise Exception, 'config set failed'
    if ldap_host:
        output = run_qvd_admin (os_vm_ip, 'config set auth.ldap.host=%s' % ldap_host)
        if output != '':
            raise Exception, 'config set failed'
    if ldap_scope:
        output = run_qvd_admin (os_vm_ip, 'config set auth.ldap.scope=%s' % ldap_scope)
        if output != '':
            raise Exception, 'config set failed'

def qvd_set_auth_method(os_vm_ip, auth_method):
    output = run_qvd_admin (os_vm_ip, 'config set l7r.auth.plugins=%s' % auth_method)
    if output != '':
        raise Exception, 'config set failed'
    run_cmd_in_vm (os_vm_ip, '/etc/init.d/qvd-l7r stop')
    time.sleep(1)
    run_cmd_in_vm (os_vm_ip, 'pgrep -lf l7r')
    qvd_run_l7r(os_vm_ip)

def qvd_setup_qvd(os_vm_ip, qvd_network_start_ip, hypervisor, unionfs_type, qvd_use_dhcp):
    run_cmd_in_vm (os_vm_ip, 'bash -c \\"":>/var/log/qvd.log"\\"')

    output = run_qvd_admin (os_vm_ip, 'config set vm.network.ip.start=%s' % qvd_network_start_ip)
    if output != '': raise Exception, 'config set failed'

    output = run_qvd_admin (os_vm_ip, 'config set vm.network.netmask=16')
    if output != '': raise Exception, 'config set failed'

    output = run_qvd_admin (os_vm_ip, 'config set vm.network.gateway=100.10.10.1')
    if output != '': raise Exception, 'config set failed'

    output = run_qvd_admin (os_vm_ip, 'config set vm.network.use_dhcp=%d' % qvd_use_dhcp)
    if output != '': raise Exception, 'config set failed'

    output = run_qvd_admin (os_vm_ip, 'config set vm.hypervisor=%s' % hypervisor)
    if output != '': raise Exception, 'config set failed'

    output = run_qvd_admin (os_vm_ip, 'config set auth.auto.osf_id=1')
    if output != '': raise Exception, 'config set failed'

    output = run_qvd_admin (os_vm_ip, 'config set vm.lxc.unionfs.type=%s' % unionfs_type)
    if output != '': raise Exception, 'config set failed'

    if not test_is_local():
        if 'btrfs' == unionfs_type:
            run_cmd_in_vm (os_vm_ip, 'dd if=/dev/zero of=/root/btrfs.img bs=1M count=5k')
            run_cmd_in_vm (os_vm_ip, 'mkfs.btrfs /root/btrfs.img')
            run_cmd_in_vm (os_vm_ip, 'mount -t btrfs /root/btrfs.img /var/lib/qvd/storage')
            run_cmd_in_vm (os_vm_ip, 'mkdir /var/lib/qvd/storage/{basefs,homes,images,overlayfs,overlays,rootfs,staging}')

def qvd_psql_connectivity(os_vm_ip, qvd_host_ip):
    output = run_cmd_in_vm (os_vm_ip, 'bash -c \\""(echo anee*z5ui2Sh) |psql -U qvd -W -h %s -d qvddb -c \'select 4*4\'"\\"' % qvd_host_ip)
    match = re.search ('16', output)
    if not match:
        raise Exception, 'psql connection/query failed'

def qvd_run_l7r(os_vm_ip):
    output = run_cmd_in_vm (os_vm_ip, '/etc/init.d/qvd-l7r start')
    output = re.compile ("Starting QVD L7R\s+qvd-l7r\n").sub ('', output)     ## suse
    if output:
        raise Exception, "L7R failed to start (non-empty output '%s')" % output
    time.sleep (2)

def qvd_run_hkd(os_vm_ip):
    output = ''
    if test_is_local():
        output = run_cmd_in_vm (os_vm_ip, 'PERL5RUN=-Mlib::glob/home/vagrant/ext/*/lib sudo -E /usr/lib/qvd/bin/perl -Mlib::glob=../ext/*/lib ../ext/QVD-HKD/bin/qvd-hkd')
    else:
        output = run_cmd_in_vm (os_vm_ip, '/etc/init.d/qvd-hkd start')
    output = re.compile ("Starting QVD HKD\s+qvd-hkd\n").sub ('', output)     ## suse
    if output:
        raise Exception, "HKD failed to start (non-empty output '%s')" % output

    time.sleep (20)
    if test_is_local():
        output = run_cmd_in_vm (os_vm_ip, '/usr/lib/qvd/bin/perl -Mlib::glob=../ext/*/lib ../ext/QVD-Admin/bin/qvd-admin.pl host list')
    else:
        output = run_cmd_in_vm (os_vm_ip, '/usr/lib/qvd/bin/qvd-admin.pl host list')
    match = re.search ('running', output)
    if not match:
        output = run_cmd_in_vm (os_vm_ip, 'pgrep -lf qvd-hkd')
        match = re.search ('qvd-hkd', output)
        if match:
            print "HKD is up but the database doesn't show the host as running"
        else:
            print "HKD failed to start"
        run_cmd_in_vm (os_vm_ip, 'tail -n 30 /var/log/qvd.log')
        raise Exception, 'no hosts running after starting hkd'

def qvd_host_add(os_vm_ip, name, host_ip):
    output = run_qvd_admin (os_vm_ip, 'host add name=%s address=%s' % (name, host_ip))
    match = re.search ('Host added with id 1', output)
    if not match:
        raise Exception, 'host add failed'

def qvd_host_del(os_vm_ip, host_name):
    output = run_qvd_admin (os_vm_ip, 'host del -f name=%s' % (host_name))
    match = re.search ('Deleting 1 host\(s\)', output)
    if not match:
        raise Exception, 'host del failed'
    output = run_qvd_admin (os_vm_ip, 'host list')
    match = re.search (host_name, output)
    if match:
        raise Exception, 'host del failed'

def qvd_user_add(os_vm_ip, login, password):
    output = run_qvd_admin (os_vm_ip, 'user add login=%s password=%s' % (login, password))
    match = re.search ('User added with id (\d+)', output)
    if not match:
        raise Exception, 'user add failed'
    qvd_user_id = match.group(1)
    output = run_qvd_admin (os_vm_ip, 'user list')
    match = re.search ('%s +%s' % (qvd_user_id, login), output)
    if not match:
        raise Exception, 'user add failed'

def qvd_search_user(os_vm_ip, username):
    output = run_qvd_admin (os_vm_ip, 'user list -f login=%s' % (username))
    match = re.search (username, output)
    if not match:
        raise Exception, 'user search failed'

def qvd_del_user_having_vm(os_vm_ip, username):
    run_qvd_admin (os_vm_ip, 'user del -f login=%s' % username)
    output = run_qvd_admin (os_vm_ip, 'user list -f login=%s')
    lines = output.split ("\n")[2:-1]
    if len(lines):
        run_qvd_admin (os_vm_ip, 'vm list')   ## just to make the presence/absence of the VM explicit in robotframework's log file
        raise Exception, 'user with running VM was unexpectedly deleted'

def qvd_user_del(os_vm_ip, username):
    run_qvd_admin (os_vm_ip, 'user list -f login=%s' % username)
    output = run_qvd_admin (os_vm_ip, 'user del -f login=%s' % username)
    match = re.search ('Deleting (\d+) user\(s\)', output)
    if not match:
        raise Exception, 'user del failed'

    #num_users = match.group(1)
    output = run_qvd_admin (os_vm_ip, 'user list -f login=%s')
    lines = re.compile("\n").split (output)
    if 3 != len(lines):
        raise Exception, 'user del failed: at least one user still exists'
    #match = re.search (username, output)
    #if match:
    #    raise Exception, 'user del failed'

def qvd_osf_add(os_vm_ip, osf_name):
    output = run_qvd_admin (os_vm_ip, 'osf add name=%s' % (osf_name))
    match = re.search ('OSF added with id (\d+)', output)
    if not match:
        raise Exception, 'osf add failed'
    osf_id = match.group(1)
    output = run_qvd_admin (os_vm_ip, 'osf list')
    match = re.search ('%s +testosf' % osf_id, output)
    if not match:
        raise Exception, 'osf add failed'
    return osf_id

def qvd_osf_del(os_vm_ip, osf_name):
    run_qvd_admin (os_vm_ip, 'osf list -f name=%s' % (osf_name))
    output = run_qvd_admin (os_vm_ip, 'osf del -f name=%s' % (osf_name))
    match = re.search ("Deleting 1 osf\(s\)\n1 OSFs deleted\.", output)
    if not match:
        raise Exception, 'osf del failed'
    output = run_qvd_admin (os_vm_ip, 'osf list')
    match = re.search (osf_name, output)
    if match:
        raise Exception, 'osf del failed'

def qvd_di_add(os_vm_ip, path, osf_id):
    esc_basename = re.escape (os.path.basename (path))
    output = run_qvd_admin (os_vm_ip, 'di add path=%s osf_id=%s' % (path, osf_id))
    match = re.search ('DI added with id (\d+)', output)
    if not match:
        raise Exception, 'di add failed'
    di_id = int (match.group(1))
    output = run_qvd_admin (os_vm_ip, 'di list')
    match = re.search (regex_di_list_1 % (di_id, osf_id, di_id, esc_basename), output)
    if not match:
        raise Exception, 'di add failed'
    match = re.search ('default', output)
    if not match:
        raise Exception, 'di add failed'
    match = re.search ('head', output)
    if not match:
        raise Exception, 'di add failed'
    return di_id

def qvd_di_del(os_vm_ip, di_id):
    output = run_qvd_admin (os_vm_ip, 'di del -f id=%d' % (di_id))
    match = re.search ("Deleting 1 di\(s\)\n1 DIs deleted\.", output)
    if not match:
        raise Exception, 'DI del failed'

def qvd_di_tag(os_vm_ip):
    #output = run_qvd_admin (os_vm_ip, 'di add path=/bin/ls osf_id=1')
    #match = re.search ('DI added with id (\d+)', output)
    #if not match:
    #    raise Exception, 'DI add failed'
    #di_id = int (match.group(1))
    di_id = qvd_di_add (os_vm_ip, '/bin/ls', 1)

    output = run_qvd_admin (os_vm_ip, 'di tag tag=default di_id=%d' % (di_id))
    match = re.search ('DI tagged', output)
    if not match:
        raise Exception, 'DI tag failed'

    output = run_qvd_admin (os_vm_ip, 'di list')
    match = re.search (regex_di_list_2, output, re.M)
    if not match:
        raise Exception, "DI 1 has tags it shouldn't"
    match = re.search (regex_di_list_3 % (di_id, di_id), output, re.M)
    if not match:
        raise Exception, "DI %d hasn't the default tag" % di_id
    match = re.search (regex_di_list_4 % (di_id, di_id), output, re.M)
    if not match:
        raise Exception, "DI %d hasn't the head tag" % di_id

    qvd_di_del (os_vm_ip, di_id)

    ## after deleting DI with head and default tags, they move back to di_id 1
    output = run_qvd_admin (os_vm_ip, 'di list')
    match = re.search (regex_di_list_5, output, re.M)
    if not match:
        raise Exception, "DI 1 hasn't the default tag"
    match = re.search (regex_di_list_6, output, re.M)
    if not match:
        raise Exception, "DI 1 hasn't the head tag"

def qvd_vm_add(os_vm_ip, vm_name, user, osf_id):
    output = run_qvd_admin (os_vm_ip, 'vm add name=%s user=%s osf_id=%s' % (vm_name, user, osf_id))
    match = re.search ('VM added with id (\d+)', output)
    if not match:
        raise Exception, 'vm add failed'
    qvd_vm_id = match.group(1)
    output = run_qvd_admin (os_vm_ip, 'vm list')
    match1 = re.search (regex_vm_list_1 % (qvd_vm_id, vm_name, user), output)
    match2 = re.search (regex_vm_list_2 % (qvd_vm_id, vm_name, user), output)
    if not match1 and not match2:
        raise Exception, 'vm add failed'
    run_qvd_admin (os_vm_ip, 'vm list')
    return qvd_vm_id

def _wait_vm_started(os_vm_ip, vm_name, num_vms=1):
    starting=0
    running=0
    for i in range (25*8):
        starting=0
        running=0
        time.sleep (10)
        output = run_qvd_admin (os_vm_ip, 'vm list -f name=%s' % vm_name)
        lines = output.split ("\n")[2:-1]
        if num_vms != len(lines):
            raise Exception, "vm start failed: expect %d VMs starting, only got %d" % (num_vms, len(lines))

        for line in lines:
            print "line '%s'" % line
            match = re.search (regex_vm_list_3, line)
            if not match:
                raise Exception, 'vm start failed'
            vm_state = match.group(1)
            if vm_state == 'running':
                print "this one's running"
                running+=1
            elif vm_state == 'starting':
                print "this one's starting"
                starting+=1

        if 0 == starting:
            print "no VMs starting"
            break
        else:
            print "still %d VMs starting" % starting

    if num_vms == running:
        print "%d VMs running, good" % running
        return

    run_cmd_in_vm (os_vm_ip, 'tail -n 60 /var/log/qvd.log')
    if starting:
        raise Exception, 'vm start failed: at least one VM took too long to start'
    raise Exception, 'vm start failed: only %d VMs running, expected %d' % (running, num_vms)
    #if vm_state != 'running':
    #    raise Exception, "vm start failed, vm_state isn't 'running' but '%s'" % vm_state

def qvd_vm_start(os_vm_ip, vm_name):
    output = run_qvd_admin (os_vm_ip, 'vm start -f name=%s' % (vm_name))
    match = re.search ('Started (\d+) VMs\.', output)
    if not match:
        run_cmd_in_vm (os_vm_ip, 'grep -w -B 15 -A 5 ERROR /var/log/qvd.log')
        raise Exception, 'vm start failed'

    num_vms = int(match.group(1))
    if 0 == num_vms:
        run_cmd_in_vm (os_vm_ip, 'grep -w -B 15 -A 5 ERROR /var/log/qvd.log')
        raise Exception, 'vm start failed: 0 VMs started according to qvd-admin'

    time.sleep (2)
    _wait_vm_started (os_vm_ip, vm_name, num_vms)

def _wait_vm_stopped(os_vm_ip, vm_name, num_vms=1):
    stopping=0
    stopped=0
    for i in range (20*8):
        stopping=0
        stopped=0
        time.sleep (10)
        output = run_qvd_admin (os_vm_ip, 'vm list -f name=%s' % vm_name)
        lines = output.split ("\n")[2:-1]
        if num_vms != len(lines):
            raise Exception, "vm stop failed: expect %d VMs stopping, only got %d" % (num_vms, len(lines))

        for line in lines:
            #print "line '%s'" % line
            match = re.search (regex_vm_list_4, line)
            if not match:
                raise Exception, 'vm stop failed'
            vm_state = match.group(1)
            #print "vm_state '%s'" % vm_state
            if vm_state == 'stopping':
                #print "this one's stopping"
                stopping+=1
            elif vm_state == 'stopped':
                #print "this one's stopped"
                stopped+=1

        if 0 == stopping:
            #print "no VMs stopping"
            break
        #else:
        #    print "still %d VMs stopping" % stopping

    if num_vms == stopped:
        #print "%d VMs stopped, good" % stopped
        return

    run_cmd_in_vm (os_vm_ip, 'tail -n 60 /var/log/qvd.log')
    if stopping:
        raise Exception, 'vm stop failed: at least one VM took too long to stop'
    raise Exception, 'vm stop failed: only %d VMs stopped, expected %d' % (stopped, num_vms)
    #if vm_state != 'stopped':
    #    raise Exception, 'vm stop failed'

def qvd_vm_stop(os_vm_ip, vm_name):
    vm_ids=[]
    output = run_qvd_admin (os_vm_ip, 'vm list -f name=%s' % vm_name)
    lines = output.split ("\n")[2:-1]
    for line in lines:
        ## bug: hay q quitar/quotear lo de vm_name de aqui, pues puede tener wildcards
        match = re.search ('^\s*(\d+)\s+%s' % vm_name, line)
        if not match:
            raise Exception, 'error obtaining vm_id for vm %s' % vm_name    ## bug: vm_name puede tener wildcards, este error no determina la vm exacta
        vm_ids.append (int (match.group(1)))

    output = run_qvd_admin (os_vm_ip, 'vm stop -f name=%s' % (vm_name))
    match = re.search ('Stopped (\d+) VMs\.', output)
    if not match:
        raise Exception, 'vm stop failed'
    num_vms=int(match.group(1))

    _wait_vm_stopped (os_vm_ip, vm_name, num_vms)

    output = run_cmd_in_vm (os_vm_ip, 'grep qvd/storage /proc/mounts')    ## bug: use /proc/<hkd's pid>/mountinfo
    still_mounted=0
    for vm_id in vm_ids:
        match = re.search ('aufs /var/lib/qvd/storage/rootfs/%d-fs aufs ' % vm_id, output)
        if match:
            still_mounted+=1
    if still_mounted:
        raise Exception, "some aufs filesystems are still mounted after stopping VMs"

def qvd_vm_block(os_vm_ip, vm_name):
    run_qvd_admin (os_vm_ip, 'vm block -f name=%s' % (vm_name))
    output = run_qvd_admin (os_vm_ip, 'vm list -f name=%s' % (vm_name))

    lines = output.split ("\n")[2:-1]
    for line in lines:
        #print "line '%s'" % line
        fields = re.compile("\s+").split (line)
        #print "fields '%s'" % '-'.join (fields)
        blocked = int (fields[11])
        #print "blocked '%d'" % blocked
        if not blocked:
            raise Exception, 'not all VMs were blocked'

def qvd_vm_unblock(os_vm_ip, vm_name):
    run_qvd_admin (os_vm_ip, 'vm unblock -f name=%s' % (vm_name))
    output = run_qvd_admin (os_vm_ip, 'vm list -f name=%s' % (vm_name))

    lines = output.split ("\n")[2:-1]
    for line in lines:
        #print "line '%s'" % line
        fields = re.compile("\s+").split (line)
        #print "fields '%s'" % '-'.join (fields)
        blocked = int (fields[11])
        #print "blocked '%d'" % blocked
        if blocked:
            raise Exception, 'not all VMs were unblocked'

def qvd_vm_di_tag(os_vm_ip, vm_id, tag):
    output = run_qvd_admin (os_vm_ip, 'vm edit -f id=%s di_tag=%s' % (vm_id, tag))
    match = re.search ('Edited 1 VMs\.', output)
    if not match:
        raise Exception, 'VM edit failed'

    output = run_qvd_admin (os_vm_ip, 'vm list')
    match = re.search ('\s%s\s' % tag, output)
    if not match:
        raise Exception, 'VM edit or list failed'

    output = run_qvd_admin (os_vm_ip, 'vm edit -f id=%s di_tag=default' % vm_id)
    match = re.search ('Edited 1 VMs\.', output)
    if not match:
        raise Exception, 'VM edit failed'

    output = run_qvd_admin (os_vm_ip, 'vm list')
    match = re.search ('\sdefault\s', output)
    if not match:
        raise Exception, 'VM edit or list failed'

def qvd_vm_del(os_vm_ip, vm_name):
    run_qvd_admin (os_vm_ip, 'vm list -f name=%s' % (vm_name))
    output = run_qvd_admin (os_vm_ip, 'vm del -f name=%s' % (vm_name))
    match = re.search ('Deleting (\d+) vm\(s\)', output)
    if not match:
        raise Exception, 'vm del failed'
    num_deleted = match.group(1)
    if 0 == num_deleted:
        raise Exception, 'vm del failed: 0 VMs deleted'

    output = run_qvd_admin (os_vm_ip, 'vm list -f name=%s' % vm_name)
    lines = re.compile("\n").split (output)
    if 3 != len(lines):
        raise Exception, 'vm del failed: at least one VM still exists'

def qvd_vm_running_ok(os_vm_ip, vm_name):
    output = run_qvd_admin (os_vm_ip, 'vm list -f name=%s' % vm_name)
    match = re.search (' %s .* running ' % vm_name, output)
    if not match:
        raise Exception, 'vm is not running failed'

def qvd_cfg_props(os_vm_ip):
    for obj in 'host', 'vm', 'user', 'osf', 'di':
        output = run_qvd_admin (os_vm_ip, '%s propset foo=bar' % (obj))
        match = re.search ('propset in 1 ', output)
        if not match:
            raise Exception, '%s propset failed' % obj

        output = run_qvd_admin (os_vm_ip, '%s propget' % (obj))
        match = re.search ('\sfoo=bar', output)
        if not match:
            raise Exception, 'either %s propset or propget failed' % obj
        lines = re.compile("\n").split (output)
        if 1 != len(lines)-1:
            raise Exception, "propget doesn't return exactly one line"

        output = run_qvd_admin (os_vm_ip, '%s propset foo=baz' % (obj))
        match = re.search ('propset in 1 ', output)
        if not match:
            raise Exception, '%s propset failed' % obj

        output = run_qvd_admin (os_vm_ip, '%s propget' % (obj))
        match = re.search ('\sfoo=baz', output)
        if not match:
            raise Exception, 'either %s propset or propget failed' % obj
        lines = re.compile("\n").split (output)
        if 1 != len(lines)-1:
            raise Exception, "propget doesn't return exactly one line"

        #output = run_cmd_in_vm (os_vm_ip, 'bash -c \\""echo y |/usr/lib/qvd/bin/qvd-admin.pl %s propdel foo"\\"' % (obj))
        output = run_qvd_admin (os_vm_ip, '--force %s propdel foo' % (obj))
        #match = re.search ('Are you sure you want to delete the prop in all ', output)
        #if not match:
        #    raise Exception, '%s propdel failed' % obj

        output = run_qvd_admin (os_vm_ip, '%s propget' % (obj))
        match = re.search ('foo', output)
        if match:
            raise Exception, 'either %s propdel or propget failed' % obj

    output = run_qvd_admin (os_vm_ip, 'config set foo=bar')
    if output != '':
        raise Exception, 'config set failed'

    output = run_qvd_admin (os_vm_ip, 'config get foo')
    match = re.search ('foo=bar', output)
    if not match:
        raise Exception, 'either config set or get failed' % obj

    output = run_qvd_admin (os_vm_ip, 'config set foo=baz')
    if output != '':
        raise Exception, 'config set failed'

    output = run_qvd_admin (os_vm_ip, 'config get foo')
    match = re.search ('foo=baz', output)
    if not match:
        raise Exception, 'either config set or get failed' % obj

    output = run_qvd_admin (os_vm_ip, 'config del foo')
    match = re.search ('1 config entries deleted\.', output)
    if not match:
        raise Exception, 'config del failed' % obj

    output = run_qvd_admin (os_vm_ip, 'config get foo')
    match = re.search ('foo', output)
    if match:
        raise Exception, 'either config del or set failed'

def qvd_wat_smoke(os_vm_ip):
    ## TODO: restore this to something sane
    output = ''
    if test_is_local():
        output = run_cmd_in_vm (os_vm_ip, 'bash -c "(echo GET / HTTP/1.0; echo)" |netcat localhost 3000 |head -n 1')
        time.sleep (2)
        output = run_cmd_in_vm (os_vm_ip, 'bash -c "(echo GET / HTTP/1.0; echo)" |netcat localhost 3000 |head -n 1')
        time.sleep (2)
        output = run_cmd_in_vm (os_vm_ip, 'bash -c "(echo GET / HTTP/1.0; echo)" |netcat localhost 3000 |head -n 1')
        time.sleep (2)
        output = run_cmd_in_vm (os_vm_ip, 'bash -c "(echo GET / HTTP/1.0; echo)" |netcat localhost 3000 |head -n 1')
    else:
        output = run_cmd_in_vm (os_vm_ip, 'bash -c \\""(echo "GET / HTTP/1.0"; echo) |netcat localhost 3000 |head -n 1"\\"')
        time.sleep (2)
        output = run_cmd_in_vm (os_vm_ip, 'bash -c \\""(echo "GET / HTTP/1.0"; echo) |netcat localhost 3000 |head -n 1"\\"')
        time.sleep (2)
        output = run_cmd_in_vm (os_vm_ip, 'bash -c \\""(echo "GET / HTTP/1.0"; echo) |netcat localhost 3000 |head -n 1"\\"')
        time.sleep (2)
        output = run_cmd_in_vm (os_vm_ip, 'bash -c \\""(echo "GET / HTTP/1.0"; echo) |netcat localhost 3000 |head -n 1"\\"')
    match = re.search ('HTTP/1.1 200 OK', output)
    if not match:
        raise Exception, "qvd-wat doesn't respond with HTTP 200"

def qvd_daemons_logging(os_vm_ip):
    if test_is_local():
        run_cmd_in_vm (os_vm_ip, 'bash -c "(echo GET /qvd/ping HTTP/1.1; echo Host: localhost; echo)" |socat - OPENSSL:localhost:8443,verify=0')
    else:
        run_cmd_in_vm (os_vm_ip, 'bash -c \\""(echo "GET /qvd/ping HTTP/1.1"; echo "Host: localhost"; echo) |socat - OPENSSL:localhost:8443,verify=0"\\"')
    ts = time.strftime ('%Y/%m/%d')

    if test_is_local():
        output = run_cmd_in_vm (os_vm_ip, 'grep "^%s .*/QVD/HTTPD\.pm.*processing.request.GET./qvd/ping.HTTP/1\.1" /var/log/qvd.log' % ts)
    else:
        output = run_cmd_in_vm (os_vm_ip, 'grep \\""^%s .*/QVD/HTTPD\.pm.*processing.request.GET./qvd/ping.HTTP/1\.1"\\" /var/log/qvd.log' % ts)
    if not output:
        raise Exception, 'L7R is not writing to the log file'

    if test_is_local():
        output = run_cmd_in_vm (os_vm_ip, 'grep "^%s .*QVD/HKD" /var/log/qvd.log' % ts)
    else:
        output = run_cmd_in_vm (os_vm_ip, 'grep \\""^%s .*QVD/HKD"\\" /var/log/qvd.log' % ts)
    if not output:
        raise Exception, 'HKD is not writing to the log file'

def _run_xorg(os_vm_ip):
    run_cmd_in_vm (os_vm_ip, 'pgrep -lf Xorg')
    run_cmd_in_vm (os_vm_ip, 'pkill -f Xorg')
    time.sleep(2)
    run_cmd_in_vm (os_vm_ip, 'pgrep -lf Xorg')
    run_cmd_in_vm (os_vm_ip, 'bash -c \\""Xorg &"\\" </dev/null &>/dev/null')
    time.sleep(1)
    run_cmd_in_vm (os_vm_ip, 'pgrep -lf Xorg')

def _kill_xorg(os_vm_ip):
    run_cmd_in_vm (os_vm_ip, 'pkill -f Xorg')
    time.sleep(2)
    run_cmd_in_vm (os_vm_ip, 'pgrep -lf Xorg')

def run_gui_tests(os_vm_ip, user, passwd, host):
    run_cmd_in_vm (os_vm_ip, 'rm -rf /root/.qvd')
    run_cmd_in_vm (os_vm_ip, 'mkdir -p /root/.qvd/certs')
    _run_xorg (os_vm_ip)
    output = run_cmd_in_vm (os_vm_ip, 'DISPLAY=:0 /root/x11-gui-test.pl -u %s -p %s -h %s' % (user, passwd, host))
    for testnum in range(1,9):
        match = re.search ('^ok %d - ' % testnum, output, re.M)
        if not match:
            raise Exception, "client gui tests: test %d failed" % testnum
    _kill_xorg (os_vm_ip)

def run_disconnect_test(os_vm_ip, vm_name, user, password):
    _run_xorg (os_vm_ip)
    run_cmd_in_vm (os_vm_ip, 'bash -c \\""echo y | DISPLAY=:0 /usr/lib/qvd/bin/perl /usr/lib/qvd/bin/qvd-client.pl %s %s localhost &>/tmp/qc &"\\"' % (user, password))
    output = run_cmd_in_vm (os_vm_ip, 'pgrep -lf qvd-client')
    match = re.search ('qvd-client', output)
    if not match:
        run_cmd_in_vm (os_vm_ip, 'cat /tmp/qc')
        raise Exception, 'client has died'
    _wait_vm_started (os_vm_ip, vm_name)

    output = run_qvd_admin (os_vm_ip, 'vm list -f name=%s' % vm_name)
    match = re.search (regex_vm_list_5 % (vm_name, user), output)
    if not match:
        raise Exception, 'user is not connected to the VM'

    run_qvd_admin (os_vm_ip, 'vm disconnect_user -f name=%s' % vm_name)
    time.sleep(180)          ## anything between 10-45 seconds seems to be required
    output = run_cmd_in_vm (os_vm_ip, 'pgrep -lf qvd-client')
    match = re.search ('qvd-client', output)
    if match:
        print "*WARN* qvd-client is still running when it should have exited\n"

    output = run_qvd_admin (os_vm_ip, 'vm list')
    match = re.search (regex_vm_list_6 % (vm_name, user), output)
    if not match:
        raise Exception, 'user has not been disconnected from the VM'

    _kill_xorg (os_vm_ip)

def _get_qvd_vm_ip(os_vm_ip, vm_name):
    output = run_qvd_admin (os_vm_ip, 'vm list -f name=%s' % vm_name)
    match = re.search (regex_vm_list_7 % vm_name, output)        #'5 sess_kept sess_kept_user - 10.69.255.253 testosf default 2013-10-24-000 - stopped disconnected 0 - -'

    if not match:
        raise Exception, 'no running VM with name %s' % vm_name
    qvd_vm_ip = match.group(1)
    match = re.search ('\d+\.\d+\.\d+\.\d+', qvd_vm_ip)
    if not match:
        raise Exception, "QVD VM IP '%s' doesn't look like an IP" % qvd_vm_ip
    return qvd_vm_ip

def run_session_kept_test(os_vm_ip, vm_name, user, password):
    _run_xorg (os_vm_ip)

    run_cmd_in_vm (os_vm_ip, 'bash -c \\""echo y | DISPLAY=:0 /usr/lib/qvd/bin/perl /usr/lib/qvd/bin/qvd-client.pl %s %s localhost &>/tmp/qc &"\\"' % (user, password))
    output = run_cmd_in_vm (os_vm_ip, 'pgrep -lf qvd-client')
    match = re.search ('qvd-client', output)
    if not match:
        run_cmd_in_vm (os_vm_ip, 'cat /tmp/qc')
        raise Exception, 'client has died'
    _wait_vm_started (os_vm_ip, vm_name)

    qvd_vm_ip = _get_qvd_vm_ip (os_vm_ip, vm_name)
    run_cmd_in_vm (os_vm_ip, 'ssh -o StrictHostKeyChecking=no root@%s touch /tmp/qvd-reconnect-test' % qvd_vm_ip)

    run_qvd_admin (os_vm_ip, 'vm disconnect_user -f name=%s' % vm_name)
    time.sleep(180)          ## anything between 10-45 seconds seems to be required
    output = run_cmd_in_vm (os_vm_ip, 'pgrep -lf qvd-client')
    match = re.search ('qvd-client', output)
    if match:
        print "*WARN* qvd-client is still running when it should have exited\n"

    run_cmd_in_vm (os_vm_ip, 'bash -c \\""echo y | DISPLAY=:0 /usr/lib/qvd/bin/perl /usr/lib/qvd/bin/qvd-client.pl %s %s localhost &>/tmp/qc &"\\"' % (user, password))
    run_cmd_in_vm (os_vm_ip, 'pgrep -lf qvd-client')
    #_wait_vm_started (os_vm_ip, vm_name)     ## not needed in theory

    output = run_cmd_in_vm (os_vm_ip, 'ssh -o StrictHostKeyChecking=no root@%s ls /tmp/qvd-reconnect-test' % qvd_vm_ip)
    match = re.search ('qvd-reconnect-test$', output)
    if not match:
        raise Exception, 'temp file is not there'

    qvd_vm_stop (os_vm_ip, vm_name)
    qvd_vm_start (os_vm_ip, vm_name)

    output = run_cmd_in_vm (os_vm_ip, 'ssh -o StrictHostKeyChecking=no root@%s ls /tmp/qvd-reconnect-test' % qvd_vm_ip)
    match = re.search ('qvd-reconnect-test$', output)
    if match:
        raise Exception, 'temp file is still there after restarting the vm'

    _kill_xorg (os_vm_ip)

def qvd_new_node(os_full_reset, os_img, os_img_name, os_vm_name, sources_list, qvd_host_name, qvd_host_ip, qvd_user_name, qvd_user_pass, qvd_osf_name, qvd_di_path, qvd_vm_name, qvd_hypervisor, unionfs_type, qvd_use_dhcp, pkgs1='', pkgs2='', all_pkgs=''):
    ROBOT_EXIT_ON_FAILURE = True
    os_full_reset = int(os_full_reset)
    qvd_use_dhcp = int(qvd_use_dhcp)

    ## no trinary 'foo ? bar : baz' operator in python. This makes me weep
    if test_is_local():
        print 'test is local'
    else:
        print 'test is not local'
    print "os_full_reset: ", os_full_reset
    print "os_img: ", os_img
    print "os_img_name: ", os_img_name
    print "os_vm_name: ", os_vm_name
    print "sources_list: ", sources_list
    print "qvd_host_name: ", qvd_host_name
    print "qvd_host_ip: ", qvd_host_ip
    print "qvd_user_name: ", qvd_user_name
    print "qvd_user_pass: ", qvd_user_pass
    print "qvd_osf_name: ", qvd_osf_name
    print "qvd_di_path: ", qvd_di_path
    print "qvd_vm_name: ", qvd_vm_name

    if not test_is_local():
        if 1 == os_full_reset:
            if not os.access(os_img, os.F_OK):
                raise Exception, '%s: No such file or directory' % qvd_di_path
        if not os.access(qvd_di_path, os.F_OK):
            raise Exception, '%s: No such file or directory' % qvd_di_path

    ## qvd_network_start_ip = qvd_host_ip + 1, ignore overflow
    p=re.compile('^(.*\.)(\d+)$')
    m=p.match(qvd_host_ip)
    qvd_network_start_ip = m.group(1) + str (1+int(m.group(2)))

    if not test_is_local():
        sanity()

    os_vm_id=''
    os_vm_ip=''
    distro=''

    if not test_is_local():
        if 1 == os_full_reset:
            os_cleanup(os_vm_name, os_img_name)
            os_img_id = os_glance_image (os_img, os_img_name)
            os_vm_id = os_nova_boot (os_img_id, os_vm_name)
            os_vm_ip = os_vm_id2ip (os_vm_id)
            distro = detect_distro (os_vm_ip)
        else:
            try:
                os_vm_id = re.findall ('[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}', run_cmd('nova list --name %s' % os_vm_name))[0]
            except:
                raise Exception, "openstack node '%s' doesn't exist, you must pass --os-full-reset 1" % os_vm_name
            os_vm_ip = os_vm_id2ip (os_vm_id)
            distro = detect_distro (os_vm_ip)
            if '' != pkgs1: set_install_pkgs_1 (distro, pkgs1)
            if '' != pkgs2: set_install_pkgs_2 (distro, pkgs2)
            if '' != all_pkgs: set_all_pkgs (distro, all_pkgs)
            os_quick_cleanup(os_vm_id)
    else:
        distro = detect_distro (os_vm_ip)

    if not test_is_local():
        qvd_install_1 (os_vm_ip, distro, qvd_host_name, qvd_host_ip, sources_list)
        upload_gui_tests (os_vm_ip)

    qvd_setup_db (os_vm_ip, distro, qvd_host_ip)

    if not test_is_local():
        qvd_install_2 (os_vm_ip, distro)
    else:
        run_cmd_in_vm (os_vm_ip, '/etc/init.d/apache2 restart')

    qvd_setup_ssl (os_vm_ip)
    qvd_setup_qvd (os_vm_ip, qvd_network_start_ip, qvd_hypervisor, unionfs_type, qvd_use_dhcp)

    if not test_is_local():
        run_cmd_in_vm (os_vm_ip, 'mkdir -p /var/lib/qvd/storage/staging')
        run_cmd ('scp -o StrictHostKeyChecking=no %s root@%s:/var/lib/qvd/storage/staging' % (qvd_di_path, os_vm_ip))
    qvd_di_path = '/var/lib/qvd/storage/staging/%s' % os.path.basename (qvd_di_path)
    run_cmd_in_vm (os_vm_ip, 'find /var/lib/qvd -maxdepth 3')

    qvd_host_add (os_vm_ip, qvd_host_name, qvd_host_ip)
    qvd_run_l7r (os_vm_ip)
    qvd_run_hkd (os_vm_ip)
    qvd_user_add (os_vm_ip, qvd_user_name, qvd_user_pass)
    osf_id = qvd_osf_add (os_vm_ip, qvd_osf_name)
    di_id = qvd_di_add (os_vm_ip, qvd_di_path, osf_id)
    qvd_vm_id = qvd_vm_add (os_vm_ip, qvd_vm_name, qvd_user_name, osf_id)
    return os_vm_ip, qvd_vm_id, di_id, osf_id
