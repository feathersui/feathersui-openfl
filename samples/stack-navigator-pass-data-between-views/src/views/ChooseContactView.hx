package views;

import events.ContactEvent;
import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.ListView;
import feathers.controls.Panel;
import feathers.core.InvalidationFlag;
import feathers.data.ArrayCollection;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import openfl.events.Event;
import valueObjects.Contact;

class ChooseContactView extends Panel {
	public static final ID = "choose-contact";

	public function new() {
		super();
	}

	public var contacts(default, set):ArrayCollection<Contact> = null;

	private function set_contacts(value:ArrayCollection<Contact>):ArrayCollection<Contact> {
		if (this.contacts == value) {
			return this.contacts;
		}
		this.contacts = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this.contacts;
	}

	public var selectedContact(default, set):Contact = null;

	private function set_selectedContact(value:Contact):Contact {
		if (this.selectedContact == value) {
			return this.selectedContact;
		}
		this.selectedContact = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this.selectedContact;
	}

	private var contactList:ListView;

	override private function initialize():Void {
		super.initialize();

		this.layout = new AnchorLayout();

		var header = new LayoutGroup();
		header.variant = LayoutGroup.VARIANT_TOOL_BAR;
		header.layout = new AnchorLayout();
		this.header = header;

		var title = new Label();
		title.variant = Label.VARIANT_HEADING;
		title.text = "Contacts";
		title.layoutData = AnchorLayoutData.center();
		header.addChild(title);

		var doneButton = new Button();
		doneButton.addEventListener(TriggerEvent.TRIGGER, doneButton_triggerHandler);
		doneButton.text = "Done";
		doneButton.layoutData = AnchorLayoutData.middleLeft(0.0, 10.0);
		header.addChild(doneButton);

		this.contactList = new ListView();
		this.contactList.itemToText = (item:Contact) -> item.name;
		this.contactList.layoutData = AnchorLayoutData.fill();
		this.contactList.addEventListener(Event.CHANGE, contactList_changeHandler);
		this.addChild(this.contactList);
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);

		if (dataInvalid) {
			this.contactList.dataProvider = this.contacts;
			this.contactList.selectedItem = this.selectedContact;
		}

		super.update();
	}

	private function doneButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new ContactEvent(ContactEvent.CHOOSE_CONTACT, this.selectedContact));
	}

	private function contactList_changeHandler(event:Event):Void {
		this.selectedContact = cast(this.contactList.selectedItem, Contact);
	}
}
