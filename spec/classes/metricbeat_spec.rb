require 'spec_helper'

describe 'metricbeat' do
  on_supported_os(facterversion: '2.4').each do |os, os_facts|
    context "on #{os}" do
      context 'with defaults' do
        let(:facts) { os_facts }

        it { is_expected.to compile }
        it { is_expected.to contain_class('metricbeat::repo') }

        if os_facts[:os][:family] == 'RedHat'
          it do
            is_expected.to contain_yumrepo('beats').with(
              baseurl: 'https://artifacts.elastic.co/packages/5.x/yum',
              enabled: 1,
              gpgcheck: 1,
              gpgkey: 'https://artifacts.elastic.co/GPG-KEY-elasticsearch',
            )
          end
        end
      end

      context 'with manage_repo = false' do
        let(:facts) { os_facts }
        let(:params) { { 'manage_repo' => false } }

        it { is_expected.to compile }
        it { is_expected.not_to contain_class('metricbeat::repo') }

        if os_facts[:os][:family] == 'RedHat'
          it do
            is_expected.not_to contain_yumrepo('beats')
          end
        end
      end
    end
  end
end
