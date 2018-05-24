require 'spec_helper'

describe 'metricbeat' do
  on_supported_os(facterversion: '2.4').each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      describe 'metricbeat::config' do
        it do
          is_expected.to contain_file('metricbeat.yml').with(
            ensure: 'present',
            owner: 'root',
            group: 'root',
            mode: '0644',
            path: '/etc/metricbeat/metricbeat.yml',
            validate_cmd: '/usr/share/metricbeat/bin/metricbeat test -c %',
          )
        end

        describe 'with ensure = absent' do
          let(:params) { { 'ensure' => 'absent' } }

          it do
            is_expected.to contain_file('metricbeat.yml').with(
              ensure: 'absent',
              path: '/etc/metricbeat/metricbeat.yml',
              validate_cmd: '/usr/share/metricbeat/bin/metricbeat test -c %',
            )
          end
        end

        describe 'with disable_configtest = true' do
          let(:params) { { 'disable_configtest' => true } }

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
        end
      end

      describe 'metricbeat::install' do
        it { is_expected.to contain_package('metricbeat').with(ensure: 'present') }

        describe 'with ensure = absent' do
          let(:params) { { 'ensure' => 'absent' } }

          it { is_expected.to contain_package('metricbeat').with(ensure: 'absent') }
        end

        describe 'with package_ensure to a specific version' do
          let(:params) { { 'package_ensure' => '5.6.2-1' } }

          it { is_expected.to contain_package('metricbeat').with(ensure: '5.6.2-1') }
        end

        describe 'with package_ensure = latest' do
          let(:params) { { 'package_ensure' => 'latest' } }

          it { is_expected.to contain_package('metricbeat').with(ensure: 'latest') }
        end
      end

      describe 'metricbeat::repo' do
        case os_facts[:osfamily]
        when 'RedHat'
          it do
            is_expected.to contain_yumrepo('beats').with(
              baseurl: 'https://artifacts.elastic.co/packages/5.x/yum',
              enabled: 1,
              gpgcheck: 1,
              gpgkey: 'https://artifacts.elastic.co/GPG-KEY-elasticsearch',
            )
          end
        when 'Debian'
          it { is_expected.to contain_class('apt') }

          it do
            is_expected.to contain_apt__source('beats').with(
              location: 'https://artifacts.elastic.co/packages/5.x/apt',
              release: 'stable',
              repos: 'main',
              key: {
                'id' => '46095ACC8548582C1A2699A9D27D666CD88E42B4',
                'source' => 'https://artifacts.elastic.co/GPG-KEY-elasticsearch',
              },
            )
          end
        when 'SuSe'
          it do
            is_expected.to contain_zypprepo('beats').with(
              baseurl: 'https://artifacts.elastic.co/packages/5.x/yum',
              autorefresh: 1,
              enabled: 1,
              gpgcheck: 1,
              gpgkey: 'https://artifacts.elastic.co/GPG-KEY-elasticsearch',
              name: 'beats',
              type: 'yum',
            )
          end
        end

        describe 'with major_version = 6' do
          let(:params) { { 'major_version' => '6' } }

          case os_facts[:osfamily]
          when 'RedHat'
            it do
              is_expected.to contain_yumrepo('beats').with(
                baseurl: 'https://artifacts.elastic.co/packages/6.x/yum',
                enabled: 1,
                gpgcheck: 1,
                gpgkey: 'https://artifacts.elastic.co/GPG-KEY-elasticsearch',
              )
            end
          when 'Debian'
            it { is_expected.to contain_class('apt') }

            it do
              is_expected.to contain_apt__source('beats').with(
                location: 'https://artifacts.elastic.co/packages/6.x/apt',
                release: 'stable',
                repos: 'main',
                key: {
                  'id' => '46095ACC8548582C1A2699A9D27D666CD88E42B4',
                  'source' => 'https://artifacts.elastic.co/GPG-KEY-elasticsearch',
                },
              )
            end
          when 'SuSe'
            it do
              is_expected.to contain_zypprepo('beats').with(
                baseurl: 'https://artifacts.elastic.co/packages/6.x/yum',
                autorefresh: 1,
                enabled: 1,
                gpgcheck: 1,
                gpgkey: 'https://artifacts.elastic.co/GPG-KEY-elasticsearch',
                name: 'beats',
                type: 'yum',
              )
            end
          end
        end

        describe 'with major_version = idontknow' do
          let(:params) { { 'major_version' => 'idontknow' } }

          it { is_expected.to raise_error(Puppet::Error) }
        end
      end

      describe 'metricbeat::service' do
        it do
          is_expected.to contain_service('metricbeat').with(
            ensure: 'running',
            enable: true,
            hasrestart: true,
          )
        end

        describe 'with ensure = absent' do
          let(:params) { { 'ensure' => 'absent' } }

          it do
            is_expected.to contain_service('metricbeat').with(
              ensure: 'stopped',
              enable: false,
              hasrestart: true,
            )
          end
        end

        describe 'with service_has_restart = false' do
          let(:params) { { 'service_has_restart' => false } }

          it do
            is_expected.to contain_service('metricbeat').with(
              ensure: 'running',
              enable: true,
              hasrestart: false,
            )
          end
        end

        describe 'with service_ensure = disabled' do
          let(:params) { { 'service_ensure' => 'disabled' } }

          it do
            is_expected.to contain_service('metricbeat').with(
              ensure: 'stopped',
              enable: false,
              hasrestart: true,
            )
          end
        end

        describe 'with service_ensure = running' do
          let(:params) { { 'service_ensure' => 'running' } }

          it do
            is_expected.to contain_service('metricbeat').with(
              ensure: 'running',
              enable: false,
              hasrestart: true,
            )
          end
        end

        describe 'with service_ensure = unmanaged' do
          let(:params) { { 'service_ensure' => 'unmanaged' } }

          it do
            is_expected.to contain_service('metricbeat').with(
              ensure: nil,
              enable: false,
              hasrestart: true,
            )
          end
        end
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
      end

      context 'with ensure = idontknow' do
        let(:params) { { 'ensure' => 'idontknow' } }

        it { is_expected.to raise_error(Puppet::Error) }
      end

      context 'with service_ensure = thisisnew' do
        let(:params) { { 'ensure' => 'thisisnew' } }

        it { is_expected.to raise_error(Puppet::Error) }
      end

      context 'with multiple modules' do
        let(:params) do
          {
            'ensure'  => 'absent',
            'modules' => [
              { 'module' => 'system', 'metricsets' => %w[cpu memory], 'period' => '10s' },
              { 'module' => 'apache', 'metricsets' => %w[status], 'period' => '10s', 'hosts' => ['http://127.0.0.1'] },
            ],
            'outputs' => { 'elasticsearch' => { 'hosts' => ['http://localhost:9200'] } },
          }
        end

        it { is_expected.to compile }
      end

      context 'with multiple processors' do
        let(:params) do
          {
            'ensure'     => 'absent',
            'modules'    => [{ 'module' => 'system', 'metricsets' => %w[cpu memory], 'period' => '10s' }],
            'outputs'    => { 'elasticsearch' => { 'hosts' => ['http://localhost:9200'] } },
            'processors' => [
              { 'add_cloud_metadata' => { 'timeout' => '3s' } },
              { 'drop_fields' => { 'fields' => %w[field1 field2] } },
            ],
          }
        end

        it { is_expected.to compile }
      end
    end
  end
end
