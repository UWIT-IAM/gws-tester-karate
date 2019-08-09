# ported from Jim's Python tester
Feature: group member manipulation tests
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


Scenario: groupsMembers--Create group, add members, change members, verify,

# print 'cleanup before starting'
Given path 'group', testgroup2.put.data.id
When method delete


  # create group
* print 'create the group'
Given path 'group', testgroup2.put.data.id
And param synchronized = ''
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

  # add members via querystring
* def members_list = members.members1[0].id + ',' + members.members1[1].id + ',' + members.members1[2].id
Given path 'group', testgroup2.put.data.id, 'member', members_list
And param synchronized = ''
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

  # add members via JSON payload (this removes all current members and replaces them with the ones in the payload)
Given path 'group', testgroup2.put.data.id, 'member', '/'
And param synchronized = ''
* def payload = { data: '#(members.members2)' }
And request payload
When method put
Then status 200
# notFound should be blank
And match response.errors[0].notFound == []

  # try to add non-existent netid
* def fakenetid = 'notarealnetid456'
Given path 'group', testgroup2.put.data.id, 'member', fakenetid
And param synchronized = ''
# karate requires payload for put, but GWS doesn't require one
And request ''
When method put
Then status 200
And match response.errors[0].notFound contains fakenetid

  # delete group
Given path 'group', testgroup2.put.data.id
When method delete
Then status 200
