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
# * `beat_name`
# [String] The name of the beat which is published as the `beat.name`
# field of each transaction. (default: $::hostname)
#
# * `ensure`
# [String] Ensures that all required resources are managed or removed
# from the target node. This is good for bulk uninstallation across a
# network. Valid values are 'present' or 'absent'. (default: 'present')
# 
# * `fields`
# Optional[Hash] Optional fields to add to each transaction to provide
# additonal information. (default: undef)
#
# * `fields_under_root`
# [Boolean] Custom fields are added to each transaction under the `fields`
# sub-dictionary. When this is true custom fields are added to the top
# level dictionary of each transaction. (default: false)
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
# * `queue_size`
# [Integer] The size of the internal queue for single events in the
# processing pipeline. (default: 1000)
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
#
# * `tags`
# Optional[Array[String]] An optional list of values to include in the 
# `tag` field of each published transaction. This is useful for
# identifying groups of servers by logical property. (default: undef)
class metricbeat(
  Hash $outputs,
  String $beat_name                                                   = $::hostname,
  Enum['present', 'absent'] $ensure                                   = 'present',
  Optional[Hash] $fields                                              = undef,
  Boolean $fields_under_root                                          = false,
  Boolean $manage_repo                                                = true,
  String $package_ensure                                              = 'present',
  Stdlib::Absolutepath $path_conf                                     = '/etc/metricbeat',
  Integer $queue_size                                                 = 1000,
  Enum['enabled', 'disabled', 'running', 'unmanaged'] $service_ensure = 'enabled',
  Boolean $service_has_restart                                        = true,
  Optional[Array[String]] $tags                                       = undef,
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
