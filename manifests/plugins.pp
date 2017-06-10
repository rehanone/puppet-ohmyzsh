# == Define: ohmyzsh::plugins
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
# plugins: (string) space separated list of tmux plugins
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
define ohmyzsh::plugins(
  $plugins = ['git'],
  $custom_plugins = {},
) {

  validate_array($plugins)
  validate_hash($custom_plugins)

  include ohmyzsh

  if $name == 'root' {
    $home = '/root'
  } else {
    $home = "${ohmyzsh::home}/${name}"
  }

  $custom_plugins_path = "${home}/.oh-my-zsh/custom/plugins"

  $custom_plugins.each |$plugin, $repo| {
    vcsrepo { "${custom_plugins_path}/${plugin}":
      ensure   => present,
      provider => git,
      source   => $repo,
      revision => 'master',
      require  => ::Ohmyzsh::Install[$name],
    }
  }

  $all_plugins = union($plugins, keys($custom_plugins))

  $plugins_real = join($all_plugins, ' ')

  file_line { "${name}-${plugins_real}-install":
    path    => "${home}/.zshrc",
    line    => "plugins=(${plugins_real})",
    match   => '^plugins=',
    require => Ohmyzsh::Install[$name]
  }
}
