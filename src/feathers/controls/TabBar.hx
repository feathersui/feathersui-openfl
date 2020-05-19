/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import feathers.core.IFocusObject;
import feathers.core.IIndexSelector;
import feathers.core.IUIControl;
import feathers.core.IStateContext;
import feathers.core.IValidating;
import feathers.core.IStateObserver;
import openfl.display.DisplayObject;
import feathers.events.TriggerEvent;
import feathers.controls.dataRenderers.IDataRenderer;
import feathers.core.FeathersControl;
import feathers.core.IDataSelector;
import feathers.core.InvalidationFlag;
import feathers.data.IFlatCollection;
import feathers.data.TabBarItemState;
import feathers.events.FeathersEvent;
import feathers.events.FlatCollectionEvent;
import feathers.layout.ILayout;
import feathers.layout.LayoutBoundsResult;
import feathers.layout.Measurements;
import feathers.themes.steel.components.SteelTabBarStyles;
import feathers.utils.DisplayObjectRecycler;
import haxe.ds.ObjectMap;
import openfl.errors.IllegalOperationError;
import openfl.events.Event;

/**
	A line of tabs, where one may be selected at a time.

	The following example sets the data provider, tells the tabs how to
	interpret the data, selects the second tab, and listens for when the
	selection changes:

	```hx
	var tabs = new TabBar();
	tabs.dataProvider = new ArrayCollection([
		{ text: "Latest Posts" },
		{ text: "Profile" },
		{ text: "Settings" }
	]);

	tabBar.itemToText = (item:Dynamic) -> {
		return item.text;
	};

	tabs.selectedIndex = 1;

	tabs.addEventListener(Event.CHANGE, tabs_changeHandler);

	this.addChild(tabs);
	```

	@see [Tutorial: How to use the TabBar component](https://feathersui.com/learn/haxe-openfl/tab-bar/)
	@see `feathers.controls.navigators.TabNavigator`

	@since 1.0.0
**/
@:access(feathers.data.TabBarItemState)
@:styleContext
class TabBar extends FeathersControl implements IIndexSelector implements IDataSelector<Dynamic> implements IFocusObject {
	private static final INVALIDATION_FLAG_TAB_FACTORY = "tabFactory";

	/**
		The variant used to style the tab child components in a theme.

		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)
	**/
	public static final CHILD_VARIANT_TAB = "tabBar_tab";

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

