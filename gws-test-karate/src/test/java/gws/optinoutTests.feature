# ported from uwebinject
Feature: Membership Opt In/Out Tests

  Background:

    * url BaseURL
    * configure headers = { 'Accept': 'application/json' ,'Content-type': 'application/json'}

    * def members = read('members.json')
    * def groupid = BaseGroup + 'optinout'
    * def readergroup = BaseGroup + 'memberview-authreadergroup'
    * def authgroup = BaseGroup + 'memberview-authgroup'
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


  Scenario: Membership Opt In/Out Tests

    * print 'Make sure clean up ran last time'
    # clean up
    Given path 'group', groupid
    When method delete


    * print 'Membership Opt In/Out Tests'
    * def payload =
    """
    {
      data: {
      id: '#(groupid)',
      description: unit testing - subgroup functions - authorized,
      admins: [ '#(AuthCertificateNode)','#(netidadmin)' ],
      readers:  ['#(UnAuthCertificateNode)'],
      optins: [{type: set, id: all}]
            }
    }
    """
    Given path 'group', groupid
    And param synchronized = ''
    And request payload
    When method put
    Then status 201

  Scenario: Unauth cert
    * configure ssl = NoAccessConfig

    * print 'PUT self membership succeeds with optin (and not optout)'
    Given path 'group', groupid, 'member'
    And param synchronized = ''
    * def payload = {data: ['#(UnAuthCertificateNode)']}
    And request payload
    And header If-Match = '*'
    When method put
    Then status 200
   # notFound should be blank--it's the members that weren't able to be added because they don't exist
    And match response.errors[0].notFound == []


    * print 'PUT other membership fails with optin (and not optout)'
    Given path 'group', groupid, 'member'
    And param synchronized = ''
    * def payload = {data: ['#(members.members2[0])']}
    And request payload
    And header If-Match = '*'
    When method put
    Then status 401

    * print 'Delete self membership fails with optin (and not optout)'
    Given path 'group', groupid, 'member', 'd:' + UnAuthCertificateNode.id
    And param synchronized = ''
    And header If-Match = '*'
    When method delete
    Then status 401

    Scenario:  Back to auth cert

    * print 'delete subgroup'
    # clean up
    Given path 'group', groupid
    And header If-Match = '*'
    When method delete
    Then status 200

    * print 'Build the group for optout tests is successful'
    * def payload =
    """
    {
      data: {
      id: '#(groupid)',
      description: unit testing - subgroup functions - authorized,
      admins: [ '#(AuthCertificateNode)','#(netidadmin)' ],
      readers:  ['#(UnAuthCertificateNode)'],
      optouts: [{type: set, id: all}]
            }
    }
    """
    Given path 'group', groupid
    And param synchronized = ''
    And request payload
    When method put
    Then status 201

  Scenario: Unauth cert
    * configure ssl = NoAccessConfig

    * print 'PUT self membership fails with optout (and not optin)'
    Given path 'group', groupid, 'member'
    And param synchronized = ''
    * def payload = {data: ['#(UnAuthCertificateNode)']}
    And request payload
    And header If-Match = '*'
    When method put
    Then status 401

    * print 'PUT other membership fails with optout (and not optin)'
    Given path 'group', groupid, 'member'
    And param synchronized = ''
    * def payload = {data: ['#(members.members2[0])']}
    And request payload
    And header If-Match = '*'
    When method put
    Then status 401

  Scenario: back to auth cert

    * print 'PUT membership as admin succeeds'
    Given path 'group', groupid, 'member'
    And param synchronized = ''
    * def payload = {data: ['#(UnAuthCertificateNode)']}
    And request payload
    And header If-Match = '*'
    When method put
    Then status 200

  Scenario: unauth cert
    * configure ssl = NoAccessConfig

    * print 'Delete self membership succeeds with optout (and not optin)'
    Given path 'group', groupid, 'member', 'd:' + UnAuthCertificateNode.id
    And param synchronized = ''
    And header If-Match = '*'
    When method delete
    Then status 200

  Scenario:  Back to auth cert

    * print 'delete subgroup'
  # clean up
    Given path 'group', groupid
    And header If-Match = '*'
    When method delete
    Then status 200

    * print 'Build the group with recursive optout is successful'
    * def payload =
    """
    {
      data: {
      id: '#(groupid)',
      description: unit testing - subgroup functions - authorized,
      admins: [ '#(AuthCertificateNode)','#(netidadmin)' ],
      readers:  ['#(UnAuthCertificateNode)'],
      optouts: [{type: group, id: '#(groupid)'}]
            }
    }
    """
    Given path 'group', groupid
    And param synchronized = ''
    And request payload
    When method put
    Then status 201

    * print 'PUT membership as admin succeeds'
    Given path 'group', groupid, 'member'
    And param synchronized = ''
    * def payload = {data: ['#(UnAuthCertificateNode)']}
    And request payload
    And header If-Match = '*'
    When method put
    Then status 200

  Scenario: unauth cert
    * configure ssl = NoAccessConfig

    * print 'Delete self membership succeeds with recursive optout'
    Given path 'group', groupid, 'member', 'd:' + UnAuthCertificateNode.id
    And param synchronized = ''
    And header If-Match = '*'
    When method delete
    Then status 200

  Scenario: auth cert

    * print 'delete subgroup'
  # clean up
    Given path 'group', groupid
    And header If-Match = '*'
    When method delete
    Then status 200

    # webinject #40
    * print 'Build the group with recursive optin is successful'
    * def payload =
    """
    {
      data: {
      id: '#(groupid)',
      description: unit testing - subgroup functions - authorized,
      admins: [ '#(AuthCertificateNode)','#(netidadmin)' ],
      readers:  ['#(UnAuthCertificateNode)'],
      optins: [{type: group, id: '#(groupid)'}]
            }
    }
    """
    Given path 'group', groupid
    And param synchronized = ''
    And request payload
    When method put
    Then status 201


  Scenario: unauth cert
    * configure ssl = NoAccessConfig

    * print 'PUT self membership fails with recursive optin when not member of optin group'
    Given path 'group', groupid, 'member', 'd:' + UnAuthCertificateNode.id
    And param synchronized = ''
    And request ''
    And header If-Match = '*'
    When method put
    Then status 401

  Scenario: auth cert

    #webinject #41
    * print 'PUT membership as admin succeeds'
    Given path 'group', groupid, 'member'
    And param synchronized = ''
    * def payload = {data: ['#(UnAuthCertificateNode)']}
    And request payload
    And header If-Match = '*'
    When method put
    Then status 200

    * print 'delete subgroup'
  # clean up
    Given path 'group', groupid
    And header If-Match = '*'
    When method delete
    Then status 200

    * print 'Build the group (specific optin/optout) is successful'
    * def payload =
    """
    {
      data: {
      id: '#(groupid)',
      description: unit testing - subgroup functions - authorized,
      admins: [ '#(AuthCertificateNode)','#(netidadmin)' ],
      readers:  ['#(UnAuthCertificateNode)'],
      optins: ['#(UnAuthCertificateNode)']
            }
    }
    """
    Given path 'group', groupid
    And param synchronized = ''
    And request payload
    When method put
    Then status 201


  Scenario: unauth cert
    * configure ssl = NoAccessConfig

    * print 'PUT self membership succeeds with specific optin (and not optout)"'
    Given path 'group', groupid, 'member'
    * def payload = {data: ['#(UnAuthCertificateNode)']}
    And param synchronized = ''
    And request payload
    And header If-Match = '*'
    When method put
    Then status 200

    * print 'PUT other membership fails with optin (and not optout)'
    Given path 'group', groupid, 'member'
    And param synchronized = ''
    * def payload = {data: ['#(members.members2[0])']}
    And request payload
    And header If-Match = '*'
    When method put
    Then status 401

    * print 'Delete self membership fails with specific optin (and not optout)'
    Given path 'group', groupid, 'member'
    And param synchronized = ''
    Amd header If-Match = '*'
    When method delete
    Then status 401

  Scenario: auth cert

    * print 'delete subgroup'
    Given path 'group', groupid
    And header If-Match = '*'
    When method delete
    Then status 200






