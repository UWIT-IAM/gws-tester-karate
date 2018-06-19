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
    * def payload = {data: ['#(members.members2[0])']}
    And request payload
    And header If-Match = '*'
    When method put
    Then status 200
   # notFound should be blank--it's the members that weren't able to be added because they don't exist
    And match response.errors[0].notFound == []

  Scenario: Unauth cert
    * configure ssl = NoAccessConfig

    * print 'PUT other membership fails with optin (and not optout)'
    Given path 'group', groupid, 'member'
    And param synchronized = ''
    * def payload = {data: ['#(UnAuthCertificateNode)']}
    And request payload
    And header If-Match = '*'
    When method put
    Then status 200
 # notFound should be blank--it's the members that weren't able to be added because they don't exist
    And match response.errors[0].notFound == []