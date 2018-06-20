# metricbeat::config
# @api private
#
# Manages the state and contests of Metricbeat's configuration file
#
# @summary Manages Metricbeat's configuration file
class metricbeat::config inherits metricbeat {
  $validate_cmd      = $metricbeat::disable_configtest ? {
    true    => undef,
    default => '/usr/share/metricbeat/bin/metricbeat -configtest -c %',
  }

  if $metricbeat::major_version == '5' {
    $metricbeat_config = delete_undef_values({
      'name'              => $metricbeat::beat_name,
      'fields'            => $metricbeat::fields,
      'fields_under_root' => $metricbeat::fields_under_root,
      'tags'              => $metricbeat::tags,
      'logging'           => $metricbeat::logging,
      'processors'        => $metricbeat::processors,
      'queue_size'        => $metricbeat::queue_size,
      'metricbeat'        => {
        'modules'           => $metricbeat::modules,
      },
      'output'            => $metricbeat::outputs,
    })
  }
  elsif $metricbeat::major_version == '6' {
    $metricbeat_config_temp = delete_undef_values({
      'name'              => $metricbeat::beat_name,
      'fields'            => $metricbeat::fields,
      'fields_under_root' => $metricbeat::fields_under_root,
      'tags'              => $metricbeat::tags,
      'logging'           => $metricbeat::logging,
      'processors'        => $metricbeat::processors,
      'queue'             => $metricbeat::queue,
      'metricbeat'        => {
        'modules'           => $metricbeat::modules,
      },
      'output'            => $metricbeat::outputs,
    })
    case $metricbeat::package_ensure {
      'latest': { $metricbeat_config = deep_merge($metricbeat_config_temp, {'xpack' => $metricbeat::xpack}) }
      /^\w+$/:  { $metricbeat_config = $metricbeat_config_temp }
      default:  {
        if versioncmp($metricbeat::package_ensure, '6.3.0') >= 0 {
          $metricbeat_config = deep_merge($metricbeat_config_temp, {'xpack' => $metricbeat::xpack})
        }
        else {
          $metricbeat_config = $metricbeat_config_temp
        }
      }
    }
  }

  file{'metricbeat.yml':
    ensure       => $metricbeat::ensure,
    path         => '/etc/metricbeat/metricbeat.yml',
    owner        => 'root',
    group        => 'root',
    mode         => '0644',
    content      => inline_template('<%= @metricbeat_config.to_yaml() %>'),
    validate_cmd => $validate_cmd,
  }
}
