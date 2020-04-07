/** 
At once place I worked we have a class very similar to this.
Eventually I rewrote it as follows.
Feel free to use it, just add a comment saying where you got it from.
**/

/**
* Created by samuel-reyes on 4/7/2020.
**/

public with sharing class DMLUtility implements Queueable
{
    enum DMLType {INSERTS, UPDATES, DELETES}

    private SObject[] recordsToDml;
    private Set<Id> uniqueRecordIds;
    private Id[] recordIds;
    private DMLType dml;

    //sourceInformation tells us where this is coming from. Eg AccountTriggerHandler.specificMethodName()
    private String sourceInformation;

    //Thi is our constructor method. This will complete when we initially instantiate a copy of this class.
    //The execute method will automatically fire AFTER the constructor finishes.
    public DMLUtility(SObject[] records, DMLType dml, String specifics)
    {
        this.sourceInformation = String.isBlank(specifics) ? 'DMLUtility.execute()' : specifics;
        this.recordsToDml = new SObject[0];
        this.dml = dml;
        if(DMLType.UPDATES == dml){ this.uniqueRecordIds = new Set<Id>(); }

        if(null != records && !records.isEmpty())
        {
            System.debug(LoggingLevel.FINE, 'DMLUtility with operation :: ' + dml);

            for(SObject sObj : records)
            {
                Id recordId = (Id) sObj.get('Id');
                if(DMLType.DELETES == dml)
                {
                    if(null == recordIds){ recordIds = new Id[0]; }
                    recordIds.add(recordId);
                }
                else
                {
                    if(DMLType.UPDATES == dml)
                    {
                        if(!uniqueRecordIds.contains(recordId))
                        {
                            uniqueRecordIds.add(recordId);
                            recordsToDml.add(sObj);
                        }
                    }
                    else if(DMLType.INSERTS == dml)
                    {
                        recordsToDml.add(sObj);
                    }
                }
            }

            if(!recordsToDml.isEmpty() && DMLType.DELETES == dml)
            {
                System.debug( LoggingLevel.FINER, 'DMLUtility preparing to delete :: '+ recordIds);
            }
            else if(!recordsToDml.isEmpty())
            {
                String objectType = recordsToDml[0].getSObjectType().getDescribe().getName();
                System.debug(LoggingLevel.INFO, 'DMLUtility set with first record of operation and type ' + dml + ' :: ' + objectType );
            }

        }

    }

    public void execute(QueueableContext ctx)
    {
        String[] errors = new String[0];
        if(!recordsToDml.isEmpty())
        {
            if(DMLType.INSERTS == this.dml || DMLType.UPDATES == this.dml)
            {
                for(Database.SaveResult result :
                        (DMLType.UPDATES == this.dml) ?
                            Database.update(this.recordsToDml, false) :
                            Database.insert(this.recordsToDml, false)
                )
                {
                    if(!result.isSuccess())
                    {
                        for(Database.Error err : result.getErrors() )
                        {
                            errors.add(String.valueOf(err));
                        }
                    }
                }
            }
        }

        if(!recordIds.isEmpty() && DMLType.DELETES == this.dml)
        {
            for(Database.DeleteResult del : Database.delete(this.recordIds, false))
            {
                if(!del.isSuccess())
                {
                    for(Database.Error err : del.getErrors())
                    {
                        errors.add(String.valueOf(err));
                    }
                }
            }
        }

        if(!errors.isEmpty() && errors.size() > 0)
        {
            System.debug(LoggingLevel.DEBUG, 'DMLUtility Returned errors for :: ' + this.dml + ' operation for :: ' + this.recordIds);
            System.debug(LoggingLevel.DEBUG, 'DMLUtility errors output :: ' + errors);
        }

    }



}
