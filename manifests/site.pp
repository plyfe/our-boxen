require boxen::environment
require homebrew
require gcc

Exec {
  group       => 'staff',
  logoutput   => on_failure,
  user        => $boxen_user,

  path => [
    "${boxen::config::home}/rbenv/shims",
    "${boxen::config::home}/rbenv/bin",
    "${boxen::config::home}/rbenv/plugins/ruby-build/bin",
    "${boxen::config::home}/homebrew/bin",
    '/usr/bin',
    '/bin',
    '/usr/sbin',
    '/sbin'
  ],

  environment => [
    "HOMEBREW_CACHE=${homebrew::config::cachedir}",
    "HOME=/Users/${::boxen_user}"
  ]
}

File {
  group => 'staff',
  owner => $boxen_user
}

Package {
  provider => homebrew,
  require  => Class['homebrew']
}

Repository {
  provider => git,
  extra    => [
    '--recurse-submodules'
  ],
  require  => File["${boxen::config::bindir}/boxen-git-credential"],
  config   => {
    'credential.helper' => "${boxen::config::bindir}/boxen-git-credential"
  }
}

Service {
  provider => ghlaunchd
}

Homebrew::Formula <| |> -> Package <| |>

node default {
  # core modules, needed for most things
  include dnsmasq
  include git
  include hub
  include nginx

  # fail if FDE is not enabled
  if $::root_encrypted == 'no' {
    fail('Please enable full disk encryption and try again')
  }

  # node versions
  class { 'nodejs::global':
    version => 'v0.10'
  }
  include nodejs::v0_8_8
  include nodejs::v0_10

  # default ruby versions
  class { 'ruby::global':
    version => '1.9.3'
  }
  include ruby::1_8_7
  include ruby::1_9_3
  include ruby::2_0_0

  include group::environment
  include plyfe::apps::mac

  include osx::global::expand_print_dialog
  include osx::global::expand_save_dialog

  # Symlink from boxen source directory to the boxen repo.
  file { "${boxen::config::srcdir}/dliggat-boxen":
    ensure => link,
    target => $boxen::config::repodir
  }
}
