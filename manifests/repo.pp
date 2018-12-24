# metricbeat::repo
# @api private
#
# If included, configure the relevant repo manager on the target node.
#
# @summary Manages the relevant repo manager on the target node.
class metricbeat::repo inherits metricbeat {
  case $facts['osfamily'] {
    'Debian': {
      include ::apt

      $download_url = $metricbeat::major_version ? {
        '5' => 'https://artifacts.elastic.co/packages/5.x/apt',
        '6' => 'https://artifacts.elastic.co/packages/6.x/apt',
      }

      unless defined(Apt::Source['beats']) {
        apt::source{'beats':
          location => $download_url,
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

      $download_url = $metricbeat::major_version ? {
        '5' => 'https://artifacts.elastic.co/packages/5.x/yum',
        '6' => 'https://artifacts.elastic.co/packages/6.x/yum',
      }

      unless defined(Yumrepo['beats']) {
        yumrepo{'beats':
          descr    => 'Elastic repository for 5.x packages',
          baseurl  => $download_url,
          gpgcheck => 1,
          gpgkey   => 'https://artifacts.elastic.co/GPG-KEY-elasticsearch',
          enabled  => 1,
        }
      }
    }
    'SuSe': {

      $download_url = $metricbeat::major_version ? {
        '5' => 'https://artifacts.elastic.co/packages/5.x/yum',
        '6' => 'https://artifacts.elastic.co/packages/6.x/yum',
      }

      exec { 'topbeat_suse_import_gpg':
        command => '/usr/bin/rpmkeys --import https://artifacts.elastic.co/GPG-KEY-elasticsearch',
        unless  => '/usr/bin/test $(rpm -qa gpg-pubkey | grep -i "D88E42B4" | wc -l) -eq 1 ',
        notify  => [ Zypprepo['beats'] ],
      }
      unless defined (Zypprepo['beats']) {
        zypprepo{'beats':
          baseurl     => $download_url,
          enabled     => 1,
          autorefresh => 1,
          name        => 'beats',
          gpgcheck    => 1,
          gpgkey      => 'https://artifacts.elastic.co/GPG-KEY-elasticsearch',
          type        => 'yum',
        }
      }
    }
    default: {
    }
  }
}
