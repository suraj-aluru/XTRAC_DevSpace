public with sharing class authTestController {
	
	public String responseBody { get; set; } 
	
	public map<Id,oAuth2Service__c> oAuth2Services {get;set;}
	public List<SelectOption> services {get;set;}
	public String selectedServiceId { get; set; }
	
	public List<SelectOption> savedURLS {get;set;}
	public String selectedsavedURL { get; set; }
	
    public oAuth2Service__c selectedService{get;set;}
    public oAuth2Token__c selectedServiceToken {get;set;} 
    private Integer refreshRetries = 0;
  
	public authTestController(){
		String serviceIdentifier = ApexPages.currentPage().getParameters().get('sIdentifier');
		services = new List<SelectOption>();
		savedURLS = new List<SelectOption>();
		oAuth2Services = new map<Id,oAuth2Service__c>([SELECT Id,Name,Auth_URL__c,Token_URL__c,redirect_uri__c,client_secret__c,Client_Id__c,
		                                                      Auth_Scope__c,Service_Identifier__c,
		                                                      (Select Name, Saved_URL__c From oAuth2SaveURLs__r ),
		                                                      (Select Name, Access_Token__c, Refresh_Token__c, Code__c From oAuth2Tokens__r Where User__c=:userInfo.getUserId() limit 1)  
		                                               FROM oAuth2Service__c]);
		if(oAuth2Services.size()>0){
			selectedServiceId = oAuth2Services.values().get(0).Id;
			selectedService = oAuth2Services.values().get(0);
			for(oAuth2Service__c oA:oAuth2Services.values()){
        services.add(new SelectOption(oA.Id,oA.Name));
        if(serviceIdentifier != null && serviceIdentifier != '' && serviceIdentifier == oA.Service_Identifier__c){
          selectedServiceId = oA.Id;
          selectedService = oA;
          if(selectedService.oAuth2Tokens__r != null && selectedService.oAuth2Tokens__r.size()>0){
          	selectedServiceToken = selectedService.oAuth2Tokens__r[0];
            responseBody = 'Code:'+selectedServiceToken.Code__c;
          }
          else{
          	selectedServiceToken = null;
          }
        }
      }
      
      for(oAuth2SaveURL__c asu :selectedService.oAuth2SaveURLs__r){
      	savedURLS.add(new SelectOption(asu.Saved_URL__c,asu.Saved_URL__c));
      }
		}
	}
	
	public PageReference authorize(){
    if((selectedServiceToken != null && (selectedServiceToken.Code__c == null || selectedServiceToken.Code__c == '' )) || selectedServiceToken == null){
      string urlParams = '';
      urlParams += ('redirect_uri=' + selectedService.redirect_uri__c);
      urlParams += ('&client_id='+selectedService.Client_Id__c);
      urlParams += ('&scope='+System.Encodingutil.urlEncode(selectedService.Auth_Scope__c, 'UTF-8'));
      urlParams += ('&approval_prompt=force');
      urlParams += ('&response_type=code');
      urlParams += ('&access_type=offline');
      return new PageReference(selectedService.Auth_URL__c + '?' + urlParams);
    }
   else{
    return null;
   }
 }
 
 public PageReference fetchToken(){
 	String accessToken;
 	String refreshToken;
 	if((selectedServiceToken != null && (selectedServiceToken.Code__c == null || selectedServiceToken.Code__c == '' )) || selectedServiceToken == null ){
 		authorize();
 	}
 	
  HttpRequest req = new HttpRequest();
  HttpResponse res = new HttpResponse();
  Http http = new Http();
  req.setEndpoint(selectedService.Token_URL__c);
  req.setMethod('POST');
    
  string postData = 'code='+selectedServiceToken.Code__c;
  postData += ('&client_id='+selectedService.Client_Id__c);
  postData += ('&client_secret='+selectedService.client_secret__c);
  postData += ('&redirect_uri='+ selectedService.redirect_uri__c);
  postData += ('&grant_type=authorization_code');
  postData += ('&scope=');
  //postData += ('&scope='+System.Encodingutil.urlEncode(selectedService.Auth_Scope__c, 'UTF-8'));
  
  req.setBody(postData); 
  req.setHeader('Content-Type', 'application/x-www-form-urlencoded');  
  
  try {
    res = http.send(req);
    responseBody = 'endpoint:'+ req.getEndpoint() + '\n'; 
    responseBody += res.getBody();
        
    String regEx = '\"access_token\" : \"(.*?)\"';
    Pattern p = Pattern.compile(regEx);
    Matcher m = p.matcher(responseBody);
    if(m.find()){
      accessToken = m.group(1);
      System.debug('Suraj -->'+accessToken);
    }
        
    regEx = '\"refresh_token\" : \"(.*?)\"';
    p = Pattern.compile(regEx);
    m = p.matcher(responseBody);
    if(m.find()){
      refreshToken = m.group(1);
      System.debug('Suraj -->'+refreshToken);
    }
    
    if(accessToken != null && refreshToken != null){
    	selectedServiceToken.Access_Token__c = accessToken;
    	selectedServiceToken.Refresh_Token__c = refreshToken;
    	update selectedServiceToken;
    	refreshRetries = 0;
    }
	} 
	catch(System.CalloutException e) {
	 System.debug('Callout error: '+ e);
	 responseBody = 'Callout error: '+ e + '\n';
	 responseBody += res.toString();     
	}
  return null;
 }
	
 public PageReference refreshToken(){
 	String accessToken;
 	HttpRequest req = new HttpRequest();
  HttpResponse res = new HttpResponse();
  Http http = new Http();
  req.setEndpoint(selectedService.Token_URL__c);
  req.setMethod('POST');
  
  string postData = 'refresh_token='+selectedServiceToken.Refresh_Token__c;
  postData += ('&client_id='+selectedService.Client_Id__c);
  postData += ('&client_secret='+selectedService.client_secret__c);
  postData += ('&grant_type=refresh_token');
  
  req.setBody(postData); 
  req.setHeader('Content-Type', 'application/x-www-form-urlencoded');  
  
  try {
    res = http.send(req);
    responseBody = 'endpoint:'+ req.getEndpoint() + '\n'; 
    responseBody += res.getBody();
        
    String regEx = '\"access_token\" : \"(.*?)\"';
    Pattern p = Pattern.compile(regEx);
    Matcher m = p.matcher(responseBody);
    if(m.find()){
      accessToken = m.group(1);
      System.debug('Suraj -->'+accessToken);
    }

    if(accessToken != null){
    	selectedServiceToken.Access_Token__c = accessToken;
      update selectedServiceToken;
    }
	} 
	catch(System.CalloutException e) {
	 System.debug('Callout error: '+ e);
	 responseBody = 'Callout error: '+ e + '\n';
	 responseBody += res.toString();     
	}
 	return null;
 }	
 
 public PageReference fetchDetails(){
  
  string errorCode = '';
  HttpRequest req = new HttpRequest();
  HttpResponse res = new HttpResponse();
  Http http = new Http();
  string getData = 'access_token='+selectedServiceToken.Access_Token__c;
  //req.setEndpoint('https://www.googleapis.com/calendar/v3/users/me/settings?'+getData);
  req.setEndpoint(selectedsavedURL +'?'+getData);
  req.setMethod('GET'); 
  req.setHeader('Content-Type', 'application/json;charset=UTF-8');
  try {
     res = http.send(req);
     System.debug('Suraj --> refreshRetries: '+ refreshRetries);
     System.debug('Suraj --> Callout error: '+ res.getStatusCode());
     
     if(res.getStatusCode()== 401){
	 	  refreshToken();
	    if(refreshRetries < 3){
	     fetchDetails();
	    }
	    refreshRetries +=1;
     }
     responseBody = 'endpoint:'+ req.getEndpoint() + '\n'; 
     responseBody += 'refreshRetries:' +refreshRetries + '\n';
     responseBody += res.getBody();
	} 
	catch(System.CalloutException e) {
	 System.debug('Callout error: '+ e);
	 responseBody = 'Callout error: '+ e + '\n';
	 responseBody += res.toString();     
	}
  return null;
 } 
}