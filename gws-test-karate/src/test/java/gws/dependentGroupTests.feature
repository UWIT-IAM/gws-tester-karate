# ported from uwebinject
Feature:  Dependant Group Tests

  Background:

    * url BaseURL
    * configure headers = { 'Accept': 'application/json' ,'Content-type': 'application/json'}

    * def members = read('members.json')
    * def depgroup = BaseGroup + 'depgroup-dep'
    * def maingroup = BaseGroup + 'depgroup-main'
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
    Given path 'group', depgroup
    When method delete

  # clean up
    Given path 'group', maingroup
    When method delete

    * print 'Build the dependency group is successful'
    * def payload =
    """
    {
      data: {
      id: '#(depgroup)',
      description: Unit Testing - building dependency group is successful,
      admins: [ '#(AuthCertificateNode)','#(netidadmin)' ],
      readers:  ['#(UnAuthCertificateNode)']
            }
    }
    """
    Given path 'group', depgroup
    And param synchronized = ''
    And request payload
    When method put
    Then status 201

    * print 'PUT dependency membership succeeds'
    Given path 'group', depgroup, 'member'
    And param synchronized = ''
    * def payload = { data: ['#(UnAuthCertificateNode)'] }
    And request payload
    And header If-Match = '*'
    # note this is a post not a put
    When method put
    Then status 200

    * print 'Build the main group is successful'
    * def payload =
    """
    {
      data: {
      id: '#(maingroup)',
      description: Unit Testing - building main group is successful,
      admins: [ '#(AuthCertificateNode)','#(netidadmin)' ],
      readers:  ['#(UnAuthCertificateNode)'],
      updaters:  ['#(UnAuthCertificateNode)'],
      dependsOn:  '#(depgroup)'
            }
    }
    """
    Given path 'group', maingroup
    And param synchronized = ''
    And request payload
    When method put
    Then status 201