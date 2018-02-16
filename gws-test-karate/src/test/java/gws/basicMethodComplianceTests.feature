Feature: ported from uwebinject, basic method compliance tests

  Background:

    * url BaseURL
    * configure headers = { 'Accept': 'application/json' ,'Content-type': 'application/json'}
    * def groupid = BaseGroup + 'webinject'
    * def certid = CertificateName
    * def netidadmin = AdminNetidUser
    # etag is just a timestamp in milliseconds.  This range is good 02/2018 through sometime in 2038
    * def minEtag = 1518736574921
    * def maxEtag = 2149889926000

  Scenario: Basic group manipulation tests

  # clean up
    Given path 'group', groupid
    When method delete

    #todo
  # GET at root is allowed
    #Given path
    #When method get
    #Then status 200

    # post at root is prevented
    Given path ''
    And request ''
    When method post
    Then status 405

    # put at root is prevented
    Given path ''
    And request ''
    When method put
    Then status 405

    # delete at root is prevented
    Given path ''
    And request ''
    When method delete
    Then status 405

    # get at group root is prevented
    Given path 'group'
    And request ''
    When method get
    Then status 400

     # post at group root is prevented
    Given path 'group'
    And request ''
    When method post
    Then status 400

     # put at group root is prevented
    Given path 'group'
    And request ''
    When method put
    Then status 400

    * print 'delete at group root is prevented'
    Given path 'group'
    And request ''
    When method delete
    Then status 400

    # todo 500 right now
    #* print 'GET at search root is allowed'
    #Given path 'search', '/'
    #When method get
    #Then status 200

    * print 'post at search root is prevented'
    Given path 'search', '/'
    And request ''
    When method post
    Then status 405

    * print 'put at search root is prevented'
    Given path 'search', '/'
    And request ''
    When method put
    Then status 405

    * print 'delete at search root is prevented'
    Given path 'search', '/'
    And request ''
    When method delete
    Then status 405

    * print 'GET at bogus root is bad request: 400'
    Given path 'bogus', '/'
    And request ''
    When method get
    Then status 400
    # Then Bill and Ted's Bogus Journey

    * print 'GET at bogus root is bad request: 400'
    Given path 'bogus', '/'
    When method get
    Then status 400

    * print 'post at bogus root is bad request: 400'
    Given path 'bogus', '/'
    And request ''
    When method post
    Then status 400

    * print 'PUT at bogus root is bad request: 400'
    Given path 'bogus', '/'
    And request ''
    When method put
    Then status 400

    * print 'delete at bogus root is bad request: 400'
    Given path 'bogus', '/'
    And request ''
    When method delete
    Then status 400


    # malformed URL checking
   * print 'Malformed URL returns 400: baseurl/course/'
    Given path 'course', '/'
    When method get
    Then status 400

    # malformed URL checking
    * print 'Malformed URL returns 400: baseurl/foo/'
    Given path 'foo', '/'
    When method get
    Then status 400

    # malformed URL checking
    * print 'Malformed URL returns 400: baseurl/group!!'
    Given path 'group!!'
    When method get
    Then status 400

    # malformed URL checking
    * print 'Malformed URL returns 400: baseurl/group?hi=foo'
    Given path 'group'
    And param hi = 'foo'
    When method get
    Then status 400

    * print 'Malformed URL returns 400: Malformed URL returns 400: baseurl/group/../group'
    Given path 'group' , '..', 'group'
    When method get
    Then status 400