		this.addEventListener(KeyboardEvent.KEY_DOWN, tabBar_keyDownHandler);
	}

	/**
		The collection of data displayed by the tab bar.

		The following example passes in a data provider and tells the tabs how
		to interpret the data:

		```hx
		tabBar.dataProvider = new ArrayCollection([
			{ text: "Latest Posts" },
			{ text: "Profile" },
			{ text: "Settings" }
		]);

		tabBar.itemToText = (item:Dynamic) -> {
			return item.text;
		};
		```

		@default null

		@see `feathers.data.ArrayCollection`

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
	public var selectedItem(get, set):Dynamic = null;

	private function get_selectedItem():Dynamic {
		return this.selectedItem;
	}

	private function set_selectedItem(value:Dynamic):Dynamic {
		if (this.dataProvider == null) {
			this.selectedIndex = -1;
			return this.selectedItem;
		}
		this.selectedIndex = this.dataProvider.indexOf(value);
		return this.selectedItem;
	}

	/**
		Manages tabs used by the tab bar.

		In the following example, the tab bar uses a custom tab renderer class:

		```hx
		tabBar.tabRecycler = DisplayObjectRecycler.withClass(ToggleButton);
		```

		@since 1.0.0
	**/
	public var tabRecycler:DisplayObjectRecycler<Dynamic, TabBarItemState, ToggleButton> = DisplayObjectRecycler.withClass(ToggleButton);

	private var inactiveTabs:Array<ToggleButton> = [];
	private var activeTabs:Array<ToggleButton> = [];
	private var dataToTab = new ObjectMap<Dynamic, ToggleButton>();
	private var tabToData = new ObjectMap<ToggleButton, Dynamic>();
	private var _unrenderedData:Array<Dynamic> = [];

	private var _ignoreSelectionChange = false;

	/**
		Converts an item to text to display within tab bar. By default, the
		`toString()` method is called to convert an item to text. This method
		may be replaced to provide custom text.

		For example, consider the following item:

		```hx
		{ text: "Example Item" }
		```

		If the `TabBar` should display the text "Example Item", a custom
		implementation of `itemToText()` might look like this:

		```hx
		tabBar.itemToText = (item:Dynamic) -> {
			return item.text;
		};
		```

		@since 1.0.0
	**/
	public dynamic function itemToText(data:Dynamic):String {
		return Std.string(data);
	}

	/**
		The layout algorithm used to position and size the tabs.

		By default, if no layout is provided by the time that the tab bar
		initializes, a default layout that displays items horizontally will be
		created.

		The following example tells the tab bar to use a custom layout:

		```hx
		var layout = new HorizontalDistributedLayout();
		layout.maxItemWidth = 300.0;
		tabBar.layout = layout;
		```

		@since 1.0.0
	**/
	@:style
	public var layout:ILayout = null;

	private var _currentBackgroundSkin:DisplayObject = null;
	private var _backgroundSkinMeasurements:Measurements = null;

	/**
		The default background skin to display behind the tabs.

		The following example passes a bitmap for the tab bar to use as a
		background skin:

		```hx
		tabBar.backgroundSkin = new Bitmap(bitmapData);
		```

		@default null

		@see `TabBar.disabledBackgroundSkin`

		@since 1.0.0
	**/
	@:style
	public var backgroundSkin:DisplayObject = null;

	/**
		A background skin to display behind the tabs when the tab bar is
		disabled.

		The following example gives the tab bar a disabled background skin:

		```hx
		tabBar.disabledBackgroundSkin = new Bitmap(bitmapData);
		tabBar.enabled = false;
		```

		@default null

		@see `TabBar.backgroundSkin`

		@since 1.0.0
	**/
	@:style
	public var disabledBackgroundSkin:DisplayObject = null;

	private var _layoutMeasurements = new Measurements();
	private var _layoutResult = new LayoutBoundsResult();
	private var _ignoreChildChanges = false;

	private var _currentItemState = new TabBarItemState();

	private function initializeTabBarTheme():Void {
		SteelTabBarStyles.initialize();
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);
		var layoutInvalid = this.isInvalid(InvalidationFlag.LAYOUT);
		var selectionInvalid = this.isInvalid(InvalidationFlag.SELECTION);
		var stateInvalid = this.isInvalid(InvalidationFlag.STATE);
		var stylesInvalid = this.isInvalid(InvalidationFlag.STYLES);
		var tabsInvalid = this.isInvalid(INVALIDATION_FLAG_TAB_FACTORY);

		if (stylesInvalid || stateInvalid) {
			this.refreshBackgroundSkin();
		}

		if (tabsInvalid || selectionInvalid || stateInvalid || dataInvalid) {
			this.refreshTabs();
		}

		this.refreshViewPortBounds();
		this.handleLayout();
		this.handleLayoutResult();

		this.layoutBackgroundSkin();

		// final invalidation to avoid juggler next frame issues
		this.validateChildren();
	}

	private function refreshViewPortBounds():Void {
		this._layoutMeasurements.save(this);
	}

	private function handleLayout():Void {
		var oldIgnoreChildChanges = this._ignoreChildChanges;
		this._ignoreChildChanges = true;
		this.layout.layout(cast this.activeTabs, this._layoutMeasurements, this._layoutResult);
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
			tab.removeEventListener(TriggerEvent.TRIGGER, tab_triggerHandler);
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

	private function refreshBackgroundSkin():Void {
		var oldSkin = this._currentBackgroundSkin;
		this._currentBackgroundSkin = this.getCurrentBackgroundSkin();
		if (this._currentBackgroundSkin == oldSkin) {
			return;
		}
		this.removeCurrentBackgroundSkin(oldSkin);
		if (this._currentBackgroundSkin == null) {
			this._backgroundSkinMeasurements = null;
			return;
		}
		if (Std.is(this._currentBackgroundSkin, IUIControl)) {
			cast(this._currentBackgroundSkin, IUIControl).initializeNow();
		}
		if (this._backgroundSkinMeasurements == null) {
			this._backgroundSkinMeasurements = new Measurements(this._currentBackgroundSkin);
		} else {
			this._backgroundSkinMeasurements.save(this._currentBackgroundSkin);
		}
		if (Std.is(this, IStateContext) && Std.is(this._currentBackgroundSkin, IStateObserver)) {
			cast(this._currentBackgroundSkin, IStateObserver).stateContext = cast(this, IStateContext<Dynamic>);
		}
		this.addChildAt(this._currentBackgroundSkin, 0);
	}

	private function getCurrentBackgroundSkin():DisplayObject {
		if (!this.enabled && this.disabledBackgroundSkin != null) {
			return this.disabledBackgroundSkin;
		}
		return this.backgroundSkin;
	}

	private function removeCurrentBackgroundSkin(skin:DisplayObject):Void {
		if (skin == null) {
			return;
		}
		if (Std.is(skin, IStateObserver)) {
			cast(skin, IStateObserver).stateContext = null;
		}
		this._backgroundSkinMeasurements.restore(skin);
		if (skin.parent == this) {
			// we need to restore these values so that they won't be lost the
			// next time that this skin is used for measurement
			this.removeChild(skin);
		}
	}

	private function layoutBackgroundSkin():Void {
		if (this._currentBackgroundSkin == null) {
			return;
		}
		this._currentBackgroundSkin.x = 0.0;
		this._currentBackgroundSkin.y = 0.0;

		// don't set the width or height explicitly unless necessary because if
		// our explicit dimensions are cleared later, the measurement may not be
		// accurate anymore
		if (this._currentBackgroundSkin.width != this.actualWidth) {
			this._currentBackgroundSkin.width = this.actualWidth;
		}
		if (this._currentBackgroundSkin.height != this.actualHeight) {
			this._currentBackgroundSkin.height = this.actualHeight;
		}
		if (Std.is(this._currentBackgroundSkin, IValidating)) {
			cast(this._currentBackgroundSkin, IValidating).validateNow();
		}
	}

	private function findUnrenderedData():Void {
		var depthOffset = this._currentBackgroundSkin != null ? 1 : 0;
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
				this.addChildAt(tab, i + depthOffset);
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
		var depthOffset = this._currentBackgroundSkin != null ? 1 : 0;
		for (item in this._unrenderedData) {
			var index = this.dataProvider.indexOf(item);
			var tab = this.createTab(item, index);
			this.activeTabs.push(tab);
			this.addChildAt(tab, index + depthOffset);
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
		if (tab.variant == null) {
			// if the factory set a variant already, don't use the default
			tab.variant = TabBar.CHILD_VARIANT_TAB;
		}
		this._currentItemState.data = item;
		this._currentItemState.index = index;
		this._currentItemState.selected = item == this.selectedItem;
		this._currentItemState.text = itemToText(item);
		var oldIgnoreSelectionChange = this._ignoreSelectionChange;
		this._ignoreSelectionChange = true;
		if (this.tabRecycler.update != null) {
			this.tabRecycler.update(tab, this._currentItemState);
		}
		tab.selected = this._currentItemState.selected;
		this._ignoreSelectionChange = oldIgnoreSelectionChange;
		tab.addEventListener(TriggerEvent.TRIGGER, tab_triggerHandler);
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

	private function navigateWithKeyboard(event:KeyboardEvent):Void {
		if (this.dataProvider == null || this.dataProvider.length == 0) {
			return;
		}
		var result = this.selectedIndex;
		switch (event.keyCode) {
			case Keyboard.UP:
				result = result - 1;
			case Keyboard.DOWN:
				result = result + 1;
			case Keyboard.LEFT:
				result = result - 1;
			case Keyboard.RIGHT:
				result = result + 1;
			case Keyboard.PAGE_UP:
				result = result - 1;
			case Keyboard.PAGE_DOWN:
				result = result + 1;
			case Keyboard.HOME:
				result = 0;
			case Keyboard.END:
				result = this.dataProvider.length - 1;
			default:
				// not keyboard navigation
				return;
		}
		if (result < 0) {
			result = 0;
		} else if (result >= this.dataProvider.length) {
			result = this.dataProvider.length - 1;
		}
		event.stopPropagation();
		this.selectedIndex = result;
	}

	private function tabBar_keyDownHandler(event:KeyboardEvent):Void {
		if (!this.enabled) {
			return;
		}
		this.navigateWithKeyboard(event);
	}

	private function tab_triggerHandler(event:TriggerEvent):Void {
		var tab = cast(event.currentTarget, ToggleButton);
		var item = this.tabToData.get(tab);
		// trigger before change
		this.dispatchEvent(event);
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
