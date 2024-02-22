# ported from uwebinject
Feature:  Classification Tests

  Background:

    * url BaseURL
    * configure headers = { 'Accept': 'application/json' ,'Content-type': 'application/json'}

    * def members = read('members.json')
    * def groupid = BaseGroup + 'classification'
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


  Scenario: Classification Tests

    * print 'Make sure clean up ran last time'
  # clean up
    Given path 'group', groupid
    When method delete


    * print 'Build the group, class -u- is successful'
    * def payload =
    """
    {
      data: {
      id: '#(groupid)',
      description: Unit Testing - classification functions,
      admins: [ '#(AuthCertificateNode)','#(netidadmin)' ],
      readers:  ['#(UnAuthCertificateNode)'],
      classification: u
            }
    }
    """
    Given path 'group', groupid
    And param synchronized = ''
    And request payload
    When method put
    Then status 201

    * print 'modify the group, class -p- is successful'
    * def payload =
    """
    {
      data: {
      id: '#(groupid)',
      description: Unit Testing - classification functions,
      admins: [ '#(AuthCertificateNode)','#(netidadmin)' ],
      readers:  ['#(UnAuthCertificateNode)'],
      classification: p
            }
    }
    """
    Given path 'group', groupid
    And header If-Match = '*'
    And param synchronized = ''
    And request payload
    When method put
    Then status 200

    * print 'modify the group, class -r- is successful'
    * def payload =
    """
    {
      data: {
      id: '#(groupid)',
      description: Unit Testing - classification functions,
      admins: [ '#(AuthCertificateNode)','#(netidadmin)' ],
      readers:  ['#(UnAuthCertificateNode)'],
      classification: r
            }
    }
    """
    Given path 'group', groupid
    And header If-Match = '*'
    And param synchronized = ''
    And request payload
    When method put
    Then status 200

    * print 'modify the group, class -c- is successful'
    * def payload =
    """
    {
      data: {
      id: '#(groupid)',
      description: Unit Testing - classification functions,
      admins: [ '#(AuthCertificateNode)','#(netidadmin)' ],
      readers:  ['#(UnAuthCertificateNode)'],
      classification: c
            }
    }
    """
    Given path 'group', groupid
    And header If-Match = '*'
    And param synchronized = ''
    And request payload
    When method put
    Then status 200

    * print 'modify the group, class -z- is not allowed'
    * def payload =
    """
    {
      data: {
      id: '#(groupid)',
      description: Unit Testing - classification functions,
      admins: [ '#(AuthCertificateNode)','#(netidadmin)' ],
      readers:  ['#(UnAuthCertificateNode)'],
      classification: z
            }
    }
    """
    Given path 'group', groupid
    And header If-Match = '*'
    And param synchronized = ''
    And request payload
    When method put
    Then status 400

    * print 'modify the group, class -U- (upper case) is not allowed'
    * def payload =
    """
    {
      data: {
      id: '#(groupid)',
      description: Unit Testing - classification functions,
      admins: [ '#(AuthCertificateNode)','#(netidadmin)' ],
      readers:  ['#(UnAuthCertificateNode)'],
      classification: U
            }
    }
    """
    Given path 'group', groupid
    And header If-Match = '*'
    And param synchronized = ''
    And request payload
    When method put
    Then status 400

    * print 'Modify the group, authorizationFactor -2- is ignored'
    * def payload =
    """
    {
      data: {
      id: '#(groupid)',
      description: Unit Testing - classification functions,
      admins: [ '#(AuthCertificateNode)','#(netidadmin)' ],
      readers:  ['#(UnAuthCertificateNode)'],
      authnfactor: 2
            }
    }
    """
    Given path 'group', groupid
    And header If-Match = '*'
    And param synchronized = ''
    And request payload
    When method put
    Then status 200

    * print 'clean up'
    # clean up
    Given path 'group', groupid
    When method delete
    Then status 200