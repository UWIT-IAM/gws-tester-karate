# ported from uwebinject
Feature: subgroup membership updatertests

  Background:

    * url BaseURL
    * configure headers = { 'Accept': 'application/json' ,'Content-type': 'application/json'}

    * def members = read('members.json')
    * def groupauth = BaseGroup + 'subgroupmember-auth'
    * def groupnoauth = BaseGroup + 'subgroupmember-noauth'
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
    Given path 'group', groupauth
    When method delete

    * print 'Make sure clean up ran last time'
    # clean up
    Given path 'group', groupnoauth
    When method delete


    # webinject #1
    * print 'Build the authorized subgroup is successful'
    * def payload =
    """
    {
      data: {
      id: '#(groupauth)',
      description: Unit Testing: subgroup functions: authorized,
      admins: [ '#(certid)','#(netidadmin)' ],
      updaters:  ['#(certid)', '#(UnAuthCertificateNode)'],
      creators:  ['#(certid)']
            }
    }
    """
    Given path 'group', groupauth
    And request payload
    When method put
    Then status 201

    * print 'Get membership: membership is empty'
    Given path 'group', groupauth, 'member'
    And param source = 'registry'
    When method get
    Then status 200
    And match response.data == []


    * print 'Authorized POST to membership URL is prevented'
      # add members via JSON payload (this removes all current members and replaces them with the ones in the payload)
    Given path 'group', groupauth, 'member'
    * def payload = { data: '#(members.members2)' }
    And request payload
    And header If-Match = '*'
    # note this is a post not a put
    When method post
    # TODO
    Then status 200

    * print 'Recursive membership is prevented'
      # add members via JSON payload (this removes all current members and replaces them with the ones in the payload)
    Given path 'group', groupauth, 'member'
    * def payload = { data: [{type: group, id: '#(groupauth)'}] }
    And request payload
    And header If-Match = '*'
    When method put
    Then status 400

  Scenario:  Switch to unauth cert
    * configure ssl = NoAccessConfig

    * print 'Authorized PUT membership succeeds'
      # add members via JSON payload (this removes all current members and replaces them with the ones in the payload)
    Given path 'group', groupauth, 'member'
    * def payload = { data: '#(members.members2)' }
    And request payload
    And header If-Match = '*'
    # note this is a post not a put
    When method put
    Then status 200

    * print 'RE-Get membership: has our new members'
    Given path 'group', groupauth, 'member'
    And param source = 'registry'
    When method get
    Then status 200
    * def netid = 'lisas22g'
    # pretty sure I'm abusing this JSONPATH syntax (note it crashes out if this user doesn't exist-- TODO make smarter)
    And match netid == get[0] response.data[?(@.id == 'lisas22g')].id
    * def netid = 'joeuser'
    And match netid == get[0] response.data[?(@.id == 'joeuser')].id

    Scenario:  back to authorized cert

      * print 'Authorized delete members succeeds'
    # clean up
      Given path 'group', groupauth, 'member'
      When method delete
      And header If-Match = '*'
      Then status 200

      # webinject #30
      * print 'Build the unauthorized subgroup is successful'
      * def payload =
    """
    {
      data: {
      id: '#(groupnoauth)',
      description: Unit Testing: subgroup functions: authorized,
      admins: [ '#(certid)','#(netidadmin)' ],
      updaters:  ['#(certid)'],
      creators:  ['#(certid)']
            }
    }
    """
      Given path 'group', groupnoauth
      And request payload
      When method put
      Then status 201


  Scenario:  Switch to unauth cert
    * configure ssl = NoAccessConfig

    * print 'Unauthorized PUT membership is prevented'
      # add members via JSON payload (this removes all current members and replaces them with the ones in the payload)
    Given path 'group', groupnoauth, 'member'
    * def payload = { data: [{type: uwnetid, id: mattjm}] }
    And request payload
    And header If-Match = '*'
    When method put
    Then status 401

  Scenario:  back to authorized cert

    * print 'Authorized PUT membership succeeds'
      # add members via JSON payload (this removes all current members and replaces them with the ones in the payload)
    Given path 'group', groupnoauth, 'member'
    * def payload = { data: [{type: uwnetid, id: mattjm}] }
    And request payload
    And header If-Match = '*'
    When method put
    Then status 200


    * print 'clean up'
    # clean up
    Given path 'group', groupauth
    When method delete

    * print 'clean up'
    # clean up
    Given path 'group', groupnoauth
    When method delete