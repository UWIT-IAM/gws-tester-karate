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

  * url BaseURL
  * configure headers = { 'Accept': 'application/json' ,'Content-type': 'application/json'}
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
  # assemble test data and response
  * def args = {testdata: '#(testgroup2)', responsedata: '#(response)'}
  # pass test data and response to verifier feature
  And call read('classpath:groups_meta.feature') args


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
    And match response.schemas contains testgroup2.schema
    And match response.meta.resourceType == 'affiliate'
    And match response.meta.selfRef contains  BaseURL + '/group/' + testdata.put.data.id + '/affiliate/' + members.google_affiliate_2.name
    And match response.data.name == members.google_affiliate_2.name
    And match response.data.status == members.google_affiliate_2.status
    And match response.data.senders[0].type == 'set'


  Given path 'group', testgroup2.put.data.id
  When method get
  Then status 200
  # assemble test data and response
  * def args = {testdata: '#(testgroup2)', responsedata: '#(response)'}
  # pass test data and response to verifier feature
  And call read('classpath:groups_meta.feature') args

  * print 'delete the group'
  Given path 'group', testgroup2.put.data.id
  When method delete
  Then status 200

Scenario: Create group, add members, change members, verify,

  # create group
  * print 'create the group'
  Given path 'group', testgroup2.put.data.id
  And request testgroup2.put
  When method put
  Then status 201

  * print 'verify the group'
  Given path 'group', testgroup2.put.data.id
  When method get
  Then status 200
  # assemble test data and response
  * def args = {testdata: '#(testgroup2)', responsedata: '#(response)'}
  # pass test data and response to verifier feature
  And call read('classpath:groups_meta.feature') args

  # add members
  * def members_list = members.members1[0].id + ',' + members.members1[1].id + ',' + members.members1[2].id
  Given path 'group', testgroup2.put.data.id, 'member', members_list
  Given param synchronized = ''
  # karate requires payload for put, but GWS doesn't require one
  And request ''
  When method put
  Then status 200

  # verify members
  Given path 'group', testgroup2.put.data.id, 'member'
  When method get
  Then status 200
  And match response.schemas contains testgroup2.schema
  And match response.meta.resourceType == 'members'
  And match response.meta.id == testgroup2.put.data.id
  And match response.meta.selfRef contains BaseURL + '/group/' + testgroup2.put.data.id + '/member'
  And match response.meta.type == 'direct'
  And match response.meta.version == 'v3.0'
  And match response.meta.regid == '#? _.length == 32'
  And match response.data contains members.members1[0,1,2]

  # delete group
  Given path 'group', testgroup2.put.data.id
  When method delete
  Then status 200