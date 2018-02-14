@ignore
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
* def makeDelay =
  """
  function(x) {
    java.lang.Thread.sleep(x);
    karate.log('sleeping');
  }
  """



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

  # verify google affiliate 1 added (query affiliate endpoint)
Given path 'group', testgroup2.put.data.id, 'affiliate', members.google_affiliate_1.name
When method get
Then status 200
And match response.data.name == members.google_affiliate_1.name
And match response.data.status == members.google_affiliate_1.status
And match response.data.senders == []

  # verify group metadata (query main group endpoint)
Given path 'group', testgroup2.put.data.id
When method get
Then status 200
  # assemble test data and response
* def args = {testdata: '#(testgroup2)', responsedata: '#(response)'}
  # pass test data and response to verifier feature
And call read('classpath:groups_meta.feature') args
And match response.data.affiliates[*].name contains members.google_affiliate_1.name


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

  # verify group metadata (query main group endpoint)
* print 'verify affiliate 2 group query'
Given path 'group', testgroup2.put.data.id
When method get
Then status 200
  # assemble test data and response
* def args = {testdata: '#(testgroup2)', responsedata: '#(response)'}
  # pass test data and response to verifier feature
And call read('classpath:groups_meta.feature') args
And match response.data.affiliates[*].name contains members.google_affiliate_1.name
# TODO following fails right now
# And match response.data.affiliates contains {"type": "set", "id": "member"}

    # clear google affiliate
  Given path 'group', testgroup2.put.data.id, 'affiliate', members.google_affiliate_9.name
  Given param status = members.google_affiliate_9.status
  And param sender = members.google_affiliate_9.senders
  # karate requires payload for put, but GWS doesn't require one
  And request ''
  When method put
  Then status 200

  # verify clear google affiliate
  Given path 'group', testgroup2.put.data.id, 'affiliate', members.google_affiliate_9.name
  When method get
  Then status 200
  And match response.schemas contains testgroup2.schema
  And match response.meta.resourceType == 'affiliate'
  And match response.meta.selfRef contains  BaseURL + '/group/' + testdata.put.data.id + '/affiliate/' + members.google_affiliate_9.name
  And match response.data.name == members.google_affiliate_9.name
  And match response.data.status == members.google_affiliate_9.status
  And match response.data.senders == []

  #set email affiliate 1
  Given path 'group', testgroup2.put.data.id, 'affiliate', members.email_affiliate_1.name
  Given param status = members.email_affiliate_1.status
  And param sender = members.email_affiliate_1.senders
  # karate requires payload for put, but GWS doesn't require one
  And request ''
  When method put
  Then status 200

   # verify email affiliate 1 added (query affiliate endpoint)
  Given path 'group', testgroup2.put.data.id, 'affiliate', members.email_affiliate_1.name
  When method get
  Then status 200
  And match response.schemas contains testgroup2.schema
  And match response.meta.resourceType == 'affiliate'
  And match response.meta.selfRef contains  BaseURL + '/group/' + testdata.put.data.id + '/affiliate/' + members.email_affiliate_1.name
  And match response.data.name == members.email_affiliate_1.name
  And match response.data.status == members.email_affiliate_1.status
  And match response.data.senders == []

  # verify group metadata (query main group endpoint)
  Given path 'group', testgroup2.put.data.id
  When method get
  Then status 200
  # assemble test data and response
  * def args = {testdata: '#(testgroup2)', responsedata: '#(response)'}
  # pass test data and response to verifier feature
  And call read('classpath:groups_meta.feature') args
  And match response.data.affiliates[*].name contains members.email_affiliate_1.name

  #set email affiliate 2

  Given path 'group', testgroup2.put.data.id, 'affiliate', members.email_affiliate_2.name
  Given param status = members.email_affiliate_2.status
  And param sender = members.email_affiliate_2.senders[0]
  # karate requires payload for put, but GWS doesn't require one
  And request ''
  When method put
  Then status 200

   # verify email affiliate 2 added (query affiliate endpoint)
  Given path 'group', testgroup2.put.data.id, 'affiliate', members.email_affiliate_2.name
  When method get
  Then status 200
  And match response.schemas contains testgroup2.schema
  And match response.meta.resourceType == 'affiliate'
  And match response.meta.selfRef contains  BaseURL + '/group/' + testdata.put.data.id + '/affiliate/' + members.email_affiliate_2.name
  And match response.data.name == members.email_affiliate_2.name
  And match response.data.status == members.email_affiliate_2.status
  And match response.data.senders contains {"type":"set","id":"all"}

  # verify group metadata (query main group endpoint)
  Given path 'group', testgroup2.put.data.id
  When method get
  Then status 200
  # assemble test data and response
  * def args = {testdata: '#(testgroup2)', responsedata: '#(response)'}
  # pass test data and response to verifier feature
  And call read('classpath:groups_meta.feature') args
  And match response.data.affiliates[*].name contains members.email_affiliate_2.name

  # clear email affiliate
  Given path 'group', testgroup2.put.data.id, 'affiliate', members.google_affiliate_9.name
  Given param status = members.google_affiliate_9.status
  And param sender = members.google_affiliate_9.senders
  # karate requires payload for put, but GWS doesn't require one
  And request ''
  When method put
  Then status 200

  # verify history
  Given path 'group', testgroup2.put.data.id, 'history'
  When method get
  Then status 200
  And match response.schemas contains testgroup2.schema
  And match response.meta.resourceType == 'history'
  And match response.meta.selfRef == BaseURL + '/group/' + testgroup2.put.data.id + '/history'
  And match response.data[*].description contains 'set affiliate \'google\' to inactive'
  And match response.data[*].description contains 'set affiliate \'google\' to active (forward=sender=member)'

* print 'affiliate cleanup:  delete the group'
Given path 'group', testgroup2.put.data.id
When method delete
Then status 200