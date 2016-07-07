public with sharing class BulkContactReportController {

  public Blob csvFileBody{get;set;}
  public string csvAsString{get;set;}
  private String[] csvLineData{get;set;}
  private String[] csvLines{get;set;}
  public List<contact> contactList{public get;private set;}
  public List<String> badCWIDs{public get; private set;}
  public boolean showBadCWIDs{public get; private set;} 
  public Task tempTask{get;set;}
  public List<Task> successCRs{public get; private set;}
  public List<Task> failCRs{public get; private set;}
  public Map<Contact, Id> successContacts{public get; private set;}  
  public List<Contact> failContacts{public get; private set;}
  public boolean showCRErrors{public get; private set;}    
  
  public void importCSVFile(){
    Set<contact> contactSet = new Set<Contact>();
    Set<String> IDs = new Set<String>();  
    badCWIDs = new List<String>();

    showBadCWIDs = false;
    
    try{
     csvAsString = csvFileBody.toString();
           //regex split accomodates Mac and Windows CSV
           csvLines = csvAsString.split('[\\r\\n]+');
           
           if(csvLines.size() > 500){
             throw new ContactReportException();
           }

           for(String line : csvLines){
               //check for blank CSV lines (only commas)
               if (line.replaceAll(',','').trim().length() == 0) break;

               csvLineData = line.split(',');
               
               for(Integer i=0;i<csvLineData.size();i++){
                string CWID = csvLineData[i];
                IDs.add(CWID);
              }
            }
            
            contactList = [select Id, AccountId,Name,CWID__c from Contact where CWID__c in :IDs and CWID__C != NULL];
            
            for(Contact c : contactList){
             IDs.remove(c.CWID__c);
           }
           
           if(IDs.size() > 0){
             badCWIDs.addAll(IDs);
             showBadCWIDs=true;
           }

         }
         catch (ContactReportException e)
         {
          ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'CSV size exceeds 500 rows. Please reduce your import file size and try again.');
          ApexPages.addMessage(errorMessage);
        }
        catch (Exception e)
        {
          ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error occurred while importing data. Please make sure input is a CSV file of CWIDs.');
          ApexPages.addMessage(errorMessage);
        }  
      }
      
      public void clearContacts(){
        contactList.clear();
        badCWIDs.clear();
        showBadCWIDs=false;
      }
      
      public PageReference createContactReport() {
        tempTask = new Task(RecordTypeId=[select Id from RecordType where SObjectType='Task' and Name='Contact Report'].Id,Status='Completed');
        return Page.BulkContactReportCreate;
      }
      
      public PageReference cancelCRs() {
        PageReference ref = new PageReference('/');
        return ref;
      }
      
      public PageReference createCRs() {
       List<Task> newCRs = new List<Task>();
       for(Contact c : contactList){
        Task t = tempTask.clone(false,true,false,false);
        t.WhoId = c.Id;
        t.WhatId = c.AccountId;
        
        newCRs.add(t);             
      }
      
      Database.saveResult[] results = Database.insert(newCRs,false);
      
      successContacts = new Map<Contact,Id>();
      failContacts = new List<Contact>();
      
      for(Integer i = 0; i < results.size(); i++){
        if(results[i].isSuccess()){
          successContacts.put(contactList[i], results[i].getId());
        }
        else{
          failContacts.add(contactList[i]);
        }
      } 

      if(failContacts.size() > 0){
        showCRErrors = true;
      }      
      
      return Page.BulkContactReportResult;
    }
    
    public class ContactReportException extends Exception{
      
    }
  }