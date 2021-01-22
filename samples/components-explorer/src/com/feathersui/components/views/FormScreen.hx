package com.feathersui.components.views;

import feathers.events.FormEvent;
import feathers.controls.TextArea;
import feathers.layout.HorizontalLayout;
import feathers.controls.TextInput;
import feathers.controls.FormItem;
import feathers.controls.Button;
import feathers.controls.Form;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.Panel;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.VerticalLayout;
import openfl.events.Event;

class FormScreen extends Panel {
	private var commentForm:Form;
	private var nameInput:TextInput;
	private var emailInput:TextInput;
	private var messageInput:TextArea;

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

		this.commentForm = new Form();
		this.commentForm.addEventListener(FormEvent.SUBMIT, commentForm_submitHandler);
		this.addChild(this.commentForm);

		var title = new Label();
		title.variant = Label.VARIANT_HEADING;
		title.text = "Leave a Comment";
		this.commentForm.addChild(title);

		var nameItem = new FormItem();
		nameItem.text = "Name";
		nameItem.textPosition = LEFT;
		this.nameInput = new TextInput();
		this.nameInput.prompt = "Your Full Name";
		nameItem.content = this.nameInput;
		this.commentForm.addChild(nameItem);

		var emailItem = new FormItem();
		emailItem.text = "Email";
		emailItem.textPosition = LEFT;
		this.emailInput = new TextInput();
		this.emailInput.prompt = "name@example.com";
		emailItem.content = this.emailInput;
		this.commentForm.addChild(emailItem);

		var mesageItem = new FormItem();
		mesageItem.text = "Message";
		mesageItem.textPosition = TOP;
		mesageItem.horizontalAlign = JUSTIFY;
		this.messageInput = new TextArea();
		this.messageInput.prompt = "Feathers UI is so cool!";
		mesageItem.content = this.messageInput;
		this.commentForm.addChild(mesageItem);

		var buttonGroup = new LayoutGroup();
		var buttonsLayout = new HorizontalLayout();
		buttonsLayout.gap = 10.0;
		buttonsLayout.horizontalAlign = RIGHT;
		buttonGroup.layout = buttonsLayout;
		var sendButton = new Button();
		sendButton.text = "Send";
		buttonGroup.addChild(sendButton);
		var clearButton = new Button();
		clearButton.text = "Clear";
		clearButton.addEventListener(TriggerEvent.TRIGGER, clearButton_triggerHandler);
		buttonGroup.addChild(clearButton);
		this.commentForm.addChild(buttonGroup);

		this.commentForm.submitButton = sendButton;
	}

	private function createHeader():Void {
		var header = new LayoutGroup();
		header.variant = LayoutGroup.VARIANT_TOOL_BAR;
		header.layout = new AnchorLayout();
		this.header = header;

		var headerTitle = new Label();
		headerTitle.variant = Label.VARIANT_HEADING;
		headerTitle.text = "Form";
		headerTitle.layoutData = AnchorLayoutData.center();
		header.addChild(headerTitle);

		var backButton = new Button();
		backButton.text = "Back";
		backButton.layoutData = AnchorLayoutData.middleLeft(0.0, 10.0);
		backButton.addEventListener(TriggerEvent.TRIGGER, backButton_triggerHandler);
		header.addChild(backButton);
	}

	private function clearForm():Void {
		this.nameInput.text = "";
		this.emailInput.text = "";
		this.messageInput.text = "";
	}

	private function backButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}

	private function commentForm_submitHandler(event:FormEvent):Void {
		var name = this.nameInput.text;
		var email = this.emailInput.text;
		var message = this.messageInput.text;
		trace('Submitted message! Name: ${name}, Email: ${email}, Message: ${message}');
		this.clearForm();
	}

	private function clearButton_triggerHandler(event:TriggerEvent):Void {
		this.clearForm();
	}
}
