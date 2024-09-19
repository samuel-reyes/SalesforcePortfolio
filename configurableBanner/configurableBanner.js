/**
 * Created by Samuel Reyes on 9/19/2024.
 */

import { LightningElement, api } from 'lwc';

export default class NoticeComponent extends LightningElement
{
	//Expose recordId and Object API name if needed.
	@api recordId;
	@api objectApiName;
	
	//Default Message
	@api message = 'This is a default message. Replace this.';
	
	//Default Appearance Variables. Hex values work for colors.
	@api backgroundColor = '#3470A8'; // Light blue
	@api textColor = 'White'; // White
	@api fontSize = '16px'; // Smaller font size
	@api borderColor = 'White'; // White
	@api borderWidth = '2px'; // Thinner border
	@api borderStyle = 'solid'; // Keep solid
	@api borderRadius = '8px'; // Slightly more rounded
	
	get computedStyle()
	{
		const styles = [];
		
		if (this.backgroundColor) { styles.push(`background-color: ${this.backgroundColor}`); }
		if (this.textColor) { styles.push(`color: ${this.textColor}`); }
		if (this.fontSize) { styles.push(`font-size: ${this.fontSize}`); }
		if (this.borderColor) { styles.push(`border-color: ${this.borderColor}`); }
		if (this.borderWidth) { styles.push(`border-width: ${this.borderWidth}`); }
		if (this.borderStyle) { styles.push(`border-style: ${this.borderStyle}`); }
		if (this.borderRadius) { styles.push(`border-radius: ${this.borderRadius}`); }
		
		return styles.join('; ');
	}
	
}
