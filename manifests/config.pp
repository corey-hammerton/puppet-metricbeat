# metricbeat::config
# @api private
#
# Manages the state and contests of Metricbeat's configuration file
#
# @summary Manages Metricbeat's configuration file
class metricbeat::config inherits metricbeat {

  # Use lookup to merge metricbeat::modules config from different levels of hiera
  $modules_lookup = lookup('metricbeat::modules', undef, 'unique', undef)
  # Check to see if anything has been confiugred in hiera
  if $modules_lookup {
    $modules_arr = $modules_lookup
  # check if array is empty, no need to create a config entry then
  } elsif $metricbeat::modules[0].length() > 0 {
    $modules_arr = $metricbeat::modules
  } else {
    $modules_arr = undef
  }

  # if fields are "under root", then remove prefix
  if $metricbeat::fields_under_root == true {
      $fields_tmp = $metricbeat::fields.each | $key, $value | { {$key => $value} }
  } else {
      $fields_tmp = $metricbeat::fields
  }

  if $metricbeat::major_version == '5' {
    $metricbeat_config_base = delete_undef_values({
      'cloud.id'                       => $metricbeat::cloud_id,
      'cloud.auth'                     => $metricbeat::cloud_auth,
      'name'                           => $metricbeat::beat_name,
      'tags'                           => $metricbeat::tags,
      'logging'                        => $metricbeat::logging,
      'processors'                     => $metricbeat::processors,
      'queue_size'                     => $metricbeat::queue_size,
      'metricbeat'                     => {
        'modules' => $metricbeat::modules,
      },
      'output'                         => $metricbeat::outputs,
      'metricbeat.config.modules.path' => "${metricbeat::config_dir}/modules.d/*.yml",
      'setup'                          => $metricbeat::setup,
    })

    $metricbeat_config = deep_merge($metricbeat_config_base, $fields_tmp)
  }
  else {
    $metricbeat_config_base = delete_undef_values({
      'cloud.id'                       => $metricbeat::cloud_id,
      'cloud.auth'                     => $metricbeat::cloud_auth,
      'name'                           => $metricbeat::beat_name,
      'tags'                           => $metricbeat::tags,
      'logging'                        => $metricbeat::logging,
      'processors'                     => $metricbeat::processors,
      'queue'                          => $metricbeat::queue,
      'fields_under_root'              => $metricbeat::fields_under_root,
      'metricbeat.modules'             => $modules_arr,
      'output'                         => $metricbeat::outputs,
      'metricbeat.config.modules.path' => "${metricbeat::config_dir}/modules.d/*.yml",
      'setup'                          => $metricbeat::setup,
    })

    if $fields_tmp {
      $fields_tmp2 = { 'fields' => $fields_tmp, }
      $metricbeat_config_temp = deep_merge( $metricbeat_config_base, $fields_tmp2 )
    } else {
      $metricbeat_config_temp = $metricbeat_config_base
    }

    # Add the 'xpack' section if supported (version >= 6.2.0)
    if versioncmp($metricbeat::package_ensure, '6.2.0') >= 0 {
      $metricbeat_config = deep_merge($metricbeat_config_temp, {'xpack' => $metricbeat::xpack})
    }
    else {
      $metricbeat_config = $metricbeat_config_temp
    }

  }

  # Create modules.d files that exist in hiera then collect any created via exported resources
  $module_templates_real = hiera_array('metricbeat::module_templates', $metricbeat::module_templates)
  $module_templates_real.each |$module| {
    @metricbeat::modulesd { $module: }
  }
  Metricbeat::Modulesd <<||>>

  case $::kernel {
    'Linux': {
      $validate_cmd = $metricbeat::disable_configtest ? {
        true    => undef,
        default => $metricbeat::major_version ? {
          '5'     => '/usr/share/metricbeat/bin/metricbeat -configtest -c %',
          default => "/usr/share/metricbeat/bin/metricbeat --path.config ${metricbeat::config_dir} test config",
        }
      }

      file{'metricbeat.yml':
        ensure       => $metricbeat::ensure,
        path         => "${metricbeat::config_dir}/metricbeat.yml",
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
          default => "\"${metricbeat_path}\" --path.config \"${metricbeat::config_dir}\" test config",
        }
      }

      file{'metricbeat.yml':
        ensure       => $metricbeat::ensure,
        path         => "${metricbeat::config_dir}/metricbeat.yml",
        content      => inline_template('<%= @metricbeat_config.to_yaml() %>'),
        validate_cmd => $validate_cmd,
      }
    }
    default: {
      fail("${::kernel} is not supported by metricbeat.")
    }
  }
}
