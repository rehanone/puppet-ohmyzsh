#
# @summary Install and configure Oh-My-ZSH plugins for an user
#
#
# @param plugins        List of built-in plugins.
# @param custom_plugins List of plugins to install and use.
#
#
# @author Leon Brocard <acme@astray.com>
# @author Zan Loy <zan.loy@gmail.com>
#
define ohmyzsh::plugins (
  Array[String] $plugins        = ['git'],
  Hash[String,
    Struct[
      {
        source   => Enum[git],
        url      => Stdlib::Httpsurl,
        ensure   => Enum[present, latest],
        revision => Optional[String],
        depth    => Optional[Integer]
      }
    ]
  ]             $custom_plugins = {},
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

  $custom_plugins_path = "${home}/.oh-my-zsh/custom/plugins"

  $custom_plugins.each |$key, $plugin| {
    vcsrepo { "${custom_plugins_path}/${key}":
      ensure   => $plugin[ensure],
      provider => $plugin[source],
      source   => $plugin[url],
      depth    => $plugin[depth],
      revision => $plugin[revision],
      require  => ::Ohmyzsh::Install[$name],
    }
  }

  $all_plugins = union($plugins, keys($custom_plugins))

  $plugins_real = join($all_plugins, ' ')

  file_line { "${name}-${plugins_real}-install":
    path    => "${home}/.zshrc",
    line    => "plugins=(${plugins_real})",
    match   => '^plugins=',
    require => Ohmyzsh::Install[$name],
  }
}
