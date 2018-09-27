# ported from uwebinject
Feature:  Group Exchange Tests

  Background:

    * url BaseURL
    * configure headers = { 'Accept': 'application/json' ,'Content-type': 'application/json'}

    * def members = read('members.json')
    * def exchgroup = BaseGroup + 'exchange-tests'
    * def exchgroup2 = BaseGroup + 'exchange-tests' + '_subgroup'
    * def exchrenameleaf = 'exchange-rename'
    * def exchrename = BaseGroup + exchrenameleaf
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


  Scenario: Exchange enable and disable operations

   # since we have child groups, order matters
    # this one in case tests failed before rename
    * print 'Make sure clean up ran last time'
  # clean up
    Given path 'group', exchgroup2
    When method delete

    #this one in case tests failed before rename
    * print 'Make sure clean up ran last time'
  # clean up
    Given path 'group', exchgroup
    When method delete

    # since we have child groups, order matters
    * print 'Make sure clean up ran last time'
  # clean up
    Given path 'group', exchrename + '_subgroup'
    When method delete

    * print 'Make sure clean up ran last time'
  # clean up
    Given path 'group', exchrename
    When method delete


    * print 'Create test group and add admins and contact'
    * def payload =
    """
    {
      data: {
      id: '#(exchgroup)',
      description: karate exchange testing,
      admins: [ '#(AuthCertificateNode)','#(netidadmin2)' ],
      contact:  '#(netidadmin.id)',
            }
    }
    """
    Given path 'group', exchgroup
    And param synchronized = ''
    And request payload
    When method put
    Then status 201
    And match response.data.contact == netidadmin.id
    * def etag = responseHeaders['ETag'][0]

    * print 'Create second test group and add admins'
    * def payload =
    """
    {
      data: {
      id: '#(exchgroup2)',
      description: karate exchange testing,
      admins: [ '#(AuthCertificateNode)','#(netidadmin2)' ],
            }
    }
    """
    Given path 'group', exchgroup2
    And param synchronized = ''
    And request payload
    When method put
    Then status 201
    * def etag2 = responseHeaders['ETag'][0]


    * print 'add second group (exchange disabled) to first group (exchange disabled)'
    Given path 'group', exchgroup, 'member', 'g:' + exchgroup2
    And param synchronized = ''
    And request ''
    When method put
    Then status 200
    And match response.errors[0].notFound == []
    # Update: add non-mail group to non-mail group SHOULD have been allowed! (note from webinject)

    * print 'Exchange enable group'
    Given path 'group', exchgroup, 'affiliate', 'email'
    And param status = 'active'
    And header If-Match = '*'
    And request ''
    When method put
    Then status 403
    #  Update: add EmailEnabled attribute *SHOULD NOT* have been allowed since member group is not mail enabled!

    * print 'remove second group (exchange disabled) from first group (exchange disabled)'
    Given path 'group', exchgroup, 'member', 'g:' + exchgroup2
    And param synchronized = ''
    When method delete
    Then status 200
    # Removing group SHOULD have been allowed!

    * print 'Exchange enable group'
    Given path 'group', exchgroup, 'affiliate', 'email'
    And param status = 'active'
    And header If-Match = '*'
    And request ''
    When method put
    Then status 200
    #  Update: add EmailEnabled attribute *SHOULD* have been allowed!

  #reporttoorig tests not ported over--Jim says no need.  --mattjm 2018-06-25

  #publishemail tests not ported over--Jim says no need.  --mattjm 2018-06-25

    * print 'Remove contact for exchange enabled group'
    * def payload =
    """
    {
      data: {
      id: '#(exchgroup)',
      description: karate exchange testing,
      admins: [ '#(AuthCertificateNode)','#(netidadmin2)' ],
      contact: ""
            }
    }
    """
    Given path 'group', exchgroup
    And param synchronized = ''
    And request payload
    And header If-Match = '*'
    When method put
    Then status 200
    And match response.data.contact == ''
    # Update: remove contact attribute for exchange enabled group *SHOULD* have been allowed!

    * print 'add second group (exchange disabled) to first group (exchange enabled)'
    Given path 'group', exchgroup, 'member', 'g:' + exchgroup2
    And param synchronized = ''
    And request ''
    When method put
    Then status 400
    #  Update: add exchange-disabled group as member SHOULD NOT have been allowed!

    * print 'add second group (exchange disabled) as authorized sender of first group'
    Given path 'group', exchgroup, 'affiliate', 'email'
    And param status = 'active'
    And param sender = 'g:' + exchgroup2
    And param synchronized = ''
    And request ''
    When method put
    Then status 403
    #  Update: add exchange-disabled group as authorized sender SHOULD NOT have been allowed!

    * print 'Exchange enable second group'
    Given path 'group', exchgroup2, 'affiliate', 'email'
    And param status = 'active'
    And param synchronized = ''
    And header If-Match = '*'
    And request ''
    When method put
    Then status 200
    #  Update: add EmailEnabled attribute for second group *SHOULD* have been allowed!

    #todo
    * call makeDelay 5000

    * print 'add second group (exchange enabled) to first group (exchange enabled)'
    Given path 'group', exchgroup, 'member', 'g:' + exchgroup2
    And param synchronized = ''
    And request ''
    When method put
    Then status 200
    And match response.errors[0].notFound == []
    #  Update: add exchange-enabled group as member SHOULD have been allowed!



    * print 'add second group (exchange enabled) as authorized sender of first group'
    Given path 'group', exchgroup, 'affiliate', 'email'
    And param status = 'active'
    And param sender = 'g:' + exchgroup2
    And param synchronized = ''
    And request ''
    When method put
    Then status 200
    #   Update: add exchange-disabled group as authorized sender SHOULD have been allowed!


  * print 'attempt to rename parent group'
    Given path 'groupMove', exchgroup
    And param newext = exchrenameleaf
    And param subgroups = ''
    And request ''
    When method put
    Then status 200



    # since we have child groups, order matters
    * print 'Make sure clean up ran last time'
    Given path 'group', exchrename + '_subgroup'
    When method delete
    Then status 200

    * print 'Make sure clean up ran last time'
    Given path 'group', exchrename
    When method delete
    Then status 200