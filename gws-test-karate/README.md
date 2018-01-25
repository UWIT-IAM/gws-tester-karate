rename karate-config.js.tmpl to remove .tmpl extension.

create a .pfx certificate file with public and private keys authorized for GWS.  This file should be in the same 
folder as karate-config.js.  

Adjust .json test groups as appropriate.  You need a base group u_<netid>_jsontests with cert above authorized as 
an admin.  

Right now this requires a forked version of Karate:

https://github.com/mattjm/karate/tree/karate-develop-2

These features will soon exist in the official release from the maintainer.  

The testgroupxx.json files have two main parts, "verify" and "put".  

* "put" is the actual payload sent to the API.  
* "verify" includes keys that aren't sent to the API but *are* returned from it.  Many of them are dynamic.  

groups-meta.feature can be called to verify the "basic" group attributes of a group.  There are some examples of this
in groups.feature.  Look for the "call" keyword.  