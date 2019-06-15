# rehan-ohmyzsh

[![Puppet Forge](http://img.shields.io/puppetforge/v/rehan/ohmyzsh.svg)](https://forge.puppetlabs.com/rehan/ohmyzsh) [![Build Status](https://travis-ci.org/rehanone/puppet-ohmyzsh.svg?branch=master)](https://travis-ci.org/rehanone/puppet-ohmyzsh)

#### Table of Contents
1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Setup](#setup)
4. [Usage](#usage)
5. [Dependencies](#dependencies)
6. [Development](#development)
7. [Acknowledgments](#acknowledgments)

## Overview
This is a [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh) module. It
installs oh-my-zsh for a user and can change their shell to zsh. It can install
and configure themes and plugins for users.

## Module Description
oh-my-zsh is a community-driven framework for managing your zsh configuration.
See [https://github.com/robbyrussell/oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh)
for more details.

## Setup
In order to install `rehan-ohmyzsh`, run the following command:
```bash
$ puppet module install rehan-ohmyzsh
```
The module does expect all the data to be provided through 'Hiera'. See [Usage](#usage) for examples on how to configure it.

#### Requirements
This module is designed to be as clean and compliant with latest puppet code guidelines. It works with:

  - `puppet >=5.5.10`

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
ohmyzsh::plugins { 'user1': plugins => ['git', 'github'] }
```


**YAML**
```yaml
ohmyzsh::installs:
  alice:
    set_sh: true
  bob:
    set_sh: true

ohmyzsh::themes:
  alice:
    theme: 'random'
  bob:
    theme: 'amuse'

ohmyzsh::plugins:
  alice:
    plugins: ['autojump', 'git', 'screen', 'ssh-agent', 'sudo', 'tmux' ]
    custom_plugins:
      zsh-syntax-highlighting:
       ensure: latest
       source: git
       url:    'https://github.com/zsh-users/zsh-syntax-highlighting.git'
      zsh-autosuggestions:
       ensure: latest
       source: git
       url:    'https://github.com/zsh-users/zsh-autosuggestions.git'
  bob:
    plugins: ['autojump', 'git', 'screen', 'ssh-agent', 'sudo', 'tmux', 'vagrant', 'scala', 'rvm' ]

```


## Dependencies

* [stdlib][1]
* [vcsrepo][2]
* [wget][3]

[1]:https://forge.puppet.com/puppetlabs/stdlib
[2]:https://forge.puppet.com/puppetlabs/vcsrepo
[3]:https://forge.puppet.com/rehan/wget

## Development

You can submit pull requests and create issues through the official page of this module on [GitHub](https://github.com/rehanone/puppet-ohmyzsh).
Please do report any bug and suggest new features/improvements.

## Acknowledgments

This module was originally a fork of [zanloy/ohmyzsh](https://forge.puppet.com/zanloy/ohmyzsh) at version 0.1.3
