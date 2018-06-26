#ported from uwebinject
Feature:  Groups with periods in their names

  Background:

    * url BaseURL
    * configure headers = { 'Accept': 'application/json' ,'Content-type': 'application/json'}

    * def members = read('members.json')
    * def groupid = BaseGroup + 'webinject'
    * def dotleaf = 'web.inject'
    * def dotgroupid = BaseGroup + dotleaf

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


  Scenario: Groups with periods in their names


    * print ''
  # clean up
    Given path 'group', groupid
    When method delete

    * print 'Make sure clean up ran last time'
    Given path 'group', dotgroupid
    When method delete




    * print 'Create a group with a period is successful'
    * def payload =
    """
    {
      data: {
      id: '#(dotgroupid)',
      description: webinject affiliate testing,
      admins: [ '#(AuthCertificateNode)','#(netidadmin)' ]
            }
    }
    """
    Given path 'group', dotgroupid
    And param synchronized = ''
    And request payload
    When method put
    Then status 201


    * print 'update google affiliate status to active is prevented'
    Given path 'group', dotgroupid, 'affiliate', 'google'
    And param status = 'active'
    And request ''
    When method put
    Then status 403
    And match response.errors[*].detail[*] contains 'Google group cannot have a dot.'

    * print 'Google affiliate status remains inactive'
    Given path 'group', dotgroupid
    When method get
    Then status 200
    And match response.data.affiliates == '#[1]'
    And match response.data.affiliates[0].senders == []

    * print 'cleanup:  delete group is successful'
    Given path 'group', dotgroupid
    When method delete
    Then status 200

    * print 'Create a group without a period is successful'
    * def payload =
    """
    {
      data: {
      id: '#(groupid)',
      description: webinject affiliate testing,
      admins: [ '#(AuthCertificateNode)','#(netidadmin)' ]
            }
    }
    """
    Given path 'group', groupid
    And param synchronized = ''
    And request payload
    When method put
    Then status 201


    * print 'update google affiliate status to active is allowed'
    Given path 'group', groupid, 'affiliate', 'google'
    And param status = 'active'
    And request ''
    When method put
    Then status 200

    * print 'rename the group to have a period is prevented'
    Given path 'groupMove', groupid
    And param newext = dotleaf
    And param subgroups = ''
    And param synchronized = ''
    And request ''
    When method put
    Then status 409
    # TODO why is this error (rename) different text from trying to enable with dot?
    And match response.errors[*].detail[*] contains 'google group cannot have dot'

    * print 'verify rename failed'
    Given path 'group', dotgroupid
    When method get
    Then status 404

    * print 'group without period remains unchanged'
    Given path 'group', groupid
    When method get
    Then status 200
    * def mystatus = get[0] response.data.affiliates[?(@.name == 'google')].status
    And match mystatus == 'active'

    Given path 'group', groupid
    When method delete
    Then status 200