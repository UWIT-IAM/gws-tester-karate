# ported from uwebinject--some overlap with groupsMembers.feature
Feature: membership manipulation tests

  Background:

    * url BaseURL
    * configure headers = { 'Accept': 'application/json' ,'Content-type': 'application/json'}

    * def members = read('members.json')
    * def groupid = BaseGroup + 'membermanip'
    * def readergroup = BaseGroup + 'membermanip-authreadergroup'
    * def authgroup = BaseGroup + 'membermanip-authgroup'
    * def certid = AuthCertificateNode
    * def netidadmin = AdminNetidUser
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


  Scenario: Group read and edit tests

    * print 'Make sure clean up ran last time'
    # clean up
    Given path 'group', groupid
    When method delete

    # webinject #1
    * print 'Build the authorized subgroup is successful'
    * def payload =
    """
    {
      data: {
      id: '#(groupid)',
      description: build the subgroup is successful,
      admins: [ '#(certid)','#(netidadmin)' ],
      readers:  ['#(UnAuthCertificateNode)']
            }
    }
    """
    Given path 'group', groupid
    And request payload
    When method put
    Then status 201

    * print 'Put membership succeeds'
      # add members via JSON payload (this removes all current members and replaces them with the ones in the payload)
    Given path 'group', groupid, 'member', '/'
    And param synchronized = ''
    * def payload = { data: '#(members.members2)' }
    And request payload
    And header If-Match = '*'
    When method put
    Then status 200
   # notFound should be blank--it's the members that weren't able to be added because they don't exist
    And match response.errors[0].notFound == []

  Scenario: unauthorized cert SSL config -- view with unauth cert
    # pull different cert from karate-config.js
    * configure ssl = NoAccessConfig



    * print 'Viewing the auth group membership is authorized via cert'
    Given path 'group', groupid, 'member'
    When method get
    Then status 200
    * def parsedresult = responseHeaders['ETag'][0]


    # webinject #4
    * print 'Unauthorized update of the group membership is denied (using ETag from GET)'
      # add members via JSON payload (this removes all current members and replaces them with the ones in the payload)
    Given path 'group', groupid, 'member', '/'
    And param synchronized = ''
    * def payload = { data: '#(members.members3)' }
    And request payload
    And header If-None-Match = parsedresult
    When method put
    Then status 401

  Scenario: back to authorized SSL config for more tests

    # since we switched to a new scenario parsedresult was reset...
    # we need another get....
    * print 'Viewing the auth group membership is authorized via cert'
    Given path 'group', groupid, 'member'
    When method get
    Then status 200
    * def parsedresult = responseHeaders['ETag'][0]

    * print 'Authorized update of the group membership is allowed (using ETag from GET)'
      # add members via JSON payload (this removes all current members and replaces them with the ones in the payload)
    Given path 'group', groupid, 'member', '/'
    And param synchronized = ''
    * def payload = { data: '#(members.members4)' }
    And request payload
    And header If-None-Match = parsedresult
    When method put
    Then status 200
    And match response.errors[0].notFound contains 'zzbsalnickzzz'
    * def parsedresult = responseHeaders['ETag'][0]

    * print 'Add to the group membership is permitted (using ETag from PUT)'
    Given path 'group', groupid, 'member', members.members1[0].id
    And param synchronized = ''
  # karate requires payload for put, but GWS doesn't require one
    And request ''
    And header If-None-Match = parsedresult
    When method put
    Then status 200

    #webinject #7
    * print 'Add to the group membership is permitted (using ETag from PUT) but "bogus" is not found'
    Given path 'group', groupid, 'member', 'bogus'
    And param synchronized = ''
  # karate requires payload for put, but GWS doesn't require one
    And request ''
    And header If-None-Match = parsedresult
    When method put
    Then status 200
    And match response.errors[0].notFound contains 'bogus'

    * print 'Add the second cert as a member manager is successful (ETag *)'
    * def payload =
    """
    {
      data: {
      id: '#(groupid)',
      description: Unit Testing: subgroup functions: authorized,
      admins: [ '#(certid)','#(netidadmin)' ],
      updaters:  ['#(UnAuthCertificateNode)']
            }
    }
    """
    Given path 'group', groupid
    And request payload
    And header If-Match = '*'
    When method put
    Then status 200

  Scenario: unauthorized cert SSL config -- update members with unauth cert as member updater
    # pull different cert from karate-config.js
    * configure ssl = NoAccessConfig

    * print 'Authorized update of the group membership is allowed (using ETag *)'
      # add members via JSON payload (this removes all current members and replaces them with the ones in the payload)
    Given path 'group', groupid, 'member', '/'
    And param synchronized = ''
    * def payload = { data: '#(members.members2)' }
    And request payload
    And header If-Match = '*'
    When method put
    Then status 200
    And match response.errors[0].notFound == []
    * def parsedresult = responseHeaders['ETag'][0]

    * print 'Add to the group membership is permitted (ETag from PUT)'
      # add members via JSON payload (this removes all current members and replaces them with the ones in the payload)
    Given path 'group', groupid, 'member', 'mattjm'
    And param synchronized = ''
    And request ''
    And header If-None-Match = parsedresult
    When method put
    Then status 200
    And match response.errors[0].notFound == []

    * print 'Newly added member is found in the membership'
    Given path 'group', groupid, 'member'
    And param source = 'registry'
    When method get
    Then status 200
    * def netid = 'mattjm'
    # pretty sure I'm abusing this JSONPATH syntax (note it crashes out if this user doesn't exist-- TODO make smarter)
    And match netid == get[0] response.data[?(@.id == 'mattjm')].id


    * print 'delete a member is permitted (ETAG *)'
    Given path 'group', groupid, 'member', 'mattjm'
    And header If-Match = '*'
    When method delete
    Then status 200

    * print 'Deleted member is not found in the membership'
    Given path 'group', groupid, 'member'
    And param source = 'registry'
    When method get
    Then status 200
    * def members = get response.data[*].id
    And match members !contains ['mattjm']


  Scenario: back to authorized SSL config for cleanup

    * print 'delete the test group'
    Given path 'group', groupid
    When method delete
    And header If-Match = '*'
    Then status 200