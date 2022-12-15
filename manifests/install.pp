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
# set_sh: (boolean) controls whether to change the user shell to zsh
# update_zshrc: (enum) controls the update of .zshrc from the upstream template. Default value is `disabled`
# auto_update_mode: (enum) controls the update check for oh-my-zsh. Default value is `disabled`.
# auto_update_frequency: (integer) controls the update check frequency. Default value is `14`.
#
# === Authors
#
# Leon Brocard <acme@astray.com>
# Zan Loy <zan.loy@gmail.com>
# Rehan Mahmood
#
# === Copyright
#
# Copyright 2022
#
define ohmyzsh::install (
  Enum[present, latest] $ensure     = latest,
  Boolean $set_sh                   = false,
  Enum[always, disabled, sync]
  $update_zshrc                     = disabled,
  Boolean $backup_zshrc             = true,
  Enum[auto, disabled, reminder]
  $auto_update_mode                 = disabled,
  Integer[0] $auto_update_frequency = 14,
) {
  include ohmyzsh
  $date_command = '$(date +\'%Y-%m-%dT%H:%M:%S%:z\')'

  if !defined(Package['git']) {
    package { 'git':
      ensure => present,
    }
  }

  if !defined(Package['zsh']) {
    package { 'zsh':
      ensure => present,
    }
  }

  if $name == 'root' {
    $home = '/root'
    $group = fact('os.family') ? {
      /(Free|Open)BSD/ => 'wheel',
      default          => 'root',
    }
  } else {
    $home = "${ohmyzsh::home}/${name}"
    $group = $name
  }

  vcsrepo { "${home}/.oh-my-zsh":
    ensure   => $ensure,
    provider => git,
    source   => $ohmyzsh::source,
    revision => 'master',
    user     => $name,
    require  => Package['git'],
  }

  if $update_zshrc == sync {
    if $backup_zshrc {
      exec { "backup .zshrc ${name}":
        command     => "cp ${home}/.zshrc ${home}/.zshrc.bak.${date_command}",
        path        => ['/bin', '/usr/bin'],
        user        => $name,
        before      => [
          File_Line["ohmyzsh::auto_update_frequency - ${name}"],
        ],
        subscribe   => Vcsrepo["${home}/.oh-my-zsh"],
        refreshonly => true,
      }
    }
    -> exec { "ohmyzsh::cp .zshrc ${name}":
      command     => "cp ${home}/.oh-my-zsh/templates/zshrc.zsh-template ${home}/.zshrc",
      path        => ['/bin', '/usr/bin'],
      user        => $name,
      before      => [
        File_Line["ohmyzsh::auto_update_frequency - ${name}"],
      ],
      subscribe   => Vcsrepo["${home}/.oh-my-zsh"],
      refreshonly => true,
    }
  } elsif $update_zshrc == disabled {
    exec { "ohmyzsh::cp .zshrc ${name}":
      creates => "${home}/.zshrc",
      command => "cp ${home}/.oh-my-zsh/templates/zshrc.zsh-template ${home}/.zshrc",
      path    => ['/bin', '/usr/bin'],
      onlyif  => "getent passwd ${name} | cut -d : -f 6 | xargs test -e",
      user    => $name,
      require => Vcsrepo["${home}/.oh-my-zsh"],
      before  => [
        File_Line["ohmyzsh::auto_update_frequency - ${name}"],
      ],
    }
  } elsif $update_zshrc == always {
    if $backup_zshrc {
      exec { "backup .zshrc ${name}":
        command     => "cp ${home}/.zshrc ${home}/.zshrc.bak.${date_command}",
        path        => ['/bin', '/usr/bin'],
        user        => $name,
        before      => [
          File_Line["ohmyzsh::auto_update_frequency - ${name}"],
        ],
        require => Vcsrepo["${home}/.oh-my-zsh"],
      }
    }
    -> exec { "ohmyzsh::cp .zshrc ${name}":
      command => "cp ${home}/.oh-my-zsh/templates/zshrc.zsh-template ${home}/.zshrc",
      path    => ['/bin', '/usr/bin'],
      user    => $name,
      before  => [
        File_Line["ohmyzsh::auto_update_frequency - ${name}"],
      ],
      require => Vcsrepo["${home}/.oh-my-zsh"],
    }
  }

  if $set_sh {
    if !defined(User[$name]) {
      user { "ohmyzsh::user ${name}":
        ensure     => present,
        name       => $name,
        managehome => true,
        shell      => lookup('ohmyzsh::zsh_shell_path'),
        require    => Package['zsh'],
      }
    } else {
      User <| title == $name |> {
        shell => lookup('ohmyzsh::zsh_shell_path')
      }
    }
  }

  file_line { "ohmyzsh::auto_update_frequency - ${name}":
    path  => "${home}/.zshrc",
    line  => "zstyle ':omz:update' frequency ${auto_update_frequency}",
    match => '.*zstyle\ \':omz:update\'\ frequency .*',
  }
  if $auto_update_mode == disabled {
    file_line { "enable ohmyzsh::auto_update_mode disabled - ${name}":
      path    => "${home}/.zshrc",
      line    => "zstyle ':omz:update' mode disabled",
      match   => '.*zstyle\ \':omz:update\'\ mode\ disabled.*',
      require => File_Line["ohmyzsh::auto_update_frequency - ${name}"],
    }
    file_line { "disable ohmyzsh::auto_update_mode auto - ${name}":
      path    => "${home}/.zshrc",
      line    => "# zstyle ':omz:update' mode auto",
      match   => '.*zstyle\ \':omz:update\'\ mode\ auto.*',
      require => File_Line["ohmyzsh::auto_update_frequency - ${name}"],
    }
    file_line { "disable ohmyzsh::auto_update_mode reminder - ${name}":
      path    => "${home}/.zshrc",
      line    => "# zstyle ':omz:update' mode reminder",
      match   => '.*zstyle\ \':omz:update\'\ mode\ reminder.*',
      require => File_Line["ohmyzsh::auto_update_frequency - ${name}"],
    }
  } elsif $auto_update_mode == auto {
    file_line { "enable ohmyzsh::auto_update_mode auto - ${name}":
      path    => "${home}/.zshrc",
      line    => "zstyle ':omz:update' mode auto",
      match   => '.*zstyle\ \':omz:update\'\ mode\ auto.*',
      require => File_Line["ohmyzsh::auto_update_frequency - ${name}"],
    }
    file_line { "disable ohmyzsh::auto_update_mode disabled - ${name}":
      path    => "${home}/.zshrc",
      line    => "# zstyle ':omz:update' mode disabled",
      match   => '.*zstyle\ \':omz:update\'\ mode\ disabled.*',
      require => File_Line["ohmyzsh::auto_update_frequency - ${name}"],
    }
    file_line { "disable ohmyzsh::auto_update_mode reminder - ${name}":
      path    => "${home}/.zshrc",
      line    => "# zstyle ':omz:update' mode reminder",
      match   => '.*zstyle\ \':omz:update\'\ mode\ reminder.*',
      require => File_Line["ohmyzsh::auto_update_frequency - ${name}"],
    }
  } elsif $auto_update_mode == reminder {
    file_line { "enable ohmyzsh::auto_update_mode reminder - ${name}":
      path    => "${home}/.zshrc",
      line    => "zstyle ':omz:update' mode reminder",
      match   => '.*zstyle\ \':omz:update\'\ mode\ reminder.*',
      require => File_Line["ohmyzsh::auto_update_frequency - ${name}"],
    }
    file_line { "disable ohmyzsh::auto_update_mode auto - ${name}":
      path    => "${home}/.zshrc",
      line    => "# zstyle ':omz:update' mode auto",
      match   => '.*zstyle\ \':omz:update\'\ mode\ auto.*',
      require => File_Line["ohmyzsh::auto_update_frequency - ${name}"],
    }
    file_line { "disable ohmyzsh::auto_update_mode disabled - ${name}":
      path    => "${home}/.zshrc",
      line    => "# zstyle ':omz:update' mode disabled",
      match   => '.*zstyle\ \':omz:update\'\ mode\ disabled.*',
      require => File_Line["ohmyzsh::auto_update_frequency - ${name}"],
    }
  }

  # Fix permissions on '~/.oh-my-zsh/cache/completions'
  file { "${home}/.oh-my-zsh/cache/completions":
    ensure  => directory,
    replace => 'no',
    owner   => $name,
    group   => $group,
    mode    => '0755',
    require => Vcsrepo["${home}/.oh-my-zsh"],
  }
}
