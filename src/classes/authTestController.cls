public with sharing class authTestController {
 public String service { get; set; }
 public String authUrl { get; set; }
 public boolean authSuccess { get; set; }
 public String message { get; set; }
 public String token { get; set; }
 public String verifier { get; set; }
 public String detailUrl {get;set;}
 public String body { get; set; }
 public List<SelectOption> services {
  get {
   if(services==null){
    List<OAuthService__c> l = [SELECT name FROM OAuthService__c];
    services = new List<SelectOption>();
    for(OAuthService__c obj : l) {
     services.add(new SelectOption(obj.name,obj.name));
     System.debug('service: '+obj.name);
    }
   }
   return services;
  }
  set;
 }
 
 public authTestController(){
   detailUrl = 'https://www.blogger.com/feeds/4064807799047825156/posts/default';
   token = null;
   if(ApexPages.currentPage().getParameters().get('oauth_token') !=null){
    token = ApexPages.currentPage().getParameters().get('oauth_token');
    verifier = ApexPages.currentPage().getParameters().get('oauth_verifier');
    message = ApexPages.currentPage().getParameters().get('message');
    if(message == 'null'){
    	message = '';
    }
   }
 }
 
 public PageReference authorize(){
  OAuth oa = new OAuth();
  authUrl = oa.newAuthorization(service);
  System.debug('Suraj --> authUrl:' + authUrl);
  if(authUrl==null) {
   this.message = oa.message;
   return null;
  }
  else {
   return new PageReference('/apex/CompleteAuth?authUrl='+authUrl);
  }
 }
 
 public PageReference fetchDetails() {
  Http h = new Http();
  HttpRequest req = new HttpRequest();
  req.setMethod('GET');
  req.setEndpoint(detailUrl);
	OAuth oa = new OAuth();
	oa.setConsumerKey('anonymous');
  oa.setConsumerSecret('anonymous');
	oa.setToken('');
	oa.setTokenSecret('');
	oa.sign(req);
	System.debug('Sending request...');
  System.debug('Suraj --> req.getHeader():' + req.getHeader('Content-Type'));
	HttpResponse res = h.send(req);
	body = res.getBody();
	System.debug('Received response ('+res.getStatusCode()+' '+res.getStatus()+')');
	message = '';
	return null;
 }
 
 /*public PageReference completeAuthorization() {
  String token = ApexPages.currentPage().getParameters().get('oauth_token');
  if(token!=null)
  {
   String verifier = ApexPages.currentPage().getParameters().get('oauth_verifier');
   OAuth oa = new OAuth();
   authSuccess = oa.completeAuthorization(token,verifier);
   this.message = oa.message;
  }
  else {
   message = 'Invalid request. Missing parameter oauth_token';
  }
  return null;
 }*/
 
 /*
  public String url {get;set;}
  public String result {get;set;}
  public String service {get;set;}
  public String callbackUrl {get; set; }
  private Map<String,String> parameters = new Map<String,String>();
  
  private String request_token_url ='https://www.google.com/accounts/OAuthGetRequestToken?scope=https%3A%2F%2Fwww.blogger.com%2Ffeeds%2F4064807799047825156%2Fposts%2Fdefault';
  private String access_token_url = 'https://www.google.com/accounts/OAuthGetAccessToken';
  private String authorization_url = 'https://www.google.com/accounts/OAuthAuthorizeToken';
  
  private String consumer_key = 'anonymous';
  private String consumer_secret = 'anonymous';
  
  private String nonce;
  private String timestamp;
  private String signature;
  
  public String token {get;set;}
  public String tokenSecret {get;set;}
  
  public authTestController(){
    url ='https://www.blogger.com/feeds/4064807799047825156/posts/default';
    service = 'Google Blogger APIs';
    callbackUrl = EncodingUtil.urlEncode('https://'+ApexPages.currentPage().getHeaders().get('Host')+  '/apex/authTest','UTF-8');
  }
  
  public PageReference fetchTokenDetails() {
    System.debug('Suraj --> fetchTokenDetails:');
    
    Http h = new Http();
    HttpRequest req = new HttpRequest();
    req.setMethod('GET');
    req.setEndpoint(request_token_url);
    
    nonce = String.valueOf(Crypto.getRandomLong());
    timestamp = String.valueOf(DateTime.now().getTime()/1000);

    parameters.put('oauth_consumer_key',consumer_key);
    
    parameters.put('oauth_signature_method','HMAC-SHA1');
    parameters.put('oauth_timestamp',timestamp);
    parameters.put('oauth_nonce',nonce);
    parameters.put('oauth_callback',callbackUrl);
    
    String s = createBaseString(parameters, req);
    System.debug('Suraj --> s:' + s);
    
    Blob sig = Crypto.generateMac('HmacSHA1', Blob.valueOf(s),Blob.valueOf(consumer_secret+'&'+(tokenSecret!=null ? tokenSecret : '')));
    System.debug('Suraj --> sig:' + sig);
                              
    signature = EncodingUtil.urlEncode(EncodingUtil.base64encode(sig), 'UTF-8');
    System.debug('Suraj --> signature:' + signature);
    
    String header = 'OAuth ';
    
    for (String key : parameters.keySet()) {
      header = header + key + '="'+parameters.get(key)+'", ';
    }
    
    header = header + 'oauth_signature="'+signature+'"';
    req.setHeader('Authorization',header);
    
    HttpResponse res = null;
    res = h.send(req);
    String resParams = res.getBody();
    System.debug('Suraj --> resParams:' + resParams);
    
    Map<String,String> rp = getUrlParams(resParams);
    
    token = rp.get('oauth_token');
    tokenSecret = rp.get('oauth_token_secret');
    
    System.debug('Suraj --> token:' +token );
    System.debug('Suraj --> tokenSecret:' + tokenSecret );
    result =resParams;
    
    return null;
  }
  
   public PageReference fetchData() {
    System.debug('Suraj --> fetchData:');
    Http h = new Http();
    HttpRequest req = new HttpRequest();
    req.setMethod('POST');
    req.setEndpoint(access_token_url);
    req.setBody('');
    nonce = String.valueOf(Crypto.getRandomLong());
    timestamp = String.valueOf(DateTime.now().getTime()/1000);

    parameters.put('oauth_consumer_key',consumer_key);
    parameters.put('oauth_token',token);
    parameters.put('oauth_signature_method','HMAC-SHA1');
    parameters.put('oauth_timestamp',timestamp);
    parameters.put('oauth_nonce',nonce);
    parameters.put('oauth_callback',callbackUrl);
    
    String s = createBaseString(parameters, req);
    System.debug('Suraj --> s:' + s);
    
    Blob sig = Crypto.generateMac('HmacSHA1', Blob.valueOf(s),Blob.valueOf(consumer_secret+'&'+(tokenSecret!=null ? tokenSecret : '')));
    System.debug('Suraj --> sig:' + sig);
                              
    signature = EncodingUtil.urlEncode(EncodingUtil.base64encode(sig), 'UTF-8');
    System.debug('Suraj --> signature:' + signature);
    
    String header = 'OAuth ';
    
    for (String key : parameters.keySet()) {
      header = header + key + '="'+parameters.get(key)+'", ';
    }
    
    header = header + 'oauth_signature="'+signature+'"';
    req.setHeader('Authorization',header);
    
    HttpResponse res = null;
    res = h.send(req);
    String resParams = res.getBody();
    System.debug('Suraj --> resParams:' + resParams);
    result =resParams;
    return null;
   }
   
   public PageReference fetchTokenAndData(){
     fetchTokenDetails();
     fetchData();
     return null;
   }
  
  
  private String createBaseString(Map<String,String> oauthParams, HttpRequest req) {
    Map<String,String> p = oauthParams.clone();
    if(req.getMethod().equalsIgnoreCase('post') && req.getBody()!=null &&
       req.getHeader('Content-Type')=='application/x-www-form-urlencoded') {
        p.putAll(getUrlParams(req.getBody()));
    }
    String host = req.getEndpoint();
    Integer n = host.indexOf('?');
    if(n>-1) {
      p.putAll(getUrlParams(host.substring(n+1)));
      host = host.substring(0,n);
    }
    List<String> keys = new List<String>();
    keys.addAll(p.keySet());
    keys.sort();
    String s = keys.get(0)+'='+p.get(keys.get(0));
    for(Integer i=1;i<keys.size();i++) {
      s = s + '&' + keys.get(i)+'='+p.get(keys.get(i));
    }

    // According to OAuth spec, host string should be lowercased, but Google and LinkedIn
    // both expect that case is preserved.
    return req.getMethod().toUpperCase()+ '&' +
      EncodingUtil.urlEncode(host, 'UTF-8') + '&' +
      EncodingUtil.urlEncode(s, 'UTF-8');
  }
  
  private Map<String,String> getUrlParams(String value) {

    Map<String,String> res = new Map<String,String>();
    if(value==null || value=='') {
      return res;
    }
    for(String s : value.split('&')) {
      System.debug('getUrlParams: '+s);
      List<String> kv = s.split('=');
      if(kv.size()>1) {
        String encName = EncodingUtil.urlEncode(EncodingUtil.urlDecode(kv[0], 'UTF-8'), 'UTF-8').replace('+','%20');
        String encValue = EncodingUtil.urlEncode(EncodingUtil.urlDecode(kv[1], 'UTF-8'), 'UTF-8').replace('+','%20');
        System.debug('getUrlParams:  -> '+encName+','+encValue);
        res.put(encName,encValue);
      }
    }
    return res;
  }*/
}