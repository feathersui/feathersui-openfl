/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.navigators;

import openfl.display.DisplayObject;

/**
	An individual item that will be displayed by a `PageNavigator` component.

	The following example creates a page navigator and adds some items:

	```hx
	var navigator = new PageNavigator();
	navigator.dataProvider = new ArrayCollection([
		PageItem.withClass(WizardView1),
		PageItem.withClass(WizardView1),
		PageItem.withClass(WizardView3)
	]);
	addChild(this.navigator);
	```

	@see [Tutorial: How to use the PageNavigator component](https://feathersui.com/learn/haxe-openfl/page-navigator/)
	@see `feathers.controls.PageNavigator`

	@since 1.0.0
**/
class PageItem {
	/**
		Creates a `PageItem` that instantiates a view from a class that extends
		`DisplayObject` when the `PageNavigator` requests the item's view.

		@since 1.0.0
	**/
	public static function withClass(viewClass:Class<DisplayObject>):PageItem {
		var item = new PageItem();
		item.viewClass = viewClass;
		return item;
	}

	/**
		Creates a `PageItem` that calls a function that returns a `DisplayObject`
		when the `PageNavigator` requests the item's view.

		@since 1.0.0
	**/
	public static function withFunction(viewFunction:() -> DisplayObject):PageItem {
		var item = new PageItem();
		item.viewFunction = viewFunction;
		return item;
	}

	/**
		Creates a `PageItem` that always returns the same `DisplayObject`
		instance when the `PageNavigator` requests the item's view.

		@since 1.0.0
	**/
	public static function withDisplayObject(viewInstance:DisplayObject):PageItem {
		var item = new PageItem();
		item.viewInstance = viewInstance;
		return item;
	}

	private function new() {
		this.internalID = Std.string(internalIDCounter);
		internalIDCounter++;
	}

	private static var internalIDCounter = 0;

	private var internalID:String;

	private var viewClass:Class<DisplayObject>;
	private var viewFunction:() -> DisplayObject;
	private var viewInstance:DisplayObject;

	// called internally by PageNavigator to get this item's view
	private function getView(navigator:PageNavigator):DisplayObject {
		var view:DisplayObject = this.viewInstance;
		if (view == null && this.viewClass != null) {
			view = Type.createInstance(this.viewClass, []);
		}
		if (view == null && this.viewFunction != null) {
			view = this.viewFunction();
		}

		return view;
	}

	// called internally by PageNavigator to clean up this item's view
	private function returnView(view:DisplayObject):Void {}
}
