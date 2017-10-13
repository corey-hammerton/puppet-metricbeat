# metricbeat::service
# @api private
#
# Manages the state of Service['metricbeat']
#
# @summary Manages the state of Service['metricbeat']
class metricbeat::service inherits metricbeat {
  if $metricbeat::ensure == 'present' {
    case $metricbeat::service_ensure {
      'enabled': {
        $service_ensure = 'running'
        $service_enable = true
      }
      'disabled': {
        $service_ensure = 'stopped'
        $service_enable = false
      }
      'running': {
        $service_ensure = 'running'
        $service_enable = false
      }
      'unmanaged': {
        $service_ensure = undef
        $service_enable = false
      }
      default: {
      }
    }
  }
  else {
    $service_ensure = 'stopped'
    $service_enable = false
  }

  service{'metricbeat':
    ensure     => $service_ensure,
    enable     => $service_enable,
    hasrestart => $metricbeat::service_has_restart,
  }
}
