require 'spec_helper'

testcases = {
  'user_default' => {
    params: { },
    expect: { home: '/home/user_default', plugins:'git' }
  },
  'user_with_plugins' => {
    params: { plugins: ['tmux'] },
    expect: { home: '/home/user_with_plugins', plugins: 'tmux' }
  },
  'user_with_custom_plugins' => {
    params: { plugins: ['scala'], custom_plugins: { 'zsh-autosuggestions' => 'https://github.com/zsh-users/zsh-autosuggestions.git' } },
    expect: { home: '/home/user_with_custom_plugins', plugins: 'scala zsh-autosuggestions' }
  },
  'root' => {
    params: { plugins: ['git', 'tmux'] },
    expect: { home: '/root', plugins: 'git tmux' }
  },
}

describe 'ohmyzsh::plugins' do
  testcases.each do |user, values|
    context "using case #{user}" do
      let(:title) { user }
      let(:params) { values[:params] }
      it do
        should contain_file_line("#{user}-#{values[:expect][:plugins]}-install")
          .with_path("#{values[:expect][:home]}/.zshrc")
          .with_line("plugins=(#{values[:expect][:plugins]})")
      end
    end
  end
  context 'using bad data' do
    let(:title) { 'user' }
    context 'using hash as plugins' do
      let(:params) { { plugins: { 'this' => 'is a hash' } } }
      it { expect { should compile }.to raise_error }
    end
    context 'using integer as plugins' do
      let(:params) { { plugins: 1 } }
      it { expect { should compile }.to raise_error }
    end
  end
end
