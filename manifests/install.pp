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
  -> unless $ohmyzsh::concat {
    ohmyzsh::install::classic { $name:
      update_zshrc          => $update_zshrc,
      backup_zshrc          => $backup_zshrc,
      auto_update_mode      => $auto_update_mode,
      auto_update_frequency => $auto_update_frequency,
      home                  => $home,
      group                 => $group,
    }
  } else {
    ohmyzsh::install::concat { $name:
      auto_update_mode      => $auto_update_mode,
      auto_update_frequency => $auto_update_frequency,
      home                  => $home,
      group                 => $group,
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
