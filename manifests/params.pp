# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include metricbeat::params
class metricbeat::params {
  $ensure             = 'present'
  $beat_name          = $::hostname
  $config_mode        = '0600'
  $disable_configtest = false
  $download_url       = undef
  $fields             = undef
  $fields_under_root  = false
  $manage_repo        = true
  $major_version      = '5'
  $modules            = [{}]
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

  case $::kernel {
    'Linux': {
      $config_file = '/etc/metricbeat/metricbeat.yml'
      $install_dir = undef
      $logging     = {
        'level'     => 'info',
        'files'     => {
          'keepfiles'        => 7,
          'name'             => 'metricbeat',
          'path'             => '/var/log/metricbeat',
          'rotateeverybytes' => '10485760',
        },
        'metrics'   => {
          'enabled' => false,
          'period'  => '30s',
        },
        'selectors' => undef,
        'to_files'  => true,
        'to_syslog' => false,
      }
      $package_ensure   = 'present'
      $service_provider = $::osfamily ? {
        'RedHat' => 'redhat',
        default  => undef,
      }
      $tmp_dir        = '/tmp'
      $url_arch       = undef
    }
    'Windows': {
      $config_file      = 'C:/Program Files/Metricbeat/metricbeat.yml'
      $install_dir      = 'C:/Program Files'
      $package_ensure   = '5.6.2'
      $service_provider = undef
      $tmp_dir          = 'C:/Windows/Temp'
      $url_arch         = $::architecture ? {
        'x86'   => 'x86',
        'x64'   => 'x86_64',
        default => fail("${::architecture} is not supported by metricbeat."),
      }
    }
    default: {
      fail("${::kernel} is not supported by metricbeat.")
    }
  }
}
