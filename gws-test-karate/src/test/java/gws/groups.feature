Feature: sample karate test script    
    If you are using Eclipse, install the free Cucumber-Eclipse plugin from
    https://cucumber.io/cucumber-eclipse/
    Then you will see syntax-coloring for this file. But best of all,
    you will be able to right-click within this file and [Run As -> Cucumber Feature].
    If you see warnings like "does not have a matching glue code",
    go to the Eclipse preferences, find the 'Cucumber User Settings'
    and enter the following Root Package Name: com.intuit.karate    
    Refer to the Cucumber-Eclipse wiki for more: http://bit.ly/2mDaXeV

Background:
  * url 'https://iam-ws.u.washington.edu/group_sws/v3'
  * configure headers = { 'Accept': 'application/json' ,'Content-type': 'application/json'}
  * def testgroup1 = read('testgroup1.json')
  * def testgroup2 = read('testgroup2.json')
  * def testgroup1_temp = read('testgroup1.json').put
  * def testgroup2_temp = read('testgroup2.json').put
  * def members = read('members.json')
  * def schema = 'urn:mace:washington.edu:schemas:groups:1.0'
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
  Given path 'group', testgroup1.put.data.id
  When method get
  Then status 200
  # update if number of elements changes
  Then match response.data.admins[*] contains testgroup1.put.data.admins[0,1]
  Then match response.data.updaters[*] contains testgroup1.put.data.updaters[0]
  # set to ignore before matching the entire payload, otherwise out of order elements cause error
  * set testgroup1_temp $.data.admins = '#ignore'
  * set testgroup1_temp $.data.updaters = '#ignore'
  # verify put data
  And match response.data contains testgroup1_temp.data
  # verify data--calculated or programmatic
  And match response.data contains testgroup2.verify.data
  And match response.schemas contains schema
  And match response.meta contains testgroup2.verify.meta

  * print 'delete the group'
  Given path 'group', testgroup1.put.data.id
  When method delete
  Then status 200



Scenario: Create group, add affiliates and test, google_affiliate_1

  * print 'Make sure clean up ran last time'
  Given path 'group', testgroup2.put.data.id
  When method delete


  # create group
  * print 'create the group'
  Given path 'group', testgroup2.put.data.id
  And request testgroup2.put
  When method put
  Then status 201

  # add google affiliate 1
  Given path 'group', testgroup2.put.data.id, 'affiliate', members.google_affiliate_1.name
  Given param status = members.google_affiliate_1.status
  And param sender = members.google_affiliate_1.senders
  # karate requires payload for put, but GWS doesn't require one
  And request ''
  When method put
  Then status 200

  # verify google affiliate 1
  Given path 'group', testgroup2.put.data.id, 'affiliate', members.google_affiliate_1.name
  When method get
  Then status 200
  And match response.data.name == members.google_affiliate_1.name
  And match response.data.status == members.google_affiliate_1.status
  And match response.data.senders == []

  * print 'verify the group'
  Given path 'group', testgroup2.put.data.id
  When method get
  Then status 200
  # update if number of elements changes
  Then match response.data.admins[*] contains testgroup2.put.data.admins[0,1]
  # set to ignore before matching the entire payload, otherwise out of order elements cause error
  * set testgroup2_temp $.data.admins = '#ignore'
  And match response.data contains testgroup2_temp.data
  # verify data--calculated or programmatic
  And match response.data contains testgroup2.verify.data
  And match response.schemas contains schema
  And match response.meta contains testgroup2.verify.meta


  # add google affiliate 2
    Given path 'group', testgroup2.put.data.id, 'affiliate', members.google_affiliate_2.name
    Given param status = members.google_affiliate_2.status
    And param sender = members.google_affiliate_2.senders
  # karate requires payload for put, but GWS doesn't require one
    And request ''
    When method put
    Then status 200

  # verify google affiliate 2
    Given path 'group', testgroup2.put.data.id, 'affiliate', members.google_affiliate_2.name
    When method get
    Then status 200
    And match response.schemas contains schema
    And match response.meta.resourceType == 'affiliate'
  # TODO fix this -- should match URL but I'm not sure how to build it
    And match response.meta.selfRef == '#present'
    And match response.data.name == members.google_affiliate_2.name
    And match response.data.status == members.google_affiliate_2.status
    And match response.data.senders[0].type == 'set'


  * print 'verify the group'
  Given path 'group', testgroup2.put.data.id
  When method get
  Then status 200
  # update if number of elements changes
  * print testgroup2.put.data.admins
  Then match response.data.admins[*] contains testgroup2.put.data.admins[0,1]
  # set to ignore before matching the entire payload, otherwise out of order elements cause error
  * set testgroup2_temp $.data.admins = '#ignore'
  And match response.data contains testgroup2_temp.data
  # verify data--calculated or programmatic
  And match response.data contains testgroup2.verify.data
  And match response.schemas contains schema
  And match response.meta contains testgroup2.verify.meta

    * print 'delete the group'
    Given path 'group', testgroup2.put.data.id
    When method delete
    Then status 200


