function() {    
  var env = karate.env; // get system property 'karate.env'
  karate.log('karate.env system property was:', env);
  if (!env) {
    env = 'dev';
  }
  var config = {
    env: env,
	myVarName: 'someValue'
  }
  if (env == 'dev') {
    // customize
    // e.g. config.foo = 'bar';
  } else if (env == 'e2e') {
    // customize
  }
 //karate.configure('ssl', true);
  var certConfig = {rootcert: 'C:/Users/mattjm/Documents/spregworking/uwca.crt', privatekey:'C:/Users/mattjm/Documents/spregworking/urizen3.key', publickey:'C:/Users/mattjm/Documents/spregworking/urizen3.crt'};
  karate.configure('certAuth', certConfig)
  return config;
}