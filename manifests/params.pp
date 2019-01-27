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
  $fields             = undef
  $fields_under_root  = false
  $manage_repo        = true
  $major_version      = '5'
  $modules            = [{}]
  $outputs            = {}
  $package_ensure     = 'present'
  $processors         = undef
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
      $logging = {
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
    }
    default: {
      fail("${::kernel} is not supported by metricbeat.")
    }
  }
}
