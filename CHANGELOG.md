# Changelog

All notable changes to this project will be documented in this file.

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

