# metricbeat::install
#
# Manages the state of Package['metricbeat']
#
# @summary Manages the state of Package['metricbeat']
class metricbeat::install {
  assert_private()

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
