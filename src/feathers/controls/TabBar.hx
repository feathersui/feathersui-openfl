/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.controls.dataRenderers.IDataRenderer;
import feathers.layout.LayoutBoundsResult;
import feathers.layout.Measurements;
import feathers.layout.ILayout;
import feathers.layout.HorizontalLayout;
import feathers.core.FeathersControl;
import feathers.utils.DisplayObjectRecycler;
import feathers.events.FlatCollectionEvent;
import haxe.ds.ObjectMap;
import openfl.errors.IllegalOperationError;
import openfl.events.Event;
import feathers.core.InvalidationFlag;
import feathers.data.IFlatCollection;
import feathers.events.FeathersEvent;
import feathers.data.TabBarItemState;

/**

	@since 1.0.0
**/
@:access(feathers.data.TabBarItemState)
@:styleContext
class TabBar extends FeathersControl {
	private static final INVALIDATION_FLAG_TAB_FACTORY = "tabFactory";

	private static function defaultUpdateTab(tab:ToggleButton, state:TabBarItemState):Void {
		tab.text = state.text;
	}

	private static function defaultResetTab(tab:ToggleButton, state:TabBarItemState):Void {
		tab.text = null;
	}

	/**
		Creates a new `TabBar` object.

		@since 1.0.0
	**/
	public function new() {
		initializeTabBarTheme();

		super();
	}

	/**

		@since 1.0.0
	**/
	public var dataProvider(default, set):IFlatCollection<Dynamic> = null;

	private function set_dataProvider(value:IFlatCollection<Dynamic>):IFlatCollection<Dynamic> {
		if (this.dataProvider == value) {
			return this.dataProvider;
		}
		if (this.dataProvider != null) {
			this.dataProvider.removeEventListener(Event.CHANGE, dataProvider_changeHandler);
			this.dataProvider.removeEventListener(FlatCollectionEvent.ADD_ITEM, dataProvider_addItemHandler);
			this.dataProvider.removeEventListener(FlatCollectionEvent.REMOVE_ITEM, dataProvider_removeItemHandler);
			this.dataProvider.removeEventListener(FlatCollectionEvent.REPLACE_ITEM, dataProvider_replaceItemHandler);
			this.dataProvider.removeEventListener(FlatCollectionEvent.SORT_CHANGE, dataProvider_sortChangeHandler);
			this.dataProvider.removeEventListener(FlatCollectionEvent.FILTER_CHANGE, dataProvider_filterChangeHandler);
		}
		this.dataProvider = value;
		if (this.dataProvider != null) {
			this.dataProvider.addEventListener(Event.CHANGE, dataProvider_changeHandler);
			this.dataProvider.addEventListener(FlatCollectionEvent.ADD_ITEM, dataProvider_addItemHandler);
			this.dataProvider.addEventListener(FlatCollectionEvent.REMOVE_ITEM, dataProvider_removeItemHandler);
			this.dataProvider.addEventListener(FlatCollectionEvent.REPLACE_ITEM, dataProvider_replaceItemHandler);
			this.dataProvider.addEventListener(FlatCollectionEvent.SORT_CHANGE, dataProvider_sortChangeHandler);
			this.dataProvider.addEventListener(FlatCollectionEvent.FILTER_CHANGE, dataProvider_filterChangeHandler);
		}
		if (this.selectedIndex == -1 && this.dataProvider != null && this.dataProvider.length > 0) {
			this.selectedIndex = 0;
		} else if (this.selectedIndex != -1 && (this.dataProvider == null || this.dataProvider.length == 0)) {
			this.selectedIndex = -1;
		}
		this.setInvalid(InvalidationFlag.DATA);
		return this.dataProvider;
	}

	/**

		@since 1.0.0
	**/
	public var selectedIndex(default, set):Int = -1;

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

		@since 1.0.0
	**/
	@:isVar
	public var selectedItem(default, set):Dynamic = null;

	private function set_selectedItem(value:Dynamic):Dynamic {
		if (this.dataProvider == null) {
			this.selectedIndex = -1;
			return this.selectedItem;
		}
		this.selectedIndex = this.dataProvider.indexOf(value);
		return this.selectedItem;
	}

	/**
		@since 1.0.0
	**/
	public var tabRecycler:DisplayObjectRecycler<Dynamic, TabBarItemState, ToggleButton> = new DisplayObjectRecycler(ToggleButton);

	private var inactiveTabs:Array<ToggleButton> = [];
	private var activeTabs:Array<ToggleButton> = [];
	private var dataToTab = new ObjectMap<Dynamic, ToggleButton>();
	private var tabToData = new ObjectMap<ToggleButton, Dynamic>();
	private var _unrenderedData:Array<Dynamic> = [];

	private var _ignoreSelectionChange = false;

	public dynamic function itemToText(data:Dynamic):String {
		return Std.string(data);
	}

