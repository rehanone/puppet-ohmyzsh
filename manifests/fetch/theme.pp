define ohmyzsh::fetch::theme (
  Optional[Stdlib::Httpurl] $url      = undef,
  Optional[String]          $source   = undef,
  Optional[String]          $content  = undef,
  Optional[String]          $filename = undef,
) {

  include ohmyzsh

  if $name == 'root' {
    $home = '/root'
  } else {
    $home = "${ohmyzsh::home}/${name}"
  }

  $themepath = "${home}/.oh-my-zsh/custom/themes"
  $fullpath = "${themepath}/${filename}"

  if ! defined(File[$themepath]) {
    file { $themepath:
      ensure  => directory,
      owner   => $name,
      require => Ohmyzsh::Install[$name],
    }
  }

  if $url != undef {
    wget::retrieve { "ohmyzsh::fetch-${name}-${filename}":
      source      => $url,
      destination => $fullpath,
      user        => $name,
      require     => File[$themepath],
    }
  } elsif $source != undef {
    file { $fullpath:
      ensure  => present,
      source  => $source,
      owner   => $name,
      require => File[$themepath],
    }
  } elsif $content != undef {
    file { $fullpath:
      ensure  => present,
      content => $content,
      owner   => $name,
      require => File[$themepath],
    }
  } else {
    fail('No valid option set.')
  }
}
