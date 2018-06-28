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
    Given path 'group', groupid
    When method delete


# create group


    * print 'Create group with two admins'

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
    And param synchronized = ''
    When method put
    Then status 201
    And match response.data.admins[*].id contains [ '#(AuthCertificateNode.id)', '#(UnAuthCertificateNode.id)' ]


    * print 'confirm admins are present'
    Given path 'group', groupid
    When method get
    Then status 200
    * def parsedresult = responseHeaders['ETag'][0]
    And match response.data.admins[*].id contains [ '#(AuthCertificateNode.id)', '#(UnAuthCertificateNode.id)' ]


    * print 'remove both admins, leaving none.  Should fail.  '
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
    And param synchronized = ''
    When method put
    Then status 400

    * print 'confirm admins are present after attempt to delete both admins.'
    Given path 'group', groupid
    When method get
    Then status 200
    And match response.data.admins[*].id contains [ '#(AuthCertificateNode.id)', '#(UnAuthCertificateNode.id)' ]
    * def parsedresult = responseHeaders['ETag'][0]


    * print 'remove one admin, leaving one remaining admin (via put payload).  Should succeed.  '
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
    And param synchronized = ''
    And header If-Match = parsedresult
    When method put
    Then status 200
    And match response.data.admins[0].id == AuthCertificateNode.id
    And match response.data.admins == '#[1]'

    * print 'confirm single admin is present after deleting second admin'
    Given path 'group', groupid
    When method get
    Then status 200
    And match response.data.admins[0].id == AuthCertificateNode.id
    * def parsedresult = responseHeaders['ETag'][0]

    * print 'remove last remaining admin (via put payload)'
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
    And param synchronized = ''
    And header If-Match = parsedresult
    When method put
    Then status 400



    * print 'confirm single admin is present after attempt to delete last remaining admin'
    Given path 'group', groupid
    When method get
    Then status 200
    And match response.data.admins[0].id == AuthCertificateNode.id
    * def parsedresult = responseHeaders['ETag'][0]
    And match response.data.admins == '#[1]'

    * print 'delete group'
    Given path 'group', groupid
    When method delete
    Then status 200

