#!/usr/bin/env coffee

Twit        = require 'twit'
Netmask     = require('netmask').Netmask
minimist    = require 'minimist'
WikiChanges = require('wikichanges').WikiChanges

argv = minimist process.argv.slice(2), default: config: './config.json'

# Convert IP to int
ipToInt = (ip) ->
  octets = (parseInt(s) for s in ip.split('.'))
  result = 0
  result += n * Math.pow(255, i) for n, i in octets.reverse()
  result

# Compare two IP addresses
compareIps = (ip1, ip2) ->
  q1 = ipToInt(ip1)
  q2 = ipToInt(ip2)
  if q1 == q2
    r = 0
  else if q1 < q2
    r = -1
  else
    r = 1
  return r
  

# Check if IP is in a range
isIpInRange = (ip, block) ->
  if Array.isArray block
    return compareIps(ip, block[0]) >= 0 and compareIps(ip, block[1]) <= 0
  else
    return new Netmask(block).contains ip

# Check if IP is in any range
isIpInAnyRange = (ip, blocks) ->
  for block in blocks
    if isIpInRange(ip, block)
      return true
  return false

# Get config
getConfig = (path) ->
  if path[0] != '/' and path[0..1] != './'
    path = './' + path
  return require(path)

# truncateTweet = (name, tweet, edit) ->
#   # Check that the composed tweet is not longer than the limit, which
#   # is shorter than tweet length because URLs will probably mess things
#   # up even if they get shortened
#   if tweet.length > 130
#     # Add a little extra room for error
#     diff = Math.abs(130 - tweet.length) + 3
#     truncated = edit.page.slice(0, edit.page.length - diff) + '…'
#     tweet = "#{name} has edited #{truncated} #{edit.url}"
#     console.log("TRUNCATED:      " + tweet)
#   tweet

class Politicians

  getByName: (full_name) ->
    if full_name of @politicians then @politicians[full_name] else false

  maybeArticle: (full_name) ->
    if full_name of @aliases then @aliases[full_name] else full_name

  getTweetName: (full_name) ->
    if full_name of @politicians
      p = @politicians[full_name]
      if (p.district and p.party and p.twitter) and p.title == "Rep."
        district = "#{p.district}-#{p.party}, @#{p.twitter}"
      else if (p.party and p.twitter) and p.title == "Council Member"
        district = "#{p.party}, @#{p.twitter}"
      else if p.twitter
        district = "@#{p.twitter}"
      else if p.party
        district = "#{p.party}"
      return "#{p.jurisdiction} #{p.title} #{full_name} (#{district})"
    return full_name

  getTweetTitleFromPageTitle: (page) ->
    n = @getFullNameFromPage page
    if n
      return @getTweetName(n)
    else
      return page

  getFullNameFromPage: (page) ->
    if page of @names then @names[page] else false

  readPages: () ->
    @names = {}
    @pages = []
    for name, data of @politicians
      @names[data.article] = name
      @pages.push data.article

  constructor: (config) ->
    @politicians = config.politicians
    @readPages()

main = ->
  config = getConfig(argv.config)
  twitter = new Twit config unless argv['noop']
  console.log("Connecting")
  wikipedia = new WikiChanges({ircNickname: config.nick, wikipedias: config.wikipedias})
  politicians = new Politicians config
  listening = false
  wikipedia.listen (edit) ->
    if not listening
      console.log("Now listening for edits... ")
      listening = true
    # if we have an anonymous edit, then edit.user will be the ip address
    # we iterate through each group of ip ranges looking for a match
    if (edit.page in config.articles) or (edit.page in politicians.pages)
      status = politicians.getTweetTitleFromPageTitle(edit.page) + ' has been edited ' + edit.url
      console.log status
      return if argv.noop
      twitter.post 'statuses/update', status: status, (err, d, r) ->
        if err
          console.log err
      return

if require.main == module
  main()

# export these for testing
exports.compareIps = compareIps
exports.isIpInRange = isIpInRange
exports.isIpInAnyRange = isIpInAnyRange
exports.ipToInt = ipToInt
exports.run = main
exports.getConfig = getConfig
exports.Politicians = Politicians
