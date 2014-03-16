class xerl (
  $user_password,
  $user = 'xerl',
) {

  conf_user::create { "${user}_name":
    user_name       => $user,
    has_public_html => true,
    password        => $user_password,
  }

  class { 'xerl::directories':
    require => Conf_user::Create["${user}_name"]
  }

  class { 'xerl::application':
    require => Class['xerl::directories'],
  }

  class { 'xerl::cron':
    require => Class['xerl::directories'],
  }
}

