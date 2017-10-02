# metricbeat::config
#
# Manages the state and contests of Metricbeat's configuration file
#
# @summary Manages Metricbeat's configuration file
class metricbeat::config {
  assert_private()

  file{'metricbeat.yml':
    ensure => $metricbeat::ensure,
    path   => "${metricbeat::path_conf}/metricbeat.yml",
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }
}
