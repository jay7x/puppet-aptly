#
# @summary aptly::mirror
#
#   Create a mirror using `aptly mirror create`. It will not update, snapshot,
#   or publish the mirror for you, because it will take a long time and it
#   doesn't make sense to schedule these actions frequenly in Puppet.
#
#   NB: This will not recreate the mirror if the params change! You will need
#   to manually `aptly mirror drop <name>` after also dropping all snapshot
#   and publish references.
#
# @param location URL of the APT repo.
# @param key This can either be a key id or a hash including key options. If using a hash, key => { 'id' => <id> } must be specified
# @param filter Package query that is applied to packages in the mirror
# @param release Distribution to mirror for.
# @param repos Components to mirror. If an empty array then aptly will default to mirroring all components.
# @param architectures Architectures to mirror. If attribute is ommited Aptly will mirror all available architectures.
# @param with_sources Boolean to control whether Aptly should download source packages in addition to binary packages.
# @param with_udebs Boolean to control whether Aptly should also download .udeb packages.
# @param filter_with_deps Boolean to control whether when filtering to include dependencies of matching packages as well
# @param environment Optional environment variables to pass to the exec. Example: ['http_proxy=http://127.0.0.2:3128']
# @param keyring path to the keyring used by aptly
# @param force_components Boolean to control whether Aptly should force download of components.
#
define aptly::mirror (
  String $location,
  Variant[String[1], Hash[String[1],Variant[Array,Integer[1],String[1]]]] $key = {},
  String $keyring            = '/etc/apt/trusted.gpg',
  Optional[String[1]] $filter = undef,
  String $release            = $facts['os']['distro']['codename'],
  Array $architectures       = [],
  Array $repos               = [],
  Boolean $with_sources      = false,
  Boolean $with_udebs        = false,
  Boolean $filter_with_deps  = false,
  Array $environment         = [],
  Boolean $force_components  = false,
) {
  include aptly

  $gpg_cmd = "/usr/bin/gpg --no-default-keyring --keyring ${keyring}"
  $aptly_cmd = "${aptly::aptly_cmd} mirror"

  if empty($architectures) {
    $architectures_arg = ''
  } else {
    $architectures_as_s = join($architectures, ',')
    $architectures_arg = "-architectures='${architectures_as_s}'"
  }

  $components_arg = if empty($repos) {
    ''
  } else {
    " ${join($repos, ' ')}"
  }

  $filter_arg = if $filter {
    " -filter=\"${filter}\""
  } else {
    ''
  }

  $filter_with_deps_arg = if $filter_with_deps {
    ' -filter-with-deps'
  } else {
    ''
  }

  # $aptly::key_server will be used as default key server
  # key in hash format
  if $key =~ Hash and $key[id] {
    if $key[id] =~ Array {
      $key_string = join($key[id], "' '")
    } else {
      $key_string = $key[id]
    }
    if $key[server] {
      $key_server = $key[server]
    } else {
      $key_server = $aptly::key_server
    }

    # key in string/array format
  } elsif $key =~ String {
    $key_server = $aptly::key_server
    $key_string = $key
  }

  # no GPG key
  if $key.empty {
    $exec_aptly_mirror_create_require = [
      Package['aptly'],
      File['/etc/aptly.conf'],
    ]
  } else {
    exec { "aptly_mirror_gpg-${title}":
      path    => $facts['path'],
      command => "${gpg_cmd} --keyserver '${key_server}' --recv-keys '${key_string}'",
      unless  => "echo '${key_string}' | xargs -n1 ${gpg_cmd} --list-keys",
      user    => $aptly::user,
    }

    $exec_aptly_mirror_create_require = [
      Package['aptly'],
      File['/etc/aptly.conf'],
      Exec["aptly_mirror_gpg-${title}"],
    ]
  }

  $force_components_arg = if $force_components {
    ' -force-components'
  } else {
    ''
  }

  exec { "aptly_mirror_create-${title}":
    command     => "${aptly_cmd} create ${architectures_arg} -with-sources=${with_sources} -with-udebs=${with_udebs}${filter_arg}${filter_with_deps_arg}${force_components_arg} ${title} ${location} ${release}${components_arg}",
    unless      => "${aptly_cmd} show ${title} >/dev/null",
    user        => $aptly::user,
    require     => $exec_aptly_mirror_create_require,
    environment => $environment,
  }
}
