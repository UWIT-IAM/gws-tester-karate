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





