require 'spec_helper'

describe 'metricbeat' do
  on_supported_os(facterversion: '2.4').each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      describe 'metricbeat::config' do
        if os_facts[:kernel] == 'windows'
          it do
            is_expected.to contain_file('metricbeat.yml').with(
              ensure: 'present',
              path: 'C:/Program Files/Metricbeat/metricbeat.yml',
              validate_cmd: "\"C:\\Program Files\\Metricbeat\\metricbeat.exe\" -N configtest -c \"%\"", # rubocop:disable StringLiterals
            )
          end
        else
          it do
            is_expected.to contain_file('metricbeat.yml').with(
              ensure: 'present',
              owner: 'root',
              group: 'root',
              mode: '0600',
              path: '/etc/metricbeat/metricbeat.yml',
              validate_cmd: '/usr/share/metricbeat/bin/metricbeat -configtest -c %',
            )
          end
        end

        describe 'with ensure = absent' do
          let(:params) { { 'ensure' => 'absent' } }

          if os_facts[:kernel] == 'windows'
            it do
              is_expected.to contain_file('metricbeat.yml').with(
                ensure: 'absent',
                path: 'C:/Program Files/Metricbeat/metricbeat.yml',
                validate_cmd: "\"C:\\Program Files\\Metricbeat\\metricbeat.exe\" -N configtest -c \"%\"", # rubocop:disable StringLiterals
              )
            end
          else
            it do
              is_expected.to contain_file('metricbeat.yml').with(
                ensure: 'absent',
                path: '/etc/metricbeat/metricbeat.yml',
                validate_cmd: '/usr/share/metricbeat/bin/metricbeat -configtest -c %',
              )
            end
          end
        end

        describe 'with disable_configtest = true' do
          let(:params) { { 'disable_configtest' => true } }

          if os_facts[:kernel] == 'windows'
            it do
              is_expected.to contain_file('metricbeat.yml').with(
                ensure: 'present',
                path: 'C:/Program Files/Metricbeat/metricbeat.yml',
                validate_cmd: nil,
              )
            end
          else
            it do
              is_expected.to contain_file('metricbeat.yml').with(
                ensure: 'present',
                owner: 'root',
                group: 'root',
                mode: '0600',
                path: '/etc/metricbeat/metricbeat.yml',
                validate_cmd: nil,
              )
            end
          end
        end

        describe 'with config_mode = 0644' do
          let(:params) { { 'config_mode' => '0644' } }

          if os_facts[:kernel] != 'windows'
            it do
              is_expected.to contain_file('metricbeat.yml').with(
                ensure: 'present',
                owner: 'root',
                group: 'root',
                mode: '0644',
                path: '/etc/metricbeat/metricbeat.yml',
                validate_cmd: '/usr/share/metricbeat/bin/metricbeat -configtest -c %',
              )
            end
          end
        end

        describe 'with config_mode = 9999' do
          let(:params) { { 'config_mode' => '9999' } }

          it { is_expected.to raise_error(Puppet::Error) }
        end

        describe 'with major_version = 6 for new config test flag' do
          let(:params) { { 'major_version' => '6' } }

          if os_facts[:kernel] == 'windows'
            it do
              is_expected.to contain_file('metricbeat.yml').with(
                ensure: 'present',
                path: 'C:/Program Files/Metricbeat/metricbeat.yml',
                validate_cmd: "\"C:\\Program Files\\Metricbeat\\metricbeat.exe\" --path.config \"C:/Program Files/Metricbeat\" test config", # rubocop:disable StringLiterals
              )
            end
          else
            it do
              is_expected.to contain_file('metricbeat.yml').with(
                ensure: 'present',
                owner: 'root',
                group: 'root',
                mode: '0600',
                path: '/etc/metricbeat/metricbeat.yml',
                validate_cmd: '/usr/share/metricbeat/bin/metricbeat --path.config /etc/metricbeat test config',
              )
            end
          end
        end
      end

      describe 'metricbeat::install' do
        if os_facts[:kernel] == 'windows'
          it do
            is_expected.to contain_file('C:/Program Files').with(ensure: 'directory')
            is_expected.to contain_archive('C:/Windows/Temp/metricbeat-6.6.1-windows-x86_64.zip').with(
              creates: 'C:/Program Files/Metricbeat/metricbeat-6.6.1-windows-x86_64',
              source: 'https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-6.6.1-windows-x86_64.zip',
            )
            is_expected.to contain_exec('unzip metricbeat-6.6.1-windows-x86_64').with(
              command: "\$sh=New-Object -COM Shell.Application;\$sh.namespace((Convert-Path 'C:/Program Files')).Copyhere(\$sh.namespace((Convert-Path 'C:/Windows/Temp/metricbeat-6.6.1-windows-x86_64.zip')).items(), 16)", # rubocop:disable LineLength
              creates: 'C:/Program Files/Metricbeat/metricbeat-6.6.1-windows-x86_64',
            )
            is_expected.to contain_exec('stop service metricbeat-6.6.1-windows-x86_64').with(
              creates: 'C:/Program Files/Metricbeat/metricbeat-6.6.1-windows-x86_64',
              command: 'Set-Service -Name metricbeat -Status Stopped',
              onlyif: 'if(Get-WmiObject -Class Win32_Service -Filter "Name=\'metricbeat\'") {exit 0} else {exit 1}',
            )
            is_expected.to contain_exec('rename metricbeat-6.6.1-windows-x86_64').with(
              creates: 'C:/Program Files/Metricbeat/metricbeat-6.6.1-windows-x86_64',
              command: "Remove-Item 'C:/Program Files/Metricbeat' -Recurse -Force -ErrorAction SilentlyContinue;Rename-Item 'C:/Program Files/metricbeat-6.6.1-windows-x86_64' 'C:/Program Files/Metricbeat'", # rubocop:disable LineLength
            )
            is_expected.to contain_exec('mark metricbeat-6.6.1-windows-x86_64').with(
              creates: 'C:/Program Files/Metricbeat/metricbeat-6.6.1-windows-x86_64',
              command: "New-Item 'C:/Program Files/Metricbeat/metricbeat-6.6.1-windows-x86_64' -ItemType file",
            )
            is_expected.to contain_exec('install metricbeat-6.6.1-windows-x86_64').with(
              command: './install-service-metricbeat.ps1',
              cwd: 'C:/Program Files/Metricbeat',
              refreshonly: true,
            )
          end
        else
          it { is_expected.to contain_package('metricbeat').with(ensure: 'present') }
        end

        describe 'with ensure = absent' do
          let(:params) { { 'ensure' => 'absent' } }

          if os_facts[:kernel] != 'windows'
            it { is_expected.to contain_package('metricbeat').with(ensure: 'absent') }
          end
        end

        describe 'with package_ensure to a specific version' do
          let(:params) { { 'package_ensure' => '6.6.1' } }

          if os_facts[:kernel] != 'windows'
            it { is_expected.to contain_package('metricbeat').with(ensure: '6.6.1') }
          end
        end

        describe 'with package_ensure = latest' do
          let(:params) { { 'package_ensure' => 'latest' } }

          if os_facts[:kernel] != 'windows'
            it { is_expected.to contain_package('metricbeat').with(ensure: 'latest') }
          end
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
            'modules' => [{ 'module' => 'system', 'metricsets' => ['cpu', 'memory'], 'period' => '10s' }],
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
            'modules'     => [{ 'module' => 'system', 'metricsets' => ['cpu', 'memory'], 'period' => '10s' }],
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
            'modules' => [{ 'module' => 'system', 'metricsets' => ['cpu', 'memory'], 'period' => '10s' }],
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
              { 'module' => 'system', 'metricsets' => ['cpu', 'memory'], 'period' => '10s' },
              { 'module' => 'apache', 'metricsets' => ['status'], 'period' => '10s', 'hosts' => ['http://127.0.0.1'] },
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
            'modules'    => [{ 'module' => 'system', 'metricsets' => ['cpu', 'memory'], 'period' => '10s' }],
            'outputs'    => { 'elasticsearch' => { 'hosts' => ['http://localhost:9200'] } },
            'processors' => [
              { 'add_cloud_metadata' => { 'timeout' => '3s' } },
              { 'drop_fields' => { 'fields' => ['field1', 'field2'] } },
            ],
          }
        end

        it { is_expected.to compile }
      end
    end
  end
end
