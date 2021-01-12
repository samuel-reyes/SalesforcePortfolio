@IsTest
public with sharing class TestUtility
{

  public static User insertTestUserWithPSets(String profileName, String[] permissionSetNames)
  {
    PermissionSet[] permissions = [SELECT Id FROM PermissionSet WHERE Name IN : permissionSetNames];
    System.debug(LoggingLevel.FINE,'permissions :: ' + permissions);

    User usr = insertTestUser(profileName); //Calls another method to insert a test user of base permissions.
    insert usr;

    PermissionSetAssignment[] assignments = new PermissionSetAssignment[0];
    for(PermissionSet permSet : permissions)
    {
      assignments.add(new PermissionSetAssignment(AssigneeId=usr.Id,PermissionSetId=permSet.Id));
    }
    
    if(!assignments.isEmpty())
    {
      insert assignments;
    }
    
    return usr;
  }
}
