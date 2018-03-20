# ported from Jim's Python tester
Feature: Basic group tests

Background:

  * url BaseURL
  * configure headers = { 'Accept': 'application/json', 'Content-type': 'application/json'}
  * def testgroup1 = read('testgroup1.json')
  * def testgroup2 = read('testgroup2.json')
  * def members = read('members.json')
  * def getTime =
  """
  function() {return Date.now();}
  """
  * def start_time = getTime()


Scenario: Create, verify, and delete a group

  * print 'Make sure clean up ran last time'
  Given path 'group', testgroup1.put.data.id
  When method delete

  * print 'create the group'
  Given path 'group', testgroup1.put.data.id
  And request testgroup1.put
  When method put
  Then status 201

  * print 'verify the group'
    * print start_time
  Given path 'group', testgroup1.put.data.id
  When method get
  Then status 200
  # assemble test data and response
  * def args = {testdata: '#(testgroup1)', responsedata: '#(response)'}
  # pass test data and response to verifier feature
  And call read('classpath:groups_meta.feature') args
  # the following are optional so aren't in the main verify function
  And match response.data.updaters[*] contains testgroup1.put.data.updaters[0]
  And match response.data.dependsOn contains testgroup1.put.data.dependsOn

  * print 'add an affiliate--testing some permissions'
  Given path 'group', testgroup1.put.data.id, 'affiliate', members.email_affiliate_1.name
  Given param status = members.email_affiliate_1.status
  And param sender = members.email_affiliate_1.senders
  # karate requires payload for put, but GWS doesn't require one
  And request ''
  When method put
  Then status 200


  * print 'get the group via the group edit endpoint'
  Given path 'group', testgroup1.put.data.id
  When method get
  Then status 200
  * def grpResponse = response


  * print 'edit the affiliate response and PUT it.  Should return 200 but not do anything.  Disallowed at this endpoint'
  # GRP-649
  * set grpResponse $.data.affiliates[?(@.name == 'email')].status = 'inactive'
  Given path 'group', testgroup1.put.data.id
  And header If-Match = '*'
  And request grpResponse
  When method put
  Then status 200

  # get and see
  * print 'get the group via the group edit endpoint'
  Given path 'group', testgroup1.put.data.id
  When method get
  Then status 200



  * print 'delete the group'
  Given path 'group', testgroup1.put.data.id
  When method delete
  Then status 200





