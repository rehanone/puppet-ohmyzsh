class { 'ohmyzsh': }

# for a single user
ohmyzsh::install { 'vagrant':
  set_sh                => true,
  auto_update_mode      => reminder,
  auto_update_frequency => 7,
  update_zshrc          => always,
}

ohmyzsh::plugins { 'vagrant':
  plugins => ['git', 'github'],
}
