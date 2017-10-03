# metricbeat::config
#
# Manages the state and contests of Metricbeat's configuration file
#
# @summary Manages Metricbeat's configuration file
class metricbeat::config {
  assert_private()

  $metricbeat_config = delete_undef_values({
    'output' => $metricbeat::outputs,
  })

  file{'metricbeat.yml':
    ensure  => $metricbeat::ensure,
    path    => "${metricbeat::path_conf}/metricbeat.yml",
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => inline_template('<%= @metricbeat_config.to_yaml() %>'),
  }
}
