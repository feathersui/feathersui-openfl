/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.navigators;

import feathers.core.IDataSelector;
import feathers.core.IIndexSelector;
import feathers.core.InvalidationFlag;
import feathers.data.IFlatCollection;
import feathers.events.FeathersEvent;
import feathers.events.FlatCollectionEvent;
import feathers.layout.RelativePosition;
import feathers.themes.steel.components.SteelTabNavigatorStyles;
import openfl.display.DisplayObject;
import openfl.errors.ArgumentError;
import openfl.events.Event;

/**
	A container that supports navigation between views using a tab bar.

	The following example creates a tab navigator and adds some items:

	```hx
	var navigator = new TabNavigator();
	navigator.dataProvider = new ArrayCollection([
		TabItem.withClass("Home", HomeView),
		TabItem.withClass("Profile", ProfileView),
		TabItem.withClass("Settings", SettingsView)
	]);
	addChild(this.navigator);
	```

	@see [Tutorial: How to use the TabNavigator component](https://feathersui.com/learn/haxe-openfl/tab-navigator/)
	@see [Transitions for Feathers UI navigators](https://feathersui.com/learn/haxe-openfl/navigator-transitions/)
	@see `feathers.controls.navigators.TabItem`
	@see `feathers.controls.TabBar`

	@since 1.0.0
**/
@:access(feathers.controls.navigators.TabItem)
@:styleContext
class TabNavigator extends BaseNavigator implements IIndexSelector implements IDataSelector<TabItem> {
	/**
		Creates a new `TabNavigator` object.

		@since 1.0.0
	**/
	public function new() {
		initializeTabNavigatorTheme();

		super();
	}

	private var tabBar:TabBar;

	public var dataProvider(default, set):IFlatCollection<TabItem>;

	private function set_dataProvider(value:IFlatCollection<TabItem>):IFlatCollection<TabItem> {
		if (this.dataProvider == value) {
			return this.dataProvider;
		}
		if (this.dataProvider != null) {
			this.dataProvider.removeEventListener(FlatCollectionEvent.ADD_ITEM, tabNavigator_dataProvider_addItemHandler);
			this.dataProvider.removeEventListener(FlatCollectionEvent.REMOVE_ITEM, tabNavigator_dataProvider_removeItemHandler);
			this.dataProvider.removeEventListener(FlatCollectionEvent.REPLACE_ITEM, tabNavigator_dataProvider_replaceItemHandler);
			for (item in this.dataProvider) {
				this.removeItemInternal(item.internalID);
			}
		}
		this.dataProvider = value;
		if (this.dataProvider != null) {
			for (item in this.dataProvider) {
				this.addItemInternal(item.internalID, item);
			}
			this.dataProvider.addEventListener(FlatCollectionEvent.ADD_ITEM, tabNavigator_dataProvider_addItemHandler, false, 0, true);
			this.dataProvider.addEventListener(FlatCollectionEvent.REMOVE_ITEM, tabNavigator_dataProvider_removeItemHandler, false, 0, true);
			this.dataProvider.addEventListener(FlatCollectionEvent.REPLACE_ITEM, tabNavigator_dataProvider_replaceItemHandler, false, 0, true);
		}
		this.setInvalid(InvalidationFlag.DATA);
		if (this.dataProvider == null || this.dataProvider.length == 0) {
			this.selectedIndex = -1;
		} else {
			this.selectedIndex = 0;
		}
		return this.dataProvider;
	}

	/**
		@see `feathers.core.IIndexSelector.selectedIndex`
	**/
	@:isVar
	public var selectedIndex(get, set):Int = -1;

	private function get_selectedIndex():Int {
		return this.selectedIndex;
	}

	private function set_selectedIndex(value:Int):Int {
		if (this.dataProvider == null) {
			value = -1;
		}
		if (this.selectedIndex == value) {
			return this.selectedIndex;
		}
		this.selectedIndex = value;
		// using @:bypassAccessor because if we were to call the selectedItem
		// setter, this change wouldn't be saved properly
		if (this.selectedIndex == -1) {
			@:bypassAccessor this.selectedItem = null;
		} else {
			@:bypassAccessor this.selectedItem = this.dataProvider.get(this.selectedIndex);
		}
		this.setInvalid(InvalidationFlag.SELECTION);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this.selectedIndex;
	}

	/**
		@see `feathers.core.IIndexSelector.maxSelectedIndex`
	**/
	public var maxSelectedIndex(get, never):Int;

