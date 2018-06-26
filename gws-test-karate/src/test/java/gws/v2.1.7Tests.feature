#ported from uwebinject
Feature:  Group 2.1.7 Tests

  Background:

    * url BaseURL
    * configure headers = { 'Accept': 'application/json' ,'Content-type': 'application/json'}

    * def members = read('members.json')
    * def groupid = BaseGroup + '217'
    * def netidadmin = AdminNetidUser
    * def netidadmin2 = AdminNetidUser2
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


  Scenario: Group 2.1.7 Tests


    * print 'Make sure clean up ran last time'
  # clean up
    Given path 'group', groupid
    When method delete

    * print 'Make sure clean up ran last time'
    Given path 'group', groupid + 'fail'
    When method delete




    * print 'GID testing: Create group properly handles incorrect supplied gid'
    * def payload =
    """
    {
      data: {
      id: '#(groupid)',
      description: 2.1.7 testing,
      admins: [ '#(AuthCertificateNode)','#(netidadmin)' ],
      gid: '42'
            }
    }
    """
    Given path 'group', groupid
    And param synchronized = ''
    And request payload
    When method put
    Then status 201
    And match response.data.gid == '#string'
    And match response.data.gid != ''
    And match response.data.gid != 42

    * print 'GID tests: Group search properly handles gid'
    Given path 'group', groupid
    When method get
    Then status 200
    And match response.data.gid == '#string'
    And match response.data.gid != ''
    And match response.data.gid != 42
    
    * print 'Cleanup: delete is successful'
    Given path 'group', groupid
    When method delete
    Then status 200
    
    
    * print 'REGID testing: Create group properly handles incorrect supplied regid'
    * def payload =
    """
    {
      data: {
      id: '#(groupid)',
      description: 2.1.7 testing,
      admins: [ '#(AuthCertificateNode)','#(netidadmin)' ],
      regid: '42'
            }
    }
    """
    Given path 'group', groupid
    And param synchronized = ''
    And request payload
    When method put
    Then status 400

    * print 'REGID testing: Create group properly provides regid'
    * def payload =
    """
    {
      data: {
      id: '#(groupid)',
      description: 2.1.7 testing,
      admins: [ '#(AuthCertificateNode)','#(netidadmin)' ]
            }
    }
    """
    Given path 'group', groupid
    And param synchronized = ''
    And request payload
    When method put
    Then status 201
    And match response.data.regid == '#? _.length == 32'

    * print 'GID tests: Group search properly handles gid'
    Given path 'group', groupid
    When method get
    Then status 200
    And match response.data.regid == '#? _.length == 32'
    * def parseregid =  response.data.regid

    * print 'REGID testing: Create group with already assigned regid fails'
    * def payload =
    """
    {
      data: {
      id: '#(groupid + "fail")',
      description: 2.1.7 testing,
      admins: [ '#(AuthCertificateNode)','#(netidadmin)' ],
      regid: '#(parseregid)'
            }
    }
    """
    Given path 'group', groupid + 'fail'
    And param synchronized = ''
    And request payload
    When method put
    # TODO verify with jim
    Then status 412

    * print 'Cleanup: delete is successful'
    Given path 'group', groupid
    When method delete
    Then status 200

    * print 'History tests: search by uwnetid is successful'
    Given path 'group', 'uw_employee', 'history'
    And param id = netidadmin.id
    When method get
    Then status 200
    * def member1id = 'add member: ' + "'" + netidadmin.id + "'"
    * def member2id = 'add member: ' + "'" + netidadmin2.id + "'"
    And match response.data[*].description contains member1id
    And match response.data[*].description !contains member2id

    * print 'History tests: search with size constraint is successful'
    Given path 'group', 'uw_employee', 'history'
    And param size = 10
    When method get
    Then status 200
    And match response.data == '#[10]'

    * print 'History tests: search with size constraint is successful'
    Given path 'group', 'uw_employee', 'history'
    And param size = 20
    And param order = 'a'
    When method get
    Then status 200
    And assert response.data[0].timestamp < response.data[2].timestamp
    And assert response.data[2].timestamp < response.data[5].timestamp
    And assert response.data[5].timestamp < response.data[10].timestamp
    And assert response.data[10].timestamp < response.data[19].timestamp

    * print 'History tests: search with activity = acl is successful'
    Given path 'group', 'uw_employee', 'history'
    And param size = 10
    And param activity = 'acl'
    When method get
    Then status 200
    And match response.data[*].activity contains 'acl'
    And match response.data[*].activity !contains 'membership'

    * print 'History tests: search with start= is successful'
    Given path 'group', 'uw_employee', 'history'
    And param size = 10
    # define as number
    * def starttimestamp = 1365597758441
    # concatenate to make string here or it gets turned into a double or something
    And param start = starttimestamp + ''
    When method get
    Then status 200
    # starttimestamp used as number here
    And match response.data[*].timestamp contains starttimestamp






