# metricbeat::repo
#
# If included, configure the relevant repo manager on the target node.
#
# @summary Manages the relevant repo manager on the target node.
class metricbeat::repo {
  assert_private()

  case $facts['osfamily'] {
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
