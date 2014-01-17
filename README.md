[![Build Status](https://secure.travis-ci.org/grasshoppergroup/adhearsion-cpa.png?branch=master)](http://travis-ci.org/grasshoppergroup/adhearsion-cpa) [![Coverage Status](https://coveralls.io/repos/grasshoppergroup/adhearsion-cpa/badge.png?branch=master)](https://coveralls.io/r/grasshoppergroup/adhearsion-cpa?branch=master)

# Adhearsion-CPA

This plugin aims to provide CPA detection..

## Compatibility

* Asterisk - no
* Freeswitch with Event Socket - no
* Freeswitch with [mod_rayo](https://wiki.freeswitch.org/wiki/Mod_rayo) - yes

To use you'll need [punchblock](https://github.com/adhearsion/punchblock) 2.20 or greater.

## Usage

### Basic

```ruby
class BeepOrNoBeepController < Adhearsion::CallController
  def run
    answer
    say "Try to beep like a machine"
    tone = detect_tone(:beep, timeout: 5)
    if tone
      say "Good job! You sound just like a #{tone.type}"
    else
      say "Nope, you didn't make a convincing enough beep"
    end
  end
end
```

You can also watch for more than one tone type:

```ruby
say "Something is beeping" if detect_tone(:modem, :beep, timeout: 5)
```

Some detection types let you pass extra options:

```ruby
detect_tone :speech, maxTime: 4000, minSpeechDuration: 4000, timeout: 5
```

#### Fax Detection

For fax machines, you can either watch for `fax-ced` or `fax-cng`, but not both.

### Asynchronous detection

You can also call a bang version of `#detect_tone!`, which will run the detectors in a non-blocking fashion, and execute the passed block when detection occurs:

```ruby

# Start playing a message right away, so Real Humans don't have to wait
@sound = play_sound! "/foo/message.wav"

# But quit wasting a channel if we hear dialup noises
detect_tone! :modem do |tone|
  logger.info "Call detected a tone"
  @sound.stop!
end
```

#### Once or repeat

By default, the block will only be executed the first time the signal type is detected, and the detector will quit listening.  If you'd prefer the block to fire every time the signal is detected, you can pass `:terminate => false` in the options hash:

```ruby
detector = detect_tone! :dtmf, terminate: false do |tone|
  logger.info "Callee pushed #{tone.value}"
  if tone.value == "#"
    detector.stop!
  end
end
```

## More Information

Rayo CPA Specification: [XEP-0341: Rayo CPA](http://xmpp.org/extensions/xep-0341.html)   
Mod_rayo CPA Documentation: [FS Wiki](https://wiki.freeswitch.org/wiki/Mod_rayo#call_progress_analysis_settings)

## Credits

Original author: [Justin Aiken](https://github.com/JustinAiken)

Developed by [Mojo Lingo](http://mojolingo.com) in partnership with [Grasshopper](http://http://grasshopper.com/).   
Thanks to [Grasshopper](http://http://grasshopper.com/) for sponsorship of Adhearsion-CPA.

## Links

* [Source](https://github.com/grasshoppergroup/adhearsion-cpa)
* [Bug Tracker](https://github.com/grasshoppergroup/adhearsion-cpa/issues)

## Note on Patches/Pull Requests

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  * If you want to have your own version, that is fine but bump version in a commit by itself so I can ignore when I pull
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2013 Adhearsion Foundation Inc. MIT license (see LICENSE for details).
