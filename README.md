# anon

[![Build Status](https://secure.travis-ci.org/edsu/anon.png)](http://travis-ci.org/edsu/anon)

This little coffee script will watch Wikipedia for edits (by connecting to a set of Wikipedia IRC channels) from a set of named
IP ranges and will tweet when it notices one.  It was inspired by [@parliamentedits](https://twitter.com/parliamentedits) and is used to make the [@congressedits](https://twitter.com/congressedits) feed available. 

If you are curious the default IP ranges for the US Congress in the `config.json.template` file came from [GovTrack](https://github.com/govtrack/govtrack.us-web/blob/master/website/middleware.py).  You can learn more about the significance of Congressional edits to Wikipedia [here](https://en.wikipedia.org/wiki/U.S._Congressional_staff_edits_to_Wikipedia) and [here](https://en.wikipedia.org/wiki/Wikipedia:Congressional_staffer_edits).

## Running

To run anon you will need to:

1. install [Node](http://nodejs.org)
1. `npm install -g coffee-script`
1. `git clone https://github.com/edsu/anon.git`
1. `cd anon`
1. `cp config.json.template config.json`
1. add twitter credentials for your bot to `config.json`
1. add IP ranges/names to `config.json`
1. `./anon.coffee`
1. have some :coffee: and wait

You may notice in the example `config.json.template` that you can configure 
ip address ranges using a netmask:
    
      "143.231.0.0/16"

or with an array of start/end IP addresses:

    ["143.231.0.0", "143.231.255.255"]

These two are equivalent, but the former is a bit faster, and easier to read 
The latter is convenient if your range is difficult to express using a netmask.

If you would like to test without tweeting you can run anon with the 
`--noop` flag, which will cause the tweet to be written to the console
but not actually sent to Twitter.

    ./anon.coffee --noop

By default anon will look for a `config.json` file in your current working 
directory. If you would like to specify the location of the configuration 
file use the `--config` parameter:

    ./anon.coffee --config test.config

## Develop

There is not much to anon but there is a small test suite, which might
come in handy if you want to add functionality.

    npm test

## License: 

* [CC0](LICENSE) public domain dedication
