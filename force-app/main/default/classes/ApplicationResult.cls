/* Class: ApplicationResult 
   Description: Wrapper class used to return the result of application processing.
*/
global class ApplicationResult {

    @AuraEnabled
    global Boolean success;

    @AuraEnabled
    global String recordType;

    @AuraEnabled
    global Id recordId;

    @AuraEnabled
    global String message;

}