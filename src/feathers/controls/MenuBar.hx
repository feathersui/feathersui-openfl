/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.controls.dataRenderers.IDataRenderer;
import feathers.core.FeathersControl;
import feathers.core.IDataSelector;
import feathers.core.IFocusObject;
import feathers.core.IIndexSelector;
import feathers.core.ITextControl;
import feathers.core.IUIControl;
import feathers.core.IValidating;
import feathers.core.InvalidationFlag;
import feathers.data.ArrayHierarchicalCollection;
import feathers.data.HierarchicalSubCollection;
import feathers.data.IHierarchicalCollection;
import feathers.data.MenuItemState;
import feathers.events.FeathersEvent;
import feathers.events.HierarchicalCollectionEvent;
import feathers.events.MenuEvent;
import feathers.layout.ILayout;
import feathers.layout.ILayoutIndexObject;
import feathers.layout.LayoutBoundsResult;
import feathers.layout.Measurements;
import feathers.skins.IProgrammaticSkin;
import feathers.style.IVariantStyleObject;
import feathers.utils.AbstractDisplayObjectFactory;
import feathers.utils.AbstractDisplayObjectRecycler;
import feathers.utils.DisplayObjectFactory;
import feathers.utils.DisplayObjectRecycler;
import feathers.utils.MeasurementsUtil;
import haxe.ds.ObjectMap;
import haxe.ds.StringMap;
import openfl.display.DisplayObject;
import openfl.errors.IllegalOperationError;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.ui.Keyboard;
#if (openfl >= "9.1.0")
import openfl.utils.ObjectPool;
#else
import openfl._internal.utils.ObjectPool;
#end
#if lime
import lime.ui.KeyCode;
#end

/**
	A menu bar.

	The following example sets the data provider, tells the item renderers how
	to interpret the data, and listens for when an item renderer is triggered:

	```haxe
	var menuBar = new MenuBar();
	menuBar.dataProvider = new ArrayHierarchicalCollection<MenuItemData>([
		{
			text: "File",
			children: [
				{ text: "New" },
				{ text: "Open" },
				{ separator: true },
				{ text: "Save" },
				{ text: "Quit" }
			]
		},
		{
			text: "Help",
			children: [
				{ text: "Contents" },
				{ text: "About" }
			]
		}
	], (item:MenuItemData) -> item.children);

	menuBar.itemToText = (item:MenuItemData) -> {
		return item.text;
	};

	menuBar.itemToSeparator = (item:MenuItemData) -> {
		return item.separator != null && item.separator == true;
	};

	menuBar.addEventListener(MenuEvent.ITEM_TRIGGER, menuBar_itemTriggerHandler);

	this.addChild(menuBar);
	```

	The example above uses the following custom [Haxe typedef](https://haxe.org/manual/type-system-typedef.html).

	```haxe
	typedef MenuItemData = {
		?text:String,
		?children:Array<MenuItemData>,
		?separator:Bool
	}
	```

	@event feathers.events.MenuEvent.ITEM_TRIGGER Dispatched when the user
	taps or clicks a menu item renderer. The pointer must remain within the
	bounds of the item renderer on release, or the gesture will be ignored.

	@event feathers.events.MenuEvent.MENU_OPEN Dispatched when a menu opens.

	@event feathers.events.MenuEvent.MENU_CLOSE Dispatched when a menu closes.

	@see [Tutorial: How to use the MenuBar component](https://feathersui.com/learn/haxe-openfl/menu-bar/)
	@see feathers.controls.Menu

	@since 1.4.0
**/
@:event(feathers.events.MenuEvent.ITEM_TRIGGER)
@:event(feathers.events.MenuEvent.MENU_OPEN)
@:event(feathers.events.MenuEvent.MENU_CLOSE)
@:access(feathers.data.MenuItemState)
@defaultXmlProperty("dataProvider")
@:styleContext
class MenuBar extends FeathersControl implements IDataSelector<Dynamic> implements IIndexSelector implements IFocusObject {
	private static final INVALIDATION_FLAG_ITEM_RENDERER_FACTORY = InvalidationFlag.CUSTOM("itemRendererFactory");
	private static final INVALIDATION_FLAG_MENU_FACTORY = InvalidationFlag.CUSTOM("menuFactory");

	/**
		The variant used to style the item renderer child components in a theme.

		To override this default variant, set the
		`MenuBar.customItemRendererVariant` property.

		@see `MenuBar.customItemRendererVariant`
		@see `feathers.style.IVariantStyleObject.variant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.4.0
	**/
	public static final CHILD_VARIANT_ITEM_RENDERER = "menuBar_itemRenderer";

	private static final defaultMenuFactory = DisplayObjectFactory.withClass(Menu);

	private static final RESET_ITEM_RENDERER_STATE = new MenuItemState();

	private static function defaultItemToText(data:Dynamic):String {
		return Std.string(data);
	}

	private static function defaultItemToSeparator(data:Dynamic):Bool {
		return false;
	}

	private static function defaultItemToEnabled(data:Dynamic):Bool {
		return true;
	}

	private static function defaultUpdateItemRenderer(itemRenderer:DisplayObject, state:MenuItemState):Void {
		if ((itemRenderer is ITextControl)) {
			var textControl:ITextControl = cast itemRenderer;
			textControl.text = state.text;
		}
	}

	private static function defaultResetItemRenderer(itemRenderer:DisplayObject, state:MenuItemState):Void {
		if ((itemRenderer is ITextControl)) {
			var textControl:ITextControl = cast itemRenderer;
			textControl.text = null;
		}
	}

	/**
		Creates a new `MenuBar` object.

		@since 1.4.0
	**/
	public function new(?dataProvider:IHierarchicalCollection<Dynamic>, ?itemTriggerListener:(MenuEvent) -> Void) {
		initializeMenuBarTheme();

		super();

		this.dataProvider = dataProvider;

		if (itemTriggerListener != null) {
			this.addEventListener(MenuEvent.ITEM_TRIGGER, itemTriggerListener);
		}
	}

	private var _dataProvider:IHierarchicalCollection<Dynamic>;

	/**
		The collection of data displayed by the menu bar.

		Items in the collection must be class instances or anonymous structures.
		Do not add primitive values (such as strings, booleans, or numeric
		values) directly to the collection.

		Additionally, all items in the collection must be unique object
		instances. Do not add the same instance to the collection more than
		once because a runtime exception will be thrown.

		The following example passes in a data provider and tells the item
		renderers how to interpret the data:

		```haxe
		menuBar.dataProvider = new ArrayHierarchicalCollection([
			{ text: "Latest Posts" },
			{ text: "Profile" },
			{ text: "Settings" }
		]);

		menuBar.itemToText = (item:Dynamic) -> {
			return item.text;
		};
		```

		@default null

		@see `feathers.data.ArrayCollection`

		@since 1.4.0
	**/
	@:bindable("dataChange")
	public var dataProvider(get, set):IHierarchicalCollection<Dynamic>;

