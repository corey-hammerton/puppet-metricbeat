# metricbeat::install
#
# Manages the state of Package['metricbeat']
#
# @summary Manages the state of Package['metricbeat']
class metricbeat::install {
  assert_private()

  package{'metricbeat':
    ensure => 'present',
  }
}
