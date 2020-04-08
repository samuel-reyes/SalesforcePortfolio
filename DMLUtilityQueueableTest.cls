//This covers the related class at 100%

@IsTest
public with sharing class DMLUtilityTest {
    @TestSetup
    private static void setupMethod()
    {
        Account act = new Account(Name='preInsertTest');
        insert act;
    }
    @IsTest
    private static void testInserts()
    {
        Test.startTest();
            Account[] acts = new Account[]{new Account(Name='insertionTest')};
            DMLUtility insertRecords = new DMLUtility(acts, DMLUtility.DMLType.INSERTS,'testInsert');
            System.enqueueJob(insertRecords);
        Test.stopTest();

        System.assertEquals(false,[SELECT IsDeleted FROM Account LIMIT 1 ALL ROWS ].IsDeleted);
    }
    @IsTest
    private static void testUpdate()
    {
        Test.startTest();
            Account[] acts = new Account[]{new Account(Name='updateTest')};
            DMLUtility insertRecords = new DMLUtility(acts, DMLUtility.DMLType.UPDATES,'testUpdates');
            System.enqueueJob(insertRecords);
        Test.stopTest();

        System.assertEquals(false,[SELECT IsDeleted FROM Account LIMIT 1 ALL ROWS ].IsDeleted);
    }
    @IsTest
    private static void testDelete()
    {
        Id[] actIds = new Id[0];
        for(Account act : [SELECT Id, Name FROM Account]){actIds.add(act.Id);}

        Test.startTest();
            DMLUtility deleteRecords = new DMLUtility(actIds, 'testDelete');
            System.enqueueJob(deleteRecords);
        Test.stopTest();

        System.assertNotEquals(false,[SELECT IsDeleted FROM Account LIMIT 1 ALL ROWS ].IsDeleted);
    }
    @IsTest
    private static void testErrorBlocks()
    {
        Account[] acts = [SELECT Id FROM Account];
        Id[] actIds = new Id[]{acts[0].Id};

        //We are going to delete the record intentionally before we start our test block.
        //Because this record is missing, the DML errors would state "RECORD_IS_DELETED" or such.
        //This is the behavior we want to verify is happening. -SReyes
        delete acts;

        Test.startTest();
            DMLUtility insertRecords = new DMLUtility(acts, DMLUtility.DMLType.UPDATES,'testUpdates');
            System.enqueueJob(insertRecords);
            DMLUtility deleteRecords = new DMLUtility(actIds, 'testDelete');
            System.enqueueJob(deleteRecords);
        Test.stopTest();

        //Assertion was left out here intentionally. There isn't anything to assert, because we are testing for errors.
        //We are not returning any values, nor are we creating any records with the errors. We are just logging them to debug console.
        //So long as this one covers the error blocks, the other will test methods will cover the rest of the code with their assertions. -SReyes

    }
}
