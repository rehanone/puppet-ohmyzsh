require 'spec_helper'

testcases = {
  'user1' => {
    params: {},
    expect: { source: 'https://github.com/robbyrussell/oh-my-zsh.git', home: '/home/user1', sh: false },
  },
  'user2' => {
    params: { set_sh: true, disable_auto_update: true },
    expect: { source: 'https://github.com/robbyrussell/oh-my-zsh.git', home: '/home/user2', sh: true, disable_auto_update: true },
  },
  'root' => {
    params: {},
    expect: { source: 'https://github.com/robbyrussell/oh-my-zsh.git', home: '/root', sh: false },
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
          it do
            is_expected.to contain_exec("ohmyzsh::cp .zshrc #{user}")
              .with_creates("#{values[:expect][:home]}/.zshrc")
              .with_command("cp #{values[:expect][:home]}/.oh-my-zsh/templates/zshrc.zsh-template #{values[:expect][:home]}/.zshrc")
              .with_user(user)
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
          if values[:expect][:disable_auto_update]
            it do
              is_expected.to contain_file_line("ohmyzsh::disable_auto_update #{user}")
                .with_path("#{values[:expect][:home]}/.zshrc")
                .with_line('DISABLE_AUTO_UPDATE="true"')
            end
          else
            it do
              is_expected.to contain_file_line("ohmyzsh::disable_auto_update #{user}")
                .with_path("#{values[:expect][:home]}/.zshrc")
                .with_line('DISABLE_AUTO_UPDATE="false"')
            end
          end
        end
      end
    end
  end
end
