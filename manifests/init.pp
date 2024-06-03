#
# @summary Install and configure Oh-My-ZSH
#
# This is the ohmyzsh module. It creates a profile directory under user home and allows
# custom scripts to setup and made avalible on the path.
#
# This module is called ohmyzsh as Puppet does not support hyphens in module
# names.
#
# View README.md for full documentation.
#
#
# @param source         Oh-My-ZSH repository. See data/ for the default value.
# @param home           Default home base directory. See data/ for the default value.
# @param zsh_shell_path Path of the zsh executable. See data/ for the default value.
# @param installs       Install and configure Oh-My-ZSH for users defined in this hash. See data/ for the default value.
# @param themes         Configure the themes for users defined in this hash. See data/ for the default value.
# @param plugins        Configure the plugins for users defined in this hash. See data/ for the default value.
# @param profiles       Configure the profile for users defined in this hash. See data/ for the default value.
#
#
# @author Leon Brocard <acme@astray.com>
# @author Zan Loy <zan.loy@gmail.com>
# @author Rehan Mahmood <rehanone at gmail dot com>
#
class ohmyzsh (
  Stdlib::Httpsurl     $source,
  Stdlib::Absolutepath $home,
  Stdlib::Absolutepath $zsh_shell_path,
  Hash                 $installs,
  Hash                 $themes,
  Hash                 $plugins,
  Hash                 $profiles,
) {
  create_resources('ohmyzsh::install', $ohmyzsh::installs)
  create_resources('ohmyzsh::theme', $ohmyzsh::themes)
  create_resources('ohmyzsh::plugins', $ohmyzsh::plugins)
  create_resources('ohmyzsh::profile', $ohmyzsh::profiles)
}
