Feature: Membership View Control Tests

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