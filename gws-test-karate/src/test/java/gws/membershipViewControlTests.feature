# ported from uwebinject
Feature: Membership View Control Tests

  Background:

    * url BaseURL
    * configure headers = { 'Accept': 'application/json' ,'Content-type': 'application/json'}

    * def members = read('members.json')
    * def groupid = BaseGroup + 'memberview-certauth'
    * def readergroup = BaseGroup + 'memberview-authreadergroup'
    * def authgroup = BaseGroup + 'memberview-authgroup'
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


  Scenario: Membership View Control Tests--Create test group with authorized cert as reader

    * print 'Make sure clean up ran last time'
    # clean up
    Given path 'group', groupid
    When method delete
    Given path 'group', readergroup
    When method delete
    Given path 'group', authgroup
    When method delete

    * print 'Build the authorized subgroup is successful'
    * def payload =
    """
    {
      data: {
      id: '#(groupid)',
      description: unit testing - subgroup functions - authorized,
      admins: [ '#(certid)','#(netidadmin)' ],
      readers:  ['#(certid)']
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

  Scenario: Membership View Control Tests--Try to read group with unauthorized cert is denied

    # pull different cert from karate-config.js
    * configure ssl = NoAccessConfig

    * print 'verify the group'
    Given path 'group', groupid, 'member'
    And param source = 'registry'
    When method get
    Then status 401
    # make sure data is not returned (key should not even be returned)
    And match response contains { data: '#notpresent' }

  Scenario: Membership View Control Tests--Add unauthorized cert as reader
    * def payload =
    """
    {
      data: {
      id: '#(groupid)',
      description: viewcontrol testing,
      readers:  ['#(UnAuthCertificateNode)'],
      admins: ['#(certid)', '#(netidadmin)']
            }
    }
    """
    Given path 'group', groupid
    And header If-Match = '*'
    And request payload
    When method put
    Then status 200


  Scenario: Membership View Control Tests--Try to read group with previously unauthorized cert is successful

  # pull different cert from karate-config.js
    * configure ssl = NoAccessConfig

    * print 'read the group with previously unauthorized cert'
    Given path 'group', groupid, 'member'
    And param source = 'registry'
    When method get
    Then status 200


  Scenario: Membership View Control Tests--back to authorized cert and create reader group

    # #6 in webinject
    * print 'Create group to be group member reader'
    * def payload =
    """
    {
      data: {
      id: '#(readergroup)',
      description: unit testing - subgroup functions - authorized,
      admins: [ '#(certid)','#(netidadmin)' ]
      }
    }
    """
    Given path 'group', readergroup
    And request payload
    When method put
    Then status 201


    * print 'Put membership succeeds--noauth cert as member of reader group'
      # add members via JSON payload (this removes all current members and replaces them with the ones in the payload)
    Given path 'group', readergroup, 'member', '/'
    And param synchronized = ''
    * def payload = { data: '#(members.members3)' }
    And request payload
    And header If-Match = '*'
    When method put
    Then status 200
   # notFound should be blank--it's the members that weren't able to be added because they don't exist
    And match response.errors[0].notFound == []

    * print 'Create subgroup (authgroup) with readergroup as member reader'
    * def payload =
    """
    {
      data: {
      id: '#(authgroup)',
      description: unit testing - subgroup functions - authorized,
      admins: [ '#(certid)','#(netidadmin)' ],
      readers:  [{"type":"group","id": '#(readergroup)'}]
      }
    }
    """
    Given path 'group', authgroup
    And request payload
    When method put
    Then status 201

    # #9 in webinject
    * print 'Put some membership into authgroup succeeds'
      # add members via JSON payload (this removes all current members and replaces them with the ones in the payload)
    Given path 'group', authgroup, 'member', '/'
    And param synchronized = ''
    * def payload = { data: '#(members.members2)' }
    And request payload
    And header If-Match = '*'
    When method put
    Then status 200
   # notFound should be blank--it's the members that weren't able to be added because they don't exist
    And match response.errors[0].notFound == []

  Scenario: Membership View Control Tests--unauthorized cert SSL config -- view with unauth cert
 # pull different cert from karate-config.js
    * configure ssl = NoAccessConfig

    * print 'Viewing the auth group membership is allowed via group membership'
    Given path 'group', authgroup, 'member'
    And param source = 'registry'
    When method get
    Then status 200

  Scenario: Membership View Control Tests--modify membership using auth cert

    * print 'remove unauth cert from reader group'
      # add members via JSON payload (this removes all current members and replaces them with the ones in the payload)
    # adding these members nukes the unauth cert from the membership
    Given path 'group', readergroup, 'member', '/'
    And param synchronized = ''
    * def payload = { data: '#(members.members2)' }
    And request payload
    And header If-Match = '*'
    When method put
    Then status 200
   # notFound should be blank--it's the members that weren't able to be added because they don't exist
    And match response.errors[0].notFound == []


  Scenario: Membership View Control Tests--unauthorized cert SSL config -- view with unauth cert

 # pull different cert from karate-config.js
    * configure ssl = NoAccessConfig

    * print 'Viewing the auth group membership (via member endpoint) is denied via group membership now that unauth cert is removed from reader group'
    Given path 'group', authgroup, 'member'
    When method get
    Then status 401



  Scenario:  Membership View Control Tests--auth cert--clean up - delete group

   # clean up
    Given path 'group', groupid
    When method delete
    Then status 200


    Given path 'group', readergroup
    When method delete
    Then status 200

    Given path 'group', authgroup
    When method delete
    Then status 200
