# metricbeat::config
# @api private
#
# Manages the state and contests of Metricbeat's configuration file
#
# @summary Manages Metricbeat's configuration file
class metricbeat::config inherits metricbeat {
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

    # Add the 'xpack' section if supported (version >= 6.2.0)
    if versioncmp($metricbeat::package_ensure, '6.2.0') >= 0 {
      $metricbeat_config = deep_merge($metricbeat_config_temp, {'xpack' => $metricbeat::xpack})
    }
    else {
      $metricbeat_config = $metricbeat_config_temp
    }

  }

  case $::kernel {
    'Linux': {
      $validate_cmd = $metricbeat::disable_configtest ? {
        true    => undef,
        default => $metricbeat::major_version ? {
          '5'     => '/usr/share/metricbeat/bin/metricbeat -configtest -c %',
          default => '/usr/share/metricbeat/bin/metricbeat test config',
        }
      }

      file{'metricbeat.yml':
        ensure       => $metricbeat::ensure,
        path         => $metricbeat::config_file,
        owner        => 'root',
        group        => 'root',
        mode         => $metricbeat::config_mode,
        content      => inline_template('<%= @metricbeat_config.to_yaml() %>'),
        validate_cmd => $validate_cmd,
      }
    }
    'Windows': {
      $cmd_install_dir = regsubst($metricbeat::install_dir, '/', '\\', 'G')
      $metricbeat_path = join([$cmd_install_dir, 'Metricbeat', 'metricbeat.exe'], '\\')
      $validate_cmd    = $metricbeat::disable_configtest ? {
        true    => undef,
        default => $metricbeat::major_version ? {
          '5' => "\"${metricbeat_path}\" -N configtest -c \"%\"",
          default => "\"${metricbeat_path}\" test config",
        }
      }

      file{'metricbeat.yml':
        ensure       => $metricbeat::ensure,
        path         => $metricbeat::config_file,
        content      => inline_template('<%= @metricbeat_config.to_yaml() %>'),
        validate_cmd => $validate_cmd,
      }
    }
    default: {
      fail("${::kernel} is not supported by metricbeat.")
    }
  }
}