	private function get_dataProvider():IHierarchicalCollection<Dynamic> {
		return this._dataProvider;
	}

	private function set_dataProvider(value:IHierarchicalCollection<Dynamic>):IHierarchicalCollection<Dynamic> {
		if (this._dataProvider == value) {
			return this._dataProvider;
		}
		if (this._dataProvider != null) {
			this._dataProvider.removeEventListener(Event.CHANGE, menuBar_dataProvider_changeHandler);
			this._dataProvider.removeEventListener(HierarchicalCollectionEvent.UPDATE_ITEM, menuBar_dataProvider_updateItemHandler);
			this._dataProvider.removeEventListener(HierarchicalCollectionEvent.UPDATE_ALL, menuBar_dataProvider_updateAllHandler);
		}
		this._dataProvider = value;
		if (this._dataProvider != null) {
			this._dataProvider.addEventListener(Event.CHANGE, menuBar_dataProvider_changeHandler);
			this._dataProvider.addEventListener(HierarchicalCollectionEvent.UPDATE_ITEM, menuBar_dataProvider_updateItemHandler);
			this._dataProvider.addEventListener(HierarchicalCollectionEvent.UPDATE_ALL, menuBar_dataProvider_updateAllHandler);
		}
		this.setInvalid(DATA);
		FeathersEvent.dispatch(this, "dataChange");
		return this._dataProvider;
	}

	private var _openedMenu:Menu = null;

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
		this._selectedItem = this._dataProvider.get([this._selectedIndex]);
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
		return this._dataProvider.getLength() - 1;
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
		var index = dataProviderIndexOf(value);
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

	private var _previousCustomItemRendererVariant:String = null;

	/**
		A custom variant to set on all item renderers, instead of
		`MenuBar.CHILD_VARIANT_ITEM_RENDERER`.

		The `customItemRendererVariant` will be not be used if the result of
		`itemRendererRecycler.create()` already has a variant set.

		@see `MenuBar.CHILD_VARIANT_ITEM_RENDERER`
		@see `feathers.style.IVariantStyleObject.variant`

		@since 1.4.0
	**/
	@:style
	public var customItemRendererVariant:String = null;

	/**
		Manages item renderers used by the menu bar.

		In the following example, the menu bar uses a custom item renderer class:

		```haxe
		menuBar.itemRendererRecycler = DisplayObjectRecycler.withClass(MyCustomItemRenderer);
		```

		@since 1.4.0
	**/
	public var itemRendererRecycler(get, set):AbstractDisplayObjectRecycler<Dynamic, MenuItemState, DisplayObject>;

	private function get_itemRendererRecycler():AbstractDisplayObjectRecycler<Dynamic, MenuItemState, DisplayObject> {
		return this._defaultStorage.itemRendererRecycler;
	}

