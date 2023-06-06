/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.controls.dataRenderers.IDataRenderer;
import feathers.core.FeathersControl;
import feathers.core.IDataSelector;
import feathers.core.IFocusObject;
import feathers.core.IIndexSelector;
import feathers.core.IUIControl;
import feathers.core.IValidating;
import feathers.core.InvalidationFlag;
import feathers.data.IFlatCollection;
import feathers.data.TabBarItemState;
import feathers.events.FeathersEvent;
import feathers.events.FlatCollectionEvent;
import feathers.events.TabBarEvent;
import feathers.events.TriggerEvent;
import feathers.layout.ILayout;
import feathers.layout.ILayoutIndexObject;
import feathers.layout.LayoutBoundsResult;
import feathers.layout.Measurements;
import feathers.skins.IProgrammaticSkin;
import feathers.utils.AbstractDisplayObjectRecycler;
import feathers.utils.DisplayObjectRecycler;
import haxe.ds.ObjectMap;
import openfl.display.DisplayObject;
import openfl.errors.IllegalOperationError;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;
#if (openfl >= "9.1.0")
import openfl.utils.ObjectPool;
#else
import openfl._internal.utils.ObjectPool;
#end

/**
	A line of tabs, where one may be selected at a time.

	The following example sets the data provider, tells the tabs how to
	interpret the data, selects the second tab, and listens for when the
	selection changes:

	```haxe
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

	@event openfl.events.Event.CHANGE Dispatched when either
	`TabBar.selectedItem` or `TabBar.selectedIndex` changes.

	@event feathers.events.TabBarEvent.ITEM_TRIGGER Dispatched when the user
	taps or clicks a tab. The pointer must remain within the bounds of the tab
	on release, or the gesture will be ignored.

	@see [Tutorial: How to use the TabBar component](https://feathersui.com/learn/haxe-openfl/tab-bar/)
	@see `feathers.controls.navigators.TabNavigator`

	@since 1.0.0
**/
@:event(openfl.events.Event.CHANGE)
@:event(feathers.events.TabBarEvent.ITEM_TRIGGER)
@:access(feathers.data.TabBarItemState)
@defaultXmlProperty("dataProvider")
@:styleContext
class TabBar extends FeathersControl implements IIndexSelector implements IDataSelector<Dynamic> implements IFocusObject {
	private static final INVALIDATION_FLAG_TAB_FACTORY = InvalidationFlag.CUSTOM("tabFactory");

