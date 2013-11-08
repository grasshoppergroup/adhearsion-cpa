[![Build Status](https://secure.travis-ci.org/grasshoppergroup/adhearsion-cpa.png?branch=master)](http://travis-ci.org/grasshoppergroup/adhearsion-cpa) [![Coverage Status](https://coveralls.io/repos/grasshoppergroup/adhearsion-cpa/badge.png?branch=master)](https://coveralls.io/r/grasshoppergroup/adhearsion-cpa?branch=master)

# Adhearsion-CPA

This plugin aims to provide CPA detection..

## Compatibility

* Asterisk - no
* FS/Event Socket - no
* FS/[mod_rayo](https://wiki.freeswitch.org/wiki/Mod_rayo) - yes

To use currently, you'll have to specify a feature branch of [punchblock](https://github.com/adhearsion/punchblock/tree/feature/cpa_fax) in your Gemfile:

```ruby
gem 'punchblock', github: "adhearsion/punchblock", branch: "feature/cpa_fax"
```

## Usage

```ruby
class BeepOrNoBeepController < Adhearsion::CallController
  def run
    answer
    say "Try to imitate a fax machine"
    tone = detect_tone(:fax, timeout: 5)
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
say "Something is beeping" if detect_tone(:fax, :modem, :beep, timeout: 5)
```

## More Information

Specification: [rayo-cpa](https://github.com/rayo/xmpp/blob/rayo/extensions/inbox/rayo-cpa.xml)

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
