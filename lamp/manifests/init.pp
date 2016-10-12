# 20160724 - PUPPET LAMP MODULE 
# https://github.com/garanet/puppet_lamp_x.git
# Gabriele Gatto - www.garanet.net
# Class: lamp

class lamp($version='latest') {	
  case $::operatingsystem {
    debian, ubuntu: {
      $osfound = true
      $apache = ['apache2']
      $apache_srv = 'apache2'
      $apache_conf = '/etc/apache2/apache2.conf'
      $php = ['php5', 'php5-mysql', 'libapache2-mod-php5']
      $mysql = ['mysql-server', 'libapache2-mod-auth-mysql']
      $mysql_srv = 'mysql'
      $mysql_conf = '/etc/mysql/my.cnf'
      $userdir_cmd = '/usr/sbin/a2enmod userdir'
      $mysqlpw_cmd = '/usr/bin/mysqladmin -u root password CHANGEME || /bin/true'
      $sysconfig_conf = '/tmp/hng'
      $init_cmd = '/sbin/initctl reload-configuration'
      $rm_html = '/var/www/html/index.html'
      $www = '/var/www/html/index.php'
      $selinux = false
    }
    centos, linux: {
      $osfound = true
      $apache = ['httpd', 'httpd-devel']
      $apache_srv = 'httpd'
      $apache_conf = '/etc/httpd/conf/httpd.conf'
      $php = ['php', 'php-mysql', 'php-common', 'php-gd', 'php-mbstring', 'php-devel', 'php-xml']
      $mysql = ['mysql-server', 'mysql', 'mysql-devel']
      $mysql_srv = 'mysqld'
      $mysql_conf = '/etc/my.cnf'
      $userdir_cmd = '/bin/true'
      $mysqlpw_cmd = '/bin/true'
      $init_cmd = '/bin/true'
      $sysconfig_conf = '/etc/sysconfig/httpd'
      $www = '/var/www/html/index.php'
      $selinux = '/etc/sysconfig/selinux'
    }
    default: {
      fail("Sorry, this module isn't supported on ${operatingsystem}")
    }
  }
	
  if ($osfound) {
    Package { ensure => $version, }
    File { owner => 'root', group => 'root', mode => '0644', }	
    package { $apache: }
    
    service { $apache_srv:
      ensure  => running,
      enable  => true,
      require => Package[$apache],
    }

    file { $apache_conf:
      ensure  => present,
      source  => "puppet:///modules/lamp/apache2/apache2.${operatingsystem}.conf",
      require => Package[$apache],
      notify  => Service[$apache_srv],
    }

    file { $www:
      ensure  => present,
      source  => 'puppet:///modules/lamp/www/index.php',
      require => [Package[$apache], Package[$php]],
      notify  => Service[$apache_srv],
    }

    file { $rm_html:
      ensure => absent,
     }
    
   file { $sysconfig_conf:
      ensure  => present,
      source  => "puppet:///modules/lamp/sysconfig/httpd.${operatingsystem}",
      require => Package[$apache],
      notify  => Service[$apache_srv],
    }

    exec { 'userdir':
      notify  => Service[$apache_srv],
      command => $userdir_cmd,
      require => Package[$apache],
    }

    package { $php: require => Package[$apache], }
    package { $mysql: require => Package[$php], }
    service { $mysql_srv:
      ensure    => running,
      enable    => true,
      require   => Package[$mysql], 
    }

    file { $mysql_conf:
      ensure  => present,
      source  => "puppet:///modules/lamp/mysql/my.${operatingsystem}.cnf",
        require => Package[$mysql],
      notify  => Service[$mysql_srv],
    }
   
    exec { 'initcmd':
      command => $init_cmd,
      require => Service[$mysql_srv],
    }

    exec { 'mysqlpasswd':
      command => $mysqlpw_cmd,
      onlyif  => $init_cmd,
      require => Package[$apache],
    }
 # MANAGE SELINUX
	if ($selinux) {
	    file { $selinux:
		 ensure => present,
		 }
	    file_line { 'SELINUX':
	    path => '/etc/sysconfig/selinux',
	    line => 'SELINUX=permissive',
	    match => "^SELINUX.*$",
     	   }
	}
  }
}
