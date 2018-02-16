# ported from Jim's Python tester, also added tests from uwebinject suite
Feature: groups affiliate (exchange and google) tests



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
* print 'create the group for affiliate testing'
Given path 'group', testgroup2.put.data.id
And request testgroup2.put
When method put
Then status 201

* print 'put undefined affiliation is prevented'
  Given path 'group', testgroup2.put.data.id, 'affiliate', 'bogus'
  And request ''
  When method put
  Then status 400


  * print 'put affiliation with missing status is prevented'
  Given path 'group', testgroup2.put.data.id, 'affiliate', 'google'
  And request ''
  When method put
  Then status 400

  * print 'put affiliation with bogus status is prevented'
  Given path 'group', testgroup2.put.data.id, 'affiliate', 'google'
  Given param status = 'bogus'
  And request ''
  When method put
  Then status 400

  * print 'add google affiliate 1 with inactive status'
  Given path 'group', testgroup2.put.data.id, 'affiliate', members.google_affiliate_1.name
  Given param status = 'inactive'
  And param sender = members.google_affiliate_1.senders
  # karate requires payload for put, but GWS doesn't require one
  And request ''
  When method put
  Then status 200

  * print 'verify google affiliate 1 inactive status'
  Given path 'group', testgroup2.put.data.id, 'affiliate', members.google_affiliate_1.name
  When method get
  Then status 200
  And match response.data.name == members.google_affiliate_1.name
  And match response.data.status == 'inactive'
  And match response.data.senders == []

* print 'update google affiliate 1 to active status'
Given path 'group', testgroup2.put.data.id, 'affiliate', members.google_affiliate_1.name
Given param status = members.google_affiliate_1.status
And param sender = members.google_affiliate_1.senders
  # karate requires payload for put, but GWS doesn't require one
And request ''
When method put
Then status 200


* print 'verify google affiliate 1 added (query affiliate endpoint) and active status'
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

  * print 'Put uwnetid affiliate with inactive status is successful'
  Given path 'group', testgroup2.put.data.id, 'affiliate', 'netid'
  Given param status = 'inactive'
  # karate requires payload for put, but GWS doesn't require one
  And request ''
  When method put
  Then status 200

  * print 'affiliate search is successful'
  Given path 'search'
  Given param affiliate = 'google'
  # karate requires payload for put, but GWS doesn't require one
  When method get
  Then status 200
  And match response.data[*].id contains testgroup2.put.data.id

  # verify history
  Given path 'group', testgroup2.put.data.id, 'history'
  When method get
  Then status 200
  And match response.schemas contains testgroup2.schema
  And match response.meta.resourceType == 'history'
  And match response.meta.selfRef == BaseURL + '/group/' + testgroup2.put.data.id + '/history'
  And match response.data[*].description contains 'set affiliate \'google\' to inactive'
  And match response.data[*].description contains 'set affiliate \'google\' to active (forward=sender=member)'

  * print 'Delete google affiliate succeeds'
  Given path 'group', testgroup2.put.data.id, 'affiliate', 'google'
  When method delete
  Then status 200

* print 'affiliate cleanup:  delete the group'
Given path 'group', testgroup2.put.data.id
When method delete
Then status 200

  * print 'Cleanup: Following group deletion, google affiliate is automatically deleted'
  Given path 'group', testgroup2.put.data.id, 'affiliate', 'google'
  When method get
  Then status 404

  * print 'Cleanup: Following group deletion, netid affiliate is automatically deleted'
  Given path 'group', testgroup2.put.data.id, 'affiliate', 'netid'
  When method get
  Then status 404