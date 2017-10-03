# metricbeat
#
# This class installs the Elastic metricbeat statistic and metric
# collector and manages the configuration on the include nodes.
#
# @summary Install, configures and manages Metricbeat on the target node.
#
# @example
#   include metricbeat
#
# Parameters
# ----------
#
# * `outputs`
# [Hash] Configures the output(s) this Metricbeat instance should send
# to. Required!
#
# * `ensure`
# [String] Ensures that all required resources are managed or removed
# from the target node. This is good for bulk uninstallation across a
# network. Valid values are 'present' or 'absent'. (default: 'present')
#
# * `manage_repo`
# [Boolean] Weather the upstream (elastic) repository should be
# configured. (default: true)
#
# * `package_ensure`
# [String] The desired state of Package['metricbeat']. Only valid when
# $ensure is present. (default: 'present')
#
# * `path_conf`
# [Absolute Path] The location of the configuration files. Recommend
# leaving the default value. (default: '/etc/metricbeat')
#
# * `service_ensure`
# [String] The desirec state of Service['metricbeat']. Only valid when
# $ensure is present. Valid values are 'enabled', 'disabled', 'running'
# or 'unmanaged'. (default: 'enabled')
#
# * `service_has_restart`
# [Boolean] When true use the restart function of the init script.
# When false the init script's stop and start functions will be used.
# (default: true)
class metricbeat(
  Hash $outputs,
  Enum['present', 'absent'] $ensure                                   = 'present',
  Boolean $manage_repo                                                = true,
  String $package_ensure                                              = 'present',
  Stdlib::Absolutepath $path_conf                                     = '/etc/metricbeat',
  Enum['enabled', 'disabled', 'running', 'unmanaged'] $service_ensure = 'enabled',
  Boolean $service_has_restart                                        = true,
) {
  if $manage_repo {
    class{'metricbeat::repo':}

    Anchor['metricbeat::begin']
    -> Class['metricbeat::repo']
    -> Class['metricbeat::install']
  }

  if $ensure == 'present' {
    Anchor['metricbeat::begin']
    -> Class['metricbeat::install']
    -> Class['metricbeat::config']
    ~> Class['metricbeat::service']

    Class['metricbeat::install']
    ~> Class['metricbeat::service']
  }
  else {
    Anchor['metricbeat::begin']
    -> Class['metricbeat::service']
    -> Class['metricbeat::install']
  }

  anchor{'metricbeat::begin':}
  class{'metricbeat::config':}
  class{'metricbeat::install':}
  class{'metricbeat::service':}
}
