#
# @summary Configure the ZSH profile for an user
#
#
# @param scripts A hash of name => paths to all the scripts.
#
define ohmyzsh::profile (
  Hash[String[1], Stdlib::Filesource] $scripts = {},
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

  $shell_resource_path = "${home}/.zshrc"

  file { "${home}/profile":
    ensure  => directory,
    group   => $group,
    owner   => $name,
    require => User[$name],
  }

  unless $ohmyzsh::concat {
    file_line { "${home}-profile":
      ensure  => present,
      line    => 'for f in ~/profile/*; do source "$f"; done',
      match   => 'for f in ~/profile/*; do source "$f"; done',
      path    => $shell_resource_path,
      require => [
        User[$name],
        Ohmyzsh::Install[$name],
      ],
    }
  } else {
    concat::fragment { "${home}/.zshrc:profile":
      target  => "${home}/.zshrc",
      content => "for f in ~/profile/*; do source \"\$f\"; done\n",
      order   => '080',
      require => Ohmyzsh::Install[$name],
    }
  }

  $scripts.each |$script_name, $script_path| {
    file { "${home}/profile/${script_name}":
      ensure  => file,
      owner   => $name,
      group   => $group,
      mode    => '0744',
      source  => $script_path,
      require => File["${home}/profile"],
    }
  }
}