	private function set_itemRendererRecycler(value:AbstractDisplayObjectRecycler<Dynamic, MenuItemState,
		DisplayObject>):AbstractDisplayObjectRecycler<Dynamic, MenuItemState, DisplayObject> {
		if (this._defaultStorage.itemRendererRecycler == value) {
			return this._defaultStorage.itemRendererRecycler;
		}
		this._defaultStorage.oldItemRendererRecycler = this._defaultStorage.itemRendererRecycler;
		this._defaultStorage.itemRendererRecycler = value;
		this.setInvalid(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
		return this._defaultStorage.itemRendererRecycler;
	}

	/**
		Manages item renderers used by the menu bar.

		In the following example, the menu bar uses a custom item renderer class:

		```haxe
		menuBar.itemRendererRecycler = DisplayObjectRecycler.withClass(MyCustomItemRenderer);
		```

		@since 1.4.0
	**/
	public var separatorRecycler(get, set):AbstractDisplayObjectRecycler<Dynamic, MenuItemState, DisplayObject>;

	private function get_separatorRecycler():AbstractDisplayObjectRecycler<Dynamic, MenuItemState, DisplayObject> {
		return this._separatorStorage.itemRendererRecycler;
	}

	private function set_separatorRecycler(value:AbstractDisplayObjectRecycler<Dynamic, MenuItemState, DisplayObject>):AbstractDisplayObjectRecycler<Dynamic,
		MenuItemState, DisplayObject> {
		if (this._separatorStorage.itemRendererRecycler == value) {
			return this._separatorStorage.itemRendererRecycler;
		}
		this._separatorStorage.oldItemRendererRecycler = this._separatorStorage.itemRendererRecycler;
		this._separatorStorage.itemRendererRecycler = value;
		this.setInvalid(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
		return this._separatorStorage.itemRendererRecycler;
	}

	private var _oldMenuFactory:DisplayObjectFactory<Dynamic, Menu>;

	private var _menuFactory:DisplayObjectFactory<Dynamic, Menu>;

	/**
		Creates a menu that is displayed as a sub-component. The menu must be of
		type `feathers.controls.Menu`.

		In the following example, a custom menu factory is provided:

		```haxe
		menuBar.menuFactory = () ->
		{
			return new Menu();
		};
		```

		@see `feathers.controls.Menu`

		@since 1.4.0
	**/
	public var menuFactory(get, set):AbstractDisplayObjectFactory<Dynamic, Menu>;

	private function get_menuFactory():AbstractDisplayObjectFactory<Dynamic, Menu> {
		return this._menuFactory;
	}

	private function set_menuFactory(value:AbstractDisplayObjectFactory<Dynamic, Menu>):AbstractDisplayObjectFactory<Dynamic, Menu> {
		if (this._menuFactory == value) {
			return this._menuFactory;
		}
		this._menuFactory = value;
		this.setInvalid(INVALIDATION_FLAG_MENU_FACTORY);
		return this._menuFactory;
	}

	private var _forceItemStateUpdate:Bool = false;

	/**
		Forces the `itemRendererRecycler.update()` method to be called with the
		`MenuItemState` when the menu bar validates, even if the item's
		state has not changed since the previous validation.

		Before Feathers UI 1.2, `update()` was called more frequently, and this
		property is provided to enable backwards compatibility, temporarily, to
		assist in migration from earlier versions of Feathers UI.

		In general, when this property needs to be enabled, its often because of
		a missed call to `dataProvider.updateAt()` (preferred) or
		`dataProvider.updateAll()` (less common).

		The `forceItemStateUpdate` property may be removed in a future major
		version, so it is best to avoid relying on it as a long-term solution.

		@since 1.4.0
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

	private var _recyclerMap:Map<String, DisplayObjectRecycler<Dynamic, MenuItemState, DisplayObject>> = null;

	private var _itemRendererRecyclerIDFunction:(state:MenuItemState) -> String;

	/**
		When a menu bar requires multiple item renderer styles, this function is
		used to determine which style of item renderer is required for a
		specific item. Returns the ID of the item renderer recycler to use for
		the item, or `null` if the default `itemRendererRecycler` should be used.

		The following example provides an `itemRendererRecyclerIDFunction`:

		```haxe
		var regularItemRendererRecycler = DisplayObjectRecycler.withClass(ItemRenderer);
		var firstItemRendererRecycler = DisplayObjectRecycler.withClass(MyCustomItemRenderer);

		menuBar.setItemRendererRecycler("regular-item", regularItemRendererRecycler);
		menuBar.setItemRendererRecycler("first-item", firstItemRendererRecycler);

		menuBar.itemRendererRecyclerIDFunction = function(state:MenuItemState):String {
			if(state.index == 0) {
				return "first-item";
			}
			return "regular-item";
		};
		```

		@default null

		@see `MenuBar.setItemRendererRecycler()`
		@see `MenuBar.itemRendererRecycler

		@since 1.4.0
	**/
	public var itemRendererRecyclerIDFunction(get, set):(state:MenuItemState) -> String;

	private function get_itemRendererRecyclerIDFunction():(state:MenuItemState) -> String {
		return this._itemRendererRecyclerIDFunction;
	}

	private function set_itemRendererRecyclerIDFunction(value:(state:MenuItemState) -> String):(state:MenuItemState) -> String {
		if (this._itemRendererRecyclerIDFunction == value) {
			return this._itemRendererRecyclerIDFunction;
		}
		this._itemRendererRecyclerIDFunction = value;
		this.setInvalid(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
		return this._itemRendererRecyclerIDFunction;
	}

	private var _defaultStorage:MenuBarStorage = new MenuBarStorage(null, DisplayObjectRecycler.withFunction(() -> {
		var itemRenderer = new ToggleButton();
		itemRenderer.toggleable = false;
		return itemRenderer;
	}));

	private var _separatorStorage:MenuBarStorage = new MenuBarStorage("__menuBar_separator", DisplayObjectRecycler.withClass(VRule));
	private var _additionalStorage:Array<MenuBarStorage> = null;
	private var objectDataToItemRenderer = new ObjectMap<Dynamic, DisplayObject>();
	private var stringDataToItemRenderer = new StringMap<DisplayObject>();
	private var itemRendererToItemState = new ObjectMap<DisplayObject, MenuItemState>();
	private var itemStatePool = new ObjectPool(() -> new MenuItemState());
	private var _unrenderedData:Array<Dynamic> = [];
	private var _layoutItems:Array<DisplayObject> = [];
	private var _ignoreSelectionChange = false;
	private var _itemToText:(Dynamic) -> String = defaultItemToText;

	/**
		Converts an item to text to display within menu bar. By default, the
		`toString()` method is called to convert an item to text. This method
		may be replaced to provide custom text.

		For example, consider the following item:

		```haxe
		{ text: "Example Item" }
		```

		If the `MenuBar` should display the text "Example Item", a custom
		implementation of `itemToText()` might look like this:

		```haxe
		menuBar.itemToText = (item:Dynamic) -> {
			return item.text;
		};
		```

		@since 1.4.0
	**/
	public var itemToText(get, set):(Dynamic) -> String;

	private function get_itemToText():(Dynamic) -> String {
		return this._itemToText;
	}

	private function set_itemToText(value:(Dynamic) -> String):(Dynamic) -> String {
		if (value == null) {
			value = defaultItemToText;
		}
		if (this._itemToText == value || Reflect.compareMethods(this._itemToText, value)) {
			return this._itemToText;
		}
		this._itemToText = value;
		this.setInvalid(DATA);
		return this._itemToText;
	}

	private var _itemToSeparator:(Dynamic) -> Bool = defaultItemToSeparator;

	/**
		Determines if an item represents a separator menu item.

		For example, consider the following item:

		```haxe
		var fileItems:Array<MenuItemData> = [
			{ text: "Open" },
			{ separator: true },
			{ text: "Quit" },
		];
		```

		If the `MenuBar` should display some items as separators, a custom
		implementation of `itemToSeparator()` might look like this:

		```haxe
		menuBar.itemToSeparator = (item:MenuItemData) -> {
			return item.separator != null && item.separator == true;
		};
		```

		The example above uses the following custom [Haxe typedef](https://haxe.org/manual/type-system-typedef.html).

		```haxe
		typedef MenuItemData = {
			?text:String,
			?children:Array<MenuItemData>,
			?separator:Bool
		}
		```

		@since 1.4.0
	**/
	public var itemToSeparator(get, set):(Dynamic) -> Bool;

	private function get_itemToSeparator():(Dynamic) -> Bool {
		return this._itemToSeparator;
	}

	private function set_itemToSeparator(value:(Dynamic) -> Bool):(Dynamic) -> Bool {
		if (value == null) {
			value = defaultItemToSeparator;
		}
		if (this._itemToSeparator == value || Reflect.compareMethods(this._itemToSeparator, value)) {
			return this._itemToSeparator;
		}
		this._itemToSeparator = value;
		this.setInvalid(DATA);
		return this._itemToSeparator;
	}

	private var _itemToEnabled:(Dynamic) -> Bool = defaultItemToEnabled;

	/**
		Determines if an item renderer should be enabled or disabled. By
		default, all items are enabled, unless the `MenuBar` is disabled. Thi
		method may be replaced to provide a custom value for `enabled`.

		For example, consider the following item:

		```haxe
		{ text: "Example Item", disable: true }
		```

		If the `MenuBar` should disable an item if the `disable` field is
		`true`, a custom implementation of `itemToEnabled()` might look like
		this:

		```haxe
		menuBar.itemToEnabled = (item:Dynamic) -> {
			return !item.disable;
		};
		```

		@since 1.4.0
	**/
	public var itemToEnabled(get, set):(Dynamic) -> Bool;

	private function get_itemToEnabled():(Dynamic) -> Bool {
		return this._itemToEnabled;
	}

	private function set_itemToEnabled(value:(Dynamic) -> Bool):(Dynamic) -> Bool {
		if (value == null) {
			value = defaultItemToEnabled;
		}
		if (this._itemToEnabled == value || Reflect.compareMethods(this._itemToEnabled, value)) {
			return this._itemToEnabled;
		}
		this._itemToEnabled = value;
		this.setInvalid(DATA);
		return this._itemToEnabled;
	}

	/**
		The layout algorithm used to position and size the item renderers.

		By default, if no layout is provided by the time that the menu bar
		initializes, a default layout that displays items horizontally will be
		created.

		The following example tells the menu bar to use a custom layout:

		```haxe
		var layout = new HorizontalDistributedLayout();
		layout.maxItemWidth = 300.0;
		menuBar.layout = layout;
		```

		@since 1.4.0
	**/
	@:style
	public var layout:ILayout = null;

	private var _currentBackgroundSkin:DisplayObject = null;
	private var _backgroundSkinMeasurements:Measurements = null;

	/**
		The default background skin to display behind the item renderers.

		The following example passes a bitmap for the menu bar to use as a
		background skin:

		```haxe
		menuBar.backgroundSkin = new Bitmap(bitmapData);
		```

		@default null

		@see `MenuBar.disabledBackgroundSkin`

		@since 1.4.0
	**/
	@:style
	public var backgroundSkin:DisplayObject = null;

	/**
		A background skin to display behind the item renderers when the menu bar
		is disabled.

		The following example gives the menu bar a disabled background skin:

		```haxe
		menuBar.disabledBackgroundSkin = new Bitmap(bitmapData);
		menuBar.enabled = false;
		```

		@default null

		@see `MenuBar.backgroundSkin`

		@since 1.4.0
	**/
	@:style
	public var disabledBackgroundSkin:DisplayObject = null;

	private var _layoutMeasurements = new Measurements();
	private var _layoutResult = new LayoutBoundsResult();
	private var _ignoreChildChanges = false;

	/**
		Returns the current item renderer used to render a specific item from
		the data provider. May return `null` if an item doesn't currently have
		an item renderer.

		@since 1.4.0
	**/
	public function itemToItemRenderer(item:Dynamic):DisplayObject {
		if (item == null) {
			return null;
		}
		if ((item is String)) {
			return this.stringDataToItemRenderer.get(cast item);
		}
		return this.objectDataToItemRenderer.get(item);
	}

	/**
		Returns the current item renderer used to render the item at the
		specified index in the data provider. May return `null` if an item doesn't
		currently have an item renderer.

		@since 1.4.0
	**/
	public function indexToItemRenderer(index:Int):DisplayObject {
		if (this._dataProvider == null || index < 0 || index >= this._dataProvider.getLength()) {
			return null;
		}
		var item = this._dataProvider.get([index]);
		if ((item is String)) {
			return this.stringDataToItemRenderer.get(cast item);
		}
		return this.objectDataToItemRenderer.get(item);
	}

	/**
		Returns a `MenuItemState` representing a specific item.

		@since 1.4.0
	**/
	public function itemToItemState(item:Dynamic):MenuItemState {
		if (item == null) {
			return null;
		}
		var itemState:MenuItemState = null;
		var itemRenderer:DisplayObject = null;
		if ((item is String)) {
			itemRenderer = this.stringDataToItemRenderer.get(cast item);
		} else {
			itemRenderer = this.objectDataToItemRenderer.get(item);
		}
		if (itemRenderer != null) {
			itemState = this.itemRendererToItemState.get(itemRenderer);
		} else {
			var index = dataProviderIndexOf(item);
			if (index == -1) {
				return null;
			}
			itemState = new MenuItemState();
			this.populateCurrentItemState(item, index, itemState, false);
		}
		return itemState;
	}

	/**
		Returns the item renderer recycler associated with a specific ID.
		Returns `null` if no recycler is associated with the ID.

		@see `MenuBar.itemRendererRecyclerIDFunction`
		@see `MenuBar.setItemRendererRecycler()`

		@since 1.4.0
	**/
	public function getItemRendererRecycler(id:String):DisplayObjectRecycler<Dynamic, MenuItemState, DisplayObject> {
		if (this._recyclerMap == null) {
			return null;
		}
		return this._recyclerMap.get(id);
	}

	/**
		Associates an item renderer recycler with an ID to allow multiple types
		of item renderers to be displayed in the menu bar. A custom
		`itemRendererRecyclerIDFunction` may be specified to return the ID of the
		recycler to use for a specific item in the data provider.

		To clear a recycler, pass in `null` as the value.

		@see `MenuBar.itemRendererRecyclerIDFunction`
		@see `MenuBar.getItemRendererRecycler()`

		@since 1.4.0
	**/
	public function setItemRendererRecycler(id:String, recycler:AbstractDisplayObjectRecycler<Dynamic, MenuItemState, DisplayObject>):Void {
		if (this._recyclerMap == null) {
			this._recyclerMap = [];
		}
		if (recycler == null) {
			this._recyclerMap.remove(id);
			return;
		}
		this._recyclerMap.set(id, recycler);
		this.setInvalid(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
	}

	override public function dispose():Void {
		this.refreshInactiveItemRenderers(this._defaultStorage, true);
		this.refreshInactiveItemRenderers(this._separatorStorage, true);
		if (this._additionalStorage != null) {
			for (i in 0...this._additionalStorage.length) {
				var storage = this._additionalStorage[i];
				this.refreshInactiveItemRenderers(storage, true);
			}
		}
		this.dataProvider = null;
		super.dispose();
	}

	private function initializeMenuBarTheme():Void {
		#if !feathersui_disable_default_theme
		feathers.themes.steel.components.SteelMenuBarStyles.initialize();
		#end
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(DATA);
		var layoutInvalid = this.isInvalid(LAYOUT);
		var selectionInvalid = this.isInvalid(SELECTION);
		var stateInvalid = this.isInvalid(STATE);
		var stylesInvalid = this.isInvalid(STYLES);
		if (this._previousCustomItemRendererVariant != this.customItemRendererVariant) {
			this.setInvalidationFlag(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
		}
		var itemRendererInvalid = this.isInvalid(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);

		if (stylesInvalid || stateInvalid) {
			this.refreshBackgroundSkin();
		}

		if (itemRendererInvalid || selectionInvalid || stateInvalid || dataInvalid) {
			this.refreshItemRenderers();
		}

		this.refreshViewPortBounds();
		this.handleLayout();
		this.handleLayoutResult();

		this.layoutBackgroundSkin();

		// final invalidation to avoid juggler next frame issues
		this.validateChildren();

		this._previousCustomItemRendererVariant = this.customItemRendererVariant;
	}

	private function refreshViewPortBounds():Void {
		var needsMinWidth = this.explicitMinWidth == null;
		var needsMinHeight = this.explicitMinHeight == null;
		var needsMaxWidth = this.explicitMaxWidth == null;
		var needsMaxHeight = this.explicitMaxHeight == null;

		if (this._currentBackgroundSkin != null) {
			MeasurementsUtil.resetFluidlyWithParent(this._backgroundSkinMeasurements, this._currentBackgroundSkin, this);
			if ((this._currentBackgroundSkin is IValidating)) {
				(cast this._currentBackgroundSkin : IValidating).validateNow();
			}
		}

		var viewPortMinWidth = this.explicitMinWidth;
		if (needsMinWidth) {
			viewPortMinWidth = 0.0;
		}
		var viewPortMinHeight = this.explicitMinHeight;
		if (needsMinHeight) {
			viewPortMinHeight = 0.0;
		}
		var viewPortMaxWidth = this.explicitMaxWidth;
		if (needsMaxWidth) {
			viewPortMaxWidth = 1.0 / 0.0; // Math.POSITIVE_INFINITY bug workaround for swf
		}
		var viewPortMaxHeight = this.explicitMaxHeight;
		if (needsMaxHeight) {
			viewPortMaxHeight = 1.0 / 0.0; // Math.POSITIVE_INFINITY bug workaround for swf
		}
		if (this._backgroundSkinMeasurements != null) {
			// because the layout might need it, we account for the
			// dimensions of the background skin when determining the minimum
			// dimensions of the view port.
			if (this._backgroundSkinMeasurements.width != null) {
				if (this._backgroundSkinMeasurements.width > viewPortMinWidth) {
					viewPortMinWidth = this._backgroundSkinMeasurements.width;
				}
			} else if (this._backgroundSkinMeasurements.minWidth != null) {
				if (this._backgroundSkinMeasurements.minWidth > viewPortMinWidth) {
					viewPortMinWidth = this._backgroundSkinMeasurements.minWidth;
				}
			}
			if (this._backgroundSkinMeasurements.height != null) {
				if (this._backgroundSkinMeasurements.height > viewPortMinHeight) {
					viewPortMinHeight = this._backgroundSkinMeasurements.height;
				}
			} else if (this._backgroundSkinMeasurements.minHeight != null) {
				if (this._backgroundSkinMeasurements.minHeight > viewPortMinHeight) {
					viewPortMinHeight = this._backgroundSkinMeasurements.minHeight;
				}
			}
		}

		this._layoutMeasurements.width = this.explicitWidth;
		this._layoutMeasurements.height = this.explicitHeight;
		this._layoutMeasurements.minWidth = viewPortMinWidth;
		this._layoutMeasurements.minHeight = viewPortMinHeight;
		this._layoutMeasurements.maxWidth = viewPortMaxWidth;
		this._layoutMeasurements.maxHeight = viewPortMaxHeight;
	}

	private function handleLayout():Void {
		var oldIgnoreChildChanges = this._ignoreChildChanges;
		this._ignoreChildChanges = true;
		this._layoutResult.reset();
		if (this.layout != null) {
			this.layout.layout(this._layoutItems, this._layoutMeasurements, this._layoutResult);
		} else {
			var viewPortWidth = this._layoutMeasurements.width;
			if (viewPortWidth == null) {
				if (this._layoutMeasurements.minWidth != null) {
					viewPortWidth = this._layoutMeasurements.minWidth;
				} else if (this._layoutMeasurements.minHeight != null) {
					viewPortWidth = this._layoutMeasurements.minHeight;
				} else {
					viewPortWidth = 0.0;
				}
			}
			var viewPortHeight = this._layoutMeasurements.height;
			if (viewPortHeight == null) {
				if (this._layoutMeasurements.minHeight != null) {
					viewPortHeight = this._layoutMeasurements.minHeight;
				} else if (this._layoutMeasurements.maxHeight != null) {
					viewPortHeight = this._layoutMeasurements.maxHeight;
				} else {
					viewPortHeight = 0.0;
				}
			}
			this._layoutResult.contentX = 0.0;
			this._layoutResult.contentY = 0.0;
			this._layoutResult.contentWidth = viewPortWidth;
			this._layoutResult.contentHeight = viewPortHeight;
			this._layoutResult.viewPortWidth = viewPortWidth;
			this._layoutResult.viewPortHeight = viewPortHeight;
		}
		this._ignoreChildChanges = oldIgnoreChildChanges;
	}

	private function handleLayoutResult():Void {
		var viewPortWidth = this._layoutResult.viewPortWidth;
		var viewPortHeight = this._layoutResult.viewPortHeight;
		this.saveMeasurements(viewPortWidth, viewPortHeight, viewPortWidth, viewPortHeight);
	}

	private function validateChildren():Void {
		for (itemRenderer in this._layoutItems) {
			if (!(itemRenderer is IValidating)) {
				return;
			}
			(cast itemRenderer : IValidating).validateNow();
		}
	}

	private function refreshItemRenderers():Void {
		if (this.itemRendererRecycler.update == null) {
			this.itemRendererRecycler.update = defaultUpdateItemRenderer;
			if (this.itemRendererRecycler.reset == null) {
				this.itemRendererRecycler.reset = defaultResetItemRenderer;
			}
		}
		if (this._recyclerMap != null) {
			for (recycler in this._recyclerMap) {
				if (recycler.update == null) {
					if (recycler.update == null) {
						recycler.update = defaultUpdateItemRenderer;
						// don't replace reset if we didn't replace update too
						if (recycler.reset == null) {
							recycler.reset = defaultResetItemRenderer;
						}
					}
				}
			}
		}

		var itemRendererInvalid = this.isInvalid(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
		this.refreshInactiveItemRenderers(this._defaultStorage, itemRendererInvalid);
		this.refreshInactiveItemRenderers(this._separatorStorage, itemRendererInvalid);
		if (this._additionalStorage != null) {
			for (i in 0...this._additionalStorage.length) {
				var storage = this._additionalStorage[i];
				this.refreshInactiveItemRenderers(storage, itemRendererInvalid);
			}
		}
		this.findUnrenderedData();
		this.recoverInactiveItemRenderers(this._defaultStorage);
		this.recoverInactiveItemRenderers(this._separatorStorage);
		if (this._additionalStorage != null) {
			for (i in 0...this._additionalStorage.length) {
				var storage = this._additionalStorage[i];
				this.recoverInactiveItemRenderers(storage);
			}
		}
		this.renderUnrenderedData();
		this.freeInactiveItemRenderers(this._defaultStorage);
		if (this._defaultStorage.inactiveItemRenderers.length > 0) {
			throw new IllegalOperationError('${Type.getClassName(Type.getClass(this))}: inactive item renderers should be empty after updating.');
		}
		this.freeInactiveItemRenderers(this._separatorStorage);
		if (this._separatorStorage.inactiveItemRenderers.length > 0) {
			throw new IllegalOperationError('${Type.getClassName(Type.getClass(this))}: inactive item renderers should be empty after updating.');
		}
		if (this._additionalStorage != null) {
			for (i in 0...this._additionalStorage.length) {
				var storage = this._additionalStorage[i];
				this.freeInactiveItemRenderers(storage);
				if (storage.inactiveItemRenderers.length > 0) {
					throw new IllegalOperationError('${Type.getClassName(Type.getClass(this))}: inactive item renderers ${storage.id} should be empty after updating.');
				}
			}
		}
	}

	private function refreshInactiveItemRenderers(storage:MenuBarStorage, factoryInvalid:Bool):Void {
		var temp = storage.inactiveItemRenderers;
		storage.inactiveItemRenderers = storage.activeItemRenderers;
		storage.activeItemRenderers = temp;
		if (storage.activeItemRenderers.length > 0) {
			throw new IllegalOperationError('${Type.getClassName(Type.getClass(this))}: active item renderers should be empty before updating.');
		}
		if (factoryInvalid) {
			this.recoverInactiveItemRenderers(storage);
			this.freeInactiveItemRenderers(storage);
			storage.oldItemRendererRecycler = null;
		}
	}

	private function recoverInactiveItemRenderers(storage:MenuBarStorage):Void {
		for (itemRenderer in storage.inactiveItemRenderers) {
			if (itemRenderer == null) {
				continue;
			}
			var state = this.itemRendererToItemState.get(itemRenderer);
			if (state == null) {
				continue;
			}
			var item = state.data;
			this.itemRendererToItemState.remove(itemRenderer);
			if ((item is String)) {
				this.stringDataToItemRenderer.remove(cast item);
			} else {
				this.objectDataToItemRenderer.remove(item);
			}
			this.resetItemRenderer(itemRenderer, state, storage);
			this.itemStatePool.release(state);
		}
	}

	private function freeInactiveItemRenderers(storage:MenuBarStorage):Void {
		var recycler = storage.oldItemRendererRecycler != null ? storage.oldItemRendererRecycler : storage.itemRendererRecycler;
		for (itemRenderer in storage.inactiveItemRenderers) {
			if (itemRenderer == null) {
				continue;
			}
			this.destroyItemRenderer(itemRenderer, recycler);
		}
		#if (hl && haxe_ver < 4.3)
		storage.inactiveItemRenderers.splice(0, storage.inactiveItemRenderers.length);
		#else
		storage.inactiveItemRenderers.resize(0);
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
			(cast skin : IUIControl).initializeNow();
		}
		if (this._backgroundSkinMeasurements == null) {
			this._backgroundSkinMeasurements = new Measurements(skin);
		} else {
			this._backgroundSkinMeasurements.save(skin);
		}
		if ((skin is IProgrammaticSkin)) {
			(cast skin : IProgrammaticSkin).uiContext = this;
		}
		this.addChildAt(skin, 0);
	}

	private function removeCurrentBackgroundSkin(skin:DisplayObject):Void {
		if (skin == null) {
			return;
		}
		if ((skin is IProgrammaticSkin)) {
			(cast skin : IProgrammaticSkin).uiContext = null;
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
			(cast this._currentBackgroundSkin : IValidating).validateNow();
		}
	}

	private function findUnrenderedData():Void {
		// remove all old items, then fill with null
		#if (hl && haxe_ver < 4.3)
		this._layoutItems.splice(0, this._layoutItems.length);
		#else
		this._layoutItems.resize(0);
		#end
		if (this._dataProvider == null || this._dataProvider.getLength() == 0) {
			return;
		}
		this._layoutItems.resize(this._dataProvider.getLength());

		var depthOffset = this._currentBackgroundSkin != null ? 1 : 0;
		for (i in 0...this._dataProvider.getLength()) {
			var item = this._dataProvider.get([i]);
			var itemRenderer:DisplayObject = null;
			if ((item is String)) {
				itemRenderer = this.stringDataToItemRenderer.get(cast item);
			} else {
				itemRenderer = this.objectDataToItemRenderer.get(item);
			}
			if (itemRenderer != null) {
				var state = this.itemRendererToItemState.get(itemRenderer);
				var changed = this.populateCurrentItemState(item, i, state, this._forceItemStateUpdate);
				var oldRecyclerID = state.recyclerID;
				var storage = this.itemStateToStorage(state);
				if (storage.id != oldRecyclerID) {
					this._unrenderedData.push(item);
					continue;
				}
				if (changed) {
					this.updateItemRenderer(itemRenderer, state, storage);
				}
				this._layoutItems[i] = itemRenderer;
				this.setChildIndex(itemRenderer, i + depthOffset);
				var removed = storage.inactiveItemRenderers.remove(itemRenderer);
				if (!removed) {
					throw new IllegalOperationError('${Type.getClassName(Type.getClass(this))}: item renderer map contains bad data for item at index ${i}. This may be caused by duplicate items in the data provider, which is not allowed.');
				}
				storage.activeItemRenderers.push(itemRenderer);
			} else {
				this._unrenderedData.push(item);
			}
		}
	}

	private function renderUnrenderedData():Void {
		var depthOffset = this._currentBackgroundSkin != null ? 1 : 0;
		for (item in this._unrenderedData) {
			var index = dataProviderIndexOf(item);
			var state = this.itemStatePool.get();
			this.populateCurrentItemState(item, index, state, true);
			var itemRenderer = this.createItemRenderer(state);
			this.addChildAt(itemRenderer, index + depthOffset);
			this._layoutItems[index] = itemRenderer;
		}
		#if (hl && haxe_ver < 4.3)
		this._unrenderedData.splice(0, this._unrenderedData.length);
		#else
		this._unrenderedData.resize(0);
		#end
	}

	private function createItemRenderer(state:MenuItemState):DisplayObject {
		var storage = this.itemStateToStorage(state);
		var itemRenderer:DisplayObject = null;
		if (storage.inactiveItemRenderers.length == 0) {
			itemRenderer = storage.itemRendererRecycler.create();
			if ((itemRenderer is IVariantStyleObject)) {
				var variantItemRenderer:IVariantStyleObject = cast itemRenderer;
				if (variantItemRenderer.variant == null) {
					var variant = (this.customItemRendererVariant != null) ? this.customItemRendererVariant : CHILD_VARIANT_ITEM_RENDERER;
					variantItemRenderer.variant = variant;
				}
			}
			// for consistency, initialize before passing to the recycler's
			// update function. plus, this ensures that custom item renderers
			// correctly handle property changes in update() instead of trying
			// to access them too early in initialize().
			if ((itemRenderer is IUIControl)) {
				(cast itemRenderer : IUIControl).initializeNow();
			}
		} else {
			itemRenderer = storage.inactiveItemRenderers.shift();
		}
		this.updateItemRenderer(itemRenderer, state, storage);
		itemRenderer.addEventListener(MouseEvent.MOUSE_DOWN, menuBar_itemRenderer_mouseDownHandler);
		itemRenderer.addEventListener(MouseEvent.ROLL_OVER, menuBar_itemRenderer_rollOverHandler);
		this.itemRendererToItemState.set(itemRenderer, state);
		var item = state.data;
		if ((item is String)) {
			this.stringDataToItemRenderer.set(cast item, itemRenderer);
		} else {
			this.objectDataToItemRenderer.set(item, itemRenderer);
		}
		storage.activeItemRenderers.push(itemRenderer);
		return itemRenderer;
	}

	private function destroyItemRenderer(itemRenderer:DisplayObject, recycler:DisplayObjectRecycler<Dynamic, MenuItemState, DisplayObject>):Void {
		this.removeChild(itemRenderer);
		if (recycler != null && recycler.destroy != null) {
			recycler.destroy(itemRenderer);
		}
	}

	private function itemStateToStorage(state:MenuItemState):MenuBarStorage {
		var recyclerID:String = null;
		if (this._itemRendererRecyclerIDFunction != null) {
			recyclerID = this._itemRendererRecyclerIDFunction(state);
		}
		var recycler:DisplayObjectRecycler<Dynamic, MenuItemState, DisplayObject> = null;
		if (recyclerID != null) {
			if (this._recyclerMap != null) {
				recycler = this._recyclerMap.get(recyclerID);
			}
			if (recycler == null) {
				throw new IllegalOperationError('Item renderer recycler ID "${recyclerID}" is not registered.');
			}
		}
		if (recycler == null) {
			if (state.separator) {
				return this._separatorStorage;
			}
			return this._defaultStorage;
		}
		if (this._additionalStorage == null) {
			this._additionalStorage = [];
		}
		for (i in 0...this._additionalStorage.length) {
			var storage = this._additionalStorage[i];
			if (storage.itemRendererRecycler == recycler) {
				return storage;
			}
		}
		var storage = new MenuBarStorage(recyclerID, recycler);
		this._additionalStorage.push(storage);
		return storage;
	}

	private function populateCurrentItemState(item:Dynamic, index:Int, state:MenuItemState, force:Bool):Bool {
		var changed = false;
		if (force || state.menuBarOwner != this) {
			state.menuBarOwner = this;
			changed = true;
		}
		if (force || state.menuOwner != null) {
			state.menuOwner = null;
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
		var separator = itemToSeparator(item);
		if (force || state.separator != separator) {
			state.separator = separator;
			changed = true;
		}
		var selected = !separator && this._selectedIndex == index;
		if (force || state.selected != selected) {
			state.selected = selected;
			changed = true;
		}
		var branch = !separator && this._dataProvider != null && this._dataProvider.isBranch(item);
		if (force || state.branch != branch) {
			state.branch = branch;
			changed = true;
		}
		var enabled = this._enabled && itemToEnabled(item);
		if (force || state.enabled != enabled) {
			state.enabled = enabled;
			changed = true;
		}
		var text = separator ? null : itemToText(item);
		if (force || state.text != text) {
			state.text = text;
			changed = true;
		}
		return changed;
	}

	private function updateItemRenderer(itemRenderer:DisplayObject, state:MenuItemState, storage:MenuBarStorage):Void {
		state.recyclerID = storage.id;
		var oldIgnoreSelectionChange = this._ignoreSelectionChange;
		this._ignoreSelectionChange = true;
		if (storage.itemRendererRecycler.update != null) {
			storage.itemRendererRecycler.update(itemRenderer, state);
		}
		this._ignoreSelectionChange = oldIgnoreSelectionChange;
		this.refreshItemRendererProperties(itemRenderer, state);
	}

	private function resetItemRenderer(itemRenderer:DisplayObject, state:MenuItemState, storage:MenuBarStorage):Void {
		var oldIgnoreSelectionChange = this._ignoreSelectionChange;
		this._ignoreSelectionChange = true;
		var recycler = storage.oldItemRendererRecycler != null ? storage.oldItemRendererRecycler : storage.itemRendererRecycler;
		if (recycler != null && recycler.reset != null) {
			recycler.reset(itemRenderer, state);
		}
		this._ignoreSelectionChange = oldIgnoreSelectionChange;
		this.refreshItemRendererProperties(itemRenderer, RESET_ITEM_RENDERER_STATE);
	}

	private function refreshItemRendererProperties(itemRenderer:DisplayObject, state:MenuItemState):Void {
		var oldIgnoreSelectionChange = this._ignoreSelectionChange;
		this._ignoreSelectionChange = true;
		if ((itemRenderer is IUIControl)) {
			var uiControl:IUIControl = cast itemRenderer;
			uiControl.enabled = state.enabled;
		}
		if ((itemRenderer is IDataRenderer)) {
			var dataRenderer:IDataRenderer = cast itemRenderer;
			// if the item renderer is an IDataRenderer, this cannot be overridden
			dataRenderer.data = state.data;
		}
		if ((itemRenderer is ILayoutIndexObject)) {
			var layoutObject:ILayoutIndexObject = cast itemRenderer;
			layoutObject.layoutIndex = state.index;
		}
		this._ignoreSelectionChange = oldIgnoreSelectionChange;
	}

	private function updateItemRendererForIndex(index:Int):Void {
		var item = this._dataProvider.get([index]);
		var itemRenderer:DisplayObject = null;
		if ((item is String)) {
			itemRenderer = this.stringDataToItemRenderer.get(cast item);
		} else {
			itemRenderer = this.objectDataToItemRenderer.get(item);
		}
		if (itemRenderer == null) {
			// doesn't exist yet, so we need to do a full invalidation
			this.setInvalid(DATA);
			return;
		}
		var state = this.itemRendererToItemState.get(itemRenderer);
		if (state.menuBarOwner == null) {
			// a previous update is already pending
			return;
		}
		var storage = this.itemStateToStorage(state);
		this.populateCurrentItemState(item, index, state, true);
		// in order to display the same item with modified properties, this
		// hack tricks the item renderer into thinking that it has been given
		// a different item to render.
		this.resetItemRenderer(itemRenderer, state, storage);
		// ensures that the change is detected when we validate later
		state.menuBarOwner = null;
		this.setInvalid(DATA);

		if (state.branch && state.selected) {
			this.closeOpenedMenu();
			this.openMenuAtIndex(state.index);
		}
	}

	private function closeOpenedMenu():Void {
		if (this._openedMenu != null) {
			this._openedMenu.close();
		}
	}

	private function openMenuAtIndex(index:Int):Void {
		this.closeOpenedMenu();

		var itemRenderer = this.indexToItemRenderer(index);
		var itemState = this.itemRendererToItemState.get(itemRenderer);
		if (!itemState.enabled || itemState.separator) {
			throw new IllegalOperationError("Cannot open an menu for a disabled item");
		}
		if (itemState.separator) {
			throw new IllegalOperationError("Cannot open an menu for a separator item");
		}

		var menuLocation = [index];
		var menuCollection:IHierarchicalCollection<Dynamic> = null;
		if (itemState.branch) {
			menuCollection = new HierarchicalSubCollection(this._dataProvider, menuLocation);
		} else {
			MenuEvent.dispatch(this, MenuEvent.ITEM_TRIGGER, itemState);
			return;
		}
		var factory = this._menuFactory != null ? this._menuFactory : defaultMenuFactory;
		this._oldMenuFactory = factory;
		this._openedMenu = factory.create();
		this._openedMenu.menuBarOwner = this;
		this._openedMenu.menuOwner = null;
		this._openedMenu.dataProvider = menuCollection;
		this._openedMenu.itemToText = itemToText;
		this._openedMenu.itemToSeparator = itemToSeparator;
		this._openedMenu.itemToEnabled = itemToEnabled;
		this._openedMenu.addEventListener(MenuEvent.ITEM_TRIGGER, menuBar_menu_itemTriggerHandler);
		this._openedMenu.addEventListener(Event.CLOSE, menuBar_menu_closeHandler);

		this.stage.addEventListener(KeyboardEvent.KEY_DOWN, menuBar_stage_keyDownHandler, false, 0, true);
		this._selectedIndex = index;

		this._openedMenu.showAtOrigin(itemRenderer);
		MenuEvent.dispatch(this, MenuEvent.MENU_OPEN, itemState);
	}

	private function navigateWithKeyboard(event:KeyboardEvent):Void {
		if (event.isDefaultPrevented()) {
			return;
		}
		if (this._dataProvider == null || this._dataProvider.getLength() == 0) {
			return;
		}
		var result = this._selectedIndex;
		var needsAnotherPass = true;
		var lastResult = -1;
		while (needsAnotherPass) {
			needsAnotherPass = false;
			switch (event.keyCode) {
				case Keyboard.LEFT:
					result = result - 1;
				case Keyboard.RIGHT:
					result = result + 1;
				default:
					// not keyboard navigation
					return;
			}
			// both macOS and Windows will loop around to the beginning when
			// pressing RIGHT at the end, or the end when pressing LEFT at the
			// beginning
			if (result < 0) {
				result += this._dataProvider.getLength();
			} else if (result >= this._dataProvider.getLength()) {
				result -= this._dataProvider.getLength();
			}
			var item = this._dataProvider.get([result]);
			var separator = this.itemToSeparator(item);
			var enabled = this.itemToEnabled(item);
			if (separator || !enabled) {
				// keep going until we reach a non-separator that is enabled
				if (result == lastResult) {
					// but don't keep trying if we got the same result more than
					// once because it means that we got stuck (and we want to
					// avoid an infinite loop)
					return;
				}
				needsAnotherPass = true;
			}
		}
		event.preventDefault();
		// use the setter
		this.selectedIndex = result;
		// restore focus to the container so that the wrong item renderer
		// doesn't respond to keyboard events
		if (this._focusManager != null) {
			this._focusManager.focus = this;
		} else if (this.stage != null) {
			this.stage.focus = this;
		}
		if (this.selectedIndex != -1) {
			this.openMenuAtIndex(this.selectedIndex);
		}
	}

	private function dataProviderIndexOf(item:Dynamic):Int {
		if (this._dataProvider == null) {
			return -1;
		}
		for (i in 0...this._dataProvider.getLength()) {
			var otherItem = this._dataProvider.get([i]);
			if (otherItem == item) {
				return i;
			}
		}
		return -1;
	}

	private function menuBar_itemRenderer_mouseDownHandler(event:MouseEvent):Void {
		var itemRenderer = cast(event.currentTarget, DisplayObject);
		var itemState = this.itemRendererToItemState.get(itemRenderer);
		this.openMenuAtIndex(itemState.index);
	}

	private function menuBar_stage_keyDownHandler(event:KeyboardEvent):Void {
		switch (event.keyCode) {
			case Keyboard.ESCAPE:
				if (event.isDefaultPrevented()) {
					return;
				}
				if (this._openedMenu != null) {
					event.preventDefault();
					this.closeOpenedMenu();
				}
			#if lime
			case KeyCode.APP_CONTROL_BACK:
				if (event.isDefaultPrevented()) {
					return;
				}
				if (this._openedMenu != null) {
					event.preventDefault();
					this.closeOpenedMenu();
				}
			#end
		}
		this.navigateWithKeyboard(event);
	}

	private function menuBar_itemRenderer_rollOverHandler(event:MouseEvent):Void {
		if (this._openedMenu == null) {
			return;
		}
		var itemRenderer = cast(event.currentTarget, DisplayObject);
		var itemState = this.itemRendererToItemState.get(itemRenderer);
		if (!itemState.enabled || itemState.separator) {
			return;
		}
		this.openMenuAtIndex(itemState.index);
	}

	private function menuBar_menu_closeHandler(event:Event):Void {
		var menu = cast(event.currentTarget, Menu);
		menu.menuBarOwner = null;
		menu.menuOwner = null;
		if (this._openedMenu == menu) {
			this._openedMenu = null;
		}
		this.stage.removeEventListener(KeyboardEvent.KEY_DOWN, menuBar_stage_keyDownHandler);
		if (this._oldMenuFactory.destroy != null) {
			this._oldMenuFactory.destroy(menu);
		}

		if (this._selectedIndex == -1) {
			// this shouldn't happen
			return;
		}

		var item = this._dataProvider.get([this._selectedIndex]);
		var itemState = this.itemToItemState(item);
		MenuEvent.dispatch(this, MenuEvent.MENU_CLOSE, itemState);
	}

	private function menuBar_menu_itemTriggerHandler(event:MenuEvent):Void {
		MenuEvent.dispatch(this, MenuEvent.ITEM_TRIGGER, event.state);
	}

	private function menuBar_dataProvider_changeHandler(event:Event):Void {
		this.setInvalid(DATA);
	}

	private function menuBar_dataProvider_updateItemHandler(event:HierarchicalCollectionEvent):Void {
		var index = -1;
		if (event.location.length == 1) {
			index = event.location[0];
		}
		if (index == -1) {
			return;
		}
		this.updateItemRendererForIndex(index);
	}

	private function menuBar_dataProvider_updateAllHandler(event:HierarchicalCollectionEvent):Void {
		for (i in 0...this._dataProvider.getLength()) {
			this.updateItemRendererForIndex(i);
		}
	}
}

private class MenuBarStorage {
	public function new(?id:String, ?recycler:DisplayObjectRecycler<Dynamic, MenuItemState, DisplayObject>) {
		this.id = id;
		this.itemRendererRecycler = recycler;
	}

	public var id:String;
	public var oldItemRendererRecycler:DisplayObjectRecycler<Dynamic, MenuItemState, DisplayObject>;
	public var itemRendererRecycler:DisplayObjectRecycler<Dynamic, MenuItemState, DisplayObject>;
	public var activeItemRenderers:Array<DisplayObject> = [];
	public var inactiveItemRenderers:Array<DisplayObject> = [];
}
