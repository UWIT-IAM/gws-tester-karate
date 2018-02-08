Feature:  Verifies group metadata, admins, and updaters (called from other features)

Background:

  # accepts arguments for testdata (what was put) and responsedata (what we got back from the API)
  * def testdata =  __arg.testdata
  * def responsedata = __arg.responsedata

Scenario:

# check admins
# update if number of elements changes (these are arrays)
Then match responsedata.data.admins[*] contains testdata.put.data.admins[0,1]
#check standard put elements (not arrays)
And match responsedata.data.id contains testdata.put.data.id
And match responsedata.data.displayName contains testdata.put.data.displayName
And match responsedata.data.description contains testdata.put.data.description
And match responsedata.data.contact contains testdata.put.data.contact
And match responsedata.data.authnFactor contains testdata.put.data.authnFactor
And match responsedata.data.classification contains testdata.put.data.classification
# check fields that aren't in the put payload
And match responsedata.data contains testdata.verify.data
And match responsedata.schemas contains testdata.schema
And match responsedata.meta.resourceType contains testdata.verify.meta.resourceType
And match responsedata.meta.selfRef contains BaseURL + '/group/' + testdata.put.data.id
And match responsedata.meta.memberRef contains BaseURL + '/group/' + testdata.put.data.id + '/member/'