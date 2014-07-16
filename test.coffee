anon = require './anon'

assert = require('chai').assert

compareIps = anon.compareIps
isIpInRange = anon.isIpInRange
isIpInAnyRange = anon.isIpInAnyRange
AliasSet = anon.AliasSet
getConfig = anon.getConfig
Politicians = anon.Politicians


describe 'anon', ->
  describe "getConfig", ->
    it "reads the test file", ->
      config = getConfig('config.json')

  describe 'Politicians', ->
    it "reads the config", ->
      config = getConfig('config.json')

    it "resolves politician info", ->
      config = getConfig('config.json')
      aliases = new Politicians config
      pat = aliases.getByName "Pat Garofalo"
      assert.equal pat.district, "58B"
      abdi = aliases.getByName "Abdi Warsame"
      assert.equal abdi.district, "6"

    it "creates the tweet title format", ->
      config = getConfig('config.json')
      aliases = new Politicians config

      test = 'Minnesota Rep. Pat Garofalo (58B-R, @sandbox432412)'
      assert.equal test, aliases.getTweetName "Pat Garofalo"

      test_b = 'Minneapolis Council Member Abdi Warsame (D)'
      assert.equal test_b, aliases.getTweetName "Abdi Warsame"

    it "resolves the full name from the article title", ->
      config = getConfig('config.json')
      aliases = new Politicians config

      name = "Mike Nelson"
      from_article = aliases.getFullNameFromPage("Michael Nelson (Minnesota politician)")
      assert.equal name, from_article

    it "resolves the tweet title from the article title", ->
      config = getConfig('config.json')
      aliases = new Politicians config

      from_article = aliases.getTweetTitleFromPageTitle("Michael Nelson (Minnesota politician)")
      test = "Minnesota Rep. Mike Nelson (D)"
      assert.equal test, from_article

  describe "AliasSet", ->
    it "reads the aliases", ->
      config = getConfig('config.json')
      aliases = new AliasSet config

    it "resolves the alias", ->
      config = getConfig('config.json')
      aliases = new AliasSet config
      test = aliases.maybe "Al Franken (Politician)"
      assert.equal "Al Franken", test

    it "correctly returns the original", ->
      config = getConfig('config.json')
      aliases = new AliasSet config
      guinea_pig = "Dr. Frank-n-furter (Transylvanian)"
      assert.equal guinea_pig, aliases.maybe guinea_pig

  describe "compareIps", ->
    it 'equal', ->
      assert.equal 0, compareIps '1.1.1.1', '1.1.1.1'
    it 'greater than', ->
      assert.equal 1, compareIps '1.1.1.2', '1.1.1.1'
    it 'less than', ->
      assert.equal -1, compareIps '1.1.1.1', '1.1.1.2'

  describe 'isIpInRange', ->

    it 'ip in range', ->
      assert.isTrue isIpInRange '123.123.123.123', ['123.123.123.0', '123.123.123.255']

    it 'ip less than range', ->
      assert.isFalse isIpInRange '123.123.122.123', ['123.123.123.0', '123.123.123.123']

    it 'ip greater than range', ->
      assert.isFalse isIpInRange '123.123.123.123', ['123.123.123.0', '123.123.123.122']

    it 'ip in cidr range', ->
      assert.isTrue isIpInRange '123.123.123.123', '123.123.0.0/16'

    it 'ip is not in cidr range', ->
      assert.isFalse isIpInRange '123.123.123.123', '123.123.123.122/32'

  describe 'isIpInAnyRange', ->
    r1 = ['1.1.1.0', '1.1.1.5']
    r2 = ['2.2.2.0', '2.2.2.5']

    it 'ip in first range', ->
      assert.isTrue isIpInAnyRange '1.1.1.1', [r1, r2]

    it 'ip in second range', ->
      assert.isTrue isIpInAnyRange '2.2.2.1', [r1, r2]

    it 'ip not in any ranges', ->
      assert.isFalse isIpInAnyRange '1.1.1.6', [r1, r2]
      
  describe 'IP Range Error (#12)', ->
    it 'false positive not in ranges', ->
      assert.isFalse isIpInAnyRange '199.19.250.20', [["199.19.16.0", "199.19.27.255"], ["4.42.247.224", "4.42.247.255"]]
