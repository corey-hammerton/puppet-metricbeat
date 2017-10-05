# metricbeat::repo
#
# If included, configure the relevant repo manager on the target node.
#
# @summary Manages the relevant repo manager on the target node.
class metricbeat::repo {
  assert_private()

  case $facts['osfamily'] {
    'Debian': {
      include ::apt

      if !defined(Apt::Source['beats']) {
        apt::source{'beats':
          location => 'https://artifacts.elastic.co/packages/5.x/apt',
          release  => 'stable',
          repos    => 'main',
          key      => {
            id     => '46095ACC8548582C1A2699A9D27D666CD88E42B4',
            source => 'https://artifacts.elastic.co/GPG-KEY-elasticsearch',
          },
        }
      }
    }
    'RedHat': {
      if !defined(Yumrepo['beats']) {
        yumrepo{'beats':
          descr    => 'Elastic repository for 5.x packages',
          baseurl  => 'https://artifacts.elastic.co/packages/5.x/yum',
          gpgcheck => 1,
          gpgkey   => 'https://artifacts.elastic.co/GPG-KEY-elasticsearch',
          enabled  => 1,
        }
      }
    }
    default: {
    }
  }
}
