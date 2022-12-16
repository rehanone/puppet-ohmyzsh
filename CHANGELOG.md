## 5.0.0 (December 16, 2022)

**Breaking Changes:**

This release addresses the upstream changes in `oh-my-zsh` related to `DISABLE_AUTO_UPDATE`
variable being deprecated. It replaces the `disable_auto_update` with `auto_update_mode` and `auto_update_frequency` variables in class `ohmyzsh::install`. The `auto_update_mode` has these values (`auto`, `disabled`, `reminder`). This is as per documentation for [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh/wiki/Settings).

Also, this release replaces `override_template` feature with a new `update_zshrc` variable in `ohmyzsh::install`. This new variable has three values:
- `always` - Always replaces your local .zshrc file with upstream template. Use it with care!
- `disabled` - Disables replacement of your local .zshrc file with upstream template except if the file does not exist or on first installation. This is default.
- `sync` - Replaces your local .zshrc file with upstream template only when there is a change in upstream git repository. The upstream change is not just limited to the template but could be any file.

There is a backup feature that creates a backup of your previous `.zshrc` file using the following naming convention:

`.zshrc.bak.$(date +'%Y-%m-%dT%H:%M:%S%:z')`

It is enabled by default but can be disabled using `backup_zshrc` variable.

## 4.1.0 (November 16, 2022)

**Improvements:**

- fix disable_auto_update. ([#34](https://github.com/rehanone/puppet-ohmyzsh/pull/34); anthonysomerset)
- Add the ability to customize the clone for plugins. ([#32](https://github.com/rehanone/puppet-ohmyzsh/pull/33); Safranil)
- Add the ability to use a Git repository for themes. ([#32](https://github.com/rehanone/puppet-ohmyzsh/pull/32); Safranil)
- Updated os support matrix.
- Updated `pdk` templates.

## 4.0.0 (April 3, 2022)

**Breaking Changes:**

- Updated upstream ohmyzsh project url to reflect the new repository. ([#28](https://github.com/rehanone/puppet-ohmyzsh/pull/28); anthonysomerset)
- *Note:* To get this module working again, please manually delete the directory `~/.oh-my-zsh` and then run the puppet again. 

**Improvements:**

- Updated `pdk` templates.
- Fix permissions on `~/.oh-my-zsh/cache/completions`.

## 3.0.0 (December 23, 2021)

**Improvements:**

- Support for proper FreeBSD shell path. ([#22](https://github.com/rehanone/puppet-ohmyzsh/pull/22); dctrotz)
- Updated os support matrix.
- Updated `pdk` templates.
- Updated minimum `puppet` version to `6.0.0`.
- Updated dependency versions.

## 2.4.0 (May 7, 2021)

**Improvements:**

- Updated os support matrix.
- Updated `pdk` templates.
- Updated travis-ci links in the documentation.
- Added acceptance tests for openSUSE Leap 15.

## 2.3.2 (May 1, 2020)

**Improvements:**

- Added support for Ubuntu 20.04.

## 2.3.1 (April 12, 2020)

**Improvements:**

- Updated `pdk` templates.

## 2.3.0 (February 14, 2020)

**Improvements:**

- Added support for CentOS 8.
- Updated os support matrix.
- Updated `pdk` templates.

## 2.2.0 (August 25, 2019)

**Improvements:**

- Added support for Debian 10.
- Updated os support matrix.
- Updated `pdk` templates.

## 2.1.3 (June 15, 2019)

**Improvements:**

- Updated minimum `puppet` version to 5.5.10.
- Updated os support matrix.
- Updated `pdk` templates.

## 2.1.2 (January 21, 2019)

**Improvements:**

  - Change the default value for override_template from `true` to `false`. This change is due to the upstream PR [#7498](https://github.com/robbyrussell/oh-my-zsh/pull/7498).

## 2.1.1 (January 5, 2019)

**Bugfixes:**

  - Fix the issue with multiple line replacement for plugins section in the zshrc template. [#14](https://github.com/rehanone/puppet-ohmyzsh/pull/14)

**Improvements:**

- Updated `pdk` templates.

## 2.1.0 (October 14, 2018)

**Improvements:**

- Updated `pdk` templates.
- Added support for `puppet` version 6.

## 2.0.5 (September 1, 2018)

**Improvements:**

- Updated `pdk` templates.
- Added tests for Ubuntu 18.04 release.
- Added tests for Debian 9 release.
- Updated `puppetlabs-stdlib` dependency version.

## 2.0.4 (May 19, 2018)

**Improvements:**

- Updated documentation.

## 2.0.3 (May 9, 2018)

**Improvements:**

- Updated `pdk` templates.
- Updated minimum required `puppet` version to `4.10.0`.
- Improved acceptance tests.

## 2.0.2 (April 23, 2018)

**Improvements:**

  - Updated module data to `hiera 5`.
  - Improved acceptance tests.

## 2.0.1 (April 22, 2018)

**Improvements:**

  - Updated documentation.

**Bugfixes:**

  - Fixed the dependency cycle issues.

## 2.0.0 (April 22, 2018)

**Features:**

  - Initial release
