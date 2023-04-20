#
# @api private
#
#
# @summary Manage the zsh file with concat
#
#
# @param auto_update_mode      Controls the update check for oh-my-zsh.
# @param auto_update_frequency Controls the update check frequency.
# @param home                  Controls the home directory of the install
# @param group                 Controls the group of the files
#
#
# @author David Cachau <david.cachau@capsi-informatique.fr>
#
define ohmyzsh::install::concat (
  Enum[auto, disabled, reminder] $auto_update_mode,
  Integer[0]                     $auto_update_frequency,
  String                         $home,
  String                         $group,
) {
  assert_private()

  concat { "${home}/.zshrc":
    ensure  => present,
    owner   => $name,
    group   => $group,
    mode    => '0644',
    require => Vcsrepo["${home}/.oh-my-zsh"],
  }

  concat::fragment { "${home}/.zshrc:000-header":
    target  => "${home}/.zshrc",
    source => "puppet:///modules/${module_name}/concat/zshrc-000-header.zsh-template",
    order   => '000',
  }

  concat::fragment { "${home}/.zshrc:010-export":
    target => "${home}/.zshrc",
    source => "puppet:///modules/${module_name}/concat/zshrc-010-export.zsh-template",
    order  => '010',
  }

  concat::fragment { "${home}/.zshrc:050-update":
    target  => "${home}/.zshrc",
    content => epp("${module_name}/concat/zshrc-050-update.zsh-template.epp", {
        auto_update_mode      => $auto_update_mode,
        auto_update_frequency => $auto_update_frequency,
    }),
    order   => '050',
  }

  concat::fragment { "${home}/.zshrc:070-source":
    target => "${home}/.zshrc",
    source => "puppet:///modules/${module_name}/concat/zshrc-070-source.zsh-template",
    order  => '070',
  }
}
