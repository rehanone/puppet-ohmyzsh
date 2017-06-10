# == Define: ohmyzsh::install
#
# This is the ohmyzsh module. It installs oh-my-zsh for a user and changes
# their shell to zsh. It has been tested under Ubuntu.
#
# This module is called ohmyzsh as Puppet does not support hyphens in module
# names.
#
# oh-my-zsh is a community-driven framework for managing your zsh configuration.
#
# === Parameters
#
# set_sh: (boolean) whether to change the user shell to zsh
# disable_auto_update: (boolean) whether to prompt for updates bi-weekly
#
# === Authors
#
# Leon Brocard <acme@astray.com>
# Zan Loy <zan.loy@gmail.com>
#
# === Copyright
#
# Copyright 2014
#
define ohmyzsh::install(
  $set_sh              = false,
  $disable_auto_update = false,
) {

  validate_bool($set_sh)
  validate_bool($disable_auto_update)

  include ohmyzsh

  if ! defined(Package['git']) {
    package { 'git':
      ensure => present,
    }
  }

  if ! defined(Package['zsh']) {
    package { 'zsh':
      ensure => present,
    }
  }

  if $name == 'root' {
    $home = '/root'
  } else {
    $home = "${ohmyzsh::home}/${name}"
  }

  vcsrepo { "${home}/.oh-my-zsh":
    ensure   => present,
    provider => git,
    source   => $ohmyzsh::source,
    revision => 'master',
    user     => $name,
    require  => Package['git'],
  }

  exec { "ohmyzsh::cp .zshrc ${name}":
    creates => "${home}/.zshrc",
    command => "cp ${home}/.oh-my-zsh/templates/zshrc.zsh-template ${home}/.zshrc",
    path    => ['/bin', '/usr/bin'],
    onlyif  => "getent passwd ${name} | cut -d : -f 6 | xargs test -e",
    user    => $name,
    require => Vcsrepo["${home}/.oh-my-zsh"],
    before  => File_Line["ohmyzsh::disable_auto_update ${name}"],
  }

  if $set_sh {
    if ! defined(User[$name]) {
      user { "ohmyzsh::user ${name}":
        ensure     => present,
        name       => $name,
        managehome => true,
        shell      => $ohmyzsh::params::zsh,
        require    => Package['zsh'],
      }
    } else {
      User <| title == $name |> {
        shell => $ohmyzsh::params::zsh
      }
    }
  }

  file_line { "ohmyzsh::disable_auto_update ${name}":
    path  => "${home}/.zshrc",
    line  => "DISABLE_AUTO_UPDATE=\"${disable_auto_update}\"",
    match => '.*DISABLE_AUTO_UPDATE.*',
  }
}
