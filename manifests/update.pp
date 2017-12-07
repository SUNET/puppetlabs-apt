class apt::update {
  #TODO: to catch if $::apt_update_last_success has the value of -1 here. If we
  #opt to do this, a info/warn would likely be all you'd need likely to happen
  #on the first run, but if it's not run in awhile something is likely borked
  #with apt and we'd want to know about it.

  case $::apt::_update['frequency'] {
    'always': {
      $_kick_apt = true
    }
    'daily': {
      #compare current date with the apt_update_last_success fact to determine
      #if we should kick apt_update.
      $daily_threshold = (strftime('%s') - 86400)
      if $::apt_update_last_success {
        if $::apt_update_last_success + 0 < $daily_threshold {
          $_kick_apt = true
        } else {
          $_kick_apt = false
        }
      } else {
        #if apt-get update has not successfully run, we should kick apt_update
        $_kick_apt = true
      }
    }
    'weekly':{
      #compare current date with the apt_update_last_success fact to determine
      #if we should kick apt_update.
      $weekly_threshold = (strftime('%s') - 604800)
      if $::apt_update_last_success {
        if ( $::apt_update_last_success + 0 < $weekly_threshold ) {
          $_kick_apt = true
        } else {
          $_kick_apt = false
        }
      } else {
        #if apt-get update has not successfully run, we should kick apt_update
        $_kick_apt = true
      }
    }
    default: {
      #catches 'reluctantly', and any other value (which should not occur).
      #do nothing.
      $_kick_apt = false
    }
  }

  if $_kick_apt {
    $_refresh = false
  } else {
    $_refresh = true
  }
  exec { 'apt_update':
    command     => "${apt::params::provider} update",
    logoutput   => 'on_failure',
    refreshonly => true,
    timeout     => $apt::update_timeout,
    tries       => $apt::update_tries,
    try_sleep   => 1,
    returns     => [0,100]
  }
}
