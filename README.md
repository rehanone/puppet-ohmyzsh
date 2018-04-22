# puppet-ohmyzsh
[![Build Status](https://travis-ci.org/rehanone/puppet-ohmyzsh.svg?branch=master)](https://travis-ci.org/rehanone/puppet-ohmyzsh)

This is a [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh) module. It
installs oh-my-zsh for a user and can change their shell to zsh. It can install
and configure themes and plugins for users.

oh-my-zsh is a community-driven framework for managing your zsh configuration.
See [https://github.com/robbyrussell/oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh)
for more details.

## Usage

```puppet
# for a single user
ohmyzsh::install { 'user1': }

# for multiple users in one shot and set their shell to zsh
ohmyzsh::install { ['root', 'user1']: set_sh => true }

# install and disable prompt for automatic updates
ohmyzsh::install { 'user2': disable_auto_update => true }

# install a theme for a user
ohmyzsh::fetch::theme { 'root': url => 'http://zanloy.com/files/dotfiles/oh-my-zsh/squared.zsh-theme' }

# set a theme for a user
ohmyzsh::theme { ['root', 'user1']: } # would install 'clean' theme as default

ohmyzsh::theme { ['root', 'user1']: theme => 'robbyrussell' } # specific theme

# activate plugins for a user
ohmyzsh::plugins { 'user1': plugins => 'git github' }

# upgrade oh-my-zsh for a single user
ohmyzsh::upgrade { 'user1': }

# upgrade oh-my-zsh on a different schedule (only 'daily' is defined, you are responsible for creating additional schedules)
ohmyzsh::upgrade { 'user1': schedule => 'weekly' }
```

Support
-------

Please log tickets and issues on [GitHub](https://github.com/zanloy/puppet-ohmyzsh)


Acknowlegments
--------------

This module was originally a fork of [acme/ohmyzsh](https://github.com/rehanone/puppet-ohmyzsh) at version 0.1.3
