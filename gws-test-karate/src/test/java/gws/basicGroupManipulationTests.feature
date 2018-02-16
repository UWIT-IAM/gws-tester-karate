Feature: ported from uwebinject, basic group manipulation tests

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

  # PUT with no body is prevented
  Given path 'group', groupid
  And request ''
  When method put
  Then status 400

  # Put group with no admins class is prevented
  Given path 'group', groupid
  And request { data: { id: '#(groupid)', description: webinject testing } }
  When method put
  Then status 400

  # Put group with empty admins class is prevented
    Given path 'group', groupid
    And request { data: { id: '#(groupid)', description: webinject testing, admins: [] } }
    When method put
    Then status 400
    
  # Correctly formed PUT creates group successfully
    Given path 'group', groupid
    And request { data: { id: '#(groupid)', description: webinject testing, admins: [ {type: dns, id: '#(certid)', name: '#(certid)' } ] } }
    When method put
    Then status 201

    # A GET finds the group successfully (and it has the supplied ETag)
    Given path 'group', groupid
    When method get
    Then status 200
    And match header ETag == '#? _ > minEtag && _ < maxEtag'
    * def parsedresult = responseHeaders['ETag'][0]

  # Conditional (If-none-matches) GET returns 304: NOT MODIFIED
    Given path 'group', groupid
    And header If-None-Match = parsedresult
    When method get
    Then status 304

  # Modify group - add admin succeeds
    * def payload = { data: { id: '#(groupid)', description: webinject testing, admins: [ {type: dns, id: '#(certid)', name: '#(certid)' } ] } }
    * set payload.data.admins[] = netidadmin
    Given path 'group', groupid
    And request payload
    And header If-Match = parsedresult
    When method put
    Then status 200

  # clean up
  Given path 'group', groupid
  When method delete
  Then status 200