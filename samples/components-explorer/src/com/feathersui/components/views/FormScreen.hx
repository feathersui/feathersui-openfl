package com.feathersui.components.views;

import feathers.controls.Alert;
import feathers.controls.Button;
import feathers.controls.Form;
import feathers.controls.FormItem;
import feathers.controls.Header;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.Panel;
import feathers.controls.TextArea;
import feathers.controls.TextInput;
import feathers.events.FormEvent;
import feathers.events.TriggerEvent;
import feathers.layout.HorizontalLayout;
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
		nameItem.required = true;
		nameItem.textPosition = LEFT;
		this.nameInput = new TextInput();
		this.nameInput.prompt = "Your Full Name";
		nameItem.content = this.nameInput;
		this.commentForm.addChild(nameItem);

		var emailItem = new FormItem();
		emailItem.text = "Email";
		emailItem.required = true;
		emailItem.textPosition = LEFT;
		this.emailInput = new TextInput();
		this.emailInput.prompt = "name@example.com";
		emailItem.content = this.emailInput;
		this.commentForm.addChild(emailItem);

		var mesageItem = new FormItem();
		mesageItem.text = "Message";
		mesageItem.submitOnEnterEnabled = false;
		mesageItem.required = true;
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
		var header = new Header();
		header.text = "Form";
		this.header = header;

		var backButton = new Button();
		backButton.text = "Back";
		backButton.addEventListener(TriggerEvent.TRIGGER, backButton_triggerHandler);
		header.leftView = backButton;
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
		if (name.length == 0) {
			Alert.show("Name is missing.", "Error", ["OK"]);
			return;
		}
		if (email.length == 0) {
			Alert.show("Email is missing.", "Error", ["OK"]);
			return;
		}
		if (message.length == 0) {
			Alert.show("Message is missing.", "Error", ["OK"]);
			return;
		}
		trace('Submitted message! Name: ${name}, Email: ${email}, Message: ${message}');
		Alert.show("The form has been submitted.", "Confirmation", ["OK"]);
		this.clearForm();
	}

	private function clearButton_triggerHandler(event:TriggerEvent):Void {
		this.clearForm();
	}
}
