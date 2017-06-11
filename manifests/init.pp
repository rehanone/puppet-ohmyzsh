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
# Copyright 2017
#
class ohmyzsh(
  Stdlib::Httpsurl     $source   = $ohmyzsh::params::source,
  Stdlib::Absolutepath $home     = $ohmyzsh::params::home,
  Hash                 $installs = hiera_hash('ohmyzsh::installs', {}),
  Hash                 $themes   = hiera_hash('ohmyzsh::themes', {}),
  Hash                 $plugins  = hiera_hash('ohmyzsh::plugins', {}),
  Hash                 $profiles = hiera_hash('ohmyzsh::profiles', {})
) inherits ohmyzsh::params {

  create_resources('ohmyzsh::install', $ohmyzsh::installs)
  create_resources('ohmyzsh::theme', $ohmyzsh::themes)
  create_resources('ohmyzsh::plugins', $ohmyzsh::plugins)
  create_resources('ohmyzsh::profile', $ohmyzsh::profiles)
}
