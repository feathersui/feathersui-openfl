/*
	Feathers UI
	Copyright 2024 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.navigators;

import feathers.core.IUIControl;
import feathers.utils.AbstractDisplayObjectFactory;
import openfl.display.DisplayObject;

/**
	An individual item that will be displayed by a `TabNavigator` component.

	The following example creates a tab navigator and adds some items:

	```haxe
	var navigator = new TabNavigator();
	navigator.dataProvider = new ArrayCollection([
		TabItem.withClass("Home", HomeView),
		TabItem.withClass("Profile", ProfileView),
		TabItem.withClass("Settings", SettingsView)
	]);
	addChild(this.navigator);
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
		item.viewFactory = viewClass;
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
		item.viewFactory = viewFunction;
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
		item.viewFactory = viewInstance;
		return item;
	}

	/**
		Creates a `TabItem` using a `DisplayObjectFactory` when the
		`TabNavigator` requests the item's view.

		@since 1.3.0
	**/
	public static function withFactory(text:String, viewFactory:AbstractDisplayObjectFactory<Dynamic, DisplayObject>):TabItem {
		var item = new TabItem();
		item.text = text;
		item.viewFactory = viewFactory;
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

	private var viewFactory:AbstractDisplayObjectFactory<Dynamic, DisplayObject>;

	// called internally by TabNavigator to get this item's view
	private function getView(navigator:TabNavigator):DisplayObject {
		var view:DisplayObject = this.viewFactory.create();
		return view;
	}

	// called internally by TabNavigator to clean up this item's view
	private function returnView(view:DisplayObject):Void {
		if (this.viewFactory.destroy != null) {
			this.viewFactory.destroy(view);
		}
	}
}
