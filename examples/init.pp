class { 'ohmyzsh': }

# for a single user
ohmyzsh::install { 'vagrant': disable_auto_update => true, set_sh => true }

ohmyzsh::plugins { 'vagrant': plugins => ['git',  'github'] }
