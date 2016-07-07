@isTest
public class BulkContactReportControllerTest {
    
    @testSetup static void setup(){
        List<Account> accts = new List<Account>();
        List<Contact> cons = new List<Contact>();
        
        for(Integer i=0;i<30;i++) {
            Account a = new Account(Name='TestAccount' + i);
            accts.add(a);
        }
        insert accts;
        
        for (Integer j=0;j<30;j++) {
            Account acct = accts[j];            
            // For each account just inserted, add 1 contact
            cons.add(new Contact(firstname='Test',lastname='Test',AccountId=acct.Id,CWID__c = String.valueOf(j)));
        }
        // Insert all contacts for all accounts
        insert cons;
        
    }
    
    static testMethod void importAndClear(){
        //create mock CSV
        List<Contact> cwidContacts = [select CWID__c from Contact];
        List<String> CWIDs =  new List<String>();
        for(Contact c : cwidContacts){
            CWIDs.add(c.CWID__c);
        }
        String separator = ',';
        String toCSV = String.join(CWIDs,separator);
        Blob CSV = blob.valueOf(toCSV);

        
        BulkContactReportController bcr = new BulkContactReportController();
        System.assert(bcr.contactList == null);
        
        bcr.csvFileBody = CSV;
        bcr.importCSVFile();
        
        System.assertEquals(bcr.contactList.size(), 30);
        
        bcr.clearContacts();
        System.assertEquals(bcr.contactList.size(),0);
    }
    
    static testMethod void createCR(){
        BulkContactReportController bcr = new BulkContactReportController();
        bcr.createContactReport();
        System.assert(bcr.tempTask.Status=='Completed');
    }
    
    static testMethod void saveCRs(){
        //create mock CSV
        List<Contact> cwidContacts = [select CWID__c from Contact];
        List<String> CWIDs =  new List<String>();
        for(Contact c : cwidContacts){
            CWIDs.add(c.CWID__c);
        }
        String separator = ',';
        String toCSV = String.join(CWIDs,separator);
        Blob CSV = blob.valueOf(toCSV);
        
        BulkContactReportController bcr = new BulkContactReportController();        
        bcr.csvFileBody = CSV;
        bcr.importCSVFile();
        bcr.createContactReport();
        
        Integer numCRs = [select count() from Task];
        System.assertEquals(numCRs, 0);
        bcr.createCRs();
        numCRs = [select count() from Task];
        System.assertEquals(numCRs, 30);
    }
    
}