	private var _layout:ILayout = new HorizontalLayout();
	private var _layoutMeasurements = new Measurements();
	private var _layoutResult = new LayoutBoundsResult();
	private var _ignoreChildChanges = false;

	private function initializeTabBarTheme():Void {}

	override private function update():Void {
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);
		var layoutInvalid = this.isInvalid(InvalidationFlag.LAYOUT);
		var selectionInvalid = this.isInvalid(InvalidationFlag.SELECTION);
		var stateInvalid = this.isInvalid(InvalidationFlag.STATE);
		var stylesInvalid = this.isInvalid(InvalidationFlag.STYLES);
		var tabsInvalid = this.isInvalid(INVALIDATION_FLAG_TAB_FACTORY);

		if (tabsInvalid || selectionInvalid || stateInvalid || dataInvalid) {
			this.refreshTabs();
		}

		this.refreshViewPortBounds();
		this.handleLayout();
		this.handleLayoutResult();

		// final invalidation to avoid juggler next frame issues
		this.validateChildren();
	}

	private function refreshViewPortBounds():Void {
		this._layoutMeasurements.save(this);
	}

	private function handleLayout():Void {
		var oldIgnoreChildChanges = this._ignoreChildChanges;
		this._ignoreChildChanges = true;
		this._layout.layout(cast this.activeTabs, this._layoutMeasurements, this._layoutResult);
		this._ignoreChildChanges = oldIgnoreChildChanges;
	}

	private function handleLayoutResult():Void {
		var viewPortWidth = this._layoutResult.viewPortWidth;
		var viewPortHeight = this._layoutResult.viewPortHeight;
		this.saveMeasurements(viewPortWidth, viewPortHeight, viewPortWidth, viewPortHeight);
	}

	private function validateChildren():Void {
		for (tab in this.activeTabs) {
			tab.validateNow();
		}
	}

	private function refreshTabs():Void {
		if (this.tabRecycler.update == null) {
			this.tabRecycler.update = defaultUpdateTab;
			if (this.tabRecycler.reset == null) {
				this.tabRecycler.reset = defaultResetTab;
			}
		}

		var tabsInvalid = this.isInvalid(INVALIDATION_FLAG_TAB_FACTORY);
		this.refreshInactiveTabs(tabsInvalid);
		if (this.dataProvider == null) {
			return;
		}

		this.findUnrenderedData();
		this.recoverInactiveTabs();
		this.renderUnrenderedData();
		this.freeInactiveTabs();
		if (this.inactiveTabs.length > 0) {
			throw new IllegalOperationError(Type.getClassName(Type.getClass(this)) + ": inactive item renderers should be empty after updating.");
		}
	}

	private function refreshInactiveTabs(factoryInvalid:Bool):Void {
		var temp = this.inactiveTabs;
		this.inactiveTabs = this.activeTabs;
		this.activeTabs = temp;
		if (this.activeTabs.length > 0) {
			throw new IllegalOperationError(Type.getClassName(Type.getClass(this)) + ": active item renderers should be empty before updating.");
		}
		if (factoryInvalid) {
			this.recoverInactiveTabs();
			this.freeInactiveTabs();
		}
	}

	private function recoverInactiveTabs():Void {
		for (tab in this.inactiveTabs) {
			if (tab == null) {
				continue;
			}
			var item = this.tabToData.get(tab);
			if (item == null) {
				return;
			}
			this.tabToData.remove(tab);
			this.dataToTab.remove(item);
			tab.removeEventListener(FeathersEvent.TRIGGERED, tab_triggeredHandler);
			tab.removeEventListener(Event.CHANGE, tab_changeHandler);
			this._currentItemState.data = item;
			this._currentItemState.index = -1;
			this._currentItemState.selected = false;
			this._currentItemState.text = null;
			var oldIgnoreSelectionChange = this._ignoreSelectionChange;
			this._ignoreSelectionChange = true;
			if (this.tabRecycler.reset != null) {
				this.tabRecycler.reset(tab, this._currentItemState);
			}
			if (Std.is(tab, IDataRenderer)) {
				var dataRenderer = cast(tab, IDataRenderer);
				dataRenderer.data = null;
			}
			tab.selected = this._currentItemState.selected;
			this._ignoreSelectionChange = oldIgnoreSelectionChange;
		}
	}

	private function freeInactiveTabs():Void {
		for (tab in this.inactiveTabs) {
			if (tab == null) {
				continue;
			}
			this.destroyTab(tab);
		}
		this.inactiveTabs.resize(0);
	}

	private var _currentItemState = new TabBarItemState();

	private function findUnrenderedData():Void {
		for (i in 0...this.dataProvider.length) {
			var item = this.dataProvider.get(i);
			var tab = this.dataToTab.get(item);
			if (tab != null) {
				this._currentItemState.data = item;
				this._currentItemState.index = i;
				this._currentItemState.selected = item == this.selectedItem;
				this._currentItemState.text = itemToText(item);
				var oldIgnoreSelectionChange = this._ignoreSelectionChange;
				this._ignoreSelectionChange = true;
				if (this.tabRecycler.update != null) {
					this.tabRecycler.update(tab, this._currentItemState);
				}
				if (Std.is(tab, IDataRenderer)) {
					var dataRenderer = cast(tab, IDataRenderer);
					// if the tab is an IDataRenderer, this cannot be overridden
					dataRenderer.data = this._currentItemState.data;
				}
				tab.selected = this._currentItemState.selected;
				this._ignoreSelectionChange = oldIgnoreSelectionChange;
				// if this item renderer used to be the typical layout item, but
				// it isn't anymore, it may have been set invisible
				tab.visible = true;
				this.addChildAt(tab, i);
				var removed = this.inactiveTabs.remove(tab);
				if (!removed) {
					throw new IllegalOperationError(Type.getClassName(Type.getClass(this))
						+ ": data renderer map contains bad data. This may be caused by duplicate items in the data provider, which is not allowed.");
				}
				this.activeTabs.push(tab);
			} else {
				this._unrenderedData.push(item);
			}
		}
	}

	private function renderUnrenderedData():Void {
		for (item in this._unrenderedData) {
			var index = this.dataProvider.indexOf(item);
			var tab = this.createTab(item, index);
			tab.visible = true;
			this.activeTabs.push(tab);
			this.addChildAt(tab, index);
		}
		this._unrenderedData.resize(0);
	}

	private function createTab(item:Dynamic, index:Int):ToggleButton {
		var tab:ToggleButton = null;
		if (this.inactiveTabs.length == 0) {
			tab = this.tabRecycler.create();
		} else {
			tab = this.inactiveTabs.shift();
		}
		this._currentItemState.data = item;
		this._currentItemState.index = index;
		this._currentItemState.selected = item == this.selectedItem;
		this._currentItemState.text = itemToText(item);
		if (this.tabRecycler.update != null) {
			this.tabRecycler.update(tab, this._currentItemState);
		}
		tab.selected = this._currentItemState.selected;
		tab.addEventListener(FeathersEvent.TRIGGERED, tab_triggeredHandler);
		tab.addEventListener(Event.CHANGE, tab_changeHandler);
		this.tabToData.set(tab, item);
		this.dataToTab.set(item, tab);
		return tab;
	}

	private function destroyTab(tab:ToggleButton):Void {
		this.removeChild(tab);
		if (this.tabRecycler.destroy != null) {
			this.tabRecycler.destroy(tab);
		}
	}

	private function refreshSelectedIndicesAfterFilterOrSort():Void {
		if (this.selectedIndex == -1) {
			return;
		}
		// the index may have changed, possibily even to -1, if the item was
		// filtered out
		this.selectedIndex = this.dataProvider.indexOf(this.selectedItem);
	}

	private function tab_triggeredHandler(event:FeathersEvent):Void {
		var tab = cast(event.currentTarget, ToggleButton);
		var item = this.tabToData.get(tab);
		// trigger before change
		FeathersEvent.dispatch(this, FeathersEvent.TRIGGERED);
	}

	private function tab_changeHandler(event:Event):Void {
		if (this._ignoreSelectionChange) {
			return;
		}
		var tab = cast(event.currentTarget, ToggleButton);
		if (!tab.selected) {
			// no toggle off!
			tab.selected = true;
			return;
		}
		var item = this.tabToData.get(tab);
		this.selectedItem = item;
	}

	private function dataProvider_changeHandler(event:Event):Void {
		this.setInvalid(InvalidationFlag.DATA);
	}

	private function dataProvider_addItemHandler(event:FlatCollectionEvent):Void {
		if (this.selectedIndex == -1) {
			return;
		}
		if (this.selectedIndex <= event.index) {
			FeathersEvent.dispatch(this, Event.CHANGE);
		}
	}

	private function dataProvider_removeItemHandler(event:FlatCollectionEvent):Void {
		if (this.selectedIndex == -1) {
			return;
		}
		if (this.selectedIndex == event.index) {
			FeathersEvent.dispatch(this, Event.CHANGE);
		}
	}

	private function dataProvider_replaceItemHandler(event:FlatCollectionEvent):Void {
		if (this.selectedIndex == -1) {
			return;
		}
		if (this.selectedIndex == event.index) {
			FeathersEvent.dispatch(this, Event.CHANGE);
		}
	}

	private function dataProvider_sortChangeHandler(event:FlatCollectionEvent):Void {
		this.refreshSelectedIndicesAfterFilterOrSort();
	}

	private function dataProvider_filterChangeHandler(event:FlatCollectionEvent):Void {
		this.refreshSelectedIndicesAfterFilterOrSort();
	}
}
