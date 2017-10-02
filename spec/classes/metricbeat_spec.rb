require 'spec_helper'

describe 'metricbeat' do
  on_supported_os(facterversion: '2.4').each do |os, os_facts|
    context "on #{os}" do
      context 'with defaults' do
        let(:facts) { os_facts }

        it { is_expected.to compile }
        it { is_expected.to contain_class('metricbeat::install') }
        it { is_expected.to contain_class('metricbeat::repo').that_comes_before('Class[metricbeat::install]') }

        it { is_expected.to contain_package('metricbeat').with(ensure: 'present') }

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
        it { is_expected.to contain_class('metricbeat::install') }
        it { is_expected.not_to contain_class('metricbeat::repo') }

        it { is_expected.to contain_package('metricbeat').with(ensure: 'present') }

        if os_facts[:os][:family] == 'RedHat'
          it do
            is_expected.not_to contain_yumrepo('beats')
          end
        end
      end

      context 'with ensure = absent' do
        let(:facts) { os_facts }
        let(:params) { { 'ensure' => 'absent' } }

        it { is_expected.to compile }
        it { is_expected.to contain_class('metricbeat::install') }
        it { is_expected.to contain_class('metricbeat::repo').that_comes_before('Class[metricbeat::install]') }

        it { is_expected.to contain_package('metricbeat').with(ensure: 'absent') }

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

      context 'with ensure = idontknow' do
        let(:facts) { os_facts }
        let(:params) { { 'ensure' => 'idontknow' } }

        it { is_expected.to raise_error(Puppet::Error) }
      end

      context 'with package_ensure = 5.6.2-1' do
        let(:facts) { os_facts }
        let(:params) { { 'package_ensure' => '5.6.2-1' } }

        it { is_expected.to compile }
        it { is_expected.to contain_class('metricbeat::install') }
        it { is_expected.to contain_class('metricbeat::repo').that_comes_before('Class[metricbeat::install]') }

        it { is_expected.to contain_package('metricbeat').with(ensure: '5.6.2-1') }

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
    end
  end
end
