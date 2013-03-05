public with sharing class AddMapping_AC {
 
 public String selectedObj {get;set;}
 public String selectedFld {get;set;}
 public String selectedXtracFld {get;set;}  
 
 public List<SelectOption> objs{get;set;}
 public List<SelectOption> flds{get;set;}
 public List<SelectOption> XtracFlds{get;set;}
 
 private String mappingTypeName {get;set;} 
 private Mapping_Types__c mappingType; 
 private Map <String, Schema.SObjectType> schemaMap ;
 public AddMapping_AC(){
    mappingTypeName = ApexPages.CurrentPage().getParameters().get('mappingtype');
    if(mappingTypeName != null){
      mappingType = [Select id From Mapping_Types__c Where Name =: mappingTypeName];
    }
  schemaMap = Schema.getGlobalDescribe();
  objs = new List<SelectOption>();
  flds = new List<SelectOption>();
  XtracFlds = new List<SelectOption>();
  
  fillObjects();
  fillFields();
  fillXtracFields();
 }
 
 public void fillObjects(){
    List<Schema.SObjectType> gd = schemaMap.Values();
    objs.add(new SelectOption('','-- Select Object --'));
    list<String>tmp = new list<String>();
    
    for(Schema.SObjectType f : gd){
   tmp.add(f.getDescribe().getname());
  }
  
  tmp.sort();
  
  for(String s : tmp){
   Schema.SObjectType f = schemaMap.get(s);
   objs.add(new SelectOption(f.getDescribe().getname(),f.getDescribe().getLabel()));
  }     
 }
 
 public void fillFields(){
    flds.clear();
    flds.add(new SelectOption('','-- Select Field --'));
    system.debug('FMR --> schemaMap:'+schemaMap);
    system.debug('FMR --> selectedObj:'+selectedObj);
    if(selectedObj != null && selectedObj != ''){
     system.debug('FMR --> schemaMap.get(selectedObj):'+schemaMap.get(selectedObj));
     map<String, Schema.SObjectField> fieldMap = schemaMap.get(selectedObj).getDescribe().fields.getMap();
     list<Schema.SObjectField> fldValues = fieldMap.Values();
     list<String>tmp = new list<String>();
     
     for(Schema.SObjectField sfield : fldValues){
        schema.describefieldresult dfield = sfield.getDescribe();
        tmp.add(dfield.getname());
     }
     
     tmp.sort();
     
     for(string s : tmp){
        Schema.SObjectField sField = fieldMap.get(s);
        schema.describefieldresult dfield = sfield.getDescribe();
        flds.add(new SelectOption(dfield.getname(),dfield.getLabel()));
     }
    }
 }
 
 public void fillXtracFields(){
  XtracFlds.add(new SelectOption('','-- Select Xtrac Field --'));
  for(XTRAC__c x:[Select Id,Name From XTRAC__c]){
    XtracFlds.add(new SelectOption(x.Name,x.Name));
  }
 }
 
 public PageReference saveMapping(){
    Mapping__c m = new Mapping__c();
    User u = [Select Id,FirstName,LastName From User Where Id =:userInfo.getUserId()];
    m.Added_By__c = u.FirstName + ' ' + u.LastName;
    m.SF_Object_Name__c = selectedObj;
    m.SF_Field_Name__c = schemaMap.get(selectedObj).getDescribe().fields.getMap().get(selectedFld).getDescribe().getLabel();
    m.SF_API_Name__c = selectedFld;
    m.XTRAC_Field__c = selectedXtracFld;
    m.Date_Added__c = date.today();
    m.Mapping_Types__c = mappingType.Id; 
    insert m;
    return new PageReference('/apex/mappingtypelistscreen_vp?mappingtype='+mappingTypeName);
 }
}