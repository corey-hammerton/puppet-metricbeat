require 'spec_helper'

describe 'metricbeat::install' do
  on_supported_os(facterversion: '2.4').each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to raise_error(Puppet::Error) }
    end
  end
end
