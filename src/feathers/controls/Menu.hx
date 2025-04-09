/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.controls.dataRenderers.IDataRenderer;
import feathers.controls.dataRenderers.IMenuItemRenderer;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.controls.popups.DropDownPopUpAdapter;
import feathers.controls.popups.IPopUpAdapter;
import feathers.controls.popups.SubMenuPopUpAdapter;
import feathers.controls.supportClasses.AdvancedLayoutViewPort;
import feathers.controls.supportClasses.BaseScrollContainer;
import feathers.core.IDataSelector;
import feathers.core.IFocusContainer;
import feathers.core.IIndexSelector;
import feathers.core.IMeasureObject;
import feathers.core.ITextControl;
import feathers.core.IUIControl;
import feathers.core.InvalidationFlag;
import feathers.core.PopUpManager;
import feathers.data.HierarchicalSubCollection;
import feathers.data.IHierarchicalCollection;
import feathers.data.MenuItemState;
import feathers.events.FeathersEvent;
import feathers.events.HierarchicalCollectionEvent;
import feathers.events.MenuEvent;
import feathers.events.TriggerEvent;
import feathers.layout.ILayout;
import feathers.layout.ILayoutIndexObject;
import feathers.layout.IScrollLayout;
import feathers.layout.IVirtualLayout;
import feathers.layout.Measurements;
import feathers.style.IVariantStyleObject;
import feathers.utils.AbstractDisplayObjectRecycler;
import feathers.utils.DisplayObjectRecycler;
import haxe.ds.ObjectMap;
import haxe.ds.StringMap;
import openfl.display.DisplayObject;
import openfl.errors.ArgumentError;
import openfl.errors.IllegalOperationError;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.events.TouchEvent;
import openfl.geom.Point;
import openfl.text.TextField;
import openfl.ui.Keyboard;
#if air
import openfl.ui.Multitouch;
#end
#if (openfl >= "9.1.0")
import openfl.utils.ObjectPool;
#else
import openfl._internal.utils.ObjectPool;
#end
#if lime
import lime.ui.KeyCode;
#end

/**
	Displays a pop-up menu of items.

	The following example creates a menu, gives it a data provider, tells the
	item renderer how to interpret the data, and listens for when an item is
	triggered:

	```haxe
	var menu = new Menu();

	menu.dataProvider = new ArrayHierarhicalCollection<MenuItemData>([
		{ text: "New" },
		{ text: "Open" },
		{ separator: true },
		{ text: "Save" },
		{ separator: true },
		{ text: "Quit" }
	], (item:MenuItemData) -> item.children);

	menu.itemToText = (item:MenuItemData) -> {
		return item.text;
	};

	menu.itemToSeparator = (item:MenuItemData) -> {
		return item.separator;
	};

	menu.addEventListener(MenuEvent.ITEM_TRIGGER, (event:MenuEvent) -> {
		var menu = cast(event.currentTarget, Menu);
		trace("Menu item triggered: " + event.state.index + " " + event.state.text);
	});

	menu.showAtPosition(10.0, 20.0);
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
	taps or clicks an item renderer in the menu. The pointer must remain
	within the bounds of the item renderer on release, and the menu cannot
	scroll before release, or the gesture will be ignored.

	@event openfl.events.Event.CLOSE Dispatched when the menu closes.

	@see [Tutorial: How to use the Menu component](https://feathersui.com/learn/haxe-openfl/menu/)
	@see `feathers.controls.MenuBar`

	@since 1.4.0
**/
@:event(openfl.events.Event.CHANGE)
@:event(feathers.events.MenuEvent.ITEM_TRIGGER)
@:event(openfl.events.Event.CLOSE)
@:access(feathers.data.MenuItemState)
@defaultXmlProperty("dataProvider")
@:styleContext
class Menu extends BaseScrollContainer implements IIndexSelector implements IDataSelector<Dynamic> implements IFocusContainer {
	/**
		The variant used to style the menu's item renderers in a theme.

		To override this default variant, set the
		`Menu.customItemRendererVariant` property.

		@see `Menu.customItemRendererVariant`
		@see `feathers.style.IVariantStyleObject.variant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.4.0
	**/
	public static final CHILD_VARIANT_ITEM_RENDERER = "menu_itemRenderer";

	private static final INVALIDATION_FLAG_ITEM_RENDERER_FACTORY = InvalidationFlag.CUSTOM("itemRendererFactory");

	private static final RESET_ITEM_STATE = new MenuItemState();

	private static function defaultItemToText(data:Dynamic):String {
		return Std.string(data);
	}

	private static function defaultItemToEnabled(data:Dynamic):Bool {
		return true;
	}

