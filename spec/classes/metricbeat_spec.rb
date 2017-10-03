require 'spec_helper'

describe 'metricbeat' do
  on_supported_os(facterversion: '2.4').each do |os, os_facts|
    context "on #{os}" do
      context 'with defaults' do
        let(:facts) { os_facts }

        it { is_expected.to raise_error(Puppet::Error) }
      end

      context 'with elasticsearch output' do
        let(:facts) { os_facts }
        let(:params) do
          {
            'modules' => [{ 'module' => 'system', 'metricsets' => %w[cpu memory], 'period' => '10s' }],
            'outputs' => { 'elasticsearch' => { 'hosts' => ['http://localhost:9200'] } },
          }
        end

        it { is_expected.to compile }
        it { is_expected.to contain_class('metricbeat::config').that_notifies('Class[metricbeat::service]') }
        it { is_expected.to contain_class('metricbeat::install').that_comes_before('Class[metricbeat::config]').that_notifies('Class[metricbeat::service]') }
        it { is_expected.to contain_class('metricbeat::repo').that_comes_before('Class[metricbeat::install]') }
        it { is_expected.to contain_class('metricbeat::service') }

        it { is_expected.to contain_package('metricbeat').with(ensure: 'present') }
        it do
          is_expected.to contain_file('metricbeat.yml').with(
            ensure: 'present',
            owner: 'root',
            group: 'root',
            mode: '0644',
            path: '/etc/metricbeat/metricbeat.yml',
          )
        end
        it do
          is_expected.to contain_service('metricbeat').with(
            ensure: 'running',
            enable: true,
            hasrestart: true,
          )
        end

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
        let(:params) do
          {
            'manage_repo' => false,
            'modules'     => [{ 'module' => 'system', 'metricsets' => %w[cpu memory], 'period' => '10s' }],
            'outputs'     => { 'elasticsearch' => { 'hosts' => ['http://localhost:9200'] } },
          }
        end

        it { is_expected.to compile }
        it { is_expected.to contain_class('metricbeat::config').that_notifies('Class[metricbeat::service]') }
        it { is_expected.to contain_class('metricbeat::install').that_comes_before('Class[metricbeat::config]').that_notifies('Class[metricbeat::service]') }
        it { is_expected.not_to contain_class('metricbeat::repo') }
        it { is_expected.to contain_class('metricbeat::service') }

        it { is_expected.to contain_package('metricbeat').with(ensure: 'present') }
        it do
          is_expected.to contain_file('metricbeat.yml').with(
            ensure: 'present',
            owner: 'root',
            group: 'root',
            mode: '0644',
            path: '/etc/metricbeat/metricbeat.yml',
          )
        end
        it do
          is_expected.to contain_service('metricbeat').with(
            ensure: 'running',
            enable: true,
            hasrestart: true,
          )
        end

        if os_facts[:os][:family] == 'RedHat'
          it do
            is_expected.not_to contain_yumrepo('beats')
          end
        end
      end

      context 'with ensure = absent' do
        let(:facts) { os_facts }
        let(:params) do
          {
            'ensure'  => 'absent',
            'modules' => [{ 'module' => 'system', 'metricsets' => %w[cpu memory], 'period' => '10s' }],
            'outputs' => { 'elasticsearch' => { 'hosts' => ['http://localhost:9200'] } },
          }
        end

        it { is_expected.to compile }
        it { is_expected.to contain_class('metricbeat::config') }
        it { is_expected.to contain_class('metricbeat::install') }
        it { is_expected.to contain_class('metricbeat::repo').that_comes_before('Class[metricbeat::install]') }
        it { is_expected.to contain_class('metricbeat::service').that_comes_before('Class[metricbeat::install]') }

        it { is_expected.to contain_package('metricbeat').with(ensure: 'absent') }
        it do
          is_expected.to contain_file('metricbeat.yml').with(
            ensure: 'absent',
            path: '/etc/metricbeat/metricbeat.yml',
          )
        end
        it do
          is_expected.to contain_service('metricbeat').with(
            ensure: 'stopped',
            enable: false,
            hasrestart: true,
          )
        end

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
        let(:params) do
          {
            'modules'        => [{ 'module' => 'system', 'metricsets' => %w[cpu memory], 'period' => '10s' }],
            'outputs'        => { 'elasticsearch' => { 'hosts' => ['http://localhost:9200'] } },
            'package_ensure' => '5.6.2-1',
          }
        end

        it { is_expected.to compile }
        it { is_expected.to contain_class('metricbeat::config').that_notifies('Class[metricbeat::service]') }
        it { is_expected.to contain_class('metricbeat::install').that_comes_before('Class[metricbeat::config]').that_notifies('Class[metricbeat::service]') }
        it { is_expected.to contain_class('metricbeat::service') }
        it { is_expected.to contain_class('metricbeat::repo').that_comes_before('Class[metricbeat::install]') }

        it { is_expected.to contain_package('metricbeat').with(ensure: '5.6.2-1') }
        it do
          is_expected.to contain_file('metricbeat.yml').with(
            ensure: 'present',
            owner: 'root',
            group: 'root',
            mode: '0644',
            path: '/etc/metricbeat/metricbeat.yml',
          )
        end
        it do
          is_expected.to contain_service('metricbeat').with(
            ensure: 'running',
            enable: true,
            hasrestart: true,
          )
        end

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

      context 'with service_has_restart = false' do
        let(:facts) { os_facts }
        let(:params) do
          {
            'modules'             => [{ 'module' => 'system', 'metricsets' => %w[cpu memory], 'period' => '10s' }],
            'outputs'             => { 'elasticsearch' => { 'hosts' => ['http://localhost:9200'] } },
            'service_has_restart' => false,
          }
        end

        it { is_expected.to compile }
        it { is_expected.to contain_class('metricbeat::config').that_notifies('Class[metricbeat::service]') }
        it { is_expected.to contain_class('metricbeat::install').that_comes_before('Class[metricbeat::config]').that_notifies('Class[metricbeat::service]') }
        it { is_expected.to contain_class('metricbeat::service') }
        it { is_expected.to contain_class('metricbeat::repo').that_comes_before('Class[metricbeat::install]') }

        it { is_expected.to contain_package('metricbeat').with(ensure: 'present') }
        it do
          is_expected.to contain_file('metricbeat.yml').with(
            ensure: 'present',
            owner: 'root',
            group: 'root',
            mode: '0644',
            path: '/etc/metricbeat/metricbeat.yml',
          )
        end
        it do
          is_expected.to contain_service('metricbeat').with(
            ensure: 'running',
            enable: true,
            hasrestart: false,
          )
        end

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

      context 'with service_ensure = disabled' do
        let(:facts) { os_facts }
        let(:params) do
          {
            'modules'        => [{ 'module' => 'system', 'metricsets' => %w[cpu memory], 'period' => '10s' }],
            'outputs'        => { 'elasticsearch' => { 'hosts' => ['http://localhost:9200'] } },
            'service_ensure' => 'disabled',
          }
        end

        it { is_expected.to compile }
        it { is_expected.to contain_class('metricbeat::config').that_notifies('Class[metricbeat::service]') }
        it { is_expected.to contain_class('metricbeat::install').that_comes_before('Class[metricbeat::config]').that_notifies('Class[metricbeat::service]') }
        it { is_expected.to contain_class('metricbeat::service') }
        it { is_expected.to contain_class('metricbeat::repo').that_comes_before('Class[metricbeat::install]') }

        it { is_expected.to contain_package('metricbeat').with(ensure: 'present') }
        it do
          is_expected.to contain_file('metricbeat.yml').with(
            ensure: 'present',
            owner: 'root',
            group: 'root',
            mode: '0644',
            path: '/etc/metricbeat/metricbeat.yml',
          )
        end
        it do
          is_expected.to contain_service('metricbeat').with(
            ensure: 'stopped',
            enable: false,
            hasrestart: true,
          )
        end

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

      context 'with service_ensure = running' do
        let(:facts) { os_facts }
        let(:params) do
          {
            'modules'        => [{ 'module' => 'system', 'metricsets' => %w[cpu memory], 'period' => '10s' }],
            'outputs'        => { 'elasticsearch' => { 'hosts' => ['http://localhost:9200'] } },
            'service_ensure' => 'running',
          }
        end

        it { is_expected.to compile }
        it { is_expected.to contain_class('metricbeat::config').that_notifies('Class[metricbeat::service]') }
        it { is_expected.to contain_class('metricbeat::install').that_comes_before('Class[metricbeat::config]').that_notifies('Class[metricbeat::service]') }
        it { is_expected.to contain_class('metricbeat::service') }
        it { is_expected.to contain_class('metricbeat::repo').that_comes_before('Class[metricbeat::install]') }

        it { is_expected.to contain_package('metricbeat').with(ensure: 'present') }
        it do
          is_expected.to contain_file('metricbeat.yml').with(
            ensure: 'present',
            owner: 'root',
            group: 'root',
            mode: '0644',
            path: '/etc/metricbeat/metricbeat.yml',
          )
        end
        it do
          is_expected.to contain_service('metricbeat').with(
            ensure: 'running',
            enable: false,
            hasrestart: true,
          )
        end

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

      context 'with service_ensure = unmanaged' do
        let(:facts) { os_facts }
        let(:params) do
          {
            'modules'        => [{ 'module' => 'system', 'metricsets' => %w[cpu memory], 'period' => '10s' }],
            'outputs'        => { 'elasticsearch' => { 'hosts' => ['http://localhost:9200'] } },
            'service_ensure' => 'unmanaged',
          }
        end

        it { is_expected.to compile }
        it { is_expected.to contain_class('metricbeat::config').that_notifies('Class[metricbeat::service]') }
        it { is_expected.to contain_class('metricbeat::install').that_comes_before('Class[metricbeat::config]').that_notifies('Class[metricbeat::service]') }
        it { is_expected.to contain_class('metricbeat::service') }
        it { is_expected.to contain_class('metricbeat::repo').that_comes_before('Class[metricbeat::install]') }

        it { is_expected.to contain_package('metricbeat').with(ensure: 'present') }
        it do
          is_expected.to contain_file('metricbeat.yml').with(
            ensure: 'present',
            owner: 'root',
            group: 'root',
            mode: '0644',
            path: '/etc/metricbeat/metricbeat.yml',
          )
        end
        it do
          is_expected.to contain_service('metricbeat').with(
            ensure: nil,
            enable: false,
            hasrestart: true,
          )
        end

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

      context 'with service_ensure = thisisnew' do
        let(:facts) { os_facts }
        let(:params) { { 'ensure' => 'thisisnew' } }

        it { is_expected.to raise_error(Puppet::Error) }
      end
    end
  end
end
