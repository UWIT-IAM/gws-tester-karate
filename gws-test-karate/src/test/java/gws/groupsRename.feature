# ported from Jim's Python tester
Feature: Group Rename Tests

Background:

  * url BaseURL
  * configure headers = { 'Accept': 'application/json', 'Content-type': 'application/json'}
  * def groupid = BaseGroup + 'rename-base'
  * def certid = AuthCertificateNode
  * def netidadmin = AdminNetidUser


Scenario: subgroup rename/relocate tests

  * print 'Make sure clean up ran last time'
  Given path 'group', groupid + '_renamedstem_' + 'subgroup'
  When method delete

  * print 'Make sure clean up ran last time'
  Given path 'group', groupid + '_renamedstem'
  When method delete

  * print 'Make sure clean up ran last time'
  Given path 'group', groupid
  When method delete



  * print 'Build the test base group is successful'
  Given path 'group', groupid
  And request { data: { id: '#(groupid)', description: testing-subgroup functions-base, admins: [ '#(certid)', '#(netidadmin)'   ], creators: ['#(certid)'] } }
  When method put
  Then status 201

  * print 'Build the test group is successful'
  * def thisgroupid = groupid + '_originalstem'
  Given path 'group', thisgroupid
  And request { data: { id: '#(thisgroupid)', description: testing-subgroup functions-authorized, admins: [ '#(certid)', '#(netidadmin)'   ], creators: ['#(certid)'] } }
  When method put
  Then status 201

  * print 'Build the test subgroup is successful'
  * def thisgroupid = groupid + '_originalstem_' + 'subgroup'
  Given path 'group', thisgroupid
  And request { data: { id: '#(thisgroupid)', description: testing-subgroup functions-authorized, admins: [ '#(certid)', '#(netidadmin)'   ] } }
  When method put
  Then status 201

  * print 'get finds the subgroup successfully'
  Given path 'group', groupid + '_originalstem_' + 'subgroup'
  When method get
  Then status 200

  * print 'Rename the group is successful'
  Given path 'groupMove', groupid + '_originalstem'
  And param newext = 'renamedstem'
  And param subgroups = ''
  And request ''
  When method put
  Then status 200

  * print 'A GET finds the subgroup under its new stem name'
  Given path 'group', groupid + '_renamedstem_' + 'subgroup'
  When method get
  Then status 200

  * print 'A GET does not find the subgroup under the original stem name'
  Given path 'group', groupid + '_originalstem_' + 'subgroup'
  When method get
  Then status 404

  * print 'Delete the subgroup under its renamed stem is successful'
  Given path 'group', groupid + '_renamedstem_' + 'subgroup'
  When method delete
  And header If-Match = '*'
  Then status 200

  * print 'Delete the renamed group succeeds'
  Given path 'group', groupid + '_renamedstem'
  When method delete
  And header If-Match = '*'
  Then status 200

  * print 'Build the test group is successful (take two)'
  * def thisgroupid = groupid + '_originalstem'
  Given path 'group', thisgroupid
  And request { data: { id: '#(thisgroupid)', description: testing-subgroup functions-authorized, admins: [ '#(certid)', '#(netidadmin)'   ], creators: ['#(certid)'] } }
  When method put
  Then status 201

  * print 'Build the test group is successful (alternatestem)'
  * def thisgroupid = groupid + '_alternatestem'
  Given path 'group', thisgroupid
  And request { data: { id: '#(thisgroupid)', description: testing-subgroup functions-authorized, admins: [ '#(certid)', '#(netidadmin)'   ], creators: ['#(certid)'] } }
  When method put
  Then status 201

  * print 'Build the test subgroup is successful (take two)'
  * def thisgroupid = groupid + '_originalstem_' + 'subgroup'
  Given path 'group', thisgroupid
  And request { data: { id: '#(thisgroupid)', description: testing-subgroup functions-authorized, admins: [ '#(certid)', '#(netidadmin)'   ] } }
  When method put
  Then status 201

  * print 'Build the unmoved subgroup is successful'
  * def thisgroupid = groupid + '_originalstem_' + 'stationary-subgroup'
  Given path 'group', thisgroupid
  And request { data: { id: '#(thisgroupid)', description: testing-subgroup functions-authorized, admins: [ '#(certid)', '#(netidadmin)'   ] } }
  When method put
  Then status 201

  * print 'Build the test subsubgroup is successful (take two)'
  * def thisgroupid = groupid + '_originalstem_' + 'subgroup_' + 'subsubgroup'
  Given path 'group', thisgroupid
  And request { data: { id: '#(thisgroupid)', description: testing-subgroup functions-authorized, admins: [ '#(certid)', '#(netidadmin)'   ] } }
  When method put
  Then status 201

  * print 'get finds the subgroup successfully'
  Given path 'group', groupid + '_originalstem_' + 'subgroup'
  When method get
  Then status 200

  * print 'get finds the stationary subgroup successfully'
  Given path 'group', groupid + '_originalstem_' + 'stationary-subgroup'
  When method get
  Then status 200

  * print 'get finds the subsubgroup successfully'
  Given path 'group', groupid + '_originalstem_' + 'subgroup_' + 'subsubgroup'
  When method get
  Then status 200

  * print 'Relocate the group (not subgroups) is successful'
  Given path 'groupMove', groupid + '_originalstem_' + 'subgroup'
  And param newstem = groupid + '_alternatestem'
  And param subgroups = ''
  And request ''
  When method put
  Then status 200


 # clean up



