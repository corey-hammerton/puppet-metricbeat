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
# * `cloud_id`
# [String] The cloud.id setting overwrites the `output.elasticsearch.hosts` and
# `setup.kibana.host` options. You can find the `cloud.id` in the Elastic Cloud
# web UI. Default: undef
#
# * `cloud_auth`
# [String] The cloud.auth setting overwrites the `output.elasticsearch.username`
# and `output.elasticsearch.password` settings. The format is `<user>:<pass>`.
# Default: undef
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
# * `config_dir`
# [String] The absolute path to the configuration folder location. (default:
# /etc/metricbeat on Linux, C:/Program Files/Metricbeat on Windows)
#
# * `config_mode`
# [String] The file permission mode of the config file. Must be in Linux
# octal format. Default: '0600'
#
# * `disable_configtest`
# [Boolean] If true disable configuration file testing. It is generally
# recommended to leave this parameter at its default value. (default: false)
#
# * `download_url`
# Optional[Variant[Stdlib::HTTPUrl, Stdlib::HTTPSUrl]] The URL of the ZIP
# file to download. Only valid on Windows nodes. (default: undef)
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
# * `install_dir`
# Optional[String] The absolute path to the location where metricbeat will
# be installed. Only applicable on Windows. (default: C:/Program Files)
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
# $ensure is present. On Windows this is the version number of the package.
# (default: 'present')
#
# * `processors`
# Optional[Array[Hash]] An optional list of dictionaries to configure
# processors, provided by libbeat, to process events before they are
# sent to the output. (default: undef)
#
# * `proxy_address*
# Optional[Variant[Stdlib::HTTPUrl, Stdlib::HTTPSUrl]] The Proxy server used
# for downloading files. (default: undef)
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
# * `service_provider`
# Optional[String] The optional service provider of the node. (default:
# 'redhat' on RedHat nodes, undef otherwise)
#
# * `tags`
# Optional[Array[String]] An optional list of values to include in the
# `tag` field of each published transaction. This is useful for
# identifying groups of servers by logical property. (default: undef)
#
# * `tmp_dir`
# String The absolute path to the temporary directory. On Windows, this
# is the target directory for the ZIP file download. (default: /tmp on
# Linux, C:\Windows\Temp on Windows)
#
# * `url_arch
# Optional[String] An optional string describing the architecture of
# the target node. Only applicable on Windows nodes. (default: x86 or x64)
#
# * `xpack`
# Optional[Hash] Configuration items to export internal stats to a
# monitoring Elasticsearch cluster
class metricbeat(
  Optional[String] $cloud_id                                          = $metricbeat::params::cloud_id,
  Optional[String] $cloud_auth                                        = $metricbeat::params::cloud_auth,
  Array[Hash] $modules                                                = $metricbeat::params::modules,
  Array[String] $module_templates                                     = $metricbeat::params::module_templates,
  Hash $outputs                                                       = $metricbeat::params::outputs,
  String $beat_name                                                   = $metricbeat::params::beat_name,
  String $config_dir                                                  = $metricbeat::params::config_dir,
  Pattern[/^0[0-7]{3}$/] $config_mode                                 = $metricbeat::params::config_mode,
  Boolean $disable_configtest                                         = $metricbeat::params::disable_configtest,
  Optional[Variant[Stdlib::HTTPUrl, Stdlib::HTTPSUrl]] $download_url  = $metricbeat::params::download_url,
  Enum['present', 'absent'] $ensure                                   = $metricbeat::params::ensure,
  Optional[Hash] $fields                                              = $metricbeat::params::fields,
  Boolean $fields_under_root                                          = $metricbeat::params::fields_under_root,
  Optional[String] $install_dir                                       = $metricbeat::params::install_dir,
  Hash $logging                                                       = $metricbeat::params::logging,
  Enum['5', '6'] $major_version                                       = $metricbeat::params::major_version,
  Boolean $manage_repo                                                = $metricbeat::params::manage_repo,
  String $package_ensure                                              = $metricbeat::params::package_ensure,
  Optional[Array[Hash]] $processors                                   = $metricbeat::params::processors,
  Optional[Variant[Stdlib::HTTPUrl, Stdlib::HTTPSUrl]] $proxy_address = $metricbeat::params::proxy_address,
  Hash $queue                                                         = $metricbeat::params::queue,
  Integer $queue_size                                                 = $metricbeat::params::queue_size,
  Enum['enabled', 'disabled', 'running', 'unmanaged'] $service_ensure = $metricbeat::params::service_ensure,
  Boolean $service_has_restart                                        = $metricbeat::params::service_has_restart,
  Optional[String] $service_provider                                  = $metricbeat::params::service_provider,
  Optional[Array[String]] $tags                                       = $metricbeat::params::tags,
  String $tmp_dir                                                     = $metricbeat::params::tmp_dir,
  Optional[String] $url_arch                                          = $metricbeat::params::url_arch,
  Optional[Hash] $xpack                                               = $metricbeat::params::xpack,
) inherits metricbeat::params {

  $real_download_url = $download_url ? {
    undef   => "https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-${package_ensure}-windows-${metricbeat::params::url_arch}.zip",
    default => $download_url,
  }

  if $manage_repo {
    class{'metricbeat::repo':}

    Class['metricbeat::repo']
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
