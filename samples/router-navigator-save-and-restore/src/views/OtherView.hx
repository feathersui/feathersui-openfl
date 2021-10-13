package views;

import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.events.TriggerEvent;
import feathers.layout.VerticalLayout;
import openfl.events.Event;

class OtherView extends LayoutGroup {
	public static final ROUTE_PATH = "/other";

	public function new() {
		super();
	}

	override private function initialize():Void {
		super.initialize();

		var layout = new VerticalLayout();
		layout.setPadding(10.0);
		layout.gap = 10.0;
		layout.horizontalAlign = CENTER;
		this.layout = layout;

		var messageLabel = new Label();
		messageLabel.text = "Click the \"Go Back\" button to see your name restored";
		this.addChild(messageLabel);

		var backButton = new Button();
		backButton.addEventListener(TriggerEvent.TRIGGER, backButton_triggerHandler);
		backButton.text = "Go Back";
		this.addChild(backButton);
	}

	private function backButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new Event(Event.CANCEL));
	}
}
