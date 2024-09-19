Replicates the random notices Salesforce will put at the top of a page in Salesforce sometimes. This is a lightning web component. Lives on a record page in Salesforce. Customizable attributes.

You can have as many on a page as you want and control the visibility settings so they dynamically show when they are supposed to.

You can change the defaults below if you know what you want to display standard in your org, otherwise each value can be configured from the Lightning Page Builder within Salesforce.

Javascript defaults:
```
@api backgroundColor = '#3470A8'; // Light blue
@api textColor = 'White'; // White
@api fontSize = '16px'; // Smaller font size
@api borderColor = 'White'; // White
@api borderWidth = '2px'; // Thinner border
@api borderStyle = 'solid'; // Keep solid
@api borderRadius = '8px'; // Slightly more rounded
```
