public with sharing class OAuth {
  public PageReference completeAuthorization() {
  	String serviceIdentifier = ApexPages.currentPage().getParameters().get('sIdentifier');
    String code = ApexPages.currentPage().getParameters().get('code');    
    
    if(serviceIdentifier == null || serviceIdentifier == ''){
    	serviceIdentifier = 'Google_Calendar';
    }
    
    if(code != '' && code != null){
    	list<oAuth2Token__c> lstToken = [SELECT Id,Code__c FROM oAuth2Token__c Where oAuth2Service__r.Service_Identifier__c =:serviceIdentifier and User__c=:userInfo.getUserId() limit 1];
    	oAuth2Token__c oAT;
    	if(lstToken.size()>0){
    		oAT = lstToken[0];
    		oAT.Code__c = code;
        update oAT;
    	}
    	else{
    		oAuth2Service__c oA = [Select Id From oAuth2Service__c Where Service_Identifier__c =:serviceIdentifier limit 1];
    		oAT = new oAuth2Token__c();
    		oAT.oAuth2Service__c = oA.Id;
    		oAT.Code__c = code;
    		oAT.User__c = userinfo.getUserId();
    		insert oAT;
    	}
    }
    return new PageReference('/apex/authTest?sIdentifier='+serviceIdentifier);
  }
}