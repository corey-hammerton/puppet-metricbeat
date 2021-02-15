# metricbeat::install
# @api private
#
# Manages the state of Package['metricbeat']
#
# @summary Manages the state of Package['metricbeat']
class metricbeat::install inherits metricbeat {
  if $::kernel == 'Windows' {
    $filename       = regsubst($metricbeat::real_download_url, '^https?.*\/([^\/]+)\.[^.].*', '\1')
    $foldername     = 'Metricbeat'
    $zip_file       = join([$metricbeat::tmp_dir, "${filename}.zip"], '/')
    $install_folder = join([$metricbeat::install_dir, $foldername], '/')
    $version_file   = join([$install_folder, $filename], '/')

    Exec {
      provider => powershell,
    }

    if !defined(File[$metricbeat::install_dir]) {
      file{$metricbeat::install_dir:
        ensure => directory,
      }
    }

    if $metricbeat::extract_method == 'shell' {
      archive { $zip_file:
        source       => $metricbeat::real_download_url,
        cleanup      => false,
        creates      => $version_file,
        proxy_server => $metricbeat::proxy_address,
      }

      exec{"unzip ${filename}":
        command => "\$sh=New-Object -COM Shell.Application;\$sh.namespace((Convert-Path '${metricbeat::install_dir}')).Copyhere(\$sh.namespace((Convert-Path '${zip_file}')).items(), 16)", # lint:ignore:140chars
        creates => $version_file,
        require => [
          File[$metricbeat::install_dir],
          Archive[$zip_file],
        ],
      }
      # Clean up after ourselves
      file{$zip_file:
        ensure  => absent,
        backup  => false,
        require => Exec["unzip ${filename}"],
        before  => Exec["stop service ${filename}"],
      }

    } else {
      archive { $zip_file:
        source       => $metricbeat::real_download_url,
        cleanup      => true,
        extract      => true,
        extract_path => $metricbeat::install_dir,
        creates      => $version_file,
        proxy_server => $metricbeat::proxy_address,
        before       => Exec["stop service ${filename}"],
      }
    }


    # You can't remove the old dir while the service has files locked...
    exec{"stop service ${filename}":
      command => 'Set-Service -Name metricbeat -Status Stopped',
      creates => $version_file,
      onlyif  => 'if(Get-WmiObject -Class Win32_Service -Filter "Name=\'metricbeat\'") {exit 0} else {exit 1}',
    }
    exec{"rename ${filename}":
      command => "Remove-Item '${install_folder}' -Recurse -Force -ErrorAction SilentlyContinue;Rename-Item '${metricbeat::install_dir}/${filename}' '${install_folder}'", # lint:ignore:140chars
      creates => $version_file,
      require => Exec["stop service ${filename}"],
    }
    exec{"mark ${filename}":
      command => "New-Item '${version_file}' -ItemType file",
      creates => $version_file,
      require => Exec["rename ${filename}"],
    }
    exec{"install ${filename}":
      cwd         => $install_folder,
      command     => './install-service-metricbeat.ps1',
      refreshonly => true,
      subscribe   => Exec["mark ${filename}"],
    }
  }
  else {
    if $metricbeat::ensure == 'present' {
      $package_ensure = $metricbeat::package_ensure
    }
    else {
      $package_ensure = $metricbeat::ensure
    }

    package{'metricbeat':
      ensure => $package_ensure,
    }
  }
}
