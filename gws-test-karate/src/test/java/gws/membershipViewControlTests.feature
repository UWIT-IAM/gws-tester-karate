Feature: Membership View Control Tests

  Background:

    * url BaseURL
    * configure headers = { 'Accept': 'application/json' ,'Content-type': 'application/json'}

    * def members = read('members.json')
    * def groupid = BaseGroup + 'memberview-certauth'
    * def readergroup = BaseGroup + 'memberview-authreadergroup'
    * def certid = AuthCertificateNode
    * def netidadmin = AdminNetidUser
    * def getTime =
  """
  function() {return Date.now();}
  """
    * def start_time = getTime()


  Scenario: Create test group with authorized cert as reader

    * print 'Make sure clean up ran last time'
    # clean up
    Given path 'group', groupid
    When method delete

    * print 'Create group is successful'
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

  Scenario: Try to read group with unauthorized cert is denied

    # pull different cert from karate-config.js
    * configure ssl = NoAccessConfig

    * print 'verify the group'
    Given path 'group', groupid, 'member'
    And param source = 'registry'
    When method get
    Then status 401
    # make sure data is not returned (key should not even be returned)
    And match response contains { data: '#notpresent' }

  Scenario: Add unauthorized cert as reader
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


  Scenario: Try to read group with previously unauthorized cert is successful

  # pull different cert from karate-config.js
    * configure ssl = NoAccessConfig

    * print 'read the group with previously unauthorized cert'
    Given path 'group', groupid, 'member'
    And param source = 'registry'
    When method get
    Then status 200


  Scenario:  clean up - delete group

   # clean up
    Given path 'group', groupid
    When method delete
    Then status 200