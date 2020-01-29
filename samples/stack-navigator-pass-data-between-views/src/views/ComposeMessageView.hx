package views;

import events.ContactEvent;
import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.Panel;
import feathers.core.InvalidationFlag;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.VerticalLayout;
import valueObjects.Contact;

class ComposeMessageView extends Panel {
	public static final ID = "compose-message";

	public function new() {
		super();
	}

	private var contactNameLabel:Label;

	public var recipient(default, set):Contact = null;

	private function set_recipient(value:Contact):Contact {
		this.recipient = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this.recipient;
	}

	override private function initialize():Void {
		super.initialize();

		var layout = new VerticalLayout();
		layout.paddingTop = 10.0;
		layout.paddingRight = 10.0;
		layout.paddingBottom = 10.0;
		layout.paddingLeft = 10.0;
		layout.gap = 10.0;
		this.layout = layout;

		var header = new LayoutGroup();
		header.variant = LayoutGroup.VARIANT_TOOL_BAR;
		header.layout = new AnchorLayout();
		this.header = header;

		var title = new Label();
		title.variant = Label.VARIANT_HEADING;
		title.text = "Send Private Message";
		title.layoutData = AnchorLayoutData.center();
		header.addChild(title);

		this.contactNameLabel = new Label();
		this.addChild(this.contactNameLabel);

		var addRecipientButton = new Button();
		addRecipientButton.text = "Edit";
		addRecipientButton.addEventListener(TriggerEvent.TRIGGER, addRecipientButton_triggerHandler);
		this.addChild(addRecipientButton);
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);

		if (dataInvalid) {
			if (this.recipient != null) {
				this.contactNameLabel.text = "Recipient: " + this.recipient.name + " <" + this.recipient.email + ">";
			} else {
				this.contactNameLabel.text = "Recipient: None selected";
			}
		}

		// handle the layout after updating children
		super.update();
	}

	private function addRecipientButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new ContactEvent(ContactEvent.REQUEST_CONTACT, this.recipient));
	}
}
