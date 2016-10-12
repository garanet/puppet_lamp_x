# puppet_lamp_x
Puppet Module to install Lamp on CentOS and Ubuntu machines.

In Puppet we have chances to install modules like LAMP or services like mysql-server or ntpd, this puppet module does it.

Tested on:
Server - Ubuntu 16.04.1 LTS - 192.168.0.200/24 - PuppetMaster 3.8.5

On the Puppet Server machine:

cd /etc/puppet/modules/

git clone https://github.com/garanet/puppet_lamp_x.git

echo node default { include lamp } >> manifests/site.pp

sudo service puppetmaster restart

On the Clients:

Client Centos 3.10.0-327.el7.x86_64

/opt/puppetlabs/bin/puppet agent —test —noop

Client Ubuntu 14.04.1:

puppet agent --test —noop

Now via browser you should see the PHPINFO page from the client.

Remember, you can install more and more modules from puppet or git community (that’s the best part of opensource), like :

puppet module install puppetlabs-mysql
puppet module install saz/ntp
