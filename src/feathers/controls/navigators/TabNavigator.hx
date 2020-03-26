/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.navigators;

import feathers.events.FlatCollectionEvent;
import openfl.display.DisplayObject;
import openfl.events.Event;
import feathers.core.InvalidationFlag;
import feathers.data.IFlatCollection;

/**

	@see [Tutorial: How to use the TabNavigator component](https://feathersui.com/learn/haxe-openfl/tab-navigator/)
	@see [Transitions for Feathers UI navigators](https://feathersui.com/learn/haxe-openfl/navigator-transitions/)
	@see `feathers.controls.navigators.TabItem`

	@since 1.0.0
**/
@:access(feathers.controls.navigators.TabItem)
@:styleContext
class TabNavigator extends BaseNavigator {
	/**
		Creates a new `TabNavigator` object.

		@since 1.0.0
	**/
	public function new() {
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
		return this.dataProvider;
	}

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

	override private function update():Void {
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);

		if (dataInvalid) {
			this.tabBar.itemToText = this.itemToText;
			this.tabBar.dataProvider = this.dataProvider;
		}

		super.update();
	}

	override private function layoutContent():Void {
		this.tabBar.x = 0.0;
		this.tabBar.width = this.actualWidth;
		this.tabBar.validateNow();
		this.tabBar.y = this.actualHeight - this.tabBar.height;

		if (this.activeItemView != null) {
			this.activeItemView.x = 0.0;
			this.activeItemView.y = 0.0;
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
		var item = cast(this.tabBar.selectedItem, TabItem);
		var result = this.showItemInternal(item.internalID, null);
	}

	private function tabNavigator_dataProvider_addItemHandler(event:FlatCollectionEvent):Void {
		var item = event.addedItem;
		this.addItemInternal(item.internalID, item);
	}

	private function tabNavigator_dataProvider_removeItemHandler(event:FlatCollectionEvent):Void {
		var item = event.removedItem;
		this.removeItemInternal(item.internalID);
	}

	private function tabNavigator_dataProvider_replaceItemHandler(event:FlatCollectionEvent):Void {
		var addedItem = event.addedItem;
		var removedItem = event.removedItem;
		this.removeItemInternal(removedItem.internalID);
		this.addItemInternal(addedItem.internalID, addedItem);
	}
}
