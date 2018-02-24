# == Define: ohmyzsh::profile
#
# This is the ohmyzsh module. It creates a profile directory under user home and allows
# custom scripts to setup and made avalible on the path.
#
# This module is called ohmyzsh as Puppet does not support hyphens in module
# names.
#
# oh-my-zsh is a community-driven framework for managing your zsh configuration.
#
# === Parameters
#
# scripts: (array) An array of paths to all the scripts
#
define ohmyzsh::profile (
  Hash $scripts = {},
) {

  include ohmyzsh

  if $name == 'root' {
    $home = '/root'
  } else {
    $home = "${ohmyzsh::home}/${name}"
  }

  $shell_resource_path = "${home}/.zshrc"

  file { "${home}/profile":
    ensure  => directory,
    group   => $name,
    owner   => $name,
    require => User[$name],
  }
  -> file_line { "${home}-profile":
    ensure  => present,
    line    => 'for f in ~/profile/*; do source "$f"; done',
    match   => 'for f in ~/profile/*; do source "$f"; done',
    path    => $shell_resource_path,
    require => [
      User[$name],
      Ohmyzsh::Install[$name],
    ],
  }

  $scripts.each |$script_name, $script_path| {
    file { "${home}/profile/${script_name}":
      ensure  => file,
      owner   => $name,
      group   => $name,
      mode    => '0744',
      source  => $script_path,
      require => File["${home}/profile"],
    }
  }
}
