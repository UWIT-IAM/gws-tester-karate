# ported from uwebinject
Feature: Course group tests

  Background:

    * url BaseURL
    * configure headers = { 'Accept': 'application/json' ,'Content-type': 'application/json'}

    * def members = read('members.json')
    * def groupid = CourseStem
    * def groupidsub = BaseGroup + 'authreadergroup_history'
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


  Scenario: Course group tests--unauth
    # start with unauth cert
    * configure ssl = NoAccessConfig

    # webinject #1
    * print 'Unauthorized viewing the membership is denied'
    Given path 'group', groupid, 'member'
    When method get
    Then status 401

    * print 'Unauthorized viewing the membership via history is denied'
    Given path 'group', groupid, 'history'
    When method get
    Then status 200
    And match response.data[*].description !contains '#regex add member:.*'

  Scenario: Course group tests--auth

    * print 'Viewing the group membership is authorized via cert'
    Given path 'group', groupid, 'member'
    When method get
    Then status 200
    And match response.data[*].type contains 'uwnetid'

    * print 'Viewing the group membership via history is authorized via cert'
    Given path 'group', groupid, 'history'
    When method get
    Then status 200
    And match response.data[*].description contains '#regex add member:.*'


