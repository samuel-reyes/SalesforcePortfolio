public with sharing class SObjectWrapperUtility
{
	/**
	Copyright (c) 2020  ShinGenko
	https://github.com/shingenko/SF-Apex-Portfolio/edit/master/SObjectWrapperUtility.cls
	https://github.com/samuel-reyes/SalesforcePortfolio/edit/master/SObjectWrapperUtility.cls

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
	
	**/
	
	/**
	* General Use Note: This is not something you would want to use with larger SObjects that have a ton
	* of fields. This should be exclusively used by smaller objects with minimal fields.
	* Otherwise you should plan to use an Apex Wrapper class.
	* Even though this is a quick solution, it also has a larger heap size. While not an
	* issue with smaller sobjects, it will absolutely be one with larger ones.
	* **/

	private static Set<String> objectFields {get;set;}

	/**
    * @author Samuel Reyes
    * @date 2020-01-13
    * @description Constructor(s) for class to perform initial setup tasks required to work properly.
    * @param SObjectType objType - The Schema defined type of object whose fields we need to check against.
    * @param SObject[] items - A list of instantiated SObjects for any single SObjectType.
    */
	public static String buildString(SObjectType objType, SObject[] items)
	{
		if(null == objectFields)
		{
			objectFields =  new Set<String>();
			Schema.SObjectField[] fields = objType.getDescribe().fields.getMap().values();
			for( Schema.SObjectField field : fields )
			{
				DescribeFieldResult currentField = field.getDescribe();
				if(currentField.isUpdateable() && !currentField.isDeprecatedAndHidden()){ objectFields.add(currentField.getName()); }
			}
		}

		return generateJSON(items);
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
	private static String generateJSON(SObject[] items)
	{
		SObject[] records = new SObject[0];
		for(SObject item : items)
		{
			Set<String> populatedFields = item.getPopulatedFieldsAsMap().keySet();
			System.debug(LoggingLevel.FINE, 'populatedFields output :: ' + populatedFields);

			for(String field : objectFields)
			{
				if(!populatedFields.contains(field))
				{
					item.put(field,null);
				}
			}
			records.add(item);
		}
		return JSON.serialize(records);
	}
}
