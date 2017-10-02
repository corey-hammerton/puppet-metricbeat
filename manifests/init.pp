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
# * `manage_repo`
# [Boolean] Weather the upstream (elastic) repository should be
# configured. (default: true)
class metricbeat(
  Boolean $manage_repo = true,
) {
  if $manage_repo {
    class{'metricbeat::repo':}

    Anchor['metricbeat::begin']
    -> Class['metricbeat::repo']
    -> Class['metricbeat::install']
  }

  Anchor['metricbeat::begin']
  -> Class['metricbeat::install']

  anchor{'metricbeat::begin':}
  class{'metricbeat::install':}
}
