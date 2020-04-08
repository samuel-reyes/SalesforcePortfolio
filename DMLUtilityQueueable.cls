/**
Feel free to use it, just add a comment saying where you got it from. -SReyes
**/

/**
 * Created by samuel-reyes on 4/7/2020.
 * WHEN TO USE THIS CLASS:
 * The purpose of this class is to avoid firing off too many DML operations in a single given context.
 * This allows necessary DML operations to be performed on related records, or even on the initial trigger records,
 * in a new separate context of it's own. For example, if you've just upserted some records, and then need to do some
 * operations that will update the self same records, rather than calling a second update operation in the same context,
 * you can prepare the records and then instantiate this class. It will allow the current operation to finish, and allow
 * the end user to move on however they need to, and will finish related updates asap. Usually within 30-60 seconds.
*/

public with sharing class DMLUtility implements Queueable
{
    public enum DMLType {INSERTS, UPDATES, DELETES}

    private SObject[] recordsToDml;
    private Set<Id> uniqueRecordIds;
    private Id[] recordIds;
    private DMLType dml;
    //sourceInformation tells us where this is coming from. Eg AccountTriggerHandler.specificMethodName()
    private String sourceInformation;

    //This method is a DELETE ONLY job.
    public DMLUtility(Id[] recordIds, String specifics)
    {
        System.debug(LoggingLevel.FINE, 'DMLUtility set with recordIds :: ' + recordIds);
        this.dml = DMLType.DELETES;
        this.recordIds = recordIds;
        this.sourceInformation = specifics;
        if(!recordIds.isEmpty())
        {
            System.debug( LoggingLevel.FINER, 'DMLUtility preparing to delete :: '+ recordIds);
        }
    }

    //This is our constructor method. This will complete when we initially instantiate a copy of this class.
    //The execute method will automatically fire AFTER the constructor finishes.
    public DMLUtility(SObject[] records, DMLType dml, String specifics)
    {
        System.debug(LoggingLevel.FINE, 'DMLUtility set with records :: ' + records);
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
                if(null != recordId)
                {
                    if(DMLType.UPDATES == dml)
                    {
                        if(!uniqueRecordIds.contains(recordId))
                        {
                            uniqueRecordIds.add(recordId);
                            recordsToDml.add(sObj);
                        }
                    }
                }
                else if(DMLType.INSERTS == dml)
                {
                    recordsToDml.add(sObj);
                }
            }
            if(!recordsToDml.isEmpty())
            {
                String objectType = recordsToDml[0].getSObjectType().getDescribe().getName();
                System.debug(LoggingLevel.INFO, 'DMLUtility set with first record of operation and type ' + dml + ' :: ' + objectType );
            }
        }

    }

    public void execute(QueueableContext ctx)
    {
        String[] errors = new String[0];
        if(null != recordsToDml && !recordsToDml.isEmpty())
        {
            if(DMLType.INSERTS == this.dml || DMLType.UPDATES == this.dml)
            {
                System.debug(LoggingLevel.FINE, 'performing' + this.dml + ' operation on :: ' + this.recordsToDml);
                for(Database.SaveResult result :
                        (DMLType.UPDATES == this.dml) ?
                            Database.update(this.recordsToDml, false) : Database.insert(this.recordsToDml, false)
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

        if(null != recordIds && !recordIds.isEmpty() && DMLType.DELETES == this.dml)
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
            //In this example I am just logging to console.
            //Ideally I would create some kind of error logs in a custom SObject designed to store them.
            System.debug(LoggingLevel.DEBUG, 'DMLUtility Returned errors for :: ' + this.dml + ' operation for :: ' + this.recordIds);
            System.debug(LoggingLevel.DEBUG, 'DMLUtility errors output :: ' + errors);
        }

    }

}
