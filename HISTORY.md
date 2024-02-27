## [v1.0.0](https://github.com/voxpupuli/puppet-aptly/tree/v1.0.0) (2019-01-28)

- Convertion to PDK
- Update Aptly repositories keys
- More validation
- Support of the [puppetlabs/apt](https://forge.puppet.com/puppetlabs/apt) module (version 2.0+) format of keys:
  - `aptly::mirror::keyserver` has been removed
  - `aptly::mirror::key` is now a string containing the key id or a hash (see example in [Readme](Readme.md))

2017-08-11 Release 0.9.0
- Add support for running on systemd based systems. Thanks to @zipkid for the code *and* tests!

2016-09-09 Release 0.8.0
- Add `filter` parameter (Thanks @trevorrea)
- Add `filter_with_deps` parameter (Thanks @trevorrea)
- Modified travis config to run tests with puppet 4.6

2016-06-14 Release 0.7.0
- Add `environment` parameter (thanks @zipkid)

2016-06-03 Release 0.6.0
- Support Ruby 2.1.0 and 2.2.0
- Support Puppet 3.8
- Stop testing Puppet 3.1, 3.2, 3.6 and 3.7
- Ensure that `apt::update` runs before installing aptly
- Add parameter for `-no-lock` option
- Update the aptly repository's GPG key

2016-02-26 Release 0.5.0
- Update support for puppetlabs/apt from version 1-2 to version 2-3
  (thanks @zxjinn)
- Do not run an exec to add a GPG key in `aptly::mirror` if no
  GPG key is provided (thanks @antonio)

2015-12-04 Release 0.4.0
- Drop support for Puppet 2.7 and for Puppet 3.1 but only on Ruby 2
- Start running tests against Puppet 3.6 and 3.7
- Add a defined type `aptly::snapshot` to create Aptly snapshots (thanks @mklette)
- Add `$architectures`, `$with_sources` and `$with_udebs` parameters to
  `aptly::mirror` (thanks @mklette and @dw-thomast)
- Add `$architectures`, `$comment` and `$distribution` parameters to
  `aptly::repo` (thanks @mklette)
- Add `$config_file` and `$config_contents` parameters to `aptly` class
  to allow changing the location on disk and contents of the config file
  (thanks @mklette and @antonio)
- Allow an `aptly::mirror` to have more than one key (thanks @dw-thomast)
- Use full 40 character key for `repo.aptly.info` as short fingerprints are
  susceptible to collision attacks (thanks @amosshapira)
- Fix type check of `$key` in `aptly::mirror` (thanks @sw0x2A)
- Fix comment in `aptly::mirror` (thanks @zeysh)

2015-04-23 Release 0.3.0
- Add an `aptly::api` class for configuring aptly's API service.
- Add support for specifying repos and mirrors in hieradata.
- Convert Modulefile to metadata.json
- Bugfix: use absolute references to `::aptly` class to prevent a
  dependency cycle.

2014-06-26 Release 0.2.0
- Add `user` param to parent class for the user that `aptly::mirror` and
  `aptly::repo` commands are run as.
- Add `key_server` param to parent class for the key server to use when
  verifying aptly's own repo.
- Add `key_server` param to `aptly::mirror` so that you can specify a
  different hostname or protocol.
- All defaults match the behaviour of previous versions.

2014-05-16 Release 0.1.1
- Transfer to gds-operations and release to Forge.
- No functional changes.

2014-05-15 Release 0.1.0
- Remove support for Ruby 1.8
- Add `package_ensure` param so that you can specify a version
- aptly::repo for creating local repos

2014-03-31 Release 0.0.1
- First release
- Basic install and config
- aptly::mirror for creating mirror entries
