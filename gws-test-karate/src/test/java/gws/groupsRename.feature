# ported from uwebinject
Feature: Group Rename Tests

Background:

  * url BaseURL
  * configure headers = { 'Accept': 'application/json', 'Content-type': 'application/json'}
  * def groupid = BaseGroup + 'rename-base'
  * def certid = AuthCertificateNode
  * def netidadmin = AdminNetidUser


Scenario: subgroup rename/relocate tests

  * print 'Make sure clean up ran last time'
  Given path 'group', groupid + '_alternatestem' + '_subgroup' + '_subsubgroup'
  When method delete

  * print 'Make sure clean up ran last time'
  Given path 'group', groupid + '_alternatestem' + '_subgroup'
  When method delete

  * print 'Make sure clean up ran last time'
  Given path 'group', groupid + '_alternatestem'
  When method delete

  * print 'Make sure clean up ran last time'
  Given path 'group', groupid + '_originalstem' + '_stationary-subgroup'
  When method delete

  * print 'Make sure clean up ran last time'
  Given path 'group', groupid + '_originalstem' + '_subgroup' + '_subsubgroup'
  When method delete

  * print 'Make sure clean up ran last time'
  Given path 'group', groupid + '_originalstem' + '_subgroup'
  When method delete

  * print 'Make sure clean up ran last time'
  Given path 'group', groupid + '_originalstem'
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
  * def thisgroupid = groupid + '_originalstem' + '_subgroup'
  Given path 'group', thisgroupid
  And request { data: { id: '#(thisgroupid)', description: testing-subgroup functions-authorized, admins: [ '#(certid)', '#(netidadmin)'   ] } }
  When method put
  Then status 201

  * print 'get finds the subgroup successfully'
  Given path 'group', groupid + '_originalstem' + '_subgroup'
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
  Given path 'group', groupid + '_renamedstem' + '_subgroup'
  When method get
  Then status 200

  * print 'A GET does not find the subgroup under the original stem name'
  Given path 'group', groupid + '_originalstem' + '_subgroup'
  When method get
  Then status 404

  * print 'Delete the subgroup under its renamed stem is successful'
  Given path 'group', groupid + '_renamedstem' + '_subgroup'
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
  * def thisgroupid = groupid + '_originalstem' + '_subgroup'
  Given path 'group', thisgroupid
  And request { data: { id: '#(thisgroupid)', description: testing-subgroup functions-authorized, admins: [ '#(certid)', '#(netidadmin)'   ] } }
  When method put
  Then status 201

  * print 'Build the unmoved subgroup is successful'
  * def thisgroupid = groupid + '_originalstem' + '_stationary-subgroup'
  Given path 'group', thisgroupid
  And request { data: { id: '#(thisgroupid)', description: testing-subgroup functions-authorized, admins: [ '#(certid)', '#(netidadmin)'   ] } }
  When method put
  Then status 201

  * print 'Build the test subsubgroup is successful (take two)'
  * def thisgroupid = groupid + '_originalstem' + '_subgroup' + '_subsubgroup'
  Given path 'group', thisgroupid
  And request { data: { id: '#(thisgroupid)', description: testing-subgroup functions-authorized, admins: [ '#(certid)', '#(netidadmin)'   ] } }
  When method put
  Then status 201

  * print 'get finds the subgroup successfully'
  Given path 'group', groupid + '_originalstem' + '_subgroup'
  When method get
  Then status 200

  * print 'get finds the stationary subgroup successfully'
  Given path 'group', groupid + '_originalstem' + '_stationary-subgroup'
  When method get
  Then status 200

  * print 'get finds the subsubgroup successfully'
  Given path 'group', groupid + '_originalstem' + '_subgroup' + '_subsubgroup'
  When method get
  Then status 200

  * print 'Relocate the group (not subgroups) is successful'
  Given path 'groupMove', groupid + '_originalstem' + '_subgroup'
  And param newstem = groupid + '_alternatestem'
  And request ''
  When method put
  Then status 200

  * print 'A GET fails to find the subgroup under its original stem'
  Given path 'group', groupid + '_originalstem' + '_subgroup'
  When method get
  Then status 404

  * print 'A GET finds the subgroup under its original stem'
  Given path 'group', groupid + '_alternatestem' + '_subgroup'
  When method get
  Then status 200

  * print 'A GET still finds the stationary subgroup successfully'
  Given path 'group', groupid + '_originalstem' + '_stationary-subgroup'
  When method get
  Then status 200

  * print 'Relocate the subgroup back to original stem is successful'
  Given path 'groupMove', groupid + '_alternatestem_' + 'subgroup'
  And param newstem = groupid + '_originalstem'
  And request ''
  When method put
  Then status 200

  #1031
  * print 'A GET finds the again relocated subgroup successfully'
  Given path 'group', groupid + '_originalstem' + '_subgroup'
  When method get
  Then status 200

  #1032
  * print 'A GET still finds the subsubgroup under its original stem'
  Given path 'group', groupid + '_originalstem' + '_subgroup' + '_subsubgroup'
  When method get
  Then status 200

  #1035
  * print 'Relocate the subgroup (now including subgroups) is successful'
  Given path 'groupMove', groupid + '_originalstem' + '_subgroup'
  And param newstem = groupid + '_alternatestem'
  And param subgroups = ''
  And request ''
  When method put
  Then status 200

  #1036
  * print 'A GET fails to find the relocated subgroup under its original stem'
  Given path 'group', groupid + '_originalstem' + '_subgroup'
  When method get
  Then status 404

  #1037
  * print 'A GET does find the yet again relocated subgroup in the new stem'
  Given path 'group', groupid + '_alternatestem' + '_subgroup'
  When method get
  Then status 200

  #1038
  * print 'A GET fails to find the subsubgroup under the original stem'
  Given path 'group', groupid + '_originalstem' + '_subgroup' + '_subsubgroup'
  When method get
  Then status 404

  #1039
  * print 'A GET does find the subsubgroup under the new stem'
  Given path 'group', groupid + '_alternatestem' + '_subgroup' + '_subsubgroup'
  When method get
  Then status 200

  #1040
  * print 'A GET still finds the stationary subgroup successfully'
  Given path 'group', groupid + '_originalstem' + '_stationary-subgroup'
  When method get
  Then status 200

 # clean up

  #1500
  * print 'Delete the stationary subgroup under original stem'
  Given path 'group', groupid + '_originalstem' + '_stationary-subgroup'
  When method delete
  And header If-Match = '*'
  Then status 200

  #1501
  * print 'Delete the original stem group'
  Given path 'group', groupid + '_originalstem'
  When method delete
  And header If-Match = '*'
  Then status 200

  #1511
  * print 'Delete the subsubgroup is successful'
  Given path 'group', groupid + '_alternatestem' + '_subgroup' + '_subsubgroup'
  When method delete
  And header If-Match = '*'
  Then status 200

  #1512
  * print 'Delete the subgroup is successful'
  Given path 'group', groupid + '_alternatestem' + '_subgroup'
  When method delete
  And header If-Match = '*'
  Then status 200

  #1513
  * print 'Delete the alternate stem group succeeds'
  Given path 'group', groupid + '_alternatestem'
  When method delete
  And header If-Match = '*'
  Then status 200


  #1520
  * print 'Delete the base group succeeds'
  Given path 'group', groupid
  When method delete
  And header If-Match = '*'
  Then status 200



