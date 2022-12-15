require 'spec_helper'

testcases = {
  'user1' => {
    params: {},
    expect: {
      source: 'https://github.com/ohmyzsh/ohmyzsh.git',
      home: '/home/user1',
      sh: false,
      auto_update_mode: 'disabled',
      auto_update_frequency: 14,
      update_zshrc: 'disabled',
    },
  },
  'user2' => {
    params: {
      set_sh: true,
      auto_update_mode: 'auto',
      auto_update_frequency: 5,
      update_zshrc: 'always'
    },
    expect: {
      source: 'https://github.com/ohmyzsh/ohmyzsh.git',
      home: '/home/user2',
      sh: true,
      auto_update_frequency: 5,
      auto_update_mode: 'auto',
      update_zshrc: 'always',
    },
  },
  'root' => {
    params: {
      set_sh: false,
      auto_update_mode: 'reminder',
      auto_update_frequency: 10,
      update_zshrc: 'sync',
    },
    expect: {
      source: 'https://github.com/ohmyzsh/ohmyzsh.git',
      home: '/root',
      sh: false,
      auto_update_mode: 'reminder',
      auto_update_frequency: 10,
      update_zshrc: 'sync',
    },
  },
}

describe 'ohmyzsh::install' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      testcases.each do |user, values|
        context "testing #{user}" do
          let(:title) { user }
          let(:params) { values[:params] }

          it do
            is_expected.to contain_vcsrepo("#{values[:expect][:home]}/.oh-my-zsh")
              .with_provider('git')
              .with_source(values[:expect][:source])
              .with_revision('master')
          end

          if values[:expect][:sh]
            it do
              case facts[:osfamily]
              when 'Redhat'
                is_expected.to contain_user("ohmyzsh::user #{user}")
                  .with_name(user)
                  .with_shell('/bin/zsh')
              when 'Debian'
                is_expected.to contain_user("ohmyzsh::user #{user}")
                  .with_name(user)
                  .with_shell('/usr/bin/zsh')
              end
            end
          end

          if values[:expect][:update_zshrc] == 'always'
            it do
              is_expected.to contain_exec("ohmyzsh::cp .zshrc #{user}")
                .with_command("cp #{values[:expect][:home]}/.oh-my-zsh/templates/zshrc.zsh-template #{values[:expect][:home]}/.zshrc")
                .with_user(user)
            end
          elsif values[:expect][:update_zshrc] == 'disabled'
            it do
              is_expected.to contain_exec("ohmyzsh::cp .zshrc #{user}")
                .with_creates("#{values[:expect][:home]}/.zshrc")
                .with_command("cp #{values[:expect][:home]}/.oh-my-zsh/templates/zshrc.zsh-template #{values[:expect][:home]}/.zshrc")
                .with_user(user)
                .with_onlyif("getent passwd #{user} | cut -d : -f 6 | xargs test -e")
            end
          elsif values[:expect][:update_zshrc] == 'sync'
            it do
              is_expected.to contain_exec("ohmyzsh::cp .zshrc #{user}")
                .with_command("cp #{values[:expect][:home]}/.oh-my-zsh/templates/zshrc.zsh-template #{values[:expect][:home]}/.zshrc")
                .with_user(user)
                .with_refreshonly(true)
            end
          end

          it do
            is_expected.to contain_file_line("ohmyzsh::auto_update_frequency - #{user}")
              .with_path("#{values[:expect][:home]}/.zshrc")
              .with_line("zstyle ':omz:update' frequency #{values[:expect][:auto_update_frequency]}")
              .with_match(".*zstyle\\ ':omz:update'\\ frequency .*")
          end

          case values[:expect][:auto_update_mode]
          when 'auto'
            it do
              is_expected.to contain_file_line("enable ohmyzsh::auto_update_mode auto - #{user}")
                .with_path("#{values[:expect][:home]}/.zshrc")
                .with_line('zstyle \':omz:update\' mode auto')
                .with_match(".*zstyle\\ ':omz:update'\\ mode\\ auto.*")
              is_expected.to contain_file_line("disable ohmyzsh::auto_update_mode disabled - #{user}")
                .with_path("#{values[:expect][:home]}/.zshrc")
                .with_line('# zstyle \':omz:update\' mode disabled')
                .with_match(".*zstyle\\ ':omz:update'\\ mode\\ disabled.*")
              is_expected.to contain_file_line("disable ohmyzsh::auto_update_mode reminder - #{user}")
                .with_path("#{values[:expect][:home]}/.zshrc")
                .with_line('# zstyle \':omz:update\' mode reminder')
                .with_match(".*zstyle\\ ':omz:update'\\ mode\\ reminder.*")
            end
          when 'disabled'
            it do
              is_expected.to contain_file_line("enable ohmyzsh::auto_update_mode disabled - #{user}")
                .with_path("#{values[:expect][:home]}/.zshrc")
                .with_line('zstyle \':omz:update\' mode disabled')
                .with_match(".*zstyle\\ ':omz:update'\\ mode\\ disabled.*")
              is_expected.to contain_file_line("disable ohmyzsh::auto_update_mode auto - #{user}")
                .with_path("#{values[:expect][:home]}/.zshrc")
                .with_line('# zstyle \':omz:update\' mode auto')
                .with_match(".*zstyle\\ ':omz:update'\\ mode\\ auto.*")
              is_expected.to contain_file_line("disable ohmyzsh::auto_update_mode reminder - #{user}")
                .with_path("#{values[:expect][:home]}/.zshrc")
                .with_line('# zstyle \':omz:update\' mode reminder')
                .with_match(".*zstyle\\ ':omz:update'\\ mode\\ reminder.*")
            end
          when 'reminder'
            it do
              is_expected.to contain_file_line("enable ohmyzsh::auto_update_mode reminder - #{user}")
                .with_path("#{values[:expect][:home]}/.zshrc")
                .with_line('zstyle \':omz:update\' mode reminder')
                .with_match(".*zstyle\\ ':omz:update'\\ mode\\ reminder.*")
              is_expected.to contain_file_line("disable ohmyzsh::auto_update_mode auto - #{user}")
                .with_path("#{values[:expect][:home]}/.zshrc")
                .with_line('# zstyle \':omz:update\' mode auto')
                .with_match(".*zstyle\\ ':omz:update'\\ mode\\ auto.*")
              is_expected.to contain_file_line("disable ohmyzsh::auto_update_mode disabled - #{user}")
                .with_path("#{values[:expect][:home]}/.zshrc")
                .with_line('# zstyle \':omz:update\' mode disabled')
                .with_match(".*zstyle\\ ':omz:update'\\ mode\\ disabled.*")
            end
          end
        end
      end
    end
  end
end
