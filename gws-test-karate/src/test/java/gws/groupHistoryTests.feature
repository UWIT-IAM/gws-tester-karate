# ported from uwebinject
Feature: group history tests

  Background:

    * url BaseURL
    * configure headers = { 'Accept': 'application/json' ,'Content-type': 'application/json'}

    * def members = read('members.json')
    * def groupid = BaseGroup + 'history-auth'
    * def groupidsub = BaseGroup + 'authreadergroup_history'
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


  Scenario: Group history tests

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
      description: Unit Testing: history functions: authorized group,
      admins: [ '#(netidadmin)', '#(certid)' ],
      readers:  ['#(certid)']
            }
    }
    """
    Given path 'group', groupid
    And param synchronized = ''
    And request payload
    When method put
    Then status 201

    * print 'Add membership succeds'
      # add members via JSON payload (this removes all current members and replaces them with the ones in the payload)
    Given path 'group', groupid, 'member'
    And param synchronized = ''
    * def payload = { data: '#(members.members2)' }
    And request payload
    And header If-Match = '*'
    # note this is a post not a put
    When method put
    Then status 200

    * print 'Read the group history is successful (contains member actions)'
    Given path 'group', groupid, 'history'
    When method get
    Then status 200
    * def member1id = 'add member: ' + "'" + members.members2[0].id + "'"
    * def member2id = 'add member: ' + "'" + members.members2[1].id + "'"
    And match response.data[*].description contains ['#(member1id)', '#(member2id)']

    * call makeDelay 5000

    * print 'DEBUG GET THE GROUP PROPERTIES'
    Given path 'group', groupid,
    When method get
    Then status 200

  Scenario:  Switch to unauth cert
    * configure ssl = NoAccessConfig

    * print 'Unauthorized viewing of the group membership history is prevented'
    # note some history always comes back, but membership history should not
    Given path 'group', groupid, 'history'
    When method get
    Then status 200
    And match response.data[*].description !contains 'add member:'


  Scenario:  Switch back to auth cert

    # clean up
    Given path 'group', groupid
    And header If-Match = '*'
    When method delete
    Then status 200


