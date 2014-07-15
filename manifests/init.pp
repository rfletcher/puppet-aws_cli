# == Class: aws_cli
#
# Installs (or removes) AWS command line tools
#
# === Parameters
#
# [*ensure*]
#   present, latest, absent
#
# [*access_key*]
#   A global AWS access key
#
# [*secret*]
#   A global AWS secret key
#
# [*token*]
#   A global AWS token (temporary credentials)
#
# [*output*]
#   The default output format: json, table, text
#
# [*region*]
#   The default region: us-east-1, etc.
#
# === Examples
#
#  class { 'aws_cli':
#    ensure => present,
#    output => 'text',
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
class aws_cli (
  $ensure     = present,

  $access_key = undef,
  $secret     = undef,
  $token      = undef,

  $output     = undef,
  $region     = undef,
) {
  class { 'python':
    pip => true,
  }

  python::pip { 'awscli':
    ensure  => $ensure,
    require => Class['python'],
  }

  $file_ensure = $ensure ? {
    absent  => absent,
    purged  => absent,
    default => present,
  }

  file { '/etc/profile.d/aws.sh':
    ensure  => $file_ensure,
    content => template('aws_cli/aws.sh.erb'),
    mode    => '0644',
  }
}
