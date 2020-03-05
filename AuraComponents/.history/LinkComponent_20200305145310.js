/*
   Copyright (c) 2019 Thumbtack, All rights reserved.
*/
({
    doInit : function(component, event, helper){
        let recId = component.get('v.recordId');
        console.log('recId ' + recId);

        component.find('campaignMemberRecordCreator').getNewRecord(
            "CampaignMember",null,false,

            $A.getCallback(function(){

                //for whatever reason these two variables will not populate outside of this callback block
                let contId = component.get('v.simpleRecord.Contact__c');
                let cmpgnId = component.get('v.simpleRecord.Campaign__c');

                if(null === contId || undefined === contId || null === cmpgnId || undefined === cmpgnId){
                    component.set('v.showLinkButton', false);
                }

                let rec = component.get('v.campMemberRecord');
                let err = component.get('v.recordErrorCampMember');

                if(err || (rec === null) ){
                    console.log('Failed to initialize record template with error :: ' + err);
                }else {
                    console.log('Record template initialized :: ' + rec.apiName);
                }

            })
        );

    },
    handleLinkRecords : function(component, event, helper){
        let contId = component.get('v.simpleRecord.Contact__c');
        let cmpgnId = component.get('v.simpleRecord.Campaign__c');

        component.set('v.showProcessing', true);
        component.set('v.showLinkButton',false);

        console.log('contId :: ' + contId + ' :: cmpgnId :: ' + cmpgnId);

        let insertRecord = component.get('c.createNewCampaignMember');

        insertRecord.setParams({
            campaignId:cmpgnId,
            contactId:contId
        });

        insertRecord.setCallback(this,function(response){
            let state = response.getState();
            if(state === 'SUCCESS'){
                console.log('success block');

                let respValue = response.getReturnValue();
                let parsed = JSON.parse(respValue);

                if(parsed.isDuplicate){
                    component.set('v.successMessage','Campaign Member created previously and linked. Window will close in 3 seconds.');
                } else {
                    component.set('v.successMessage','Campaign Memeber created and linked successfully! Window will close in 3 seconds.');
                }
                console.log('record created with return data :: ' + respValue);

                component.set('v.campMemberRecord', parsed);
                component.set('v.showProcessing', false);
                component.set('v.showSuccess', true);

                //close window after a few seconds, so they can see it was a success...
                setTimeout(function () { $A.get("e.force:closeQuickAction").fire();}, 3000);
            } else{
                console.log('There was an issue with creating the new record :: ');
                console.log(response.getError());

                component.set('v.showProcessing', false);
                component.set('v.showError', true);
            }
        });

        $A.enqueueAction(insertRecord);
    }
});