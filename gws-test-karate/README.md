rename karate-config.js.tmpl to remove .tmpl extension.

create a .pfx certificate file with public and private keys authorized for GWS.  This file should be in the same 
folder as karate-config.js.  

Adjust .json test groups as appropriate.  You need a base group u_<netid>_jsontests with cert above authorized as 
an admin.  

