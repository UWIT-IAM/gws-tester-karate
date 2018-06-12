# ported from uwebinject
Feature: subgroup creator tests

  Background:

    * url BaseURL
    * configure headers = { 'Accept': 'application/json' ,'Content-type': 'application/json'}

    * def members = read('members.json')
    * def groupauth = BaseGroup + 'subgroup-auth'
    * def groupauthtest = BaseGroup + 'subgroup-auth_creatortesting'
    * def groupnoauth = BaseGroup + 'subgroup-noauth'
    * def groupnoauthtest = BaseGroup + 'subgroup-noauth_creatortesting'
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
    Given path 'group', groupauth
    When method delete

    * print 'Make sure clean up ran last time'
    # clean up
    Given path 'group', groupauthtest
    When method delete

    * print 'Make sure clean up ran last time'
    # clean up
    Given path 'group', groupnoauth
    When method delete

    * print 'Make sure clean up ran last time'
    # clean up
    Given path 'group', groupnoauthtest
    When method delete

    # webinject #1
    * print 'Build the authorized subgroup is successful'
    * def payload =
    """
    {
      data: {
      id: '#(groupauth)',
      description: build the authorized subgroup is successful,
      admins: [ '#(certid)','#(netidadmin)' ],
      updaters:  ['#(certid)'],
      creators:  ['#(UnAuthCertificateNode)']
            }
    }
    """
    Given path 'group', groupauth
    And request payload
    When method put
    Then status 201

  Scenario:  Switch to unauth cert
    * configure ssl = NoAccessConfig

    * print 'Building a subgroup when authorized succeeds'
    * def payload =
    """
    {
      data: {
      id: '#(groupauthtest)',
      description: Creator Testing subgroup,
      admins: [ '#(certid)','#(netidadmin)' ],
            }
    }
    """
    Given path 'group', groupauthtest
    And request payload
    When method put
    Then status 201

  Scenario:  Switch to auth cert

    * print 'Cleanup - delete subgroup'
    Given path 'group', groupauthtest
    When method delete
    And header If-Match = '*'
    Then status 200

    * print 'Cleanup - delete auth group succeeds'
    Given path 'group', groupauth
    When method delete
    And header If-Match = '*'
    Then status 200

    * print 'Build the unauthorized subgroup is successful'
    * def payload =
    """
    {
      data: {
      id: '#(groupnoauth)',
      description: build the authorized subgroup is successful,
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

    * print 'Building a subgroup when NOT authorized fails'
    * def payload =
    """
    {
      data: {
      id: '#(groupnoauthtest)',
      description: Creator Testing subgroup,
      admins: [ '#(certid)','#(netidadmin)' ],
            }
    }
    """
    Given path 'group', groupnoauthtest
    And request payload
    When method put
    Then status 401

  Scenario:  Switch to auth cert

    * print 'Cleanup: delete unauthorized subgroup succeeds'
    Given path 'group', groupnoauth
    When method delete
    And header If-Match = '*'
    Then status 200