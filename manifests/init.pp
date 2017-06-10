# View README.md for full documentation.
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
class ohmyzsh(
  $source   = $ohmyzsh::params::source,
  $home     = $ohmyzsh::params::home,
  $installs = hiera_hash('ohmyzsh::installs', {}),
  $themes   = hiera_hash('ohmyzsh::themes', {}),
  $plugins  = hiera_hash('ohmyzsh::plugins', {}),
  $profiles = hiera_hash('ohmyzsh::profiles', {})
) inherits ohmyzsh::params {

  validate_string($source)
  validate_string($home)
  validate_hash($installs)
  validate_hash($themes)
  validate_hash($plugins)
  validate_hash($profiles)

  create_resources('ohmyzsh::install', $ohmyzsh::installs)
  create_resources('ohmyzsh::theme', $ohmyzsh::themes)
  create_resources('ohmyzsh::plugins', $ohmyzsh::plugins)
  create_resources('ohmyzsh::profile', $ohmyzsh::profiles)
}
