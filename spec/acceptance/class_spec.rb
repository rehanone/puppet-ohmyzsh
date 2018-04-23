require 'spec_helper_acceptance'

describe 'ohmyzsh class:', unless: UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  it 'ohmyzsh is expected run successfully' do
    pp = "class { 'ohmyzsh': }"

    # Apply twice to ensure no errors the second time.
    apply_manifest(pp, catch_failures: true) do |r|
      expect(r.stderr).not_to match(%r{error}i)
    end
    apply_manifest(pp, catch_failures: true) do |r|
      expect(r.stderr).not_to eq(%r{error}i)

      expect(r.exit_code).to be_zero
    end
  end

  context 'installs => { root => { set_sh => true } }' do
    it 'runs successfully' do
      pp = "class { 'ohmyzsh': "\
             "installs => { 'root' => { set_sh => true } }, "\
             "themes => { 'root' => { theme => 'random' } }, "\
             "plugins => { 'root' => { plugins => ['git', 'scala'] } }, }"

      apply_manifest(pp, catch_failures: true) do |r|
        expect(r.stderr).not_to match(%r{error}i)
      end
    end
  end
end
