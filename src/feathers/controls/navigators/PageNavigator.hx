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
import feathers.themes.steel.components.SteelPageNavigatorStyles;
import openfl.display.DisplayObject;
import openfl.errors.ArgumentError;
import openfl.events.Event;

/**
	A container that supports navigation between views using a `PageIndicator`.

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
	@see [Transitions for Feathers UI navigators](https://feathersui.com/learn/haxe-openfl/navigator-transitions/)
	@see `feathers.controls.navigators.PageItem`
	@see `feathers.controls.PageIndicator`

	@since 1.0.0
**/
@:access(feathers.controls.navigators.PageItem)
@:styleContext
class PageNavigator extends BaseNavigator implements IIndexSelector implements IDataSelector<PageItem> {
	/**
		Creates a new `PageNavigator` object.

		@since 1.0.0
	**/
	public function new() {
		initializePageNavigatorTheme();

		super();
	}

	private var pageIndicator:PageIndicator;

	private var _dataProvider:IFlatCollection<PageItem>;

	@:flash.property
	public var dataProvider(get, set):IFlatCollection<PageItem>;

	private function get_dataProvider():IFlatCollection<PageItem> {
		return this._dataProvider;
	}

	private function set_dataProvider(value:IFlatCollection<PageItem>):IFlatCollection<PageItem> {
		if (this._dataProvider == value) {
			return this._dataProvider;
		}
		if (this._dataProvider != null) {
			this._dataProvider.removeEventListener(FlatCollectionEvent.ADD_ITEM, pageNavigator_dataProvider_addItemHandler);
			this._dataProvider.removeEventListener(FlatCollectionEvent.REMOVE_ITEM, pageNavigator_dataProvider_removeItemHandler);
			this._dataProvider.removeEventListener(FlatCollectionEvent.REPLACE_ITEM, pageNavigator_dataProvider_replaceItemHandler);
			for (item in this._dataProvider) {
				this.removeItemInternal(item.internalID);
			}
		}
		this._dataProvider = value;
		if (this._dataProvider != null) {
			for (item in this._dataProvider) {
				this.addItemInternal(item.internalID, item);
			}
			this._dataProvider.addEventListener(FlatCollectionEvent.ADD_ITEM, pageNavigator_dataProvider_addItemHandler, false, 0, true);
			this._dataProvider.addEventListener(FlatCollectionEvent.REMOVE_ITEM, pageNavigator_dataProvider_removeItemHandler, false, 0, true);
			this._dataProvider.addEventListener(FlatCollectionEvent.REPLACE_ITEM, pageNavigator_dataProvider_replaceItemHandler, false, 0, true);
		}
		this.setInvalid(InvalidationFlag.DATA);
		if (this._dataProvider == null || this._dataProvider.length == 0) {
			// use the setter
			this.selectedIndex = -1;
		} else {
			// use the setter
			this.selectedIndex = 0;
		}
		return this._dataProvider;
	}

	private var _selectedIndex:Int = -1;

	/**
		@see `feathers.core.IIndexSelector.selectedIndex`
	**/
	@:flash.property
	public var selectedIndex(get, set):Int;

	private function get_selectedIndex():Int {
		return this._selectedIndex;
	}

	private function set_selectedIndex(value:Int):Int {
		if (this._dataProvider == null) {
			value = -1;
		}
		if (this._selectedIndex == value) {
			return this._selectedIndex;
		}
		this._selectedIndex = value;
		// using variable because if we were to call the selectedItem setter,
		// then this change wouldn't be saved properly
		if (this._selectedIndex == -1) {
			this._selectedItem = null;
		} else {
			this._selectedItem = this._dataProvider.get(this._selectedIndex);
		}
		this.setInvalid(InvalidationFlag.SELECTION);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._selectedIndex;
	}

	/**
		@see `feathers.core.IIndexSelector.maxSelectedIndex`
	**/
	@:flash.property
	public var maxSelectedIndex(get, never):Int;

	private function get_maxSelectedIndex():Int {
		if (this._dataProvider == null) {
			return -1;
		}
		return this._dataProvider.length - 1;
	}

	private var _selectedItem:PageItem = null;

	/**
		@see `feathers.core.IDataSelector.selectedItem`
	**/
	@:flash.property
	public var selectedItem(get, set):PageItem;

