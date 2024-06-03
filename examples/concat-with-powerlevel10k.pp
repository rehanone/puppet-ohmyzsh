class { 'ohmyzsh':
  concat => true,
}

# for a single user
ohmyzsh::install { 'root':
  set_sh                => true,
  auto_update_mode      => reminder,
  auto_update_frequency => 7,
}

ohmyzsh::fetch::theme { 'root':
  filename => 'powerlevel10k',
  source   => 'git',
  depth    => 1,
  url      => 'https://github.com/romkatv/powerlevel10k.git',
}

ohmyzsh::theme { 'root':
  theme => 'powerlevel10k/powerlevel10k',
}

ohmyzsh::plugins { 'root':
  plugins => ['git', 'github'],
}

file { '/root/.p10k.zsh':
  owner   => 'root',
  group   => 'root',
  content => 'YOUR P10K CONFIGURATION FILE',
}

concat::fragment { '/root/.zshrc:p10k-instant-prompt':
  target  => '/root/.zshrc',
  content => 'YOUR P10K INSTANT PROMPT SNIPPET',
  order   => '005',
}

concat::fragment { '/root/.zshrc:p10k-load':
  target  => '/root/.zshrc',
  content => "[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh\n",
  order   => '095',
}
