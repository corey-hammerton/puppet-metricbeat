require 'spec_helper'

describe 'metricbeat' do
  on_supported_os(facterversion: '2.4').each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with defaults' do
        it { is_expected.to raise_error(Puppet::Error) }
      end

      context 'with elasticsearch output' do
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
        elsif os_facts[:os][:family] == 'Debian'
          it do
            is_expected.to contain_apt__source('beats').with(
              location: 'https://artifacts.elastic.co/packages/5.x/apt',
              release: 'stable',
              repos: 'main',
              key: {
                id: '46095ACC8548582C1A2699A9D27D666CD88E42B4',
                source: 'https://artifacts.elastic.co/GPG-KEY-elasticsearch',
              },
            )
          end
        end
      end

      context 'with manage_repo = false' do
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
          it { is_expected.not_to contain_yumrepo('beats') }
        elsif os_facts[:os][:family] == 'Debian'
          it { is_exptected.not_to contain_apt('beats') }
        end
      end

      context 'with ensure = absent' do
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
        elsif os_facts[:os][:family] == 'Debian'
          it do
            is_expected.to contain_apt__source('beats').with(
              location: 'https://artifacts.elastic.co/packages/5.x/apt',
              release: 'stable',
              repos: 'main',
              key: {
                id: '46095ACC8548582C1A2699A9D27D666CD88E42B4',
                source: 'https://artifacts.elastic.co/GPG-KEY-elasticsearch',
              },
            )
          end
        end
      end

      context 'with ensure = idontknow' do
        let(:params) { { 'ensure' => 'idontknow' } }

        it { is_expected.to raise_error(Puppet::Error) }
      end

      context 'with package_ensure = 5.6.2-1' do
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
        elsif os_facts[:os][:family] == 'Debian'
          it do
            is_expected.to contain_apt__source('beats').with(
              location: 'https://artifacts.elastic.co/packages/5.x/apt',
              release: 'stable',
              repos: 'main',
              key: {
                id: '46095ACC8548582C1A2699A9D27D666CD88E42B4',
                source: 'https://artifacts.elastic.co/GPG-KEY-elasticsearch',
              },
            )
          end
        end
      end

      context 'with service_has_restart = false' do
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
        elsif os_facts[:os][:family] == 'Debian'
          it do
            is_expected.to contain_apt__source('beats').with(
              location: 'https://artifacts.elastic.co/packages/5.x/apt',
              release: 'stable',
              repos: 'main',
              key: {
                id: '46095ACC8548582C1A2699A9D27D666CD88E42B4',
                source: 'https://artifacts.elastic.co/GPG-KEY-elasticsearch',
              },
            )
          end
        end
      end

      context 'with service_ensure = disabled' do
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
        elsif os_facts[:os][:family] == 'Debian'
          it do
            is_expected.to contain_apt__source('beats').with(
              location: 'https://artifacts.elastic.co/packages/5.x/apt',
              release: 'stable',
              repos: 'main',
              key: {
                id: '46095ACC8548582C1A2699A9D27D666CD88E42B4',
                source: 'https://artifacts.elastic.co/GPG-KEY-elasticsearch',
              },
            )
          end
        end
      end

      context 'with service_ensure = running' do
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
        elsif os_facts[:os][:family] == 'Debian'
          it do
            is_expected.to contain_apt__source('beats').with(
              location: 'https://artifacts.elastic.co/packages/5.x/apt',
              release: 'stable',
              repos: 'main',
              key: {
                id: '46095ACC8548582C1A2699A9D27D666CD88E42B4',
                source: 'https://artifacts.elastic.co/GPG-KEY-elasticsearch',
              },
            )
          end
        end
      end

      context 'with service_ensure = unmanaged' do
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
        elsif os_facts[:os][:family] == 'Debian'
          it do
            is_expected.to contain_apt__source('beats').with(
              location: 'https://artifacts.elastic.co/packages/5.x/apt',
              release: 'stable',
              repos: 'main',
              key: {
                id: '46095ACC8548582C1A2699A9D27D666CD88E42B4',
                source: 'https://artifacts.elastic.co/GPG-KEY-elasticsearch',
              },
            )
          end
        end
      end

      context 'with service_ensure = thisisnew' do
        let(:params) { { 'ensure' => 'thisisnew' } }

        it { is_expected.to raise_error(Puppet::Error) }
      end

      context 'with disable_configtest = true' do
        let(:params) do
          {
            'disable_configtest' => true,
            'modules'            => [{ 'module' => 'system', 'metricsets' => %w[cpu memory], 'period' => '10s' }],
            'outputs'            => { 'elasticsearch' => { 'hosts' => ['http://localhost:9200'] } },
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
            validate_cmd: nil,
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
        elsif os_facts[:os][:family] == 'Debian'
          it do
            is_expected.to contain_apt__source('beats').with(
              location: 'https://artifacts.elastic.co/packages/5.x/apt',
              release: 'stable',
              repos: 'main',
              key: {
                id: '46095ACC8548582C1A2699A9D27D666CD88E42B4',
                source: 'https://artifacts.elastic.co/GPG-KEY-elasticsearch',
              },
            )
          end
        end
      end
    end
  end
end
