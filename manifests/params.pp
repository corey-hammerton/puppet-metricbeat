# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include metricbeat::params
class metricbeat::params {
  $ensure             = 'present'
  $cloud_id           = undef
  $cloud_auth         = undef
  $beat_name          = $facts['networking']['hostname']
  $config_mode        = '0600'
  $disable_configtest = false
  $download_url       = undef
  $extract_method     = 'shell'
  $fields             = undef
  $fields_under_root  = false
  $manage_repo        = true
  $major_version      = '5'
  $modules            = [{}]
  $module_templates   = ['system']
  $outputs            = {}
  $processors         = undef
  $proxy_address      = undef
  $queue              = {
    'mem' => {
      'events' => 4096,
      'flush'  => {
        'min_events' => 0,
        'timeout'    => '0s',
      },
    },
  }
  $queue_size          = 1000
  $service_ensure      = 'enabled'
  $service_has_restart = true
  $tags                = undef
  $xpack               = undef
  $apt_repo_url        = undef
  $yum_repo_url        = undef

  case $::kernel {
    'Linux': {
      $config_dir = '/etc/metricbeat'
      $install_dir = undef
      $logging     = {
        'level' => 'info',
        'files' => {
          'keepfiles'        => 7,
          'name'             => 'metricbeat',
          'path'             => '/var/log/metricbeat',
          'rotateeverybytes' => '10485760',
        },
        'metrics' => {
          'enabled' => false,
          'period'  => '30s',
        },
        'selectors' => undef,
        'to_files'  => true,
        'to_syslog' => false,
      }
      $package_ensure   = 'present'
      $service_provider = $facts['os']['family'] ? {
        'RedHat' => 'redhat',
        default  => undef,
      }
      $tmp_dir        = '/tmp'
      $url_arch       = undef
    }
    'Windows': {
      $config_dir      = 'C:/Program Files/Metricbeat'
      $install_dir      = 'C:/Program Files'
      $logging          = {
        'level' => 'info',
        'files' => {
          'keepfiles'        => 7,
          'name'             => 'metricbeat',
          'path'             => 'C:/Program Files/Metricbeat/logs',
          'rotateeverybytes' => '10485760',
        },
        'metrics' => {
          'enabled' => false,
          'period'  => '30s',
        },
        'selectors'   => undef,
        'to_eventlog' => false,
        'to_files'    => true,
      }
      $package_ensure   = '6.6.1'
      $service_provider = undef
      $tmp_dir          = 'C:/Windows/Temp'
      $url_arch         = $facts['os']['architecture'] ? {
        'x86'   => 'x86',
        'x64'   => 'x86_64',
        default => fail("${facts['os']['architecture']} is not supported by metricbeat."),
      }
    }
    default: {
      fail("${::kernel} is not supported by metricbeat.")
    }
  }
}
