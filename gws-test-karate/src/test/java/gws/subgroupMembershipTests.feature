# ported from uwebinject
Feature: subgroup membership updatertests

  Background:

    * url BaseURL
    * configure headers = { 'Accept': 'application/json' ,'Content-type': 'application/json'}

    * def members = read('members.json')
    * def groupauth = BaseGroup + 'subgroupmember-auth'
    * def groupnoauth = BaseGroup + 'subgroupmember-noauth'
    * def subsubgroup = groupauth + '_subgroup'
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
    Given path 'group', subsubgroup
    When method delete

    * print 'Make sure clean up ran last time'
    # clean up
    Given path 'group', groupauth
    When method delete

    * print 'Make sure clean up ran last time'
    # clean up
    Given path 'group', groupnoauth
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
    And param synchronized = ''
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

      # not with other recursion tests because we want to do these
      # after members have been added
      * print 'create group for recursive add to subgroup'
      * def payload =
    """
    {
      data: {
      id: '#(subsubgroup)',
      description: Unit Testing: subgroup functions: authorized,
      admins: [ '#(certid)','#(netidadmin)' ],
      updaters:  ['#(certid)', '#(UnAuthCertificateNode)'],
      creators:  ['#(certid)']
            }
    }
    """
      Given path 'group', subsubgroup
      And request payload
      When method put
      Then status 201

      * print 'Recursive membership is allowed one level down'
      # add members via JSON payload (this removes all current members and replaces them with the ones in the payload)
      Given path 'group', subsubgroup, 'member'
      * def payload = { data: [{type: group, id: '#(groupauth)'}] }
      And request payload
      And header If-Match = '*'
      And param synchronized = ''
      When method put
      Then status 200
      And match response.errors[0].notFound == []

      * print 'make sure getting effective membership of a group with its parent group as a member doesn't blow up.  Verify payload.  '
      Given path 'group', subsubgroup, 'effective_member'
      And param source = 'registry'
      When method get
      Then status 200
      Then match response.data[*].id contains ['#(members.members2[0].id)', '#(members.members2[1].id)', '#(groupauth)']

      * print 'add subgroup as member of parent group'
      # add members via JSON payload (this removes all current members and replaces them with the ones in the payload)
      Given path 'group', groupauth, 'member', subsubgroup
      And param synchronized = ''
      And header If-Match = '*'
      And request ''
      When method put
      Then status 200

      * print 'make sure getting effective membership of a group that is member of subgroup and subgroup is a member of it doesn't blow up.  (trying to make a loop)'
      Given path 'group', groupauth, 'effective_member'
      And param source = 'registry'
      When method get
      Then status 200
      Then match response.data[*].id contains ['#(members.members2[0].id)', '#(members.members2[1].id)', '#(groupauth)', '#(subsubgroup)']


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
    * def payload = { data: [  {type: uwnetid, id: mattjm}] }
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


    * print 'clean up subsubgroup'
    # clean up
    Given path 'group', subsubgroup
    And header If-Match = '*'
    When method delete

    * print 'clean up'
    # clean up
    Given path 'group', groupauth
    And header If-Match = '*'
    When method delete

    * print 'clean up'
    # clean up
    Given path 'group', groupnoauth
    And header If-Match = '*'
    When method delete

