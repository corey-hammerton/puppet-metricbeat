
# metricbeat

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with metricbeat](#setup)
    * [What metricbeat affects](#what-metricbeat-affects)
    * [Beginning with metricbeat](#beginning-with-metricbeat)
3. [Usage - Configuration options and additional functionality](#usage)
    * [Processors](#processors)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
    * [Public Classes](#public-classes)
    * [Private Classes](#private-classes)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)
    * [Testing](#testing)

## Description

The `metricbeat` installs the [metricbeat operating system and service collector](https://www.elastic.co/guide/en/beats/metricbeat/current/index.html) maintained by elastic.

## Setup

### What metricbeat affects

By default `metricbeat` adds a software repository to your system and installs metricbeat
along with required configurations.

### Beginning with metricbeat  

Full `metricbeat` functionality cam be configured with the `modules` and `outputs` parameters
declared. This module can run but the metricbeat agent on the nodes may not start their
services without these parameters defined.

```puppet
class{'metricbeat':
  modules => [
    {
      'module'     => 'system',
      'metricsets' => [
        'cpu',
        'load',
        'memory',
        'process',
      ],
      'processes'  => ['.*'],
    },
  ],
  outputs => {
    'elasticsearch' => {
      'hosts' => ['http://localhost:9200'],
      'index' => 'metricbeat',
    },
  },
}
```

## Usage

As of this writing all the default values follow the upstream values. This module saves all configuration
options in a `to_yaml()` fashion. Therefore this allows some advanced configuration settings to be easily
rendered.

To ship metrics from an Apache Web Server to [Elasticsearch](https://www.elastic.co/guide/en/beats/metricbeat/current/elasticsearch-output.html)

```puppet
class{'metricbeat':
  modules => [
    {
      'module'     => 'apache',
      'metricsets' => ['status'],
      'hosts'      => ['http://localhost'],
    },
  ],
  outputs => {
    'elasticsearch' => {
      'hosts' => ['http://localhost:9200'],
    },
  },
}
```

To ship metrics from a MySQL Database Server to [Logstash](https://www.elastic.co/guide/en/beats/metricbeat/current/logstash-output.html)

```puppet
class{'metricbeat':
  modules => {
    'module' => 'mysql',
    'metricsets' => ['status'],
    'hosts'      => ['tcp(127.0.0.1:3306)/']
    'username'   => 'root',
    'password'   => 'secret',
  },
  outputs => {
    'logstash' => {
      'hosts' => ['localhost:5044'],
    },
  },
}
```

To use the module via Hiera:

```yml
metricbeat::major_version: '6'
metricbeat::manage_repo: true
metricbeat::package_ensure: 'latest'
metricbeat::cloud_id: 'xxx'
metricbeat::cloud_auth: 'xxx:xxx'
metricbeat::fields_under_root: true
metricbeat::fields:
  'metricbeat.config.modules':
    'path': '${path.config}/modules.d/*.yml'
    'reload.enabled': false
  'setup.dashboards.enabled': true
  'setup.template.settings':
    'index.number_of_shards': 1
    'index.codec': 'best_compression'
metricbeat::outputs:
  'elasticsearch':
    'hosts': 'localhost:9200'
metricbeat::xpack:
  'monitoring':
    'enabled': true
metricbeat::module_templates:
  - system
```

Please review the [elastic documentation](https://www.elastic.co/guide/en/beats/metricbeat/current/index.html) for configuration options
and service compatability.

### Upgrade to 6.0

Version 0.2.0 of this module supports Metricbeat 6.0. Please review the [Metricbeat Changelog](https://www.elastic.co/guide/en/beats/libbeat/6.0/release-notes-6.0.0.html)
for a full list of software changes and the module changelog for a list of module updates.

To upgrade existing installations:

```puppet
class{'metricbeat':
  'major_version'  => '6',
  'package_ensure' => 'latest',
  ...
}
```

### Processors


Libbeat 5.0 and later include a feature for filtering/enhancing exported data
called [processors](https://www.elastic.co/guide/en/beats/metricbeat/current/configuration-processors.html).
These may be added into the configuration by populating the `processors` parameter
and may apply to all events or those that match certain conditions.

To drop events when field `apache.status.total_accesses` is 0
```puppet
class{'metricbeat':
  processors => [
    {
      'drop_event' => {
        'when' => {
          'apache.status.total_accesses' => 0,
        }
      }
    }
  ],
  ...
}
```

To drop the `mysql.status.aborted.clients` field from the output
```
class{'metricbeat':
  processors => [
    {
      'drop_field' => {
        'fields' => 'mysql.status.aborted.clients',
      }
    }
  ]
}
```

Please review the [documentation](https://www.elastic.co/guide/en/beats/metricbeat/current/configuration-processors.html)

## Reference
 - [**Public Classes**](#public-classes)
    - [Class: metricbeat](#class-metricbeat)
 - [**Private Classes**](#private-classes)
    - [Class: metricbeat::config](#class-metricbeatconfig)
    - [Class: metricbeat::install](#class-metricbeatinstall)
    - [Class: metricbeat::repo](#class-metricbeatrepo)
    - [Class: metricbeat::service](#class-metricbeatservice)
  - [**Custom module templates**](#custom-module-templates)

### Public Classes

#### Class: `metricbeat`

Installs and configures metricbeat.

**Parameters within `metricbeat`**
- `apt_repo_url`: [HTTP(S) URL] The URL of the APT repository to install Metricbeat from. Only applicable on Debian systems. (default: "https://artifacts.elastic.co/packages/${metricbeat::major_version}.x/apt")
- `cloud_id`: [String] Override the `output.elasticsearch.hosts` and `setup.kibana.host` options. You can find the value in the Elastic Cloud web UI. (default: undef)
- `cloud_auth`: [String] Override the `output.elasticsearch.username` and `output.elasticsearch.password` options. This is in the format of `<user>:<password>`. (default: undef)
- `modules`: [Array[Hash]] The required metricbeat.modules section of the configuration.
- `outputs`: [Hash] The required output section of the configuration.
- `beat_name`: [String] The name of the beat shipper (default: hostname)
- `config_dir`: [String] The absolute path to where the Metricbeat configuration exists. (default: /etc/metricbeat on Linux, C:/Program Files/Metricbeat on Windows)
- `config_mode`: [String] The file permission mode of the Metricbeat config file in octal format. (default: 0600)
- `ensure`: [String] Valid values are 'present' and 'absent'. Determines weather to manage all required resources or remove them from the node. (default: 'present')
- `disable_config_test`: [Boolean] If true, disable configuration file testing. It is generally recommended to leave this parameter at this default value. (default: false)
- `download_url`: [HTTP(S) URL] The URL of the ZIP file to download. Only applicable on Windows systems. (default: undef)
- `fields`: [Hash] Optional fields to add any additional information to the output. (default: undef)
- `fields_under_root`: [Boolean] By default custom fields are under a `fields` sub-dictionary. When set to true custom fields are added to the root-level document. (default: false)
- `install_dir`: [String] The absolute path to the location where Metricbeat will be installed. Only applicable on Windows systems. (default: C:/Program Files)
- `logging`: [Hash] Defines metricbeat's logging configuration, if not explicitly configured all logging output is forwarded to syslog on Linux nodes and file output on Windows. See the [docs](https://www.elastic.co/guide/en/beats/metricbeat/current/configuration-logging.html) for all available options.
- `major_version`: [String] The major version of Metricbeat to install and manage. (default: 5)
- `manage_repo`: [Boolean] When false does not install the upstream repository to the node's package manager. (default: true)
- `package_ensure`: [String] The desired state of the Package resources. Only applicable if `ensure` is 'present'. (default: 'present')
- `processors`: [Array[Hash]] Add processors to the configuration to run on data before sending to the output. (default: undef)
- `proxy_address`: [HTTP(S) URL] The proxy address used for downloading files. (default: undef)
- `queue`: [Hash] Configure the internal queue in packetbeat before being consumed by the output(s) in 6.x versions and greater.
- `queue_size`: [Integer] The queue size for single events in the processing pipeline. This is only applicable if `major_version` is '5'. (default: 1000)
- `service_ensure`: [String] Determine the state of the metricbeat service. Must be one of 'enabled', 'disabled', 'running', 'unmanaged', "managed". (default: enabled)
- `service_has_restart`: [Boolean] When true the Service resource issues the 'restart' command instead of 'stop' and 'start'. (default: true)
- `service_provider`: [String] The optional service provider of the node. (default: 'redhat' on RedHat nodes, undef otherwise)
- `tags`: [Array] Optional list of tags to help group different logical properties easily. (default: undef)
- `tmp_dir`: [String] The absolute path to a temporary directory. On Windows systems this is the target directory for the ZIP file download. (default: /tmp on Linux, C:\Windows\Temp on Windows)
- `url_arch`: [String] The optional architecture of the target node. Only applicable on Windows systems. (default: x86 or x64)
- `xpack`: [Hash] Configuration items to export internal stats to a monitoring Elasticsearch cluster. (default: undef)
- `yum_repo_url`: [String] The URL of the YUM repository to install Metricbeat from. Only applicable on RedHat or Suse systems. (default: "https://artifacts.elastic.co/packages/${metricbeat::major_version}.x/yum")


### Private Classes

#### Class: `metricbeat::config`

Manages metricbeats main configuration file.

#### Class: `metricbeat::install`

Installs the metricbeat package.

#### Class: `metricbeat::repo`

Installs the upstream Yum or Apt repository for the system package manager.

#### Class: `metricbeat::service`

Manages the metricbeat service.

### Custom module templates

Define a custom configuration file in the modules.d directory using the `metricbeat::modulesd` resource type.

**Parameters within `metricbeat::modulesd`**
- `template_name`: [String] Filename of the template in modules.d
- `config`: [Hash] For passing parameters down to the .erb template
- `source`: Optional[String] Path for the file 'source' parameter, mutually exclusive with `content`
- `content`: Optional[String] Path for the file 'content' parameter, mutually exclusive with `source`


Example usage:

```
metricbeat::modulesd { 'module_name':
  config  => $custom_hash,
  content => template("path/to/your/template.yml.erb"),
}
```


## Limitations

This module does not support loading [kibana dashboards](https://www.elastic.co/guide/en/beats/metricbeat/current/metricbeat-sample-dashboards.html)
or [elasticsearch templates](https://www.elastic.co/guide/en/beats/metricbeat/current/metricbeat-template.html), used when outputting
to Elasticsearch.

## Development

Pull requests and bug reports are welcome. If you're sending a pull request,
please consider writing tests if applicable.

### Testing

Sandbox testing is done through the [PDK](https://puppet.com/docs/pdk/1.0/index.html) utility provided by
Puppet. To utilize `PDK` execute the following commands to validate and
test the new code:

1. Validate syntax of `metadata.json`, all `*.pp*` and all `*.rb` files
```
pdk validate
```
2. Perform tests
```
pdk test unit
```
