require 'spec_helper'

testcases = {
  'user1' => {
    params: {},
    expect: { home: '/home/user1', sh: false },
  },
  'user2' => {
    params: { scripts: { 'scripts.sh' => 'puppet:///modules/base/scripts.sh' } },
    expect: { home: '/home/user2', sh: true, disable_auto_update: true },
  },
  'root' => {
    params: { scripts: { 'scripts.sh' => 'puppet:///modules/base/scripts.sh' } },
    expect: { home: '/root', sh: false },
  },
}

describe 'ohmyzsh::profile' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      testcases.each do |user, values|
        let(:pre_condition) do
          [
            'user {"root": }',
            'user {"user1": }',
            'user {"user2": }',
            'ohmyzsh::install {"root": set_sh => true, }',
            'ohmyzsh::install {"user1": set_sh => true, }',
            'ohmyzsh::install {"user2": set_sh => true, }',
          ]
        end

        context "testing #{user}" do
          let(:title) { user }
          let(:params) { values[:params] }

          it do
            group = if user == 'root'
                      case facts[:osfamily]
                      when 'FreeBSD', 'OpenBSD'
                        'wheel'
                      else
                        'root'
                      end
                    else
                      user
                    end
            is_expected.to contain_file("#{values[:expect][:home]}/profile")
              .with_ensure('directory')
              .with_group(group)
              .with_owner(user)
          end

          it do
            is_expected.to contain_file_line("#{values[:expect][:home]}-profile")
              .with_ensure('present')
              .with_line('for f in ~/profile/*; do source "$f"; done')
              .with_match('for f in ~/profile/*; do source "$f"; done')
              .with_path("#{values[:expect][:home]}/.zshrc")
          end
        end
      end
    end
  end
end
