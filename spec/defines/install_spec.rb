require 'spec_helper'

testcases = {
  'user1' => {
    params: {},
    expect: { source: 'https://github.com/ohmyzsh/ohmyzsh.git', home: '/home/user1', sh: false, override_template: false },
  },
  'user2' => {
    params: { set_sh: true, disable_auto_update: true, override_template: true },
    expect: { source: 'https://github.com/ohmyzsh/ohmyzsh.git', home: '/home/user2', sh: true, disable_auto_update: true, override_template: true },
  },
  'root' => {
    params: {},
    expect: { source: 'https://github.com/ohmyzsh/ohmyzsh.git', home: '/root', sh: false, override_template: false },
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

          if values[:expect][:override_template]
            it do
              is_expected.to contain_file("#{values[:expect][:home]}/.zshrc")
                .with_ensure('file')
                .with_replace('no')
                .with_owner(user)
                .with_mode('0644')
            end
          else
            it do
              is_expected.to contain_exec("ohmyzsh::cp .zshrc #{user}")
                .with_creates("#{values[:expect][:home]}/.zshrc")
                .with_command("cp #{values[:expect][:home]}/.oh-my-zsh/templates/zshrc.zsh-template #{values[:expect][:home]}/.zshrc")
                .with_user(user)
            end
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
