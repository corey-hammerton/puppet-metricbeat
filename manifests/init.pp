# metricbeat
#
# This class installs the Elastic metricbeat statistic and metric
# collector and manages the configuration on the include nodes.
#
# @summary Install, configures and manages Metricbeat on the target node.
#
# @example
#  class{'metricbeat':
#    modules => [
#      {
#        'module'     => 'apache',
#        'metricsets' => ['status'],
#        'hosts'      => ['http://localhost'],
#      },
#    ],
#    outputs => {
#      'elasticsearch' => {
#        'hosts' => ['http://localhost:9200'],
#      },
#    },
#  }
#
# Parameters
# ----------
#
# * `modules`
# Array[Hash] The array of modules this instance of metricbeat will
# collect. (default: [{}])
#
# * `outputs`
# [Hash] Configures the output(s) this Metricbeat instance should send
# to. (default: {})
#
# * `beat_name`
# [String] The name of the beat which is published as the `beat.name`
# field of each transaction. (default: $::hostname)
#
# * `disable_configtest`
# [Boolean] If true disable configuration file testing. It is generally
# recommended to leave this parameter at its default value. (default: false)
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
# * `logging`
# [Hash] The configuration section of File['metricbeat.yml'] for the
# logging output. 
#
# * `major_version`
# [Enum] The major version of Metricbeat to install from vendor repositories.
# Valid values are '5' and '6'. (default: '5')
#
# * `manage_repo`
# [Boolean] Weather the upstream (elastic) repository should be
# configured. (default: true)
#
# * `package_ensure`
# [String] The desired state of Package['metricbeat']. Only valid when
# $ensure is present. (default: 'present')
#
# * `processors`
# Optional[Array[Hash]] An optional list of dictionaries to configure
# processors, provided by libbeat, to process events before they are
# sent to the output. (default: undef)
#
# * `queue`
# [Hash] Configure the internal queue before being consumed by the output(s)
# in bulk transactions. As of 6.0 only a memory queue is available, all
# settings must be configured by example: { 'mem' => {...}}.
#
# * `queue_size`
# [Integer] The size of the internal queue for single events in the
# processing pipeline. This is only applicable if $major_version is '5'.
# (default: 1000)
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
#
# * `xpack`
# Optional[Hash] The optional configuration of the 'xpack'
# section, to send the internal metrics to an Elasticsearch cluster. (default: undef)
class metricbeat(
  Array[Hash] $modules                                                = [{}],
  Hash $outputs                                                       = {},
  String $beat_name                                                   = $::hostname,
  Boolean $disable_configtest                                         = false,
  Enum['present', 'absent'] $ensure                                   = 'present',
  Optional[Hash] $fields                                              = undef,
  Boolean $fields_under_root                                          = false,
  Hash $logging                                                       = {
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
  },
  Enum['5', '6'] $major_version                                       = '5',
  Boolean $manage_repo                                                = true,
  String $package_ensure                                              = 'present',
  Optional[Array[Hash]] $processors                                   = undef,
  Hash $queue                                                         = {
    'mem' => {
      'events' => 4096,
      'flush'  => {
        'min_events' => 0,
        'timeout'    => '0s',
      },
    },
  },
  Integer $queue_size                                                 = 1000,
  Enum['enabled', 'disabled', 'running', 'unmanaged'] $service_ensure = 'enabled',
  Boolean $service_has_restart                                        = true,
  Optional[Array[String]] $tags                                       = undef,
  Optional[Hash] $xpack                                               = undef,
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
