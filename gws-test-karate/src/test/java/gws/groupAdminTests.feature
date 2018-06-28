Feature: Administrator tests



  Background:

    * url BaseURL
    * configure headers = { 'Accept': 'application/json' ,'Content-type': 'application/json'}
    * def groupid = BaseGroup + 'admintests'
    * def members = read('members.json')
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


  Scenario: Administrator Tests

    * print 'Make sure clean up ran last time'
    Given path 'group', testgroup2.put.data.id
    When method delete


# create group
    * print 'Create group with single admin'

    * def payload =
    """
    {
      data: {
      id: '#(groupid)',
      description: single admin group test,
      admins: [ '#(AuthCertificateNode)' ],
            }
    }
    """
    Given path 'group', groupid
    And request payload
    When method put
    Then status 201
    And match response.data.admins[0].id = AuthCertificateNode.id


    * print 'confirm admin is present'
    Given path 'group', groupid
    When method get
    Then status 200
    * def parsedresult = responseHeaders['ETag'][0]
    And match response.data.admins[0].id = AuthCertificateNode.id


    * print 'remove last remaining admin'
    * def payload =
    """
    {
      data: {
      id: '#(groupid)',
      description: single admin group test,
      admins: [],
            }
    }
    """
    Given path 'group', groupid
    And request payload
    And header If-Match = parsedresult
    When method put
    Then status 200
    And match response.data.admins[0].id = AuthCertificateNode.id

    * print 'confirm admin is present after attempt to delete last remaining admin'
    Given path 'group', groupid
    When method get
    Then status 200

    And match response.data.admins[0].id = AuthCertificateNode.id

    * print 'Create group with multiple admins'

    * def payload =
    """
    {
      data: {
      id: '#(groupid)',
      description: single admin group test,
      admins: [ '#(AuthCertificateNode)', '#(UnAuthCertificateNode)' ]
            }
    }
    """
    Given path 'group', groupid
    And request payload
    When method put
    Then status 201
    And match response.data.admins[0].id = UnAuthCertificateNode.id


    * print 'confirm admin is present'
    Given path 'group', groupid
    When method get
    Then status 200
    * def parsedresult = responseHeaders['ETag'][0]
    And match response.data.admins[*].id contains [AuthCertificateNode.id, UnAuthCertificateNode.id]


    * print 'remove last remaining admin'
    * def payload =
    """
    {
      data: {
      id: '#(groupid)',
      description: single admin group test,
      admins: [],
            }
    }
    """
    Given path 'group', groupid
    And request payload
    And header If-Match = parsedresult
    When method put
    Then status 200
    And match response.data.admins[*].id contains [AuthCertificateNode.id, UnAuthCertificateNode.id]

    * print 'confirm admin is present after attempt to delete last remaining admin'
    Given path 'group', groupid
    When method get
    Then status 200

    And match response.data.admins[*].id contains [AuthCertificateNode.id, UnAuthCertificateNode.id]


