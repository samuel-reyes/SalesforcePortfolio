public with sharing class SObjectWrapperUtility
{
	/**  Worth noting I would not use this in every use case. This is if I already have a list of SObjects ready to go.
	Also, I primarily wrote this to see if this approach would work. If you are going to need to do some extra 
	SOQL querying, you could iterate through the records and populate fields in their constructor at instantiation,
	and they should appear with null values as well.
	**/
	
	
	private Set<String> objectFields {get;set;}
	private SObjectType objectType {get;set;}
	public SObject[] records {get;set;}
	public String jsonString;

	/**
    	* @author Samuel Reyes
    	* @date 2020-01-13
    	* @description Constructor(s) for class to perform initial setup tasks required to work properly.
    	* @param SObjectType objType - The Schema defined type of object whose fields we need to check against.
    	* @param SObject[] items - A list of instantiated SObjects for any single SObjectType.
    	*/
	public SObjectWrapperUtility(SObjectType objType, SObject[] items)
	{
		this.objectType = objType;
		this.objectFields = new Set<String>();
		System.debug(LoggingLevel.DEBUG, 'SObjectWrapperUtility has been initialized with objType :: ' + objectType.getDescribe().getName());

		Map<String, Schema.SObjectField> fieldMap = objType.getDescribe().fields.getMap();

		for( String fieldName : fieldMap.keySet() )
		{
			Schema.SObjectField currentField = fieldMap.get(fieldName);
			if(currentField.getDescribe().isUpdateable()){ this.objectFields.add(currentField.getDescribe().getName()); }
		}

		this.jsonString = this.generateJSON(items);
	}

	/**
    	* @author Samuel Reyes
    	* @date 2020-01-13
    	* @description Typically Salesforce will take records returned from Apex, and pass them to the front end with any null
    	* values as empty object keys. This creates problems when trying to sort records via Javascript. This wrapper will
    	* process the records prior to their being sent to the front end, and restores all unpopulated field keys.
    	* This does NOT SOQL query any missing field values, but will simply restore keys for records passed into it.
    	* @param SObject[] items - A list of instantiated SObjects for any single SObjectType.
    	* Wrapper currently only supports wrapping types of one item.
    	* @return JSON string ready to be passed to front end Javascript.
    	*/
	private String generateJSON(SObject[] items)
	{
		this.records = new SObject[0];
		for(SObject item : items)
		{
			Set<String> populatedFields = item.getPopulatedFieldsAsMap().keySet();
			System.debug(LoggingLevel.FINE, 'populatedFields output :: ' + populatedFields);

			for(String field : this.objectFields)
			{
				if(!populatedFields.contains(field))
				{
					item.put(field,null);
				}
			}
			this.records.add(item);
		}
		return JSON.serialize(this.records);
	}



}
