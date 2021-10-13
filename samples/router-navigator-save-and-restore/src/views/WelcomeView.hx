package views;

import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.TextInput;
import feathers.core.InvalidationFlag;
import feathers.events.TriggerEvent;
import feathers.layout.VerticalLayout;
import openfl.events.Event;
import valueObjects.WelcomeData;

class WelcomeView extends LayoutGroup {
	public static final ROUTE_PATH = "/";

	public function new() {
		super();
	}

	// the welcomeData property will hold the data to save and restore
	public var welcomeData(default, set):WelcomeData = null;

	private var messageLabel:Label;
	private var nameInput:TextInput;
	private var nextButton:Button;

	private function set_welcomeData(value:WelcomeData):WelcomeData {
		this.welcomeData = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this.welcomeData;
	}

	override private function initialize():Void {
		super.initialize();

		var layout = new VerticalLayout();
		layout.setPadding(10.0);
		layout.gap = 10.0;
		layout.horizontalAlign = CENTER;
		this.layout = layout;

		this.messageLabel = new Label();
		this.addChild(this.messageLabel);

		this.nameInput = new TextInput();
		this.nameInput.addEventListener(Event.CHANGE, nameInput_changeHandler);
		this.addChild(this.nameInput);

		this.nextButton = new Button();
		this.nextButton.text = "Next";
		this.nextButton.addEventListener(TriggerEvent.TRIGGER, nextButton_triggerHandler);
		this.addChild(this.nextButton);
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(DATA);

		if (dataInvalid) {
			if (this.welcomeData != null && this.welcomeData.name != null) {
				this.messageLabel.text = 'Welcome back, ${this.welcomeData.name}!';
				this.nameInput.prompt = 'Not ${this.welcomeData.name}? Enter your name.';
			} else {
				this.messageLabel.text = "What is your name?";
				this.nameInput.prompt = null;
			}
		}

		// handle the layout after updating children
		super.update();
	}

	private function nameInput_changeHandler(event:Event):Void {
		if (this.nameInput.text.length > 0) {
			this.nameInput.errorString = null;
		}
	}

	private function nextButton_triggerHandler(event:TriggerEvent):Void {
		if (this.nameInput.text.length > 0) {
			// save the new welcome data
			this.welcomeData = {name: this.nameInput.text};
		} else if (this.welcomeData == null || this.welcomeData.name == null) {
			// if we haven't yet saved a name, require length > 0
			this.nameInput.errorString = "Please enter your name";
			return;
		}
		this.dispatchEvent(new Event(Event.COMPLETE));
	}
}
