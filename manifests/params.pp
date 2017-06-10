# Parameters class for ohmyzsh
class ohmyzsh::params {

  case $::facts[osfamily] {
    'Redhat': {
      $zsh = '/bin/zsh'
    }
    default: {
      $zsh = '/usr/bin/zsh'
    }
  }

  $source = 'https://github.com/robbyrussell/oh-my-zsh.git'
  $home   = '/home'
}
