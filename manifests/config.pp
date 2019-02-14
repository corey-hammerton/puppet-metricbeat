# metricbeat::config
# @api private
#
# Manages the state and contests of Metricbeat's configuration file
#
# @summary Manages Metricbeat's configuration file
class metricbeat::config inherits metricbeat {

  # check if array is empty, no need to create a config entry then
  if $metricbeat::modules[0].length() > 0 {
    $modules_arr = $metricbeat::modules
  } else {
    $modules_arr = undef
  }

  # if fields are "under root", then remove prefix
  if $fields_under_root == true {
    $fields_tmp = $metricbeat::fields.each | $key, $value | { {$key => $value} }
  } else {
    $fields_tmp = $metricbeat::fields
  }

  if $metricbeat::major_version == '5' {
    $metricbeat_config_base = delete_undef_values({
      'cloud.id'          => $metricbeat::cloud_id,
      'cloud.auth'        => $metricbeat::cloud_auth,
      'name'              => $metricbeat::beat_name,
      'tags'              => $metricbeat::tags,
      'logging'           => $metricbeat::logging,
      'processors'        => $metricbeat::processors,
      'queue_size'        => $metricbeat::queue_size,
      'metricbeat'        => {
        'modules'           => $metricbeat::modules,
      },
      'output'            => $metricbeat::outputs,
    })

    $metricbeat_config = deep_merge($metricbeat_config_base, $fields_tmp)
  }
  elsif $metricbeat::major_version == '6' {
    $metricbeat_config_base = delete_undef_values({
      'cloud.id'          => $metricbeat::cloud_id,
      'cloud.auth'        => $metricbeat::cloud_auth,
      'name'              => $metricbeat::beat_name,
      'tags'              => $metricbeat::tags,
      'logging'           => $metricbeat::logging,
      'processors'        => $metricbeat::processors,
      'queue'             => $metricbeat::queue,
      'metricbeat'        => $modules_arr,
      'output'            => $metricbeat::outputs,
    })

    $metricbeat_config_temp = deep_merge($metricbeat_config_base, $fields_tmp)

    # Add the 'xpack' section if supported (version >= 6.2.0)
    if versioncmp($metricbeat::package_ensure, '6.2.0') >= 0 {
      $metricbeat_config = deep_merge($metricbeat_config_temp, {'xpack' => $metricbeat::xpack})
    }
    else {
      $metricbeat_config = $metricbeat_config_temp
    }

  }

  # extra modules under `modules.d` folder, if any
  $module_templates_real = hiera_array('metricbeat::module_templates', $metricbeat::module_templates)
  each($module_templates_real) |$module_name| {
    file { "${metricbeat::config_dir}/modules.d/${module_name}.yml":
      ensure  => present,
      source  => "puppet:///modules/metricbeat/${module_name}.yml",
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package['metricbeat'],
      notify  => Service['metricbeat'],
    }
  }

  case $::kernel {
    'Linux': {
      $validate_cmd = $metricbeat::disable_configtest ? {
        true    => undef,
        default => $metricbeat::major_version ? {
          '5'     => '/usr/share/metricbeat/bin/metricbeat -configtest -c %',
          default => 'cp % /tmp/metricbeat-puppet.yml ; /usr/share/metricbeat/bin/metricbeat test config -c %',
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
        require      => Package['metricbeat'],
        notify       => Service['metricbeat'],
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
        path         => "${metricbeat::config_dir}/metricbeat.yml",
        content      => inline_template('<%= @metricbeat_config.to_yaml() %>'),
        validate_cmd => $validate_cmd,
        require      => Package['metricbeat'],
        notify       => Service['metricbeat'],
      }
    }
    default: {
      fail("${::kernel} is not supported by metricbeat.")
    }
  }
}
