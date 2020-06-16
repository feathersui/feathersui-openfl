package events;

import valueObjects.Contact;
import openfl.events.Event;

class ContactEvent extends Event {
	public static final REQUEST_CONTACT:String = "requestContact";
	public static final CHOOSE_CONTACT:String = "chooseContact";

	public function new(type:String, ?contact:Contact) {
		super(type, false, false);
		this.contact = contact;
	}

	public var contact:Contact;
}
