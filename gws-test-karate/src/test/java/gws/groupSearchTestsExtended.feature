#ported from uwebinject
Feature:  Group Search Tests 2.1.7

  Background:

    * url BaseURL
    * configure headers = { 'Accept': 'application/json' ,'Content-type': 'application/json'}
    * def groupid = CourseStem2
    * def mystem = 'uw_iam'
    * def members = read('members.json')
    * def netidadmin = AdminNetidUser
    * def netidadmin2 = AdminNetidUser2
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


  Scenario: Group Search Tests 2.1.7


    * print 'GID tests: Group search properly handles gid'
    Given path 'search'
    And param name = groupid
    When method get
    Then status 200
    And match response.data[0].regid == '#? _.length == 32'
    * def mygroup = response.data[0].id

    * print 'look up first course group from search'
    Given path 'group', mygroup
    When method get
    Then status 200
    * def instructor = response.data.course.instructors[0].id

    * print 'Search for instructor includes original group'
    Given path 'search',
    And param instructor = instructor
    When method get
    Then status 200
    And match response.data[*].id contains mygroup

    * print 'Find group uw_iam is successful (stem search)'
    Given path 'search'
    And param stem = mystem
    When method get
    Then status 200
    And match response.data[0].regid == '#? _.length == 32'
    * def mygroup = response.data[0].id

    * print 'Find group membership is successful'
    Given path 'group', mygroup, 'member'
    When method get
    Then status 200
    And match response.data[*].type contains 'uwnetid'
    * def mymember = response.data[0].id

    * print 'Search for stem + member is successful'
    Given path 'search'
    And param stem = mystem
    And param member = mymember
    When method get
    Then status 200
    And match response.data[0].regid == '#? _.length == 32'

    * print 'Search for member finds original stem'
    Given path 'search'
    And param member = mymember
    When method get
    Then status 200
    And match response.data[*].id contains 'uw_iam'

    * print 'wildcard search for partial name is successful'
    Given path 'search'
    And param name = 'uw_affil*'
    When method get
    Then status 200
    And match response.data[*].id contains 'uw_affiliation_seattle-student'

    * print 'non-wildcard search for partial name is not successful'
    Given path 'search'
    And param name = 'uw_affil'
    When method get
    Then status 200
    And match response.data = []

