	private function get_maxSelectedIndex():Int {
		if (this.dataProvider == null) {
			return -1;
		}
		return this.dataProvider.length - 1;
	}

	/**
		@see `feathers.core.IDataSelector.selectedItem`
	**/
	@:isVar
	public var selectedItem(get, set):TabItem = null;

	private function get_selectedItem():TabItem {
		return this.selectedItem;
	}

	private function set_selectedItem(value:TabItem):TabItem {
		if (this.dataProvider == null) {
			this.selectedIndex = -1;
			return this.selectedItem;
		}
		this.selectedIndex = this.dataProvider.indexOf(value);
		return this.selectedItem;
	}

	/**
		The position of the navigator's tab bar.

		@since 1.0.0
	**/
	@:style
	public var tabBarPosition:RelativePosition = BOTTOM;

	private var _ignoreSelectionChange = false;

	override private function initialize():Void {
		super.initialize();

		if (this.tabBar == null) {
			this.tabBar = new TabBar();
			this.addChild(this.tabBar);
		}
		this.tabBar.addEventListener(Event.CHANGE, tabNavigator_tabBar_changeHandler);
	}

	private function itemToText(item:TabItem):String {
		return item.text;
	}

	private function initializeTabNavigatorTheme():Void {
		SteelTabNavigatorStyles.initialize();
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);
		var selectionInvalid = this.isInvalid(InvalidationFlag.SELECTION);

		if (dataInvalid) {
			this.tabBar.itemToText = this.itemToText;
			this.tabBar.dataProvider = this.dataProvider;
		}

		if (selectionInvalid) {
			var oldIgnoreSelectionChange = this._ignoreSelectionChange;
			this._ignoreSelectionChange = true;
			this.tabBar.selectedIndex = this.selectedIndex;
			this._ignoreSelectionChange = oldIgnoreSelectionChange;

			if (this.selectedItem == null && this.activeItemID != null) {
				this.clearActiveItemInternal();
			}
			if (this.selectedItem != null && this.activeItemID != this.selectedItem.internalID) {
				this.showItemInternal(this.selectedItem.internalID, null);
			}
		}

		super.update();
	}

	override private function layoutContent():Void {
		this.tabBar.x = 0.0;
		this.tabBar.width = this.actualWidth;
		this.tabBar.validateNow();
		switch (this.tabBarPosition) {
			case TOP:
				this.tabBar.y = 0.0;
			case BOTTOM:
				this.tabBar.y = this.actualHeight - this.tabBar.height;
			default:
				throw new ArgumentError('Invalid tabBarPosition ${this.tabBarPosition}');
		}

		if (this.activeItemView != null) {
			this.activeItemView.x = 0.0;
			switch (this.tabBarPosition) {
				case TOP:
					this.activeItemView.y = this.tabBar.height;
				case BOTTOM:
					this.activeItemView.y = 0.0;
				default:
					throw new ArgumentError('Invalid tabBarPosition ${this.tabBarPosition}');
			}
			this.activeItemView.width = this.actualWidth;
			this.activeItemView.height = this.actualHeight - this.tabBar.height;
		}
	}

	override private function getView(id:String):DisplayObject {
		var item = cast(this._addedItems.get(id), TabItem);
		return item.getView(this);
	}

	override private function disposeView(id:String, view:DisplayObject):Void {
		var item = cast(this._addedItems.get(id), TabItem);
		item.returnView(view);
	}

	private function tabNavigator_tabBar_changeHandler(event:Event):Void {
		if (this._ignoreSelectionChange) {
			return;
		}
		this.selectedIndex = this.tabBar.selectedIndex;
	}

	private function tabNavigator_dataProvider_addItemHandler(event:FlatCollectionEvent):Void {
		var item = cast(event.addedItem, TabItem);
		this.addItemInternal(item.internalID, item);
	}

	private function tabNavigator_dataProvider_removeItemHandler(event:FlatCollectionEvent):Void {
		var item = cast(event.removedItem, TabItem);
		this.removeItemInternal(item.internalID);
	}

	private function tabNavigator_dataProvider_replaceItemHandler(event:FlatCollectionEvent):Void {
		var addedItem = cast(event.addedItem, TabItem);
		var removedItem = cast(event.removedItem, TabItem);
		this.removeItemInternal(removedItem.internalID);
		this.addItemInternal(addedItem.internalID, addedItem);
	}
}
