require 'spec_helper'

testcases = {
  'user1' => {
    params: { },
    expect: { home: '/home/user1', sh: false }
  },
  'user2' => {
    params: { scripts: { 'scripts.sh' => 'puppet:///modules/base/scripts.sh'} },
    expect: { home: '/home/user2', sh: true, disable_auto_update: true }
  },
  'root' => {
    params: { scripts: { 'scripts.sh' => 'puppet:///modules/base/scripts.sh'} },
    expect: { home: '/root', sh: false }
  },
}

describe 'ohmyzsh::profile' do
  testcases.each do |user, values|
    context "testing #{user}" do
      let(:title) { user }
      let(:params) { values[:params] }
      it do
        should contain_file("#{values[:expect][:home]}/profile")
          .with_ensure("directory")
          .with_group("#{user}")
          .with_owner("#{user}")
      end
      it do
        should contain_file_line("#{values[:expect][:home]}-profile")
          .with_ensure("present")
          .with_line("for f in ~/profile/*; do source \"$f\"; done")
          .with_match("for f in ~/profile/*; do source \"$f\"; done")
          .with_path("#{values[:expect][:home]}/.zshrc")
      end
    end
  end #testcases.each
end #describe
