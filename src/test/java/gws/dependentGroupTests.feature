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
    When method put
    Then status 200

    # webinject #3
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

    * print 'PUT authorized main membership succeeds'
    Given path 'group', maingroup, 'member'
    * def payload = {data: ['#(UnAuthCertificateNode)']}
    And param synchronized = ''
    And request payload
    And header If-Match = '*'
    When method put
    Then status 200
    And match response.errors[0].notFound == []

    # webinject #5
    * print 'Newly added member is found in the membership'
    Given path 'group', maingroup, 'member'
    When method get
    Then status 200
    And match response.data[0].id == UnAuthCertificateNode.id

    * print 'Delete member from dep group succeeds'
    Given path 'group', depgroup, 'member', 'd:' + UnAuthCertificateNode.id
    And header If-Match = '*'
    When method delete
    Then status 200

    * print 'Delete member from main group succeeds'
    Given path 'group', maingroup, 'member', 'd:' + UnAuthCertificateNode.id
    And header If-Match = '*'
    And param synchronized = ''
    When method delete
    Then status 200

    # webinject #10
    * print 'Confirm member is not found in the membership after delete'
    Given path 'group', maingroup, 'member'
    When method get
    Then status 200
    And match response.data == []



    * print 'PUT unauthorized membership into main is prevented'
    Given path 'group', maingroup, 'member'
    * def payload = {data: ['#(UnAuthCertificateNode)']}
    And request payload
    And header If-Match = '*'
    # used to cause timeout...apparently fixed as of 2018-09-25
    And param synchronized = ''
    When method put
    Then status 200
    And match response.errors[0].notFound == [ '#(UnAuthCertificateNode.id)' ]
    * print response

    * print 'PUT unauthorized single member into main is prevented'
    Given path 'group', maingroup, 'member', 'd:' + UnAuthCertificateNode.id
    And header If-Match = '*'
    And param synchronized = ''
    And request ''
    When method put
    Then status 200
    And match response.errors[0].notFound == [ '#(UnAuthCertificateNode.id)' ]
    * print response

    # webinject #10
    * print 'Member is not found in the membership'
    Given path 'group', maingroup, 'member'
    When method get
    Then status 200
    And match response.data == []

    # clean up
    Given path 'group', depgroup
    When method delete
    Then status 200

