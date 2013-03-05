public with sharing class MappingTypeListScreen_AC {
 
 public String selectedMappingId{get;set;}
 public String mappingType {get;set;}
 public list<Mapping__c> lstMapping {get;set;}
 
 public MappingTypeListScreen_AC(){
 	mappingType = ApexPages.CurrentPage().getParameters().get('mappingtype');
 	fetchMapping();
 }
 
 private void fetchMapping(){
 	lstMapping = [Select Id,SF_Object_Name__c,SF_Field_Name__c,XTRAC_Field__c,Added_By__c,Date_Added__c From Mapping__c Where Mapping_Types__r.Name = :mappingType];
 }
 
 public void delMapping(){
 	delete new Mapping__c(Id=selectedMappingId);
 	fetchMapping();
 }
 
}