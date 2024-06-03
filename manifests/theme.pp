#
# @summary Configure the ZSH theme for an user
#
#
# @param theme The name of the theme to use.
#
#
# @author Leon Brocard <acme@astray.com>
# @author Zan Loy <zan.loy@gmail.com>
#
define ohmyzsh::theme (
  String $theme = 'clean',
) {
  include ohmyzsh

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

  unless $ohmyzsh::concat {
    file_line { "${name}-${theme}-install":
      path    => "${home}/.zshrc",
      line    => "ZSH_THEME=\"${theme}\"",
      match   => '^ZSH_THEME',
      require => Ohmyzsh::Install[$name],
    }
  } else {
    concat::fragment { "${home}/.zshrc:ZSH_THEME":
      target  => "${home}/.zshrc",
      content => "ZSH_THEME=\"${theme}\"\n",
      order   => '020',
      require => Ohmyzsh::Install[$name],
    }
  }
}
