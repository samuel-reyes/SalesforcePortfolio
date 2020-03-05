public with sharing class LinkComponentController
{
    @AuraEnabled
    public static String createNewCampaignMember(Id campaignId, Id contactId)
    {

        String returnValue;
        CampaignMember cmpMember = new CampaignMember(ContactId=contactId,CampaignId=campaignId,Status='Action Plan Created');

        try
        {
            Database.SaveResult srlt = Database.insert(cmpMember);
            returnValue = JSON.serialize(cmpMember);
        }
        catch(Exception e)
        {
            System.debug('failed with error :: ' + e);
            returnValue = e.getMessage();
            if(returnValue.toLowerCase().contains('duplicate_value')){ returnValue = '{"isDuplicate":true}'; }
        }

        System.debug(LoggingLevel.DEBUG, 'createNewCampaignMember returnValue :: ' + returnValue);
        return returnValue;
    }
}