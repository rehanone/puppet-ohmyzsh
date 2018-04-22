require 'spec_helper'

testcases = {
  'user_default' => {
    params: {},
    expect: { home: '/home/user_default', plugins: 'git' },
  },
  'user_with_plugins' => {
    params: { plugins: ['tmux'] },
    expect: { home: '/home/user_with_plugins', plugins: 'tmux' },
  },
  'user_with_custom_plugins' => {
    params: { plugins: ['scala'], custom_plugins: { 'zsh-autosuggestions' => { 'source' => 'git', 'url' => 'https://github.com/zsh-users/zsh-autosuggestions.git', 'ensure' => 'present' } } },
    expect: { home: '/home/user_with_custom_plugins', plugins: 'scala zsh-autosuggestions' },
  },
  'root' => {
    params: { plugins: %w[git tmux] },
    expect: { home: '/root', plugins: 'git tmux' },
  },
}

describe 'ohmyzsh::plugins' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      testcases.each do |user, values|
        let(:pre_condition) do
          [
            'ohmyzsh::install {"user_default":}',
            'ohmyzsh::install {"user_with_plugins":}',
            'ohmyzsh::install {"user_with_custom_plugins":}',
            'ohmyzsh::install {"root":}',
            'user{user: }',
          ]
        end

        context "using case #{user}" do
          let(:title) { user }
          let(:params) { values[:params] }

          it do
            is_expected.to contain_file_line("#{user}-#{values[:expect][:plugins]}-install")
              .with_path("#{values[:expect][:home]}/.zshrc")
              .with_line("plugins=(#{values[:expect][:plugins]})")
          end
        end
      end
      context 'using bad data' do
        let(:title) { 'user' }

        context 'using hash as plugins' do
          let(:params) { { plugins: { 'this' => 'is a hash' } } }

          it { expect { is_expected.to compile }.to raise_error }
        end
        context 'using integer as plugins' do
          let(:params) { { plugins: 1 } }

          it { expect { is_expected.to compile }.to raise_error }
        end
      end
    end
  end
end
