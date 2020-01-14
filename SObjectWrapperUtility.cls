public with sharing class SObjectWrapperUtility
{
	/**  An experiment to provide a solution for handling null values for fields when converting to JSON, because Apex
	likes to drop null field keys on conversion to JSON.
	
	The main thing I was after here was writing one that would populate any missing field value, and would be dynamic-ish
	when new fields are added to the SObject and we wanted to include null values for them. This does not query any missing
	field values, it simply sets any unpopulated values to null so the fields can be included in JSON conversion.
	
	The idea was that I would use this to quickly prep records for passing to a JS controller for use with LWC or Aura,
	and then have existing object keys for use with Javascript array.sort().
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
			//Check specifically for fields that are writeable.
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
				if(!populatedFields.contains(field)){ item.put(field,null); }
			}
			this.records.add(item);
		}
		return JSON.serialize(this.records);
	}
}
