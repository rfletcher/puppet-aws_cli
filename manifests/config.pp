# == Class: aws_cli::config
#
# Set user-specific AWS CLI configuration
#
# === Parameters
#
# [*ensure*]
#   present, absent
#
# [*home_dir*]
#   The home dir of the user who's config will be updated. Defaults to
#   "/home/${title}".
#
# [*access_key*]
#   Your AWS access key
#
# [*secret*]
#   Your AWS secret key
#
# [*token*]
#   Your AWS token (temporary credentials)
#
# [*output*]
#   The default output format: json, table, text
#
# [*region*]
#   The default region: us-east-1, etc.
#
# === Examples
#
#  aws::config { 'rick':
#    access_key => 'asdf',
#    secret     => 'shhhhhhh...',
#  }
#
# === Authors
#
# Rick Fletcher <fletch@pobox.com>
#
# === Copyright
#
# Copyright 2014 Rick Fletcher
#
define aws_cli::config (
  $ensure     = present,

  $home_dir   = "/home/${title}",

  $access_key = undef,
  $secret     = undef,
  $token      = undef,

  $output     = undef,
  $region     = undef,
) {
  $config_path = "${home_dir}/.aws/config"
  $config_dir = dirname( $config_path )

  file { $config_path:
    ensure => $ensure,
    owner  => $title,
    group  => $title,
    mode   => '0600',
  }

  file { $config_dir:
    ensure  => $ensure ? { 'present' => directory, default => $ensure },
    owner   => $title,
    group   => $title,
    mode    => '0600',
    recurse => true,
    require => File[$config_path],
  }

  if $ensure == 'present' {
    Ini_setting {
      path    => $config_path,
      section => 'default',
      require => File[$config_path],
    }

    exec { "mkdir -p ${config_dir}":
      creates => $config_dir,
      before  => File[$config_path],
    }

    ini_setting { "$config_path default/aws_access_key_id":
      ensure  => $access_key ? { undef => 'absent', default => 'present' },
      setting => 'aws_access_key_id',
      value   => $access_key,
    }

    ini_setting { "$config_path default/aws_secret_access_key":
      ensure  => $secret ? { undef => 'absent', default => 'present' },
      setting => 'aws_secret_access_key',
      value   => $secret,
    }

    ini_setting { "$config_path default/aws_security_token":
      ensure  => $token ? { undef => 'absent', default => 'present' },
      setting => 'aws_security_token',
      value   => $token,
    }

    ini_setting { "$config_path default/output":
      ensure  => $output ? { undef => 'absent', default => 'present' },
      setting => 'output',
      value   => $output,
    }

    ini_setting { "$config_path default/region":
      ensure  => $region ? { undef => 'absent', default => 'present' },
      setting => 'region',
      value   => $region,
    }
  }
}
