public with sharing class MappingTypeScreen_AC {
 public list<Mapping_Types__c> lstMappingTypes {get;set;}
 public MappingTypeScreen_AC(){
 	lstMappingTypes = [Select id,Name  From Mapping_Types__c order by name];
 }
}