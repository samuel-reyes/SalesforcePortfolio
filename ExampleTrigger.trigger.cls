trigger SObjectTrigger on SObject (before insert, after insert, before update, after update, after delete)
{
    //Example file has a .cls extension so it'll get formatting.
    //This is a simple alternative to using the virtual class solution.
    
    //I have a mdt control pannel I like to use to control trigger contexts.
    //It can be as granular or high level as it needs to be, as you can create an individual TriggerControlPanels__mdt
    //block you wish to control execution of. -SReyes
    
    TriggerControlPanels__mdt isActive = [SELECT Id, IsActive__c FROM TriggerControlPanels__mdt WHERE Label = 'SObjectTriggerHandler' LIMIT 1];
    
    if (isActive.IsActive__c)
    {
        Boolean isInsert = (Trigger.isInsert);
        Boolean isUpdate = (Trigger.isUpdate);
        Boolean isDelete = (Trigger.isDelete);

        if (Trigger.isAfter)
        {
            SObjectTriggerHandler.doAfterTrigger(Trigger.new, Trigger.oldMap, isInsert, isUpdate, isDelete);
        }
        if (Trigger.isBefore)
        {
            SObjectTriggerHandler.doBeforeTrigger(Trigger.new, Trigger.oldMap, isInsert, isUpdate);
        }
    }

}
