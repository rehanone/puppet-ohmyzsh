# View README.md for full documentation.
#
# === Authors
#
# Leon Brocard <acme@astray.com>
# Zan Loy <zan.loy@gmail.com>
# Rehan Mahmood <rehanone at gmail dot com>
#
# === Copyright
#
# Copyright 2019
#
class ohmyzsh (
  Stdlib::Httpsurl     $source,
  Stdlib::Absolutepath $home,
  Stdlib::Absolutepath $zsh_shell_path,
  Hash                 $installs = lookup('ohmyzsh::installs', Hash, 'hash', {}),
  Hash                 $themes   = lookup('ohmyzsh::themes', Hash, 'hash', {}),
  Hash                 $plugins  = lookup('ohmyzsh::plugins', Hash, 'hash', {}),
  Hash                 $profiles = lookup('ohmyzsh::profiles', Hash, 'hash', {})
) {
  create_resources('ohmyzsh::install', $ohmyzsh::installs)
  create_resources('ohmyzsh::theme', $ohmyzsh::themes)
  create_resources('ohmyzsh::plugins', $ohmyzsh::plugins)
  create_resources('ohmyzsh::profile', $ohmyzsh::profiles)
}
