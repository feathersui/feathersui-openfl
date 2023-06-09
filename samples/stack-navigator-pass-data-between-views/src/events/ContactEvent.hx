package events;

import valueObjects.Contact;
import openfl.events.Event;

/**
	A custom event used with ChooseContactView. Allows a contact to be passed
	between views.
**/
class ContactEvent extends Event {
	public static final REQUEST_CONTACT:String = "requestContact";
	public static final CHOOSE_CONTACT:String = "chooseContact";

	public function new(type:String, ?contact:Contact) {
		super(type, false, false);
		this.contact = contact;
	}

	public var contact:Contact;
}
