define ohmyzsh::fetch::theme (
  Optional[Stdlib::Httpurl] $url      = undef,
  Optional[String]          $source   = undef,
  Optional[String]          $content  = undef,
  Optional[String]          $filename = undef,
  Optional[String]          $revision = undef,
  Optional[Integer]         $depth    = undef,
) {

  include ohmyzsh

  if $name == 'root' {
    $home  = '/root'
    $group = fact('os.family') ? {
      /(Free|Open)BSD/ => 'wheel',
      default          => 'root',
    }
  } else {
    $home  = "${ohmyzsh::home}/${name}"
    $group = $name
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

  if $source == 'git' {
    vcsrepo { $fullpath:
      ensure   => present,
      provider => 'git',
      source   => $url,
      revision => $revision,
      depth    => $depth,
      require  => ::Ohmyzsh::Install[$name],
    }
  } elsif $url != undef {
    wget::retrieve { "ohmyzsh::fetch-${name}-${filename}":
      source      => $url,
      destination => $fullpath,
      user        => $name,
      require     => File[$themepath],
    }
  } elsif $source != undef {
    file { $fullpath:
      ensure  => file,
      source  => $source,
      owner   => $name,
      group   => $group,
      mode    => '0644',
      require => File[$themepath],
    }
  } elsif $content != undef {
    file { $fullpath:
      ensure  => file,
      content => $content,
      owner   => $name,
      group   => $group,
      mode    => '0644',
      require => File[$themepath],
    }
  } else {
    fail('No valid option set.')
  }
}
