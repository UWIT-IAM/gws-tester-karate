rename karate-config.js.tmpl to remove .tmpl extension.

create a .pfx certificate file with public and private keys authorized for GWS.  This file should be in the same 
folder as karate-config.js.  

Adjust .json test groups as appropriate.  You need a base group u_<netid>_jsontests with cert above authorized as 
an admin.  

The testgroupxx.json files have two main parts, "verify" and "put".  

* "put" is the actual payload sent to the API.  
* "verify" includes keys that aren't sent to the API but *are* returned from it.  Many of them are dynamic.  

groups-meta.feature can be called to verify the "basic" group attributes of a group.  There are some examples of this
in groups.feature.  Look for the "call" keyword.  

To test all:

  $ mvn clean test

To run a single feature test:

  $ ./testone <feature_name>

