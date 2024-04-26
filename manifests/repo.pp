# metricbeat::repo
# @api private
#
# If included, configure the relevant repo manager on the target node.
#
# @summary Manages the relevant repo manager on the target node.
class metricbeat::repo inherits metricbeat {
  $apt_repo_url = $metricbeat::apt_repo_url ? {
    undef => "https://artifacts.elastic.co/packages/${metricbeat::major_version}.x/apt",
    default => $metricbeat::apt_repo_url,
  }
  $yum_repo_url = $metricbeat::yum_repo_url ? {
    undef => "https://artifacts.elastic.co/packages/${metricbeat::major_version}.x/yum",
    default => $metricbeat::yum_repo_url,
  }

  case $facts['os']['family'] {
    'Debian': {
      include ::apt

      if !defined(Apt::Source['beats']) {
        apt::source{'beats':
          location => $apt_repo_url,
          release  => 'stable',
          repos    => 'main',
          key      => {
            id     => '46095ACC8548582C1A2699A9D27D666CD88E42B4',
            source => 'https://artifacts.elastic.co/GPG-KEY-elasticsearch',
          },
        }
      }
      Class['apt::update'] -> Package['metricbeat']
    }
    'RedHat': {
      if !defined(Yumrepo['beats']) {
        yumrepo{'beats':
          descr    => "Elastic repository for ${metricbeat::major_version}.x packages",
          baseurl  => $yum_repo_url,
          gpgcheck => 1,
          gpgkey   => 'https://artifacts.elastic.co/GPG-KEY-elasticsearch',
          enabled  => 1,
        }
      }
    }
    'SuSe': {
      exec { 'topbeat_suse_import_gpg':
        command => '/usr/bin/rpmkeys --import https://artifacts.elastic.co/GPG-KEY-elasticsearch',
        unless  => '/usr/bin/test $(rpm -qa gpg-pubkey | grep -i "D88E42B4" | wc -l) -eq 1 ',
        notify  => [ Zypprepo['beats'] ],
      }
      if !defined (Zypprepo['beats']) {
        zypprepo{'beats':
          baseurl     => $yum_repo_url,
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
