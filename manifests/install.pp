#
# @summary Install and configure Oh-My-ZSH for an user
#
#
# @param ensure                Controls the way the Oh-My-ZSH repository is managed by Puppet.
# @param set_sh                Controls whether to change the user shell to zsh.
# @param update_zshrc          Controls the update of .zshrc from the upstream template.
# @param backup_zshrc          Controls if a backup of .zshrc need to be sone before changes.
# @param auto_update_mode      Controls the update check for oh-my-zsh.
# @param auto_update_frequency Controls the update check frequency.
#
#
# @author Leon Brocard <acme@astray.com>
# @author Zan Loy <zan.loy@gmail.com>
# @author Rehan Mahmood
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

      Package['zsh'] -> User <| title == $name |>
    }
  }

  vcsrepo { "${home}/.oh-my-zsh":
    ensure   => $ensure,
    provider => git,
    source   => $ohmyzsh::source,
    revision => 'master',
    user     => $name,
    require  => Package['git'],
  }
  -> if $update_zshrc == sync {
    if $backup_zshrc {
      exec { "backup .zshrc ${name}":
        command     => "cp ${home}/.zshrc ${home}/.zshrc.bak.${date_command}",
        path        => ['/bin', '/usr/bin'],
        onlyif      => "test -f ${home}/.zshrc",
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
    }
  } elsif $update_zshrc == always {
    if $backup_zshrc {
      exec { "backup .zshrc ${name}":
        command => "cp ${home}/.zshrc ${home}/.zshrc.bak.${date_command}",
        path    => ['/bin', '/usr/bin'],
        onlyif  => "test -f ${home}/.zshrc",
        user    => $name,
      }
    }
    -> exec { "ohmyzsh::cp .zshrc ${name}":
      command => "cp ${home}/.oh-my-zsh/templates/zshrc.zsh-template ${home}/.zshrc",
      path    => ['/bin', '/usr/bin'],
      user    => $name,
    }
  }
  -> file_line { "ohmyzsh::auto_update_frequency - ${name}":
    path  => "${home}/.zshrc",
    line  => "zstyle ':omz:update' frequency ${auto_update_frequency}",
    match => '.*zstyle\ \':omz:update\'\ frequency .*',
  }
  -> if $auto_update_mode == disabled {
    file_line { "enable ohmyzsh::auto_update_mode disabled - ${name}":
      path  => "${home}/.zshrc",
      line  => "zstyle ':omz:update' mode disabled",
      match => '.*zstyle\ \':omz:update\'\ mode\ disabled.*',
    }
    file_line { "disable ohmyzsh::auto_update_mode auto - ${name}":
      path  => "${home}/.zshrc",
      line  => "# zstyle ':omz:update' mode auto",
      match => '.*zstyle\ \':omz:update\'\ mode\ auto.*',
    }
    file_line { "disable ohmyzsh::auto_update_mode reminder - ${name}":
      path  => "${home}/.zshrc",
      line  => "# zstyle ':omz:update' mode reminder",
      match => '.*zstyle\ \':omz:update\'\ mode\ reminder.*',
    }
  } elsif $auto_update_mode == auto {
    file_line { "enable ohmyzsh::auto_update_mode auto - ${name}":
      path  => "${home}/.zshrc",
      line  => "zstyle ':omz:update' mode auto",
      match => '.*zstyle\ \':omz:update\'\ mode\ auto.*',
    }
    file_line { "disable ohmyzsh::auto_update_mode disabled - ${name}":
      path  => "${home}/.zshrc",
      line  => "# zstyle ':omz:update' mode disabled",
      match => '.*zstyle\ \':omz:update\'\ mode\ disabled.*',
    }
    file_line { "disable ohmyzsh::auto_update_mode reminder - ${name}":
      path  => "${home}/.zshrc",
      line  => "# zstyle ':omz:update' mode reminder",
      match => '.*zstyle\ \':omz:update\'\ mode\ reminder.*',
    }
  } elsif $auto_update_mode == reminder {
    file_line { "enable ohmyzsh::auto_update_mode reminder - ${name}":
      path  => "${home}/.zshrc",
      line  => "zstyle ':omz:update' mode reminder",
      match => '.*zstyle\ \':omz:update\'\ mode\ reminder.*',
    }
    file_line { "disable ohmyzsh::auto_update_mode auto - ${name}":
      path  => "${home}/.zshrc",
      line  => "# zstyle ':omz:update' mode auto",
      match => '.*zstyle\ \':omz:update\'\ mode\ auto.*',
    }
    file_line { "disable ohmyzsh::auto_update_mode disabled - ${name}":
      path  => "${home}/.zshrc",
      line  => "# zstyle ':omz:update' mode disabled",
      match => '.*zstyle\ \':omz:update\'\ mode\ disabled.*',
    }
  }
  # Fix permissions on '~/.oh-my-zsh/cache/completions'
  -> file { "${home}/.oh-my-zsh/cache/completions":
    ensure  => directory,
    replace => 'no',
    owner   => $name,
    group   => $group,
    mode    => '0755',
    require => Vcsrepo["${home}/.oh-my-zsh"],
  }
}