	private function get_selectedItem():PageItem {
		return this._selectedItem;
	}

	private function set_selectedItem(value:PageItem):PageItem {
		if (this._dataProvider == null) {
			// use the setter
			this.selectedIndex = -1;
			return this._selectedItem;
		}
		// use the setter
		this.selectedIndex = this._dataProvider.indexOf(value);
		return this._selectedItem;
	}

	/**
		The position of the navigator's page indicator.

		@since 1.0.0
	**/
	@:style
	public var pageIndicatorPosition:RelativePosition = BOTTOM;

	private var _ignoreSelectionChange = false;

	override private function initialize():Void {
		super.initialize();

		if (this.pageIndicator == null) {
			this.pageIndicator = new PageIndicator();
			this.addChild(this.pageIndicator);
		}
		this.pageIndicator.addEventListener(Event.CHANGE, pageNavigator_pageIndicator_changeHandler);
	}

	private function initializePageNavigatorTheme():Void {
		SteelPageNavigatorStyles.initialize();
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);
		var selectionInvalid = this.isInvalid(InvalidationFlag.SELECTION);

		if (dataInvalid) {
			this.pageIndicator.maxSelectedIndex = this._dataProvider.length - 1;
		}

		if (selectionInvalid) {
			var oldIgnoreSelectionChange = this._ignoreSelectionChange;
			this._ignoreSelectionChange = true;
			this.pageIndicator.selectedIndex = this._selectedIndex;
			this._ignoreSelectionChange = oldIgnoreSelectionChange;

			if (this._selectedItem == null && this.activeItemID != null) {
				this.clearActiveItemInternal();
			}
			if (this._selectedItem != null && this.activeItemID != this._selectedItem.internalID) {
				this.showItemInternal(this._selectedItem.internalID, null);
			}
		}

		super.update();
	}

	override private function layoutContent():Void {
		this.pageIndicator.x = 0.0;
		this.pageIndicator.width = this.actualWidth;
		this.pageIndicator.validateNow();
		switch (this.pageIndicatorPosition) {
			case TOP:
				this.pageIndicator.y = 0.0;
			case BOTTOM:
				this.pageIndicator.y = this.actualHeight - this.pageIndicator.height;
			default:
				throw new ArgumentError('Invalid pageIndicatorPosition ${this.pageIndicatorPosition}');
		}

		if (this.activeItemView != null) {
			this.activeItemView.x = 0.0;
			switch (this.pageIndicatorPosition) {
				case TOP:
					this.activeItemView.y = this.pageIndicator.height;
				case BOTTOM:
					this.activeItemView.y = 0.0;
				default:
					throw new ArgumentError('Invalid pageIndicatorPosition ${this.pageIndicatorPosition}');
			}
			this.activeItemView.width = this.actualWidth;
			this.activeItemView.height = this.actualHeight - this.pageIndicator.height;
		}
	}

	override private function getView(id:String):DisplayObject {
		var item = cast(this._addedItems.get(id), PageItem);
		return item.getView(this);
	}

	override private function disposeView(id:String, view:DisplayObject):Void {
		var item = cast(this._addedItems.get(id), PageItem);
		item.returnView(view);
	}

	private function pageNavigator_pageIndicator_changeHandler(event:Event):Void {
		if (this._ignoreSelectionChange) {
			return;
		}
		// use the setter
		this.selectedIndex = this.pageIndicator.selectedIndex;
	}

	private function pageNavigator_dataProvider_addItemHandler(event:FlatCollectionEvent):Void {
		var item = cast(event.addedItem, PageItem);
		this.addItemInternal(item.internalID, item);
	}

	private function pageNavigator_dataProvider_removeItemHandler(event:FlatCollectionEvent):Void {
		var item = cast(event.removedItem, PageItem);
		this.removeItemInternal(item.internalID);
	}

	private function pageNavigator_dataProvider_replaceItemHandler(event:FlatCollectionEvent):Void {
		var addedItem = cast(event.addedItem, PageItem);
		var removedItem = cast(event.removedItem, PageItem);
		this.removeItemInternal(removedItem.internalID);
		this.addItemInternal(addedItem.internalID, addedItem);
	}
}
