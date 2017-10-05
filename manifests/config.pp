# metricbeat::config
#
# Manages the state and contests of Metricbeat's configuration file
#
# @summary Manages Metricbeat's configuration file
class metricbeat::config {
  assert_private()

  $metricbeat_config = delete_undef_values({
    'name'              => $metricbeat::beat_name,
    'fields'            => $metricbeat::fields,
    'fields_under_root' => $metricbeat::fields_under_root,
    'tags'              => $metricbeat::tags,
    'queue_size'        => $metricbeat::queue_size,
    'logging'           => $metricbeat::logging,
    'processors'        => $metricbeat::processors,
    'metricbeat'        => {
      'modules'           => $metricbeat::modules,
    },
    'output'            => $metricbeat::outputs,
  })

  file{'metricbeat.yml':
    ensure  => $metricbeat::ensure,
    path    => '/etc/metricbeat/metricbeat.yml',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => inline_template('<%= @metricbeat_config.to_yaml() %>'),
  }
}
