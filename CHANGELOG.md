# Changelog

All notable changes to this project will be documented in this file.

## Release 0.4.2

**Added**
- Parameter `$metricbeat::extract_method` to select which extraction method to use for the downloaded zip file. Only applicable for Windows. Valid values are `shell` and `archive`
- Parameter `$metricbeat::setup` to add common configuration options for metricbeat.yml across a deployment. Typically useful for Heira

**Fixes**
- Updating the Powershell dependency requirement to use < 5.0.0 versions

## Release 0.4.1

**Added**
- Custom resource `metricbeat::modulesd`

**Fixes**
- Updating dependencies to newer major version

## Release 0.4.0

**Added**
- Built-in Metricbeat modules may be enabled and configured through Hiera
- Support for 7.x installations of Metricbeat
- Cloud ID and Auth properties to simplify usage with Elastic Cloud

**Fixes**
- The command-line option `path.config` is explicitly declared in the validate commands

## Release 0.3.0

**Added**
- Support for Puppet 6.x
- Support for Windows OS
- XPack configuration for >= 6.x installations

## Release 0.2.0

**Breaking**

**Added**
- Parameter `major_version` to configure 6.x versions of vendor repositories
-- Parameter `queue_size` applies only if `major_version` == '5'
Parameter `queue` to configure the internal queue in 6.x versions

**Fixes**
- Changing the `modules` and `processor` type from `Tuple[hash]` to `Array[Hash]` (#4)

## Release 0.1.0

- Initial release, please review module and [metricbeat](https://www.elastic.co/guide/en/beats/metricbeat/current/index.html) documentation for configuration options.

