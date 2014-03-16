define apache::ssl {
  apache::module { 'ssl':
  }

  file { '/etc/apache2/certs':
    ensure => directory,
    owner  => root,
  }

  file { '/etc/apache2/certs/ssl.ca':
    ensure => absent,
    owner  => root,
    group  => root,

    require => File['/etc/apache2/certs'],
  }

  # This refers to https://www.startssl.com/?app=21 (Apache with StartSSL)
  file { '/etc/apache2/certs/ca.pem':
    ensure => present,
    source => 'puppet:///modules/apache/certs/ca.pem',
    owner  => root,
    group  => root,

    require => File['/etc/apache2/certs'],
  }

  file { '/etc/apache2/certs/sub.class1.server.ca.pem':
    ensure => present,
    source => 'puppet:///modules/apache/certs/sub.class1.server.ca.pem',
    owner  => root,
    group  => root,

    require => File['/etc/apache2/certs'],
  }
}
