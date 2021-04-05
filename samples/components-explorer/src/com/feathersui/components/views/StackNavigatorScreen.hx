package com.feathersui.components.views;

import feathers.controls.Button;
import feathers.controls.Header;
import feathers.controls.LayoutGroup;
import feathers.controls.Panel;
import feathers.controls.navigators.StackItem;
import feathers.controls.navigators.StackNavigator;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.VerticalLayout;
import openfl.events.Event;

class StackNavigatorScreen extends Panel {
	private var navigator:StackNavigator;

	override private function initialize():Void {
		super.initialize();
		this.createHeader();

		this.layout = new AnchorLayout();

		this.navigator = new StackNavigator();
		this.navigator.layoutData = AnchorLayoutData.fill();
		this.navigator.addEventListener(Event.CHANGE, stackNavigator_changeHandler);
		this.addChild(this.navigator);

		this.navigator.addItem(StackItem.withClass("screen1", PushScreen, [PushScreen.EVENT_PUSH => Push("screen2")]));
		this.navigator.addItem(StackItem.withClass("screen2", PopScreen, [PopScreen.EVENT_PUSH => Push("screen3"), PopScreen.EVENT_POP => Pop()]));
		this.navigator.addItem(StackItem.withClass("screen3", PopToRootScreen, [
			PopToRootScreen.EVENT_POP => Pop(),
			PopToRootScreen.EVENT_POP_TO_ROOT => PopToRoot()
		]));
		this.navigator.rootItemID = "screen1";
	}

	private function createHeader():Void {
		var header = new Header();
		header.text = "Stack Navigator";
		this.header = header;

		var backButton = new Button();
		backButton.text = "Back";
		backButton.addEventListener(TriggerEvent.TRIGGER, backButton_triggerHandler);
		header.leftView = backButton;
	}

	private function stackNavigator_changeHandler(event:Event):Void {
		trace("StackNavigator activeItemID change: " + this.navigator.activeItemID);
	}

	private function backButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}
}

private class PushScreen extends LayoutGroup {
	public static final EVENT_PUSH = "push";

	public function new() {
		super();

		var layout = new VerticalLayout();
		layout.gap = 10.0;
		layout.setPadding(10.0);
		layout.horizontalAlign = CENTER;
		layout.verticalAlign = MIDDLE;
		this.layout = layout;

		var pushButton = new Button();
		pushButton.text = "Push";
		pushButton.addEventListener(TriggerEvent.TRIGGER, event -> {
			this.dispatchEvent(new Event(EVENT_PUSH));
		});
		this.addChild(pushButton);
	}
}

private class PopScreen extends LayoutGroup {
	public static final EVENT_PUSH = "push";
	public static final EVENT_POP = "pop";

	public function new() {
		super();

		var layout = new VerticalLayout();
		layout.gap = 10.0;
		layout.setPadding(10.0);
		layout.horizontalAlign = CENTER;
		layout.verticalAlign = MIDDLE;
		this.layout = layout;

		var pushButton = new Button();
		pushButton.text = "Push Another";
		pushButton.addEventListener(TriggerEvent.TRIGGER, event -> {
			this.dispatchEvent(new Event(EVENT_PUSH));
		});
		this.addChild(pushButton);

		var popButton = new Button();
		popButton.text = "Pop";
		popButton.addEventListener(TriggerEvent.TRIGGER, event -> {
			this.dispatchEvent(new Event(EVENT_POP));
		});
		this.addChild(popButton);
	}
}

private class PopToRootScreen extends LayoutGroup {
	public static final EVENT_POP = "pop";
	public static final EVENT_POP_TO_ROOT = "popToRoot";

	public function new() {
		super();

		var layout = new VerticalLayout();
		layout.gap = 10.0;
		layout.setPadding(10.0);
		layout.horizontalAlign = CENTER;
		layout.verticalAlign = MIDDLE;
		this.layout = layout;

		var popButton = new Button();
		popButton.text = "Pop";
		popButton.addEventListener(TriggerEvent.TRIGGER, event -> {
			this.dispatchEvent(new Event(EVENT_POP));
		});
		this.addChild(popButton);

		var popToRootButton = new Button();
		popToRootButton.text = "Pop To Root";
		popToRootButton.addEventListener(TriggerEvent.TRIGGER, event -> {
			this.dispatchEvent(new Event(EVENT_POP_TO_ROOT));
		});
		this.addChild(popToRootButton);
	}
}
