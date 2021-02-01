package com.feathersui.components.views;

import feathers.controls.Button;
import feathers.controls.Header;
import feathers.controls.Label;
import feathers.controls.Panel;
import feathers.events.TriggerEvent;
import feathers.layout.VerticalLayout;
import openfl.events.Event;

class LabelScreen extends Panel {
	private var label:Label;
	private var headingLabel:Label;
	private var detailLabel:Label;
	private var htmlLabel:Label;
	private var wrappedLabel:Label;
	private var disabledLabel:Label;

	override private function initialize():Void {
		super.initialize();
		this.createHeader();

		var layout = new VerticalLayout();
		layout.horizontalAlign = CENTER;
		layout.verticalAlign = MIDDLE;
		layout.gap = 20.0;
		layout.paddingTop = 20.0;
		layout.paddingRight = 20.0;
		layout.paddingBottom = 20.0;
		layout.paddingLeft = 20.0;
		this.layout = layout;

		this.label = new Label();
		this.label.text = "This is a simple label";
		this.addChild(this.label);

		this.disabledLabel = new Label();
		this.disabledLabel.enabled = false;
		this.disabledLabel.text = "A label may be disabled";
		this.addChild(this.disabledLabel);

		this.headingLabel = new Label();
		this.headingLabel.variant = Label.VARIANT_HEADING;
		this.headingLabel.text = "A heading label displays larger text";
		this.addChild(this.headingLabel);

		this.detailLabel = new Label();
		this.detailLabel.variant = Label.VARIANT_DETAIL;
		this.detailLabel.text = "A detail label displays smaller text";
		this.addChild(this.detailLabel);

		this.htmlLabel = new Label();
		this.htmlLabel.htmlText = "Use basic <b>HTML</b> — <i>including</i> <font color=\"#ff0000\">colors</font> and <font color=\"#0000ff\"><u><a href=\"https://feathersui.com/\">links</a></u></font>";
		this.addChild(this.htmlLabel);

		this.wrappedLabel = new Label();
		this.wrappedLabel.text = "A label's text may optionally wrap to multiple lines";
		this.wrappedLabel.wordWrap = true;
		this.wrappedLabel.width = 200.0; // wrap at 200 pixels wide
		this.addChild(this.wrappedLabel);
	}

	private function createHeader():Void {
		var header = new Header();
		header.text = "Label";
		this.header = header;

		var backButton = new Button();
		backButton.text = "Back";
		backButton.addEventListener(TriggerEvent.TRIGGER, backButton_triggerHandler);
		header.leftView = backButton;
	}

	private function backButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}
}