	/**
		The variant used to style the tab child components in a theme.

		To override this default variant, set the
		`TabBar.customTabVariant` property.

		@see `TabBar.customTabVariant`
		@see `feathers.style.IVariantStyleObject.variant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_TAB = "tabBar_tab";

	private static final RESET_TAB_STATE = new TabBarItemState();

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
	public function new(?dataProvider:IFlatCollection<Dynamic>, ?changeListener:(Event) -> Void) {
		initializeTabBarTheme();

		super();

		this.dataProvider = dataProvider;

		this.tabEnabled = true;
		this.tabChildren = false;

		this.addEventListener(KeyboardEvent.KEY_DOWN, tabBar_keyDownHandler);

		if (changeListener != null) {
			this.addEventListener(Event.CHANGE, changeListener);
		}
	}

	private var _dataProvider:IFlatCollection<Dynamic> = null;

	/**
		The collection of data displayed by the tab bar.

		Items in the collection must be class instances or anonymous structures.
		Do not add primitive values (such as strings, booleans, or numeric
		values) directly to the collection.

		Additionally, all items in the collection must be unique object
		instances. Do not add the same instance to the collection more than
		once because a runtime exception will be thrown.

		The following example passes in a data provider and tells the tabs how
		to interpret the data:

		```haxe
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
	public var dataProvider(get, set):IFlatCollection<Dynamic>;

	private function get_dataProvider():IFlatCollection<Dynamic> {
		return this._dataProvider;
	}

	private function set_dataProvider(value:IFlatCollection<Dynamic>):IFlatCollection<Dynamic> {
		if (this._dataProvider == value) {
			return this._dataProvider;
		}
		if (this._dataProvider != null) {
			this._dataProvider.removeEventListener(Event.CHANGE, tabBar_dataProvider_changeHandler);
			this._dataProvider.removeEventListener(FlatCollectionEvent.ADD_ITEM, tabBar_dataProvider_addItemHandler);
			this._dataProvider.removeEventListener(FlatCollectionEvent.REMOVE_ITEM, tabBar_dataProvider_removeItemHandler);
			this._dataProvider.removeEventListener(FlatCollectionEvent.REPLACE_ITEM, tabBar_dataProvider_replaceItemHandler);
			this._dataProvider.removeEventListener(FlatCollectionEvent.REMOVE_ALL, tabBar_dataProvider_removeAllHandler);
			this._dataProvider.removeEventListener(FlatCollectionEvent.RESET, tabBar_dataProvider_resetHandler);
			this._dataProvider.removeEventListener(FlatCollectionEvent.SORT_CHANGE, tabBar_dataProvider_sortChangeHandler);
			this._dataProvider.removeEventListener(FlatCollectionEvent.FILTER_CHANGE, tabBar_dataProvider_filterChangeHandler);
			this._dataProvider.removeEventListener(FlatCollectionEvent.UPDATE_ITEM, tabBar_dataProvider_updateItemHandler);
			this._dataProvider.removeEventListener(FlatCollectionEvent.UPDATE_ALL, tabBar_dataProvider_updateAllHandler);
		}
		var oldSelectedIndex = this._selectedIndex;
		var oldSelectedItem = this._selectedItem;
		this._dataProvider = value;
		if (this._dataProvider != null) {
			this._dataProvider.addEventListener(Event.CHANGE, tabBar_dataProvider_changeHandler);
			this._dataProvider.addEventListener(FlatCollectionEvent.ADD_ITEM, tabBar_dataProvider_addItemHandler);
			this._dataProvider.addEventListener(FlatCollectionEvent.REMOVE_ITEM, tabBar_dataProvider_removeItemHandler);
			this._dataProvider.addEventListener(FlatCollectionEvent.REPLACE_ITEM, tabBar_dataProvider_replaceItemHandler);
			this._dataProvider.addEventListener(FlatCollectionEvent.REMOVE_ALL, tabBar_dataProvider_removeAllHandler);
			this._dataProvider.addEventListener(FlatCollectionEvent.RESET, tabBar_dataProvider_resetHandler);
			this._dataProvider.addEventListener(FlatCollectionEvent.SORT_CHANGE, tabBar_dataProvider_sortChangeHandler);
			this._dataProvider.addEventListener(FlatCollectionEvent.FILTER_CHANGE, tabBar_dataProvider_filterChangeHandler);
			this._dataProvider.addEventListener(FlatCollectionEvent.UPDATE_ITEM, tabBar_dataProvider_updateItemHandler);
			this._dataProvider.addEventListener(FlatCollectionEvent.UPDATE_ALL, tabBar_dataProvider_updateAllHandler);
		}
		if (this._dataProvider == null || this._dataProvider.length == 0) {
			this._selectedIndex = -1;
			this._selectedItem = null;
		} else {
			this._selectedIndex = 0;
			this._selectedItem = this._dataProvider.get(0);
		}
		if (this._selectedIndex != oldSelectedIndex || this._selectedItem != oldSelectedItem) {
			this.setInvalid(SELECTION);
			FeathersEvent.dispatch(this, Event.CHANGE);
		}
		this.setInvalid(DATA);
		return this._dataProvider;
	}

	private var _selectedIndex:Int = -1;

	/**
		@see `feathers.core.IIndexSelector.selectedIndex`
	**/
	@:bindable("change")
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
		if (value == -1) {
			this._selectedIndex = -1;
			this._selectedItem = null;
			this.setInvalid(SELECTION);
			FeathersEvent.dispatch(this, Event.CHANGE);
			return this._selectedIndex;
		}
		this._selectedIndex = value;
		this._selectedItem = this._dataProvider.get(this._selectedIndex);
		this.setInvalid(SELECTION);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._selectedIndex;
	}

	/**
		@see `feathers.core.IIndexSelector.maxSelectedIndex`
	**/
	public var maxSelectedIndex(get, never):Int;

	private function get_maxSelectedIndex():Int {
		if (this._dataProvider == null) {
			return -1;
		}
		return this._dataProvider.length - 1;
	}

	private var _selectedItem:Dynamic = null;

	/**
		@see `feathers.core.IDataSelector.selectedItem`
	**/
	@:bindable("change")
	public var selectedItem(get, set):Dynamic;

	private function get_selectedItem():Dynamic {
		return this._selectedItem;
	}

	private function set_selectedItem(value:Dynamic):Dynamic {
		if (value == null || this._dataProvider == null) {
			// use the setter
			this.selectedIndex = -1;
			return this._selectedItem;
		}
		var index = this._dataProvider.indexOf(value);
		if (index == -1) {
			// use the setter
			this.selectedIndex = -1;
			return this._selectedItem;
		}
		if (this._selectedItem == value && this._selectedIndex == index) {
			return this._selectedItem;
		}
		this._selectedIndex = index;
		this._selectedItem = value;
		this.setInvalid(SELECTION);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._selectedItem;
	}

	private var _previousCustomTabVariant:String = null;

	/**
		A custom variant to set on all tabs, instead of
		`TabBar.CHILD_VARIANT_TAB`.

		The `customTabVariant` will be not be used if the result of
		`tabRecycler.create()` already has a variant set.

		@see `TabBar.CHILD_VARIANT_TAB`
		@see `feathers.style.IVariantStyleObject.variant`

		@since 1.0.0
	**/
	@:style
	public var customTabVariant:String = null;

	/**
		Manages tabs used by the tab bar.

		In the following example, the tab bar uses a custom tab renderer class:

		```haxe
		tabBar.tabRecycler = DisplayObjectRecycler.withClass(ToggleButton);
		```

		@since 1.0.0
	**/
	public var tabRecycler(get, set):AbstractDisplayObjectRecycler<Dynamic, TabBarItemState, ToggleButton>;

	private function get_tabRecycler():AbstractDisplayObjectRecycler<Dynamic, TabBarItemState, ToggleButton> {
		return this._defaultStorage.tabRecycler;
	}

	private function set_tabRecycler(value:AbstractDisplayObjectRecycler<Dynamic, TabBarItemState, ToggleButton>):AbstractDisplayObjectRecycler<Dynamic,
		TabBarItemState, ToggleButton> {
		if (this._defaultStorage.tabRecycler == value) {
			return this._defaultStorage.tabRecycler;
		}
		this._defaultStorage.oldTabRecycler = this._defaultStorage.tabRecycler;
		this._defaultStorage.tabRecycler = value;
		this.setInvalid(INVALIDATION_FLAG_TAB_FACTORY);
		return this._defaultStorage.tabRecycler;
	}

	private var _forceItemStateUpdate:Bool = false;

	/**
		Forces the `tabRecycler.update()` method to be called with the
		`TabBarItemState` when the tab bar validates, even if the item's
		state has not changed since the previous validation.

		Before Feathers UI 1.2, `update()` was called more frequently, and this
		property is provided to enable backwards compatibility, temporarily, to
		assist in migration from earlier versions of Feathers UI.

		In general, when this property needs to be enabled, its often because of
		a missed call to `dataProvider.updateAt()` (preferred) or
		`dataProvider.updateAll()` (less common).

		The `forceItemStateUpdate` property may be removed in a future major
		version, so it is best to avoid relying on it as a long-term solution.

		@since 1.2.0
	**/
	public var forceItemStateUpdate(get, set):Bool;

	private function get_forceItemStateUpdate():Bool {
		return this._forceItemStateUpdate;
	}

	private function set_forceItemStateUpdate(value:Bool):Bool {
		if (this._forceItemStateUpdate == value) {
			return this._forceItemStateUpdate;
		}
		this._forceItemStateUpdate = value;
		this.setInvalid(DATA);
		return this._forceItemStateUpdate;
	}

	private var _recyclerMap:Map<String, DisplayObjectRecycler<Dynamic, TabBarItemState, ToggleButton>> = null;

	private var _tabRecyclerIDFunction:(state:TabBarItemState) -> String;

	/**
		When a tab bar requires multiple tab styles, this function is used to
		determine which style of tab is required for a specific item. Returns
		the ID of the tab recycler to use for the item, or `null` if the default
		`tabRecycler` should be used.

		The following example provides an `tabRecyclerIDFunction`:

		```haxe
		var regularTabRecycler = DisplayObjectRecycler.withClass(ToggleButton);
		var firstTabRecycler = DisplayObjectRecycler.withClass(MyCustomToggleButton);

		tabBar.setTabRecycler("regular-tab", regularTabRecycler);
		tabBar.setTabRecycler("first-tab", firstTabRecycler);

		tabBar.tabRecyclerIDFunction = function(state:TabBarItemState):String {
			if(state.index == 0) {
				return "first-tab";
			}
			return "regular-tab";
		};
		```

		@default null

		@see `TabBar.setTabRecycler()`
		@see `TabBar.tabRecycler

		@since 1.0.0
	**/
	public var tabRecyclerIDFunction(get, set):(state:TabBarItemState) -> String;

	private function get_tabRecyclerIDFunction():(state:TabBarItemState) -> String {
		return this._tabRecyclerIDFunction;
	}

	private function set_tabRecyclerIDFunction(value:(state:TabBarItemState) -> String):(state:TabBarItemState) -> String {
		if (this._tabRecyclerIDFunction == value) {
			return this._tabRecyclerIDFunction;
		}
		this._tabRecyclerIDFunction = value;
		this.setInvalid(INVALIDATION_FLAG_TAB_FACTORY);
		return this._tabRecyclerIDFunction;
	}

	private var _defaultStorage:TabStorage = new TabStorage(null, DisplayObjectRecycler.withClass(ToggleButton));
	private var _additionalStorage:Array<TabStorage> = null;
	private var dataToTab = new ObjectMap<Dynamic, ToggleButton>();
	private var tabToItemState = new ObjectMap<ToggleButton, TabBarItemState>();
	private var itemStatePool = new ObjectPool(() -> new TabBarItemState());
	private var _unrenderedData:Array<Dynamic> = [];
	private var _layoutItems:Array<DisplayObject> = [];

	private var _ignoreSelectionChange = false;

	/**
		Converts an item to text to display within tab bar. By default, the
		`toString()` method is called to convert an item to text. This method
		may be replaced to provide custom text.

		For example, consider the following item:

		```haxe
		{ text: "Example Item" }
		```

		If the `TabBar` should display the text "Example Item", a custom
		implementation of `itemToText()` might look like this:

		```haxe
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
		Determines if a tab should be enabled or disabled. By default, all
		items are enabled, unless the `TabBar` is disabled. This method
		may be replaced to provide a custom value for `enabled`.

		For example, consider the following item:

		```haxe
		{ text: "Example Item", disable: true }
		```

		If the `TabBar` should disable an item if the `disable` field is
		`true`, a custom implementation of `itemToEnabled()` might look like
		this:

		```haxe
		tabBar.itemToEnabled = (item:Dynamic) -> {
			return !item.disable;
		};
		```

		@since 1.2.0
	**/
	public dynamic function itemToEnabled(data:Dynamic):Bool {
		return true;
	}

	/**
		The layout algorithm used to position and size the tabs.

		By default, if no layout is provided by the time that the tab bar
		initializes, a default layout that displays items horizontally will be
		created.

		The following example tells the tab bar to use a custom layout:

		```haxe
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

		```haxe
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

		```haxe
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

	/**
		Returns the current tab used to render a specific item from the data
		provider. May return `null` if an item doesn't currently have a tab.

		@since 1.0.0
	**/
	public function itemToTab(item:Dynamic):ToggleButton {
		if (item == null) {
			return null;
		}
		return this.dataToTab.get(item);
	}

	/**
		Returns the current tab used to render the item at the specified index
		in the data provider. May return `null` if an item doesn't currently
		have a tab.

		@since 1.0.0
	**/
	public function indexToTab(index:Int):ToggleButton {
		if (this._dataProvider == null || index < 0 || index >= this._dataProvider.length) {
			return null;
		}
		var item = this._dataProvider.get(index);
		return this.dataToTab.get(item);
	}

	/**
		Returns the tab recycler associated with a specific ID. Returns `null`
		if no recycler is associated with the ID.

		@see `TabBar.tabRecyclerIDFunction`
		@see `TabBar.setTabRecycler()`

		@since 1.0.0
	**/
	public function getTabRecycler(id:String):DisplayObjectRecycler<Dynamic, TabBarItemState, ToggleButton> {
		if (this._recyclerMap == null) {
			return null;
		}
		return this._recyclerMap.get(id);
	}

	/**
		Associates an tab recycler with an ID to allow multiple types
		of tabs to be displayed in the tab bar. A custom `tabRecyclerIDFunction`
		may be specified to return the ID of the recycler to use for a specific
		item in the data provider.

		To clear a recycler, pass in `null` as the value.

		@see `TabBar.tabRecyclerIDFunction`
		@see `TabBar.getTabRecycler()`

		@since 1.0.0
	**/
	public function setTabRecycler(id:String, recycler:AbstractDisplayObjectRecycler<Dynamic, TabBarItemState, ToggleButton>):Void {
		if (this._recyclerMap == null) {
			this._recyclerMap = [];
		}
		if (recycler == null) {
			this._recyclerMap.remove(id);
			return;
		}
		this._recyclerMap.set(id, recycler);
		this.setInvalid(INVALIDATION_FLAG_TAB_FACTORY);
	}

	override public function dispose():Void {
		this.refreshInactiveTabs(this._defaultStorage, true);
		if (this._additionalStorage != null) {
			for (i in 0...this._additionalStorage.length) {
				var storage = this._additionalStorage[i];
				this.refreshInactiveTabs(storage, true);
			}
		}
		this.dataProvider = null;
		super.dispose();
	}

	private function initializeTabBarTheme():Void {
		#if !feathersui_disable_default_theme
		feathers.themes.steel.components.SteelTabBarStyles.initialize();
		#end
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(DATA);
		var layoutInvalid = this.isInvalid(LAYOUT);
		var selectionInvalid = this.isInvalid(SELECTION);
		var stateInvalid = this.isInvalid(STATE);
		var stylesInvalid = this.isInvalid(STYLES);
		if (this._previousCustomTabVariant != this.customTabVariant) {
			this.setInvalidationFlag(INVALIDATION_FLAG_TAB_FACTORY);
		}
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

		this._previousCustomTabVariant = this.customTabVariant;
	}

	private function refreshViewPortBounds():Void {
		this._layoutMeasurements.save(this);
	}

	private function handleLayout():Void {
		var oldIgnoreChildChanges = this._ignoreChildChanges;
		this._ignoreChildChanges = true;
		this._layoutResult.reset();
		if (this.layout != null) {
			this.layout.layout(this._layoutItems, this._layoutMeasurements, this._layoutResult);
		}
		this._ignoreChildChanges = oldIgnoreChildChanges;
	}

	private function handleLayoutResult():Void {
		var viewPortWidth = this._layoutResult.viewPortWidth;
		var viewPortHeight = this._layoutResult.viewPortHeight;
		this.saveMeasurements(viewPortWidth, viewPortHeight, viewPortWidth, viewPortHeight);
	}

	private function validateChildren():Void {
		for (tab in this._layoutItems) {
			if (!(tab is IValidating)) {
				return;
			}
			cast(tab, IValidating).validateNow();
		}
	}

	private function refreshTabs():Void {
		if (this.tabRecycler.update == null) {
			this.tabRecycler.update = defaultUpdateTab;
			if (this.tabRecycler.reset == null) {
				this.tabRecycler.reset = defaultResetTab;
			}
		}
		if (this._recyclerMap != null) {
			for (recycler in this._recyclerMap) {
				if (recycler.update == null) {
					if (recycler.update == null) {
						recycler.update = defaultUpdateTab;
						// don't replace reset if we didn't replace update too
						if (recycler.reset == null) {
							recycler.reset = defaultResetTab;
						}
					}
				}
			}
		}

		var tabsInvalid = this.isInvalid(INVALIDATION_FLAG_TAB_FACTORY);
		this.refreshInactiveTabs(this._defaultStorage, tabsInvalid);
		if (this._additionalStorage != null) {
			for (i in 0...this._additionalStorage.length) {
				var storage = this._additionalStorage[i];
				this.refreshInactiveTabs(storage, tabsInvalid);
			}
		}
		this.findUnrenderedData();
		this.recoverInactiveTabs(this._defaultStorage);
		if (this._additionalStorage != null) {
			for (i in 0...this._additionalStorage.length) {
				var storage = this._additionalStorage[i];
				this.recoverInactiveTabs(storage);
			}
		}
		this.renderUnrenderedData();
		this.freeInactiveTabs(this._defaultStorage);
		if (this._defaultStorage.inactiveTabs.length > 0) {
			throw new IllegalOperationError('${Type.getClassName(Type.getClass(this))}: inactive tabs should be empty after updating.');
		}
		if (this._additionalStorage != null) {
			for (i in 0...this._additionalStorage.length) {
				var storage = this._additionalStorage[i];
				this.freeInactiveTabs(storage);
				if (storage.inactiveTabs.length > 0) {
					throw new IllegalOperationError('${Type.getClassName(Type.getClass(this))}: inactive tabs ${storage.id} should be empty after updating.');
				}
			}
		}
	}

	private function refreshInactiveTabs(storage:TabStorage, factoryInvalid:Bool):Void {
		var temp = storage.inactiveTabs;
		storage.inactiveTabs = storage.activeTabs;
		storage.activeTabs = temp;
		if (storage.activeTabs.length > 0) {
			throw new IllegalOperationError('${Type.getClassName(Type.getClass(this))}: active tabs should be empty before updating.');
		}
		if (factoryInvalid) {
			this.recoverInactiveTabs(storage);
			this.freeInactiveTabs(storage);
		}
	}

	private function recoverInactiveTabs(storage:TabStorage):Void {
		for (tab in storage.inactiveTabs) {
			if (tab == null) {
				continue;
			}
			var state = this.tabToItemState.get(tab);
			if (state == null) {
				continue;
			}
			var item = state.data;
			this.tabToItemState.remove(tab);
			this.dataToTab.remove(item);
			tab.removeEventListener(TriggerEvent.TRIGGER, tabBar_tab_triggerHandler);
			tab.removeEventListener(Event.CHANGE, tabBar_tab_changeHandler);
			this.resetTab(tab, state);
			this.itemStatePool.release(state);
		}
	}

	private function freeInactiveTabs(storage:TabStorage):Void {
		for (tab in storage.inactiveTabs) {
			if (tab == null) {
				continue;
			}
			this.destroyTab(tab);
		}
		#if hl
		storage.inactiveTabs.splice(0, storage.inactiveTabs.length);
		#else
		storage.inactiveTabs.resize(0);
		#end
	}

	private function refreshBackgroundSkin():Void {
		var oldSkin = this._currentBackgroundSkin;
		this._currentBackgroundSkin = this.getCurrentBackgroundSkin();
		if (this._currentBackgroundSkin == oldSkin) {
			return;
		}
		this.removeCurrentBackgroundSkin(oldSkin);
		this.addCurrentBackgroundSkin(this._currentBackgroundSkin);
	}

	private function getCurrentBackgroundSkin():DisplayObject {
		if (!this._enabled && this.disabledBackgroundSkin != null) {
			return this.disabledBackgroundSkin;
		}
		return this.backgroundSkin;
	}

	private function addCurrentBackgroundSkin(skin:DisplayObject):Void {
		if (skin == null) {
			this._backgroundSkinMeasurements = null;
			return;
		}
		if ((skin is IUIControl)) {
			cast(skin, IUIControl).initializeNow();
		}
		if (this._backgroundSkinMeasurements == null) {
			this._backgroundSkinMeasurements = new Measurements(skin);
		} else {
			this._backgroundSkinMeasurements.save(skin);
		}
		if ((skin is IProgrammaticSkin)) {
			cast(skin, IProgrammaticSkin).uiContext = this;
		}
		this.addChildAt(skin, 0);
	}

	private function removeCurrentBackgroundSkin(skin:DisplayObject):Void {
		if (skin == null) {
			return;
		}
		if ((skin is IProgrammaticSkin)) {
			cast(skin, IProgrammaticSkin).uiContext = null;
		}
		// we need to restore these values so that they won't be lost the
		// next time that this skin is used for measurement
		this._backgroundSkinMeasurements.restore(skin);
		if (skin.parent == this) {
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
		if ((this._currentBackgroundSkin is IValidating)) {
			cast(this._currentBackgroundSkin, IValidating).validateNow();
		}
	}

	private function findUnrenderedData():Void {
		// remove all old items, then fill with null
		#if hl
		this._layoutItems.splice(0, this._layoutItems.length);
		#else
		this._layoutItems.resize(0);
		#end
		if (this._dataProvider == null || this._dataProvider.length == 0) {
			return;
		}
		this._layoutItems.resize(this._dataProvider.length);

		var depthOffset = this._currentBackgroundSkin != null ? 1 : 0;
		for (i in 0...this._dataProvider.length) {
			var item = this._dataProvider.get(i);
			var tab = this.dataToTab.get(item);
			if (tab != null) {
				var state = this.tabToItemState.get(tab);
				var changed = this.populateCurrentItemState(item, i, state, this._forceItemStateUpdate);
				var oldRecyclerID = state.recyclerID;
				var storage = this.itemStateToStorage(state);
				if (storage.id != oldRecyclerID) {
					this._unrenderedData.push(item);
					continue;
				}
				if (changed) {
					this.updateTab(tab, state, storage);
				}
				this._layoutItems[i] = tab;
				this.setChildIndex(tab, i + depthOffset);
				var removed = storage.inactiveTabs.remove(tab);
				if (!removed) {
					throw new IllegalOperationError('${Type.getClassName(Type.getClass(this))}: tab renderer map contains bad data for item at index ${i}. This may be caused by duplicate items in the data provider, which is not allowed.');
				}
				storage.activeTabs.push(tab);
			} else {
				this._unrenderedData.push(item);
			}
		}
	}

	private function renderUnrenderedData():Void {
		var depthOffset = this._currentBackgroundSkin != null ? 1 : 0;
		for (item in this._unrenderedData) {
			var index = this._dataProvider.indexOf(item);
			var state = this.itemStatePool.get();
			this.populateCurrentItemState(item, index, state, true);
			var tab = this.createTab(state);
			this.addChildAt(tab, index + depthOffset);
			this._layoutItems[index] = tab;
		}
		#if hl
		this._unrenderedData.splice(0, this._unrenderedData.length);
		#else
		this._unrenderedData.resize(0);
		#end
	}

	private function createTab(state:TabBarItemState):ToggleButton {
		var storage = this.itemStateToStorage(state);
		var tab:ToggleButton = null;
		if (storage.inactiveTabs.length == 0) {
			tab = this.tabRecycler.create();
			if (tab.variant == null) {
				// if the factory set a variant already, don't use the default
				var variant = this.customTabVariant != null ? this.customTabVariant : TabBar.CHILD_VARIANT_TAB;
				tab.variant = variant;
			}
			// for consistency, initialize before passing to the recycler's
			// update function
			tab.initializeNow();
		} else {
			tab = storage.inactiveTabs.shift();
		}
		this.updateTab(tab, state, storage);
		tab.addEventListener(TriggerEvent.TRIGGER, tabBar_tab_triggerHandler);
		tab.addEventListener(Event.CHANGE, tabBar_tab_changeHandler);
		this.tabToItemState.set(tab, state);
		this.dataToTab.set(state.data, tab);
		storage.activeTabs.push(tab);
		return tab;
	}

	private function destroyTab(tab:ToggleButton):Void {
		this.removeChild(tab);
		if (this.tabRecycler.destroy != null) {
			this.tabRecycler.destroy(tab);
		}
		tab.dispose();
	}

	private function itemStateToStorage(state:TabBarItemState):TabStorage {
		var recyclerID:String = null;
		if (this._tabRecyclerIDFunction != null) {
			recyclerID = this._tabRecyclerIDFunction(state);
		}
		var recycler:DisplayObjectRecycler<Dynamic, TabBarItemState, ToggleButton> = null;
		if (recyclerID != null) {
			if (this._recyclerMap != null) {
				recycler = this._recyclerMap.get(recyclerID);
			}
			if (recycler == null) {
				throw new IllegalOperationError('Item renderer recycler ID "${recyclerID}" is not registered.');
			}
		}
		if (recycler == null) {
			return this._defaultStorage;
		}
		if (this._additionalStorage == null) {
			this._additionalStorage = [];
		}
		for (i in 0...this._additionalStorage.length) {
			var storage = this._additionalStorage[i];
			if (storage.tabRecycler == recycler) {
				return storage;
			}
		}
		var storage = new TabStorage(recyclerID, recycler);
		this._additionalStorage.push(storage);
		return storage;
	}

	private function populateCurrentItemState(item:Dynamic, index:Int, state:TabBarItemState, force:Bool):Bool {
		var changed = false;
		if (force || state.owner != this) {
			state.owner = this;
			changed = true;
		}
		if (force || state.data != item) {
			state.data = item;
			changed = true;
		}
		if (force || state.index != index) {
			state.index = index;
			changed = true;
		}
		var selected = item == this._selectedItem;
		if (force || state.selected != selected) {
			state.selected = selected;
			changed = true;
		}
		var enabled = this._enabled && itemToEnabled(item);
		if (force || state.enabled != enabled) {
			state.enabled = enabled;
			changed = true;
		}
		var text = itemToText(item);
		if (force || state.text != text) {
			state.text = text;
			changed = true;
		}
		return changed;
	}

	private function updateTab(tab:ToggleButton, state:TabBarItemState, storage:TabStorage):Void {
		state.recyclerID = storage.id;
		var oldIgnoreSelectionChange = this._ignoreSelectionChange;
		this._ignoreSelectionChange = true;
		if (this.tabRecycler.update != null) {
			this.tabRecycler.update(tab, state);
		}
		this._ignoreSelectionChange = oldIgnoreSelectionChange;
		this.refreshTabProperties(tab, state);
	}

	private function resetTab(tab:ToggleButton, state:TabBarItemState):Void {
		var oldIgnoreSelectionChange = this._ignoreSelectionChange;
		this._ignoreSelectionChange = true;
		if (this.tabRecycler != null && this.tabRecycler.reset != null) {
			this.tabRecycler.reset(tab, state);
		}
		this._ignoreSelectionChange = oldIgnoreSelectionChange;
		this.refreshTabProperties(tab, RESET_TAB_STATE);
	}

	private function refreshTabProperties(tab:ToggleButton, state:TabBarItemState):Void {
		var oldIgnoreSelectionChange = this._ignoreSelectionChange;
		this._ignoreSelectionChange = true;
		if ((tab is IUIControl)) {
			var uiControl = cast(tab, IUIControl);
			uiControl.enabled = state.enabled;
		}
		if ((tab is IDataRenderer)) {
			var dataRenderer = cast(tab, IDataRenderer);
			// if the tab is an IDataRenderer, this cannot be overridden
			dataRenderer.data = state.data;
		}
		if ((tab is ILayoutIndexObject)) {
			var layoutObject = cast(tab, ILayoutIndexObject);
			layoutObject.layoutIndex = state.index;
		}
		tab.selected = state.selected;
		tab.enabled = state.enabled;
		this._ignoreSelectionChange = oldIgnoreSelectionChange;
	}

	private function refreshSelectedIndicesAfterFilterOrSort():Void {
		if (this._selectedIndex == -1) {
			return;
		}
		// the index may have changed, possibly even to -1, if the item was
		// filtered out
		this.selectedIndex = this._dataProvider.indexOf(this._selectedItem); // use the setter
	}

	private function navigateWithKeyboard(event:KeyboardEvent):Void {
		if (event.isDefaultPrevented()) {
			return;
		}
		if (this._dataProvider == null || this._dataProvider.length == 0) {
			return;
		}
		var result = this._selectedIndex;
		switch (event.keyCode) {
			case Keyboard.UP:
				if (event.keyLocation == 4 /* KeyLocation.D_PAD */) {
					return;
				}
				result = result - 1;
			case Keyboard.DOWN:
				if (event.keyLocation == 4 /* KeyLocation.D_PAD */) {
					return;
				}
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
				result = this._dataProvider.length - 1;
			default:
				// not keyboard navigation
				return;
		}
		if (result < 0) {
			result = 0;
		} else if (result >= this._dataProvider.length) {
			result = this._dataProvider.length - 1;
		}
		event.preventDefault();
		// use the setter
		this.selectedIndex = result;
	}

	private function tabBar_keyDownHandler(event:KeyboardEvent):Void {
		if (!this._enabled) {
			return;
		}
		this.navigateWithKeyboard(event);
	}

	private function tabBar_tab_triggerHandler(event:TriggerEvent):Void {
		var tab = cast(event.currentTarget, ToggleButton);
		var state = this.tabToItemState.get(tab);
		TabBarEvent.dispatch(this, TabBarEvent.ITEM_TRIGGER, state);
	}

	private function tabBar_tab_changeHandler(event:Event):Void {
		if (this._ignoreSelectionChange) {
			return;
		}
		var tab = cast(event.currentTarget, ToggleButton);
		if (!tab.selected) {
			// no toggle off!
			tab.selected = true;
			return;
		}
		var state = this.tabToItemState.get(tab);
		// use the setter
		this.selectedItem = state.data;
	}

	private function tabBar_dataProvider_changeHandler(event:Event):Void {
		this.setInvalid(DATA);
	}

	private function tabBar_dataProvider_addItemHandler(event:FlatCollectionEvent):Void {
		if (this._selectedIndex == -1) {
			return;
		}
		if (this._selectedIndex >= event.index) {
			this._selectedIndex++;
			FeathersEvent.dispatch(this, Event.CHANGE);
		}
	}

	private function tabBar_dataProvider_removeItemHandler(event:FlatCollectionEvent):Void {
		if (this._selectedIndex == -1) {
			return;
		}
		if (this._selectedIndex == event.index) {
			if (event.index == this._dataProvider.length) {
				// keep the same selected index, unless the last item was removed
				this._selectedIndex = this._dataProvider.length - 1;
			}
			if (this._selectedIndex == -1) {
				this._selectedItem = null;
			} else {
				this._selectedItem = this._dataProvider.get(this._selectedIndex);
			}
			FeathersEvent.dispatch(this, Event.CHANGE);
		} else if (this._selectedIndex > event.index) {
			this._selectedIndex--;
			// the selected item will be the same. only its index changed.
			FeathersEvent.dispatch(this, Event.CHANGE);
		}
	}

	private function tabBar_dataProvider_replaceItemHandler(event:FlatCollectionEvent):Void {
		if (this._selectedIndex == -1) {
			return;
		}
		if (this._selectedIndex == event.index) {
			this._selectedItem = this._dataProvider.get(this._selectedIndex);
			FeathersEvent.dispatch(this, Event.CHANGE);
		}
	}

	private function tabBar_dataProvider_removeAllHandler(event:FlatCollectionEvent):Void {
		// use the setter
		this.selectedIndex = -1;
	}

	private function tabBar_dataProvider_resetHandler(event:FlatCollectionEvent):Void {
		// use the setter
		this.selectedIndex = -1;
	}

	private function tabBar_dataProvider_sortChangeHandler(event:FlatCollectionEvent):Void {
		this.refreshSelectedIndicesAfterFilterOrSort();
	}

	private function tabBar_dataProvider_filterChangeHandler(event:FlatCollectionEvent):Void {
		this.refreshSelectedIndicesAfterFilterOrSort();
	}

	private function updateTabForIndex(index:Int):Void {
		var item = this._dataProvider.get(index);
		var tab = this.dataToTab.get(item);
		if (tab == null) {
			// doesn't exist yet, so we need to do a full invalidation
			this.setInvalid(DATA);
			return;
		}
		var state = this.tabToItemState.get(tab);
		if (state.owner == null) {
			// a previous update is already pending
			return;
		}
		var storage = this.itemStateToStorage(state);
		this.populateCurrentItemState(item, index, state, true);
		// in order to display the same item with modified properties, this
		// hack tricks the item renderer into thinking that it has been given
		// a different item to render.
		this.resetTab(tab, state);
		// ensures that the change is detected when we validate later
		state.owner = null;
		this.setInvalid(DATA);
	}

	private function tabBar_dataProvider_updateItemHandler(event:FlatCollectionEvent):Void {
		this.updateTabForIndex(event.index);
	}

	private function tabBar_dataProvider_updateAllHandler(event:FlatCollectionEvent):Void {
		for (i in 0...this._dataProvider.length) {
			this.updateTabForIndex(i);
		}
	}
}

private class TabStorage {
	public function new(?id:String, ?recycler:DisplayObjectRecycler<Dynamic, TabBarItemState, ToggleButton>) {
		this.id = id;
		this.tabRecycler = recycler;
	}

	public var id:String;
	public var oldTabRecycler:DisplayObjectRecycler<Dynamic, TabBarItemState, ToggleButton>;
	public var tabRecycler:DisplayObjectRecycler<Dynamic, TabBarItemState, ToggleButton>;
	public var activeTabs:Array<ToggleButton> = [];
	public var inactiveTabs:Array<ToggleButton> = [];
}
