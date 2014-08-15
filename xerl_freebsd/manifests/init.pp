class xerl_freebsd (
  $ensure = present,
  $user = 'www',
  $document_root = '/usr/local/www/apache24/data',
  $giturl = 'git://git.buetow.org/xerl',
) {
  $xerl_root = "${document_root}/xerl"
  $cache_root = '/var/cache/xerl'
  $hosts_root = '/var/run/xerl'

  case $ensure {
    present: { 
      $ensure_directory = directory
      file { $document_root:
        ensure  => directory,
        owner   => $user,
        group   => $user,
      }
    }
    absent: { 
      $ensure_directory = absent
      file { $xerl_root:
        ensure  => absent,
        purge   => true,
      }
    }
  }

  file { [$cache_root, $hosts_root]:
    ensure => $ensure_directory,
    purge  => true,
    owner  => $user,
    group  => $user,
  }

  if $ensure == present {
    class { 'xerl_freebsd::checkout':
      user       => $user,
      xerl_root  => $xerl_root,
      hosts_root => $hosts_root,
      giturl     => $giturl,

      require => File['/var/run/xerl'],
    }

    file { "${xerl_root}/xerl-${::fqdn}.conf":
      ensure  => file,
      content => template('xerl/xerl.conf.erb'),
      owner   => $user,
      group   => $user,
      mode    => '0400',

      require => Class['xerl_freebsd::checkout']
    }
  }

  cron { 'xerl_hosts_pull':
    ensure  => $ensure,
    hour    => '*',
    minute  => '23',
    user    => $user,
    command => "/bin/test -d ${xerl_root} && cd ${xerl_root} && /usr/local/bin/git pull >/dev/null 2>/dev/null"
  }

  cron { 'xerl_clean_cache':
    ensure  => $ensure,
    hour    => '*',
    minute  => '24',
    user    => $user,
    command => "/bin/test -d /var/cache/xerl && /bin/rm -Rf /var/cache/xerl/*"
  }
}