	private static function defaultItemToSeparator(data:Dynamic):Bool {
		return false;
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
		Creates a new `Menu` object.

		@since 1.4.0
	**/
	public function new(?dataProvider:IHierarchicalCollection<Dynamic>, ?itemTriggerListener:(MenuEvent) -> Void) {
		initializeMenuTheme();

		super();

		this.dataProvider = dataProvider;

		this.tabEnabled = true;
		this.focusRect = null;

		if (this.viewPort == null) {
			this.menuViewPort = new AdvancedLayoutViewPort();
			this.addChild(this.menuViewPort);
			this.viewPort = this.menuViewPort;
		}

		this.addEventListener(KeyboardEvent.KEY_DOWN, menu_keyDownHandler);
		this.addEventListener(Event.REMOVED_FROM_STAGE, menu_removedFromStageHandler);

		if (itemTriggerListener != null) {
			this.addEventListener(MenuEvent.ITEM_TRIGGER, itemTriggerListener);
		}
	}

	public var menuOwner:Menu = null;
	public var menuBarOwner:MenuBar = null;

	private var _subMenu:Menu;
	private var popUpAdapter:IPopUpAdapter;

	private var menuViewPort:AdvancedLayoutViewPort;

	#if (flash && haxe_ver < 4.3) @:getter(tabEnabled) #end
	override private function get_tabEnabled():Bool {
		return this._enabled && this.rawTabEnabled;
	}

	private var _childFocusEnabled:Bool = true;

	/**
		@see `feathers.core.IFocusContainer.childFocusEnabled`
	**/
	public var childFocusEnabled(get, set):Bool;

	private function get_childFocusEnabled():Bool {
		return this._enabled && this._childFocusEnabled;
	}

	private function set_childFocusEnabled(value:Bool):Bool {
		if (this._childFocusEnabled == value) {
			return this._childFocusEnabled;
		}
		this._childFocusEnabled = value;
		return this._childFocusEnabled;
	}

	private var _dataProvider:IHierarchicalCollection<Dynamic>;

	/**
		The collection of data displayed by the menu.

		Items in the collection must be class instances or anonymous structures.
		Do not add primitive values (such as strings, booleans, or numeric
		values) directly to the collection.

		Additionally, all items in the collection must be unique object
		instances. Do not add the same instance to the collection more than
		once because a runtime exception will be thrown.

		The following example passes in a data provider and tells the item
		renderer how to interpret the data:

		```haxe
		menu.dataProvider = new ArrayCollection([
			{ text: "Milk" },
			{ text: "Eggs" },
			{ text: "Bread" },
			{ text: "Chicken" },
		]);

		menu.itemToText = (item:Dynamic) -> {
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
		#if (hl && haxe_ver < 4.3)
		this._virtualCache.splice(0, this._virtualCache.length);
		#else
		this._virtualCache.resize(0);
		#end
		if (this._dataProvider != null) {
			this._dataProvider.removeEventListener(Event.CHANGE, menu_dataProvider_changeHandler);
			this._dataProvider.removeEventListener(HierarchicalCollectionEvent.ADD_ITEM, menu_dataProvider_addItemHandler);
			this._dataProvider.removeEventListener(HierarchicalCollectionEvent.REMOVE_ITEM, menu_dataProvider_removeItemHandler);
			this._dataProvider.removeEventListener(HierarchicalCollectionEvent.REPLACE_ITEM, menu_dataProvider_replaceItemHandler);
			this._dataProvider.removeEventListener(HierarchicalCollectionEvent.REMOVE_ALL, menu_dataProvider_removeAllHandler);
			this._dataProvider.removeEventListener(HierarchicalCollectionEvent.RESET, menu_dataProvider_resetHandler);
			this._dataProvider.removeEventListener(HierarchicalCollectionEvent.SORT_CHANGE, menu_dataProvider_sortChangeHandler);
			this._dataProvider.removeEventListener(HierarchicalCollectionEvent.FILTER_CHANGE, menu_dataProvider_filterChangeHandler);
			this._dataProvider.removeEventListener(HierarchicalCollectionEvent.UPDATE_ITEM, menu_dataProvider_updateItemHandler);
			this._dataProvider.removeEventListener(HierarchicalCollectionEvent.UPDATE_ALL, menu_dataProvider_updateAllHandler);
		}
		this._dataProvider = value;
		if (this._dataProvider != null) {
			this._virtualCache.resize(this._dataProvider.getLength());
			this._dataProvider.addEventListener(Event.CHANGE, menu_dataProvider_changeHandler);
			this._dataProvider.addEventListener(HierarchicalCollectionEvent.ADD_ITEM, menu_dataProvider_addItemHandler);
			this._dataProvider.addEventListener(HierarchicalCollectionEvent.REMOVE_ITEM, menu_dataProvider_removeItemHandler);
			this._dataProvider.addEventListener(HierarchicalCollectionEvent.REPLACE_ITEM, menu_dataProvider_replaceItemHandler);
			this._dataProvider.addEventListener(HierarchicalCollectionEvent.REMOVE_ALL, menu_dataProvider_removeAllHandler);
			this._dataProvider.addEventListener(HierarchicalCollectionEvent.RESET, menu_dataProvider_resetHandler);
			this._dataProvider.addEventListener(HierarchicalCollectionEvent.SORT_CHANGE, menu_dataProvider_sortChangeHandler);
			this._dataProvider.addEventListener(HierarchicalCollectionEvent.FILTER_CHANGE, menu_dataProvider_filterChangeHandler);
			this._dataProvider.addEventListener(HierarchicalCollectionEvent.UPDATE_ITEM, menu_dataProvider_updateItemHandler);
			this._dataProvider.addEventListener(HierarchicalCollectionEvent.UPDATE_ALL, menu_dataProvider_updateAllHandler);
		}

		// reset the scroll position because this is a drastic change and
		// the data is probably completely different
		this.scrollX = 0.0;
		this.scrollY = 0.0;

		// clear the selection for the same reason
		this.selectedIndex = -1; // use the setter

		this.setInvalid(DATA);
		FeathersEvent.dispatch(this, "dataChange");
		return this._dataProvider;
	}

	private var _selectedIndex:Int = -1;

	/**
		@see `feathers.core.IIndexSelector.selectedIndex`
	**/
	@:bindable("change")
	@:inspectable(defaultValue = "-1")
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

	private var _previousLayout:ILayout;

	/**
		The layout algorithm used to position and size the menu's items.

		By default, if no layout is provided by the time that the menu
		initializes, a default layout that displays items vertically will be
		created.

		The following example tells the menu to use a horizontal layout:

		```haxe
		var layout = new HorizontalListLayout();
		layout.gap = 20.0;
		layout.padding = 20.0;
		menu.layout = layout;
		```

		@since 1.4.0
	**/
	@:style
	public var layout:ILayout = null;

	private var _previousCustomItemRendererVariant:String = null;

	/**
		A custom variant to set on all item renderers, instead of
		`Menu.CHILD_VARIANT_ITEM_RENDERER`.

		The `customItemRendererVariant` will be not be used if the result of
		`itemRendererRecycler.create()` already has a variant set.

		@see `Menu.CHILD_VARIANT_ITEM_RENDERER`
		@see `feathers.style.IVariantStyleObject.variant`

		@since 1.4.0
	**/
	@:style
	public var customItemRendererVariant:String = null;

	/**
		Manages item renderers used by the menu.

		In the following example, the menu uses a custom item renderer class:

		```haxe
		menu.itemRendererRecycler = DisplayObjectRecycler.withClass(CustomItemRenderer);
		```

		@see `feathers.controls.dataRenderers.ItemRenderer`
		@see `feathers.controls.dataRenderers.LayoutGroupItemRenderer`

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
		this._defaultStorage.measurements = null;
		this.setInvalid(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
		return this._defaultStorage.itemRendererRecycler;
	}

	/**
		Manages separator renderers used by the menu.

		In the following example, the menu uses a custom item renderer class:

		```haxe
		menu.separatorRecycler = DisplayObjectRecycler.withClass(CustomItemRenderer);
		```

		@see `feathers.controls.HRule`

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
		this._separatorStorage.measurements = null;
		this.setInvalid(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
		return this._separatorStorage.itemRendererRecycler;
	}

	private var _forceItemStateUpdate:Bool = false;

	/**
		Forces the `itemRendererRecycler.update()` method to be called with the
		`MenuItemState` when the menu validates, even if the item's state has
		not changed since the previous validation.

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
		When a menu requires multiple item renderer types, this function is used
		to determine which type of item renderer is required for a specific item.
		Returns the ID of the item renderer recycler to use for the item, or
		`null` if the default `itemRendererRecycler` should be used.

		The following example provides an `itemRendererRecyclerIDFunction`:

		```haxe
		var regularItemRecycler = DisplayObjectRecycler.withClass(ItemRenderer);
		var firstItemRecycler = DisplayObjectRecycler.withClass(MyCustomItemRenderer);

		menu.setItemRendererRecycler("regular-item", regularItemRecycler);
		menu.setItemRendererRecycler("first-item", firstItemRecycler);

		menu.itemRendererRecyclerIDFunction = function(state:MenuItemState):String {
			if(state.index == 0) {
				return "first-item";
			}
			return "regular-item";
		};
		```

		@default null

		@see `Menu.setItemRendererRecycler()`
		@see `Menu.itemRendererRecycler

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

	private var _defaultStorage = new ItemRendererStorage(null, DisplayObjectRecycler.withClass(ItemRenderer));
	private var _separatorStorage = new ItemRendererStorage("__menu_separator", DisplayObjectRecycler.withClass(HRule));
	private var _additionalStorage:Array<ItemRendererStorage> = null;
	private var objectDataToItemRenderer = new ObjectMap<Dynamic, DisplayObject>();
	private var stringDataToItemRenderer = new StringMap<DisplayObject>();
	private var itemRendererToItemState = new ObjectMap<DisplayObject, MenuItemState>();
	private var itemStatePool = new ObjectPool(() -> new MenuItemState());
	private var _unrenderedData:Array<Dynamic> = [];
	private var _virtualCache:Array<Dynamic> = [];
	private var _visibleIndices:VirtualLayoutRange = new VirtualLayoutRange(0, 0);
	private var _tempVisibleIndices:VirtualLayoutRange = new VirtualLayoutRange(0, 0);
	private var _layoutItems:Array<DisplayObject> = [];

	private var _virtualLayout:Bool = true;

	/**
		Indicates if the menu's layout is allowed to virtualize items or not.

		The following example disables virtual layouts:

		```haxe
		menu.virtualLayout = false;
		```

		@since 1.4.0
	**/
	public var virtualLayout(get, set):Bool;

	private function get_virtualLayout():Bool {
		return this._virtualLayout;
	}

	private function set_virtualLayout(value:Bool):Bool {
		if (this._virtualLayout = value) {
			return this._virtualLayout;
		}
		this._virtualLayout = value;
		this.setInvalid(LAYOUT);
		return this._virtualLayout;
	}

	/**
		Indicates if selection is changed with `MouseEvent.CLICK` or
		`TouchEvent.TOUCH_TAP` when the item renderer does not implement the
		`IToggle` interface. If set to `false`, all item renderers must control
		their own selection manually (not only ones that implement `IToggle`).

		The following example disables pointer selection:

		```haxe
		menu.pointerSelectionEnabled = false;
		```

		@since 1.4.0
	**/
	public var pointerSelectionEnabled:Bool = true;

	private var _pendingScrollIndex:Int = -1;
	private var _pendingScrollDuration:Null<Float> = null;

	private var _ignoreSelectionChange = false;
	private var _ignoreLayoutChanges = false;

	private var _itemToText:(Dynamic) -> String = defaultItemToText;

	/**
		Converts an item to text to display within menu. By default, the
		`toString()` method is called to convert an item to text. This method
		may be replaced to provide custom text.

		For example, consider the following item:

		```haxe
		{ text: "Example Item" }
		```

		If the `Menu` should display the text "Example Item", a custom
		implementation of `itemToText()` might look like this:

		```haxe
		menu.itemToText = (item:Dynamic) -> {
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
		var fileItems:Array<Dynamic> = [
			{ text: "Open" },
			{ separator: true },
			{ text: "Quit" },
		];
		```

		If the `Menu` should display some items as separators, a custom
		implementation of `itemToSeparator()` might look like this:

		```haxe
		menu.itemToSeparator = (item:Dynamic) -> {
			return Reflect.hasField(item, "separator") && Reflect.field(item, "separator") == true;
		};
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
		Determines if an item should be enabled or disabled. By default, all
		items are enabled, unless the `Menu` is disabled. This method
		may be replaced to provide a custom value for `enabled`.

		For example, consider the following item:

		```haxe
		{ text: "Example Item", disable: true }
		```

		If the `Menu` should disable an item if the `disable` field is
		`true`, a custom implementation of `itemToEnabled()` might look like
		this:

		```haxe
		menu.itemToEnabled = (item:Dynamic) -> {
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
		Scrolls the menu so that the specified item renderer is completely
		visible. If the item renderer is already completely visible, does not
		update the scroll position.

		A custom animation duration may be specified. To update the scroll
		position without animation, pass a value of `0.0` for the duration.

		@since 1.4.0
	**/
	public function scrollToIndex(index:Int, ?animationDuration:Float):Void {
		if (this._dataProvider == null || this._dataProvider.getLength() == 0) {
			return;
		}
		this._pendingScrollIndex = index;
		this._pendingScrollDuration = animationDuration;
		this.setInvalid(SCROLL);
	}

	/**
		Returns the current item renderer used to render a specific item from
		the data provider. May return `null` if an item doesn't currently have
		an item renderer.

		**Note:** Most menus use "virtual" layouts, which means that only
		the currently-visible subset of items will have an item renderer. As the
		menu scrolls, the items with item renderers will change, and item
		renderers may even be re-used to display different items.

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
		Returns the current item from the data provider that is rendered by a
		specific item renderer.

		@since 1.4.0
	**/
	public function itemRendererToItem(itemRenderer:DisplayObject):Dynamic {
		if (itemRenderer == null) {
			return null;
		}
		var state = this.itemRendererToItemState.get(itemRenderer);
		if (state == null) {
			return null;
		}
		return state.data;
	}

	/**
		Returns the current item renderer used to render the item at the
		specified index in the data provider. May return `null` if an item
		doesn't currently have an item renderer.

		**Note:** Most menus use "virtual" layouts, which means that only the
		currently-visible subset of items will have an item renderer. As the
		menu scrolls, the items with item renderers will change, and item
		renderers may even be re-used to display different items.

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
		Returns the item renderer recycler associated with a specific ID.
		Returns `null` if no recycler is associated with the ID.

		@see `Menu.itemRendererRecyclerIDFunction`
		@see `Menu.setItemRendererRecycler()`

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
		of item renderers may be displayed in the menu. A custom
		`itemRendererRecyclerIDFunction` may be specified to return the ID of
		the recycler to use for a specific item in the data provider.

		To clear a recycler, pass in `null` for the value.

		@see `Menu.itemRendererRecyclerIDFunction`
		@see `Menu.getItemRendererRecycler()`

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
			itemRenderer = this.stringDataToItemRenderer.get(item);
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

	override public function dispose():Void {
		this.closeSubMenu();
		this.refreshInactiveItemRenderers(this._defaultStorage, true);
		this.refreshInactiveItemRenderers(this._separatorStorage, true);
		if (this._additionalStorage != null) {
			for (i in 0...this._additionalStorage.length) {
				var storage = this._additionalStorage[i];
				this.refreshInactiveItemRenderers(storage, true);
			}
		}
		// manually clear the selection so that removing the data provider
		// doesn't result in Event.CHANGE getting dispatched
		this._selectedItem = null;
		this._selectedIndex = -1;
		this.dataProvider = null;
		super.dispose();
	}

	/**
		Shows the menu relative to the specified position, in stage coordinates.

		An optional `context` display object may be passed in to determine the
		`Stage` instance where the menu will be displayed. If `null`, the
		context will default to the `Application.topLevelApplication` value. If
		there is no top-level application, `openfl.Lib.curent

		@since 1.4.0

		@see `Menu.showAtOrigin()`
		@see `Menu.close()`
	**/
	public function showAtPosition(stageX:Float, stageY:Float, ?context:DisplayObject):Void {
		this.initializeNow();

		this.close();

		if (context == null) {
			context = Application.topLevelApplication;
			if (context == null) {
				context = openfl.Lib.current;
			}
		}
		if (context == null) {
			throw new ArgumentError("Menu.showAtPosition() requires a context");
		}
		var stage = context.stage;
		if (stage == null) {
			throw new ArgumentError("Menu.showAtPosition() requires a context that has been added to the stage");
		}

		var popUpRoot = PopUpManager.forStage(stage).root;
		var popUpPosition = new Point(stageX, stageY);
		popUpPosition = popUpRoot.globalToLocal(popUpPosition);

		this.x = popUpPosition.x;
		this.y = popUpPosition.y;
		PopUpManager.addPopUp(this, stage, false, false);

		if (this.parent != null) {
			this.stage.addEventListener(MouseEvent.MOUSE_DOWN, menu_stage_mouseDownHandler, false, 0, true);
			if (this._focusManager != null) {
				this._focusManager.focus = this;
			} else if (this.stage != null) {
				this.stage.focus = this;
			}
		}
	}

	/**
		Shows the menu relative to the specified `origin` display object.

		@since 1.4.0

		@see `Menu.showAtPosition()`
		@see `Menu.close()`
	**/
	public function showAtOrigin(origin:DisplayObject):Void {
		this.showAtOriginInternal(origin);

		if (this.popUpAdapter.active) {
			this.stage.addEventListener(MouseEvent.MOUSE_DOWN, menu_stage_mouseDownHandler, false, 0, true);
			if (this._focusManager != null) {
				this._focusManager.focus = this;
			} else if (this.stage != null) {
				this.stage.focus = this;
			}
		}
	}

	/**
		Closes the menu, if opened.

		When the menu closes, it will dispatch an event of type
		`Event.CLOSE`.

		@see [`openfl.events.Event.CLOSE`](https://api.openfl.org/openfl/events/Event.html#CLOSE)

		@since 1.4.0

		@see `Menu.showAtOrigin()`
		@see `Menu.showAtPosition()`
	**/
	public function close():Void {
		if (this.popUpAdapter != null && this.popUpAdapter.active) {
			this.popUpAdapter.close();
		} else if (this.parent != null) {
			this.parent.removeChild(this);
		}
	}

	private function initializeMenuTheme():Void {
		#if !feathersui_disable_default_theme
		feathers.themes.steel.components.SteelMenuStyles.initialize();
		#end
	}

	override private function update():Void {
		var layoutInvalid = this.isInvalid(LAYOUT);
		var stylesInvalid = this.isInvalid(STYLES);

		if (this._previousCustomItemRendererVariant != this.customItemRendererVariant) {
			this.setInvalidationFlag(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
		}

		if (layoutInvalid || stylesInvalid) {
			if (this._previousLayout != this.layout) {
				// don't keep the old layout's cache because it may not be
				// compatible with the new layout
				#if (hl && haxe_ver < 4.3)
				this._virtualCache.splice(0, this._virtualCache.length);
				#else
				this._virtualCache.resize(0);
				#end
				if (this._dataProvider != null) {
					this._virtualCache.resize(this._dataProvider.getLength());
				}
			}
			this.menuViewPort.layout = this.layout;
			this._previousLayout = this.layout;
		}

		this.menuViewPort.refreshChildren = this.refreshItemRenderers;

		for (flag in this._invalidationFlags.keys()) {
			this.menuViewPort.setInvalid(flag);
		}
		if (this._allInvalid) {
			this.menuViewPort.setInvalid();
		}

		super.update();

		this._previousCustomItemRendererVariant = this.customItemRendererVariant;

		this.handlePendingScroll();
	}

	override private function createScroller():Void {
		super.createScroller();
		this.menuViewPort.scroller = this.scroller;
	}

	override private function refreshScrollerValues():Void {
		super.refreshScrollerValues();
		if ((this.layout is IScrollLayout)) {
			var scrollLayout:IScrollLayout = cast this.layout;
			this.scroller.forceElasticTop = scrollLayout.elasticTop;
			this.scroller.forceElasticRight = scrollLayout.elasticRight;
			this.scroller.forceElasticBottom = scrollLayout.elasticBottom;
			this.scroller.forceElasticLeft = scrollLayout.elasticLeft;
		} else {
			this.scroller.forceElasticTop = false;
			this.scroller.forceElasticRight = false;
			this.scroller.forceElasticBottom = false;
			this.scroller.forceElasticLeft = false;
		}
		this.scroller.snapPositionsX = this.menuViewPort.snapPositionsX;
		this.scroller.snapPositionsY = this.menuViewPort.snapPositionsY;
	}

	override private function needsScrollMeasurement():Bool {
		var oldStart = this._visibleIndices.start;
		var oldEnd = this._visibleIndices.end;
		if (this._virtualLayout && (this.layout is IVirtualLayout)) {
			var virtualLayout:IVirtualLayout = cast this.layout;
			var oldIgnoreLayoutChanges = this._ignoreLayoutChanges;
			this._ignoreLayoutChanges = true;
			virtualLayout.scrollX = this.scroller.scrollX;
			virtualLayout.scrollY = this.scroller.scrollY;
			this._ignoreLayoutChanges = oldIgnoreLayoutChanges;
			virtualLayout.getVisibleIndices(this._layoutItems.length, this.menuViewPort.visibleWidth, this.menuViewPort.visibleHeight,
				this._tempVisibleIndices);
		} else {
			this._tempVisibleIndices.start = 0;
			this._tempVisibleIndices.end = this._layoutItems.length - 1;
		}
		return oldStart != this._tempVisibleIndices.start || oldEnd != this._tempVisibleIndices.end;
	}

	private function refreshItemRenderers(items:Array<DisplayObject>):Void {
		this._layoutItems = items;

		if (this._defaultStorage.itemRendererRecycler.update == null) {
			this._defaultStorage.itemRendererRecycler.update = defaultUpdateItemRenderer;
			if (this._defaultStorage.itemRendererRecycler.reset == null) {
				this._defaultStorage.itemRendererRecycler.reset = defaultResetItemRenderer;
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

		var itemRendererInvalid = this.menuViewPort.isInvalid(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
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

	private function refreshInactiveItemRenderers(storage:ItemRendererStorage, factoryInvalid:Bool):Void {
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

	private function recoverInactiveItemRenderers(storage:ItemRendererStorage):Void {
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
			itemRenderer.removeEventListener(TriggerEvent.TRIGGER, menu_itemRenderer_triggerHandler);
			itemRenderer.removeEventListener(MouseEvent.CLICK, menu_itemRenderer_clickHandler);
			itemRenderer.removeEventListener(TouchEvent.TOUCH_TAP, menu_itemRenderer_touchTapHandler);
			itemRenderer.removeEventListener(Event.CHANGE, menu_itemRenderer_changeHandler);
			itemRenderer.removeEventListener(Event.RESIZE, menu_itemRenderer_resizeHandler);
			itemRenderer.removeEventListener(MouseEvent.ROLL_OVER, menu_itemRenderer_rollOverHandler);
			this.resetItemRenderer(itemRenderer, state, storage);
			if (storage.measurements != null) {
				storage.measurements.restore(itemRenderer);
			}
			this.itemStatePool.release(state);
		}
	}

	private function freeInactiveItemRenderers(storage:ItemRendererStorage):Void {
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

	private function findUnrenderedData():Void {
		// remove all old items, then fill with null
		#if (hl && haxe_ver < 4.3)
		this._layoutItems.splice(0, this._layoutItems.length);
		#else
		this._layoutItems.resize(0);
		#end
		this._visibleIndices.start = 0;
		this._visibleIndices.end = 0;
		if (this._dataProvider == null || this._dataProvider.getLength() == 0) {
			return;
		}
		this._layoutItems.resize(this._dataProvider.getLength());

		if (this._virtualLayout && (this.layout is IVirtualLayout)) {
			var virtualLayout:IVirtualLayout = cast this.layout;
			var oldIgnoreLayoutChanges = this._ignoreLayoutChanges;
			this._ignoreLayoutChanges = true;
			virtualLayout.scrollX = this.scroller.scrollX;
			virtualLayout.scrollY = this.scroller.scrollY;
			virtualLayout.virtualCache = this._virtualCache;
			this._ignoreLayoutChanges = oldIgnoreLayoutChanges;
			virtualLayout.getVisibleIndices(this._dataProvider.getLength(), this.menuViewPort.visibleWidth, this.menuViewPort.visibleHeight,
				this._visibleIndices);
		} else {
			this._visibleIndices.start = 0;
			this._visibleIndices.end = this._dataProvider.getLength() - 1;
		}
		for (i in this._visibleIndices.start...this._visibleIndices.end + 1) {
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
				// if this item renderer used to be the typical layout item, but
				// it isn't anymore, it may have been set invisible
				itemRenderer.visible = true;
				this._layoutItems[i] = itemRenderer;
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

	private function populateCurrentItemState(item:Dynamic, index:Int, state:MenuItemState, force:Bool):Bool {
		var changed = false;
		if (force || state.menuBarOwner != null) {
			state.menuBarOwner = this.menuBarOwner;
			changed = true;
		}
		if (force || state.menuOwner != this) {
			state.menuOwner = this;
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

	private function resetItemRenderer(itemRenderer:DisplayObject, state:MenuItemState, storage:ItemRendererStorage):Void {
		var oldIgnoreSelectionChange = this._ignoreSelectionChange;
		this._ignoreSelectionChange = true;
		var recycler = storage.oldItemRendererRecycler != null ? storage.oldItemRendererRecycler : storage.itemRendererRecycler;
		if (recycler != null && recycler.reset != null) {
			recycler.reset(itemRenderer, state);
		}
		this._ignoreSelectionChange = oldIgnoreSelectionChange;
		this.refreshItemRendererProperties(itemRenderer, RESET_ITEM_STATE);
	}

	private function updateItemRenderer(itemRenderer:DisplayObject, state:MenuItemState, storage:ItemRendererStorage):Void {
		state.recyclerID = storage.id;
		var oldIgnoreSelectionChange = this._ignoreSelectionChange;
		this._ignoreSelectionChange = true;
		if (storage.itemRendererRecycler.update != null) {
			storage.itemRendererRecycler.update(itemRenderer, state);
		}
		this._ignoreSelectionChange = oldIgnoreSelectionChange;
		this.refreshItemRendererProperties(itemRenderer, state);
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
			// if the renderer is an IDataRenderer, this cannot be overridden
			dataRenderer.data = state.data;
		}
		if ((itemRenderer is IMenuItemRenderer)) {
			var listRenderer:IMenuItemRenderer = cast itemRenderer;
			listRenderer.index = state.index;
			listRenderer.menuBarOwner = state.menuBarOwner;
			listRenderer.menuOwner = state.menuOwner;
		}
		if ((itemRenderer is ILayoutIndexObject)) {
			var layoutIndexObject:ILayoutIndexObject = cast itemRenderer;
			layoutIndexObject.layoutIndex = state.index;
		}
		if ((itemRenderer is IToggle)) {
			var toggle:IToggle = cast itemRenderer;
			// if the renderer is an IToggle, this cannot be overridden
			toggle.selected = state.selected;
		}
		this._ignoreSelectionChange = oldIgnoreSelectionChange;
	}

	private function renderUnrenderedData():Void {
		for (item in this._unrenderedData) {
			var index = dataProviderIndexOf(item);
			var state = this.itemStatePool.get();
			this.populateCurrentItemState(item, index, state, true);
			var itemRenderer = this.createItemRenderer(state);
			itemRenderer.visible = true;
			this.menuViewPort.addChild(itemRenderer);
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
			// save measurements after initialize, because width/height could be
			// set explicitly there, and we want to restore those values
			if (storage.measurements == null) {
				storage.measurements = new Measurements(itemRenderer);
			}
		} else {
			itemRenderer = storage.inactiveItemRenderers.shift();
		}
		this.updateItemRenderer(itemRenderer, state, storage);
		if ((itemRenderer is ITriggerView)) {
			// prefer TriggerEvent.TRIGGER
			itemRenderer.addEventListener(TriggerEvent.TRIGGER, menu_itemRenderer_triggerHandler);
		} else {
			// fall back to these events if TriggerEvent.TRIGGER isn't available
			itemRenderer.addEventListener(MouseEvent.CLICK, menu_itemRenderer_clickHandler);
			#if (openfl >= "9.0.0")
			itemRenderer.addEventListener(TouchEvent.TOUCH_TAP, menu_itemRenderer_touchTapHandler);
			#end
		}
		if ((itemRenderer is IToggle)) {
			itemRenderer.addEventListener(Event.CHANGE, menu_itemRenderer_changeHandler);
		}
		if ((itemRenderer is IMeasureObject)) {
			itemRenderer.addEventListener(Event.RESIZE, menu_itemRenderer_resizeHandler);
		}
		itemRenderer.addEventListener(MouseEvent.ROLL_OVER, menu_itemRenderer_rollOverHandler);
		this.itemRendererToItemState.set(itemRenderer, state);
		var item = state.data;
		if ((item is String)) {
			this.stringDataToItemRenderer.set(cast item, itemRenderer);
		} else {
			this.objectDataToItemRenderer.set(state.data, itemRenderer);
		}
		storage.activeItemRenderers.push(itemRenderer);
		return itemRenderer;
	}

	private function destroyItemRenderer(itemRenderer:DisplayObject, recycler:DisplayObjectRecycler<Dynamic, MenuItemState, DisplayObject>):Void {
		this.menuViewPort.removeChild(itemRenderer);
		if (recycler != null && recycler.destroy != null) {
			recycler.destroy(itemRenderer);
		}
	}

	private function itemStateToStorage(state:MenuItemState):ItemRendererStorage {
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
		var storage = new ItemRendererStorage(recyclerID, recycler);
		this._additionalStorage.push(storage);
		return storage;
	}

	private function showAtOriginInternal(origin:DisplayObject):Void {
		this.initializeNow();

		this.close();

		if (this.popUpAdapter == null) {
			if (this.menuOwner != null) {
				this.popUpAdapter = new SubMenuPopUpAdapter();
			} else {
				this.popUpAdapter = new DropDownPopUpAdapter();
			}
		}
		this.popUpAdapter.open(this, origin);
	}

	private function refreshSelectedIndicesAfterFilterOrSort():Void {
		if (this._selectedIndex == -1) {
			return;
		}
		// the index may have changed, possibly even to -1, if the item was
		// filtered out
		this.selectedIndex = dataProviderIndexOf(this._selectedItem); // use the setter
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

	private function handleSelectionChange(item:Dynamic, index:Int, ctrlKey:Bool, shiftKey:Bool):Void {
		if (index == -1) {
			// use the setter
			this.selectedItem = null;
			return;
		}
		// use the setter
		this.selectedItem = item;
		if (index != -1) {
			this.scrollToIndex(index);
		}
	}

	private function handlePendingScroll():Void {
		if (this._pendingScrollIndex == -1) {
			return;
		}
		var index = this._pendingScrollIndex;
		var duration = this._pendingScrollDuration != null ? this._pendingScrollDuration : 0.0;
		this._pendingScrollIndex = -1;
		this._pendingScrollDuration = null;

		if (this._dataProvider == null || this._dataProvider.getLength() == 0) {
			return;
		}

		var targetX = this.scrollX;
		var targetY = this.scrollY;
		if ((this.layout is IScrollLayout)) {
			var scrollLayout:IScrollLayout = cast this.layout;
			var result = scrollLayout.getNearestScrollPositionForIndex(index, this._dataProvider.getLength(), this.viewPort.visibleWidth,
				this.viewPort.visibleHeight);
			targetX = result.x;
			targetY = result.y;
		} else {
			var item = this._dataProvider.get([index]);
			var itemRenderer:DisplayObject = null;
			if ((item is String)) {
				itemRenderer = this.stringDataToItemRenderer.get(cast item);
			} else {
				itemRenderer = this.objectDataToItemRenderer.get(item);
			}
			if (itemRenderer == null) {
				return;
			}

			var maxX = itemRenderer.x;
			var minX = maxX + itemRenderer.width - this.viewPort.visibleWidth;
			if (targetX < minX) {
				targetX = minX;
			} else if (targetX > maxX) {
				targetX = maxX;
			}

			var maxY = itemRenderer.y;
			var minY = maxY + itemRenderer.height - this.viewPort.visibleHeight;
			if (targetY < minY) {
				targetY = minY;
			} else if (targetY > maxY) {
				targetY = maxY;
			}
		}

		if (duration == 0.0) {
			this.scroller.stop();
			this.scroller.scrollX = targetX;
			this.scroller.scrollY = targetY;
		} else {
			this.scroller.throwTo(targetX, targetY, duration);
		}
	}

	private function menu_itemRenderer_touchTapHandler(event:TouchEvent):Void {
		if (!this._enabled) {
			return;
		}
		if (event.isPrimaryTouchPoint #if air && Multitouch.mapTouchToMouse #end) {
			// ignore the primary one because MouseEvent.CLICK will catch it
			return;
		}

		var itemRenderer = cast(event.currentTarget, DisplayObject);
		var state = this.itemRendererToItemState.get(itemRenderer);
		if (state.branch || state.separator || !state.enabled) {
			// branches and separators don't trigger
			return;
		}

		MenuEvent.dispatch(this, MenuEvent.ITEM_TRIGGER, state);

		if (this.pointerSelectionEnabled) {
			this.handleSelectionChange(state.data, state.index, event.ctrlKey, event.shiftKey);
		}

		this.close();
	}

	private function menu_itemRenderer_clickHandler(event:MouseEvent):Void {
		if (!this._enabled) {
			return;
		}

		var itemRenderer = cast(event.currentTarget, DisplayObject);
		var state = this.itemRendererToItemState.get(itemRenderer);
		if (state.branch || state.separator || !state.enabled) {
			// branches and separators don't trigger
			return;
		}

		MenuEvent.dispatch(this, MenuEvent.ITEM_TRIGGER, state);

		if (this.pointerSelectionEnabled) {
			this.handleSelectionChange(state.data, state.index, event.ctrlKey, event.shiftKey);
		}

		this.close();
	}

	private function menu_itemRenderer_triggerHandler(event:TriggerEvent):Void {
		if (!this._enabled) {
			return;
		}

		var itemRenderer = cast(event.currentTarget, DisplayObject);
		var state = this.itemRendererToItemState.get(itemRenderer);
		if (state.branch || state.separator || !state.enabled) {
			// branches and separators don't trigger
			return;
		}

		MenuEvent.dispatch(this, MenuEvent.ITEM_TRIGGER, state);

		this.handleSelectionChange(state.data, state.index, event.ctrlKey, event.shiftKey);

		this.close();
	}

	private function menu_itemRenderer_resizeHandler(event:Event):Void {
		if (this._validating) {
			return;
		}
		this.setInvalid(LAYOUT);
	}

	private function menu_itemRenderer_changeHandler(event:Event):Void {
		if (this._ignoreSelectionChange) {
			return;
		}
		var itemRenderer = cast(event.currentTarget, DisplayObject);
		var toggleItemRenderer = cast(itemRenderer, IToggle);
		var state = this.itemRendererToItemState.get(itemRenderer);
		if (toggleItemRenderer.selected == state.selected) {
			// nothing has changed
			return;
		}
		// if we get here, the selected property of the renderer changed
		// unexpectedly, and we need to restore its proper state
		this.setInvalid(SELECTION);
	}

	private function menu_dataProvider_changeHandler(event:Event):Void {
		this.setInvalid(DATA);
	}

	private function menu_dataProvider_addItemHandler(event:HierarchicalCollectionEvent):Void {
		var index = -1;
		if (event.location.length == 1) {
			index = event.location[0];
		}
		if (index == -1) {
			return;
		}
		if (this._virtualCache != null) {
			this._virtualCache.insert(index, null);
		}
		if (this._selectedIndex == -1) {
			return;
		}
		if (this._selectedIndex >= index) {
			this._selectedIndex++;
			FeathersEvent.dispatch(this, Event.CHANGE);
		}
	}

	private function menu_dataProvider_removeItemHandler(event:HierarchicalCollectionEvent):Void {
		var index = -1;
		if (event.location.length == 1) {
			index = event.location[0];
		}
		if (index == -1) {
			return;
		}
		if (this._virtualCache != null) {
			this._virtualCache.remove(index);
		}
		if (this.selectedIndex == -1) {
			return;
		}
		if (this._selectedIndex == index) {
			if (index == this._dataProvider.getLength()) {
				// keep the same selected index, unless the last item was removed
				this._selectedIndex = this._dataProvider.getLength() - 1;
			}
			if (this._selectedIndex == -1) {
				this._selectedItem = null;
			} else {
				this._selectedItem = this._dataProvider.get([this._selectedIndex]);
			}
			FeathersEvent.dispatch(this, Event.CHANGE);
		} else if (this._selectedIndex > index) {
			this._selectedIndex--;
			// the selected item will be the same. only its index changed.
			FeathersEvent.dispatch(this, Event.CHANGE);
		}
	}

	private function menu_dataProvider_replaceItemHandler(event:HierarchicalCollectionEvent):Void {
		var index = -1;
		if (event.location.length == 1) {
			index = event.location[0];
		}
		if (index == -1) {
			return;
		}
		if (this._virtualCache != null) {
			this._virtualCache[index] = null;
		}
		if (this._selectedIndex == -1) {
			return;
		}
		if (this._selectedIndex == index) {
			this._selectedItem = this._dataProvider.get([index]);
			FeathersEvent.dispatch(this, Event.CHANGE);
		}
	}

	private function menu_dataProvider_removeAllHandler(event:HierarchicalCollectionEvent):Void {
		if (this._virtualCache != null) {
			#if (hl && haxe_ver < 4.3)
			this._virtualCache.splice(0, this._virtualCache.length);
			#else
			this._virtualCache.resize(0);
			#end
		}
		// use the setter
		this.selectedIndex = -1;
	}

	private function menu_dataProvider_resetHandler(event:HierarchicalCollectionEvent):Void {
		if (this._virtualCache != null) {
			#if (hl && haxe_ver < 4.3)
			this._virtualCache.splice(0, this._virtualCache.length);
			#else
			this._virtualCache.resize(0);
			#end
			this._virtualCache.resize(this._dataProvider.getLength());
		}
		// use the setter
		this.selectedIndex = -1;
	}

	private function menu_dataProvider_sortChangeHandler(event:HierarchicalCollectionEvent):Void {
		if (this._virtualCache != null) {
			// we don't know exactly which indices have changed, so reset the
			// whole cache.
			#if (hl && haxe_ver < 4.3)
			this._virtualCache.splice(0, this._virtualCache.length);
			#else
			this._virtualCache.resize(0);
			#end
			this._virtualCache.resize(this._dataProvider.getLength());
		}
		this.refreshSelectedIndicesAfterFilterOrSort();
	}

	private function menu_dataProvider_filterChangeHandler(event:HierarchicalCollectionEvent):Void {
		if (this._virtualCache != null) {
			// we don't know exactly which indices have changed, so reset the
			// whole cache.
			#if (hl && haxe_ver < 4.3)
			this._virtualCache.splice(0, this._virtualCache.length);
			#else
			this._virtualCache.resize(0);
			#end
			this._virtualCache.resize(this._dataProvider.getLength());
		}
		this.refreshSelectedIndicesAfterFilterOrSort();
	}

	private function updateItemRendererForIndex(index:Int):Void {
		if (this._virtualCache != null) {
			this._virtualCache[index] = null;
		}
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
		if (state.menuOwner == null) {
			// a previous update is already pending
			return;
		}
		var storage = this.itemStateToStorage(state);
		this.populateCurrentItemState(item, index, state, true);
		// in order to display the same item with modified properties, this
		// hack tricks the item renderer into thinking that it has been given
		// a different item to render.
		this.resetItemRenderer(itemRenderer, state, storage);
		if (storage.measurements != null) {
			storage.measurements.restore(itemRenderer);
		}
		// ensures that the change is detected when we validate later
		state.menuOwner = null;
		this.setInvalid(DATA);
	}

	private function menu_dataProvider_updateItemHandler(event:HierarchicalCollectionEvent):Void {
		var index = -1;
		if (event.location.length == 1) {
			index = event.location[0];
		}
		if (index == -1) {
			return;
		}
		this.updateItemRendererForIndex(index);
	}

	private function menu_dataProvider_updateAllHandler(event:HierarchicalCollectionEvent):Void {
		for (i in 0...this._dataProvider.getLength()) {
			this.updateItemRendererForIndex(i);
		}
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
		var nextKeyCode = event.keyCode;
		var lastResult = -1;
		while (needsAnotherPass) {
			needsAnotherPass = false;
			switch (nextKeyCode) {
				case Keyboard.UP:
					if (result == -1) {
						// special case: if there is no current selection,
						// start at the bottom isntead of the top.
						// both macOS and Windows behave like this.
						result = this._dataProvider.getLength() - 1;
					} else {
						result = result - 1;
					}
				case Keyboard.DOWN:
					result = result + 1;
				case Keyboard.PAGE_UP:
					result = result - 1;
				case Keyboard.PAGE_DOWN:
					result = result + 1;
				case Keyboard.HOME:
					result = 0;
					nextKeyCode = Keyboard.DOWN;
				case Keyboard.END:
					result = this._dataProvider.getLength() - 1;
					nextKeyCode = Keyboard.UP;
				default:
					// not keyboard navigation
					return;
			}
			if (result < 0) {
				result = 0;
			} else if (result >= this._dataProvider.getLength()) {
				result = this._dataProvider.getLength() - 1;
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

		var changed = this._selectedIndex != result;
		if (!changed && result != -1) {
			var itemRenderer = this.itemToItemRenderer(this._dataProvider.get([result]));
			if (itemRenderer == null) {
				// if we can't find the item renderer, we need to scroll
				changed = true;
			} else if ((this.layout is IScrollLayout)) {
				var scrollLayout:IScrollLayout = cast this.layout;
				var nearestScrollPosition = scrollLayout.getNearestScrollPositionForIndex(result, this._dataProvider.getLength(), this.viewPort.visibleWidth,
					this.viewPort.visibleHeight);

				if (this.scrollX != nearestScrollPosition.x || this.scrollY != nearestScrollPosition.y) {
					changed = true;
				}
			}
		}
		event.preventDefault();
		// use the setter
		this.selectedIndex = result;
		if (this._selectedIndex != -1) {
			this.scrollToIndex(this._selectedIndex);
		}
		// restore focus to the container so that the wrong item renderer
		// doesn't respond to keyboard events
		if (this._focusManager != null) {
			this._focusManager.focus = this;
		} else if (this.stage != null) {
			this.stage.focus = this;
		}
		this.closeSubMenu();
		if (this._selectedIndex != -1) {
			var itemRenderer = this.indexToItemRenderer(this._selectedIndex);
			if (itemRenderer != null) {
				this.openSubMenu(itemRenderer);
			}
		}
	}

	override private function baseScrollContainer_keyDownHandler(event:KeyboardEvent):Void {
		if (!this._enabled || event.isDefaultPrevented()) {
			return;
		}
		if (this.stage != null && (this.stage.focus is TextField)) {
			var textField:TextField = cast this.stage.focus;
			if (textField.type == INPUT) {
				// if an input TextField has focus, don't scroll because the
				// TextField should have precedence, and the TextField won't
				// call preventDefault() on the event.
				return;
			}
		}
		switch (event.keyCode) {
			case Keyboard.LEFT:
				if (this.menuOwner != null) {
					// if this is a sub-menu, it can close itself
					event.preventDefault();
					this.close();
				}
			case Keyboard.RIGHT:
				if (this._subMenu == null && this._selectedIndex != -1) {
					// the sub-menu may or may not be already open
					var itemRenderer = this.indexToItemRenderer(this._selectedIndex);
					if (itemRenderer != null) {
						var state = this.itemRendererToItemState.get(itemRenderer);
						if (state != null && state.branch) {
							this.openSubMenu(itemRenderer);
							if (this._subMenu != null) {
								event.preventDefault();
							}
						}
					}
				}
				if (this._subMenu != null) {
					// if there's a sub-menu, pass focus and select the first item
					var subMenuHasFocus = false;
					if (this._focusManager != null) {
						subMenuHasFocus = this._focusManager.focus == this._subMenu;
					} else if (this.stage != null) {
						subMenuHasFocus = this.stage.focus == this._subMenu;
					}
					if (!subMenuHasFocus) {
						event.preventDefault();
						if (this._focusManager != null) {
							this._focusManager.focus = this._subMenu;
						} else if (this.stage != null) {
							this.stage.focus = this._subMenu;
						}
						if (this._subMenu.selectedIndex == -1 && this._subMenu.maxSelectedIndex >= 0) {
							this._subMenu.selectedIndex = 0;
						}
					}
				}
			case Keyboard.ESCAPE:
				// if we're owned by a MenuBar, let the MenuBar handle this key
				if (this.stage != null && this.menuBarOwner == null) {
					event.preventDefault();
					this.close();
				}
				return;
			#if lime
			case KeyCode.APP_CONTROL_BACK:
				// if we're owned by a MenuBar, let the MenuBar handle this key
				if (this.stage != null && this.menuBarOwner == null) {
					event.preventDefault();
					this.close();
				}
			#end
		}
		this.navigateWithKeyboard(event);
	}

	private function menu_removedFromStageHandler(event:Event):Void {
		if (this.stage != null) {
			this.stage.removeEventListener(MouseEvent.MOUSE_DOWN, menu_stage_mouseDownHandler);
		}
		this.closeSubMenu();
		FeathersEvent.dispatch(this, Event.CLOSE);
	}

	private function menu_keyDownHandler(event:KeyboardEvent):Void {
		if (!this._enabled || event.isDefaultPrevented()) {
			return;
		}
		if (event.keyCode == Keyboard.SPACE || event.keyCode == Keyboard.ENTER) {
			if (this._selectedItem == null) {
				this.close();
			} else {
				var itemRenderer:DisplayObject = null;
				if ((this._selectedItem is String)) {
					itemRenderer = this.stringDataToItemRenderer.get(cast this._selectedItem);
				} else {
					itemRenderer = this.objectDataToItemRenderer.get(this._selectedItem);
				}
				var state:MenuItemState = null;
				if (itemRenderer != null) {
					state = this.itemRendererToItemState.get(itemRenderer);
				}
				var isTemporary = false;
				if (state == null) {
					// if there is no existing state, use a temporary object
					isTemporary = true;
					state = this.itemStatePool.get();
				}
				this.populateCurrentItemState(this._selectedItem, this._selectedIndex, state, true);
				if (!state.branch && !state.separator && state.enabled) {
					MenuEvent.dispatch(this, MenuEvent.ITEM_TRIGGER, state);
					this.close();
				}
				if (isTemporary) {
					this.itemStatePool.release(state);
				}
			}
		}
	}

	private function openSubMenu(itemRenderer:DisplayObject):Void {
		var itemState = this.itemRendererToItemState.get(itemRenderer);
		if (itemState == null || !itemState.branch) {
			return;
		}

		this.closeSubMenu();

		var menuLocation = [itemState.index];
		var menuCollection = new HierarchicalSubCollection(this._dataProvider, menuLocation);

		this._subMenu = new Menu();
		this._subMenu.menuBarOwner = this.menuBarOwner;
		this._subMenu.menuOwner = this;
		this._subMenu.dataProvider = menuCollection;
		this._subMenu.itemToText = itemToText;
		this._subMenu.itemToSeparator = itemToSeparator;
		this._subMenu.itemToEnabled = itemToEnabled;
		this._subMenu.addEventListener(MenuEvent.ITEM_TRIGGER, menu_subMenu_itemTriggerHandler);
		this._subMenu.addEventListener(Event.CLOSE, menu_subMenu_closeHandler);
		// we want to show it, but we don't want to give it focus
		this._subMenu.showAtOriginInternal(itemRenderer);

		MenuEvent.dispatch(this, MenuEvent.MENU_OPEN, itemState);
	}

	private function closeSubMenu():Void {
		if (this._subMenu != null) {
			this._subMenu.close();
		}
	}

	private function menu_itemRenderer_rollOverHandler(event:MouseEvent):Void {
		this.closeSubMenu();

		var itemRenderer = cast(event.currentTarget, DisplayObject);
		var state = this.itemRendererToItemState.get(itemRenderer);
		if (state != null) {
			if (!state.separator && state.enabled) {
				this.selectedIndex = state.index;
				this.openSubMenu(itemRenderer);
			} else {
				this.selectedIndex = -1;
			}
		}
	}

	private function menu_subMenu_itemTriggerHandler(event:MenuEvent):Void {
		this.closeSubMenu();
		MenuEvent.dispatch(this, MenuEvent.ITEM_TRIGGER, event.state);
		this.close();
	}

	private function menu_subMenu_closeHandler(event:Event):Void {
		var menu = cast(event.currentTarget, Menu);
		menu.removeEventListener(MenuEvent.ITEM_TRIGGER, menu_subMenu_itemTriggerHandler);
		menu.menuBarOwner = null;
		menu.menuOwner = null;
		menu.dispose();
		if (this._subMenu == menu) {
			this._subMenu = null;
		}
		if (this._focusManager != null) {
			this._focusManager.focus = this;
		} else if (this.stage != null) {
			this.stage.focus = this;
		}
	}

	private function menu_stage_mouseDownHandler(event:MouseEvent):Void {
		var target = cast(event.target, DisplayObject);
		while (target != null) {
			if ((target is Menu) || (target is MenuBar)) {
				return;
			}
			target = target.parent;
		}
		this.close();
	}
}

private class ItemRendererStorage {
	public function new(?id:String, ?recycler:DisplayObjectRecycler<Dynamic, MenuItemState, DisplayObject>) {
		this.id = id;
		this.itemRendererRecycler = recycler;
	}

	public var id:String;
	public var oldItemRendererRecycler:DisplayObjectRecycler<Dynamic, MenuItemState, DisplayObject>;
	public var itemRendererRecycler:DisplayObjectRecycler<Dynamic, MenuItemState, DisplayObject>;
	public var activeItemRenderers:Array<DisplayObject> = [];
	public var inactiveItemRenderers:Array<DisplayObject> = [];
	public var measurements:Measurements;
}
