# ported from uwebinject
Feature: group search tests

  Background:

    * url BaseURL
    * configure headers = { 'Accept': 'application/json' ,'Content-type': 'application/json'}
    * def groupid = BaseGroup + 'search'
    * def certid = AuthCertificateNode
    * def netidadmin = AdminNetidUser
    # etag is just a timestamp in milliseconds.  This range is good 02/2018 through sometime in 2038
    * def minEtag = 1518736574921
    * def maxEtag = 2149889926000

  Scenario: group search tests
  # clean up
    Given path 'group', groupid
    When method delete

    * print 'Create group is successful'
    Given path 'group', groupid
    And request { data: { id: '#(groupid)', description: search testing, admins: [ '#(certid)' ] } }
    When method put
    Then status 201

    * print 'Get membership URL succeeds'
    Given path 'group', groupid
    When method get
    Then status 200
    * def memberurl = response.meta.memberRef


    * print 'Get membership ETag'
    Given url memberurl
    Given param source = 'registry'
    When method get
    # Expect
    And match header ETag == '0'
    * def etag = responseHeaders['ETag'][0]

    * print 'Add membership succeeds'
    Given url BaseURL
    Given path 'group', groupid, 'member', '/'
    And param synchronized = ''
    And request { data: [ {type: uwnetid, id: joeuser} ] }
    And header If-Match = '*'
    When method put
    Then status 200


    * print 'Search for stem is successful'
    Given path 'search'
    And param stem = groupid
    When method get
    Then status 200
    And match response.data[*].id contains groupid

    * print 'Search for member id is successful'
    Given path 'search'
    And param member = 'joeuser'
    When method get
    Then status 200
    And match response.data[*].id contains groupid

    * print 'Search for effective member id is successful'
    Given path 'search'
    And param member = 'joeuser'
    And param type = 'effective'
    When method get
    Then status 200
    And match response.data[*].id contains groupid

    * print 'Search for not my member id do not contain my groups names'
    Given path 'search'
    And param member = 'zzzzzzzzzzzz'
    When method get
    Then status 200
    And match response.data == []

    * print 'Search for not my admin do not contain my groups names'
    Given path 'search'
    And param owner = 'zzzzzzzzzzzz'
    When method get
    Then status 200
    And match response.data == []


    Given path 'group', groupid
    When method delete
    Then status 200