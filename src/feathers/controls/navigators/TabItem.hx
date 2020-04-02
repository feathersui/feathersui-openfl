/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.navigators;

import openfl.events.Event;
import feathers.motion.effects.IEffectContext;
import openfl.display.DisplayObject;

/**
	An individual item that will be displayed by a `StackNavigator` component.
	Provides the view, an optional function to set properties before the view is
	displayed, and an optional list of events to map to actions (like push, pop,
	and replace) on the `StackNavigator`.

	The following example creates a new `StackItem` using the `SettingsView`
	class to instantiate the view instance. This item is given am id of
	`"settings"`. When the view dispatches the
	`SettingsView.SHOW_ADVANCED_SETTINGS` event, the `StackNavigator` will push
	a different item with the ID `"advancedSettings"` onto its history stack.
	When the view instance dispatches `Event.COMPLETE`, the `StackNavigator`
	will pop the view from its history stack and return navigate to the previous
	view.

	```hx
	var item = StackItem.withClass("settings", SettingsScreen, [
		SettingsScreen.SHOW_ADVANCED_SETTINGS => StackActions.Push("advancedSettings"),
		Event.COMPLETE => StackActions.Pop()
	]);
	navigator.addItem("settings", item);
	```

	@see [Tutorial: How to use the TabNavigator component](https://feathersui.com/learn/haxe-openfl/tab-navigator/)
	@see `feathers.controls.TabNavigator`

	@since 1.0.0
**/
class TabItem {
	/**
		Creates a `TabItem` that instantiates a view from a class that extends
		`DisplayObject` when the `TabNavigator` requests the item's view.

		@since 1.0.0
	**/
	public static function withClass(text:String, viewClass:Class<DisplayObject>):TabItem {
		var item = new TabItem();
		item.text = text;
		item.viewClass = viewClass;
		return item;
	}

	/**
		Creates a `TabItem` that calls a function that returns a `DisplayObject`
		when the `TabNavigator` requests the item's view.

		@since 1.0.0
	**/
	public static function withFunction(text:String, viewFunction:() -> DisplayObject):TabItem {
		var item = new TabItem();
		item.text = text;
		item.viewFunction = viewFunction;
		return item;
	}

	/**
		Creates a `TabItem` that always returns the same `DisplayObject`
		instance when the `TabNavigator` requests the item's view.

		@since 1.0.0
	**/
	public static function withDisplayObject(text:String, viewInstance:DisplayObject):TabItem {
		var item = new TabItem();
		item.text = text;
		item.viewInstance = viewInstance;
		return item;
	}

	private function new() {
		this.internalID = Std.string(internalIDCounter);
		internalIDCounter++;
	}

	private static var internalIDCounter = 0;

	private var internalID:String;

	/**
		The text to display in the tab bar.

		@since 1.0.0
	**/
	public var text:String;

	private var viewClass:Class<DisplayObject>;
	private var viewFunction:() -> DisplayObject;
	private var viewInstance:DisplayObject;

	// called internally by TabNavigator to get this item's view
	private function getView(navigator:TabNavigator):DisplayObject {
		var view:DisplayObject = this.viewInstance;
		if (view == null && this.viewClass != null) {
			view = Type.createInstance(this.viewClass, []);
		}
		if (view == null && this.viewFunction != null) {
			view = this.viewFunction();
		}

		return view;
	}

	// called internally by TabNavigator to clean up this item's view
	private function returnView(view:DisplayObject):Void {}
}
