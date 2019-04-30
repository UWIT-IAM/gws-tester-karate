# Jim's python tester or....?
Feature: Groups Search

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


  Scenario: Verify search functions

* print 'Make sure clean up ran last time'
  Given path 'group', testgroup1.put.data.id
  When method delete

* print 'Make sure clean up ran last time'
  Given path 'group', testgroup2.put.data.id
  When method delete

# create test group 1
Given path 'group', testgroup1.put.data.id
And param synchronized = ''
And request testgroup1.put
When method put
Then status 201

# create test group 2
Given path 'group', testgroup2.put.data.id
And param synchronized = ''
And request testgroup2.put
When method put
Then status 201

# add members test group2
* def members_list = members.members1[0].id + ',' + members.members1[1].id
Given path 'group', testgroup2.put.data.id, 'member', members_list
And param synchronized = ''
# karate requires payload for put, but GWS doesn't require one
And request ''
When method put
Then status 200

# search for group
Given path 'search'
And param scope = 'one'
And param stem = 'uw_iam_gws-test'
When method get
Then status 200
And match response.schemas contains testgroup2.schema
And match response.meta.resourceType == 'search'
And match response.meta.selfRef == BaseURL + '/search/'
And match response.data[*].id contains testgroup1.put.data.id
And match response.data[*].id contains testgroup2.put.data.id



# clean up
* print 'Make sure clean up ran last time'
  Given path 'group', testgroup1.put.data.id
  When method delete
  Then status 200

* print 'Make sure clean up ran last time'
  Given path 'group', testgroup2.put.data.id
  When method delete
  Then status 200