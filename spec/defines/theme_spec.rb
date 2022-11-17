require 'spec_helper'

testcases = {
  'user1' => {
    params: {},
    expect: { home: '/home/user1', theme: 'clean' },
  },
  'user2' => {
    params: { theme: 'afowler' },
    expect: { home: '/home/user2', theme: 'afowler' },
  },
  'root' => {
    params: { theme: 'robbyrussell' },
    expect: { home: '/root', theme: 'robbyrussell' },
  },
}

describe 'ohmyzsh::theme' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      testcases.each do |user, values|
        let(:pre_condition) do
          [
            'ohmyzsh::install {"user1":}',
            'ohmyzsh::install {"user2":}',
            'ohmyzsh::install {"root":}',
            'user{user: }',
          ]
        end

        context "using case #{user}" do
          let(:title) { user }
          let(:params) { values[:params] }

          it do
            is_expected.to contain_file_line("#{user}-#{values[:expect][:theme]}-install")
              .with_path("#{values[:expect][:home]}/.zshrc")
              .with_line(%(ZSH_THEME="#{values[:expect][:theme]}"))
          end
        end
      end

      context 'using bad data' do
        let(:title) { 'user' }

        context 'using array' do
          let(:params) { { theme: ['this', 'is an array'] } }

          it { expect { is_expected.to compile }.to raise_error Exception }
        end
        context 'using hash' do
          let(:params) { { theme: { 'this' => 'is a hash' } } }

          it { expect { is_expected.to compile }.to raise_error Exception }
        end
        context 'using integer' do
          let(:params) { { plugins: 1 } }

          it { expect { is_expected.to compile }.to raise_error Exception }
        end
      end
    end
  end
end
