#
# @api private
#
#
# @summary Manage the zsh file with the original mode (file copy from the repository)
#
#
# @param update_zshrc          Controls the update of .zshrc from the upstream template.
# @param auto_update_mode      Controls the update check for oh-my-zsh.
# @param auto_update_frequency Controls the update check frequency.
# @param home                  Controls the home directory of the install
# @param group                 Controls the group of the files
#
#
# @author Leon Brocard <acme@astray.com>
# @author Zan Loy <zan.loy@gmail.com>
# @author Rehan Mahmood
#
define ohmyzsh::install::classic (
  Enum[always, disabled, sync]   $update_zshrc,
  Boolean                        $backup_zshrc,
  Enum[auto, disabled, reminder] $auto_update_mode,
  Integer[0]                     $auto_update_frequency,
  String                         $home,
  String                         $group,
) {
  assert_private()
  $date_command = '$(date +\'%Y-%m-%dT%H:%M:%S%:z\')'

  if $update_zshrc == sync {
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
}
