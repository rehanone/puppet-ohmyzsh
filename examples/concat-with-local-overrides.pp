class { 'ohmyzsh':
  concat => true,
}

# for a single user
ohmyzsh::install { 'root':
  set_sh                => true,
  auto_update_mode      => reminder,
  auto_update_frequency => 7,
}

file { '/root/.zshrc.local':
  ensure  => file,
  replace => 'no',
  owner   => 'root',
  group   => 'root',
  mode    => '0644',
  content => "# Use this file to customize ZSH, it's not managed by Puppet",
}

concat::fragment { '/root/.zshrc:puppet':
  target  => '/root/.zshrc',
  content => "### Use the file ~/.zshrc.local for your changes\n",
  order   => '000',
}

concat::fragment { '/root/.zshrc:load-local':
  target  => '/root/.zshrc',
  content => @("EOF"/L)
    # Load local zshrc if exist
    if [ -f ~/.zshrc.local ]
    then
        source ~/.zshrc.local
    fi
    | EOF
  ,
  order   => '099',
}
