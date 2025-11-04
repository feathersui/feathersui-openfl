/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.controls.dataRenderers.ItemRenderer;
import feathers.controls.popups.IPopUpAdapter;
import feathers.core.FeathersControl;
import feathers.core.IDataSelector;
import feathers.core.IIndexSelector;
import feathers.core.IStageFocusDelegate;
import feathers.core.InvalidationFlag;
import feathers.core.PopUpManager;
import feathers.data.IFlatCollection;
import feathers.data.ListViewItemState;
import feathers.events.FeathersEvent;
import feathers.events.FlatCollectionEvent;
import feathers.events.ListViewEvent;
import feathers.layout.Measurements;
import feathers.utils.AbstractDisplayObjectFactory;
import feathers.utils.AbstractDisplayObjectRecycler;
import feathers.utils.DisplayObjectFactory;
import feathers.utils.DisplayObjectRecycler;
import feathers.utils.MeasurementsUtil;
import openfl.display.DisplayObject;
import openfl.display.InteractiveObject;
import openfl.events.Event;
import openfl.events.FocusEvent;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.events.TouchEvent;
import openfl.ui.Keyboard;
#if air
import openfl.ui.Multitouch;
#end
#if lime
import lime.ui.KeyCode;
#end

/**
	Displays a `Button` that may be triggered to display a `ListView` as a
	pop-up. The list view may be customized to display in different ways, such
	as a drop-down, inside a `Callout`, or as a modal overlay.

	The following example creates a pop-up list, gives it a data provider, tells
	the item renderer how to interpret the data, and listens for when the
	selection changes:

	```haxe
	var popUpListView = new PopUpListView();

	popUpListView.dataProvider = new ArrayCollection([
		{ text: "Milk" },
		{ text: "Eggs" },
		{ text: "Bread" },
		{ text: "Steak" },
	]);

	popUpListView.itemToText = (item:Dynamic) -> {
		return item.text;
	};

	popUpListView.addEventListener(Event.CHANGE, (event:Event) -> {
		var popUpListView = cast(event.currentTarget, PopUpListView);
		trace("PopUpListView changed: " + popUpListView.selectedIndex + " " + popUpListView.selectedItem.text);
	});

	this.addChild(popUpListView);
	```

	@event openfl.events.Event.CHANGE Dispatched when either
	`PopUpListView.selectedItem` or `PopUpListView.selectedIndex` changes.

	@event openfl.events.Event.OPEN Dispatched when the pop-up list view is
	opened.

	@event openfl.events.Event.CLOSE Dispatched when the pop-up list view is
	closed.

	@event feathers.events.ListViewEvent.ITEM_TRIGGER Dispatched when the user
	taps or clicks an item renderer in the pop-up list view. The pointer must
	remain within the bounds of the item renderer on release, and the list
	view cannot scroll before release, or the gesture will be ignored.

	@see [Tutorial: How to use the PopUpListView component](https://feathersui.com/learn/haxe-openfl/pop-up-list-view/)
	@see `feathers.controls.ComboBox`

	@since 1.0.0
**/
@:event(openfl.events.Event.CHANGE)
@:event(openfl.events.Event.OPEN)
@:event(openfl.events.Event.CLOSE)
@:event(feathers.events.ListViewEvent.ITEM_TRIGGER)
@defaultXmlProperty("dataProvider")
@:styleContext
class PopUpListView extends FeathersControl implements IIndexSelector implements IDataSelector<Dynamic> implements IStageFocusDelegate {
	private static final INVALIDATION_FLAG_BUTTON_FACTORY = InvalidationFlag.CUSTOM("buttonFactory");
	private static final INVALIDATION_FLAG_LIST_VIEW_FACTORY = InvalidationFlag.CUSTOM("listViewFactory");

	/**
		The variant used to style the `Button` child component in a theme.

		To override this default variant, set the
		`PopUpListView.customButtonVariant` property.

		@see `PopUpListView.customButtonVariant`
		@see `feathers.style.IVariantStyleObject.variant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_BUTTON = "popUpListView_button";

	/**
		The variant used to style the `ListView` child component in a theme.

		To override this default variant, set the
		`PopUpListView.customListViewVariant` property.

		@see `PopUpListView.customListViewVariant`
		@see `feathers.style.IVariantStyleObject.variant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_LIST_VIEW = "popUpListView_listView";

	private static function defaultItemToText(data:Dynamic):String {
		return Std.string(data);
	}

	private static function defaultItemToEnabled(data:Dynamic):Bool {
		return true;
	}

	private static final defaultButtonFactory = DisplayObjectFactory.withClass(Button);

	private static final defaultListViewFactory = DisplayObjectFactory.withClass(ListView);

	/**
		Creates a new `PopUpListView` object.

		@since 1.0.0
	**/
	public function new(?dataProvider:IFlatCollection<Dynamic>, ?changeListener:(Event) -> Void) {
		initializePopUpListViewTheme();

		super();

		this.dataProvider = dataProvider;

		this.addEventListener(FocusEvent.FOCUS_IN, popUpListView_focusInHandler);
		this.addEventListener(Event.REMOVED_FROM_STAGE, popUpListView_removedFromStageHandler);

		if (changeListener != null) {
			this.addEventListener(Event.CHANGE, changeListener);
		}
	}

	private var button:Button;
	private var listView:ListView;

	private var buttonMeasurements:Measurements = new Measurements();

	@:dox(hide)
	public var stageFocusTarget(get, never):InteractiveObject;

	private function get_stageFocusTarget():InteractiveObject {
		return this.button;
	}

	private var _dataProvider:IFlatCollection<Dynamic>;

	/**
		The collection of data displayed by the list view.

		Items in the collection must be class instances or anonymous structures.
		Do not add primitive values (such as strings, booleans, or numeric
		values) directly to the collection.

		Additionally, all items in the collection must be unique object
		instances. Do not add the same instance to the collection more than
		once because a runtime exception will be thrown.

		The following example passes in a data provider and tells the item
		renderer how to interpret the data:

		```haxe
		popUpListView.dataProvider = new ArrayCollection([
			{ text: "Milk" },
			{ text: "Eggs" },
			{ text: "Bread" },
			{ text: "Chicken" },
		]);

		popUpListView.itemToText = (item:Dynamic) -> {
			return item.text;
		};
		```

		@default null

		@see `feathers.data.ArrayCollection`

		@since 1.0.0
	**/
	@:bindable("dataChange")
	public var dataProvider(get, set):IFlatCollection<Dynamic>;

	private function get_dataProvider():IFlatCollection<Dynamic> {
		return this._dataProvider;
	}

	private function set_dataProvider(value:IFlatCollection<Dynamic>):IFlatCollection<Dynamic> {
		if (this._dataProvider == value) {
			return this._dataProvider;
		}
		if (this._dataProvider != null) {
			this._dataProvider.removeEventListener(FlatCollectionEvent.REMOVE_ALL, popUpListView_dataProvider_removeAllHandler);
			this._dataProvider.removeEventListener(FlatCollectionEvent.UPDATE_ITEM, popUpListView_dataProvider_updateItemHandler);
			this._dataProvider.removeEventListener(FlatCollectionEvent.UPDATE_ALL, popUpListView_dataProvider_updateAllHandler);
		}
		var oldSelectedIndex = this._selectedIndex;
		var oldSelectedItem = this._selectedItem;
		this._dataProvider = value;
		if (this._dataProvider != null) {
			this._dataProvider.addEventListener(FlatCollectionEvent.REMOVE_ALL, popUpListView_dataProvider_removeAllHandler);
			this._dataProvider.addEventListener(FlatCollectionEvent.UPDATE_ITEM, popUpListView_dataProvider_updateItemHandler);
			this._dataProvider.addEventListener(FlatCollectionEvent.UPDATE_ALL, popUpListView_dataProvider_updateAllHandler);
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
		FeathersEvent.dispatch(this, "dataChange");
		return this._dataProvider;
	}

	private var _ignoreListViewChange = false;

	private var _selectedIndex:Int = -1;

	/**
		@see `feathers.core.IIndexSelector.selectedIndex`
	**/
	@:bindable("change")
	@:inspectable
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

	private var _prompt:String;

	/**
		The text displayed by the button when no item is selected.

		The following example sets the pop-up list view's prompt:

		```haxe
		popUpListView.prompt = "Select an item";
		```

		@default null

		@since 1.0.0
	**/
	public var prompt(get, set):String;

	private function get_prompt():String {
		return this._prompt;
	}

	private function set_prompt(value:String):String {
		if (this._prompt == value) {
			return this._prompt;
		}
		this._prompt = value;
		this.setInvalid(DATA);
		return this._prompt;
	}

	private var _itemRendererRecycler:DisplayObjectRecycler<Dynamic, ListViewItemState, DisplayObject> = DisplayObjectRecycler.withClass(ItemRenderer);

	/**
		Manages item renderers used by the pop-up list view.

		In the following example, the pop-up list view uses a custom item
		renderer class:

		```haxe
		popUpListView.itemRendererRecycler = DisplayObjectRecycler.withClass(CustomItemRenderer);
		```

		@see `feathers.controls.dataRenderers.ItemRenderer`
		@see `feathers.controls.dataRenderers.LayoutGroupItemRenderer`

		@since 1.0.0
	**/
	public var itemRendererRecycler(get, set):AbstractDisplayObjectRecycler<Dynamic, ListViewItemState, DisplayObject>;

	private function get_itemRendererRecycler():AbstractDisplayObjectRecycler<Dynamic, ListViewItemState, DisplayObject> {
		return this._itemRendererRecycler;
	}

	private function set_itemRendererRecycler(value:AbstractDisplayObjectRecycler<Dynamic, ListViewItemState,
		DisplayObject>):AbstractDisplayObjectRecycler<Dynamic, ListViewItemState, DisplayObject> {
		if (this._itemRendererRecycler == value) {
			return this._itemRendererRecycler;
		}
		this._itemRendererRecycler = value;
		this.setInvalid(DATA);
		return this._itemRendererRecycler;
	}

	private var _itemToText:(Dynamic) -> String = defaultItemToText;

	/**
		Converts an item to text to display within the pop-up `ListView`, or
		within the `Button`, if the item is selected. By default, the
		`toString()` method is called to convert an item to text. This method
		may be replaced to provide custom text.

		For example, consider the following item:

		```haxe
		{ text: "Example Item" }
		```

		If the `ListView` should display the text "Example Item", a custom
		implementation of `itemToText()` might look like this:

		```haxe
		popUpListView.itemToText = (item:Dynamic) -> {
			return item.text;
		};
		```

		@since 1.0.0
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

	private var _itemToEnabled:(Dynamic) -> Bool = defaultItemToEnabled;

	/**
		Determines if an item should be enabled or disabled. By default, all
		items are enabled, unless the `PopUpListView` is disabled. This method
		may be replaced to provide a custom value for `enabled`.

		For example, consider the following item:

		```haxe
		{ text: "Example Item", disable: true }
		```

		If the `PopUpListView` should disable an item if the `disable` field is
		`true`, a custom implementation of `itemToEnabled()` might look like
		this:

		```haxe
		popUpListView.itemToEnabled = (item:Dynamic) -> {
			return !item.disable;
		};
		```

		@since 1.2.0
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
		The baseline of the text, measured from the top of the control. May be
		used in layouts.

		Note: This property may not return the correct value when the control is
		in an invalid state. To be safe, call `validateNow()` before accessing
		this value.

		@since 1.4.0
	**/
	public var baseline(get, never):Float;

	private function get_baseline():Float {
		if (this.button == null) {
			return 0.0;
		}
		return this.button.baseline;
	}

	/**
		Manages how the list view is displayed when it is opened and closed.

		In the following example, a custom pop-up adapter is provided:

		```haxe
		popUpListView.popUpAdapter = new DropDownPopUpAdapter();
		```

		@since 1.0.0
	**/
	@:style
	public var popUpAdapter:IPopUpAdapter = null;

	private var _previousCustomButtonVariant:String = null;

	/**
		A custom variant to set on the button, instead of
		`PopUpListView.CHILD_VARIANT_BUTTON`.

		The `customButtonVariant` will be not be used if the result of
		`buttonFactory` already has a variant set.

		@see `PopUpListView.CHILD_VARIANT_BUTTON`
		@see `feathers.style.IVariantStyleObject.variant`

		@since 1.0.0
	**/
	@:style
	public var customButtonVariant:String = null;

	private var _previousCustomListViewVariant:String = null;

	/**
		A custom variant to set on the pop-up list view, instead of
		`PopUpListView.CHILD_VARIANT_LIST_VIEW`.

		The `customListViewVariant` will be not be used if the result of
		`listViewFactory` already has a variant set.

		@see `PopUpListView.CHILD_VARIANT_LIST_VIEW`
		@see `feathers.style.IVariantStyleObject.variant`

		@since 1.0.0
	**/
	@:style
	public var customListViewVariant:String = null;

	private var _oldButtonFactory:DisplayObjectFactory<Dynamic, Button>;

	private var _buttonFactory:DisplayObjectFactory<Dynamic, Button>;

	/**
		Creates the button, which must be of type `feathers.controls.Button`.

		In the following example, a custom button factory is provided:

		```haxe
		popUpListView.buttonFactory = () ->
		{
			return new Button();
		};
		```

		@see `feathers.controls.Button`

		@since 1.0.0
	**/
	public var buttonFactory(get, set):AbstractDisplayObjectFactory<Dynamic, Button>;

	private function get_buttonFactory():AbstractDisplayObjectFactory<Dynamic, Button> {
		return this._buttonFactory;
	}

	private function set_buttonFactory(value:AbstractDisplayObjectFactory<Dynamic, Button>):AbstractDisplayObjectFactory<Dynamic, Button> {
		if (this._buttonFactory == value) {
			return this._buttonFactory;
		}
		this._buttonFactory = value;
		this.setInvalid(INVALIDATION_FLAG_BUTTON_FACTORY);
		return this._buttonFactory;
	}

	private var _oldListViewFactory:DisplayObjectFactory<Dynamic, ListView>;

	private var _listViewFactory:DisplayObjectFactory<Dynamic, ListView>;

	/**
		Creates the list view that is displayed as a pop-up. The list view must
		be of type `feathers.controls.ListView`.

		In the following example, a custom list view factory is provided:

		```haxe
		popUpListView.listViewFactory = () ->
		{
			return new ListView();
		};
		```

		@see `feathers.controls.ListView`

		@since 1.0.0
	**/
	public var listViewFactory(get, set):AbstractDisplayObjectFactory<Dynamic, ListView>;

	private function get_listViewFactory():AbstractDisplayObjectFactory<Dynamic, ListView> {
		return this._listViewFactory;
	}

	private function set_listViewFactory(value:AbstractDisplayObjectFactory<Dynamic, ListView>):AbstractDisplayObjectFactory<Dynamic, ListView> {
		if (this._listViewFactory == value) {
			return this._listViewFactory;
		}
		this._listViewFactory = value;
		this.setInvalid(INVALIDATION_FLAG_LIST_VIEW_FACTORY);
		return this._listViewFactory;
	}

	/**
		Indicates if the list view pop-up is open or closed.

		@see `PopUpListView.openListView()`
		@see `PopUpListView.closeListView()`

		@since 1.0.0
	**/
	public var open(get, never):Bool;

	private function get_open():Bool {
		return this.listView != null && this.listView.parent != null;
	}

	override public function showFocus(show:Bool):Void {
		super.showFocus(show);
		if (this.button != null) {
			this.button.showFocus(show);
		}
	}

	/**
		Opens the pop-up list, if it is not already open.

		The following example opens the pop-up list:

		```haxe
		if(!popUpListView.open)
		{
			popUpListView.openListView();
		}
		```

		When the pop-up list opens, the component will dispatch an event of type
		`Event.OPEN`.

		@see `PopUpListView.open`
		@see `PopUpListView.closeListView()`
		@see [`openfl.events.Event.OPEN`](https://api.openfl.org/openfl/events/Event.html#OPEN)

		@since 1.0.0
	**/
	public function openListView():Void {
		if (this.open || this.stage == null) {
			return;
		}
		this.validateNow();
		if (this.popUpAdapter != null) {
			this.popUpAdapter.addEventListener(Event.OPEN, popUpListView_popUpAdapter_openHandler);
			this.popUpAdapter.addEventListener(Event.CLOSE, popUpListView_popUpAdapter_closeHandler);
			this.popUpAdapter.open(this.listView, this.button);
		} else {
			PopUpManager.addPopUp(this.listView, this.button);
			FeathersEvent.dispatch(this, Event.OPEN);
		}
		this.listView.validateNow();
		this.button.addEventListener(FocusEvent.FOCUS_OUT, popUpListView_button_focusOutHandler);
		this.listView.addEventListener(Event.REMOVED_FROM_STAGE, popUpListView_listView_removedFromStageHandler);
		this.listView.addEventListener(FocusEvent.FOCUS_OUT, popUpListView_listView_focusOutHandler);
		this.listView.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, popUpListView_listView_keyFocusChangeHandler);
		this.listView.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, popUpListView_listView_mouseFocusChangeHandler);
		this.stage.addEventListener(MouseEvent.MOUSE_DOWN, popUpListView_stage_mouseDownHandler, false, 0, true);
		this.stage.addEventListener(TouchEvent.TOUCH_BEGIN, popUpListView_stage_touchBeginHandler, false, 0, true);
		this.listView.scrollToIndex(this._selectedIndex);
		if (this.listView.focusManager != null) {
			this.listView.focusManager.focus = this.listView;
		} else {
			this.stage.focus = this.listView;
		}
	}

	/**
		Closes the pop-up list, if it is open.

		The following example closes the pop-up list:

		```haxe
		if(popUpListView.open)
		{
			popUpListView.closeListView();
		}
		```

		When the pop-up list closes, the component will dispatch an event of
		type `Event.CLOSE`.

		@see `PopUpListView.open`
		@see `PopUpListView.openListView()`
		@see [`openfl.events.Event.CLOSE`](https://api.openfl.org/openfl/events/Event.html#CLOSE)

		@since 1.0.0
	**/
	public function closeListView():Void {
		if (!this.open) {
			return;
		}
		if (this._focusManager == null) {
			if (this.stage != null) {
				this.stage.focus = this;
			}
			// removing focus from the ListView might cause closeListView()
			// to be called recursively, so check again whether it is open
			// before continuing
			if (!this.open) {
				return;
			}
		}
		if (this.popUpAdapter != null) {
			this.popUpAdapter.close();
		} else {
			this.listView.parent.removeChild(this.listView);
			FeathersEvent.dispatch(this, Event.CLOSE);
		}
	}

	override public function dispose():Void {
		this.destroyButton();
		this.destroyListView();
		// manually clear the selection so that removing the data provider
		// doesn't result in Event.CHANGE getting dispatched
		this._selectedItem = null;
		this._selectedIndex = -1;
		this.dataProvider = null;
		super.dispose();
	}

	private function initializePopUpListViewTheme():Void {
		#if !feathersui_disable_default_theme
		feathers.themes.steel.components.SteelPopUpListViewStyles.initialize();
		#end
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(DATA);
		var selectionInvalid = this.isInvalid(SELECTION);
		var stateInvalid = this.isInvalid(STATE);
		if (this._previousCustomButtonVariant != this.customButtonVariant) {
			this.setInvalidationFlag(INVALIDATION_FLAG_BUTTON_FACTORY);
		}
		if (this._previousCustomListViewVariant != this.customListViewVariant) {
			this.setInvalidationFlag(INVALIDATION_FLAG_LIST_VIEW_FACTORY);
		}
		var buttonFactoryInvalid = this.isInvalid(INVALIDATION_FLAG_BUTTON_FACTORY);
		var listViewFactoryInvalid = this.isInvalid(INVALIDATION_FLAG_LIST_VIEW_FACTORY);

		if (buttonFactoryInvalid) {
			this.createButton();
		}
		if (listViewFactoryInvalid) {
			this.createListView();
		}

		if (dataInvalid || listViewFactoryInvalid) {
			this.refreshListViewData();
		}

		if (dataInvalid || selectionInvalid || listViewFactoryInvalid || buttonFactoryInvalid) {
			this.refreshSelection();
		}

		if (dataInvalid || stateInvalid || listViewFactoryInvalid || buttonFactoryInvalid) {
			this.refreshEnabled();
		}

		this.measure();
		this.layoutChildren();

		this._previousCustomButtonVariant = this.customButtonVariant;
		this._previousCustomListViewVariant = this.customListViewVariant;
	}

	private function createButton():Void {
		this.destroyButton();
		var factory = this._buttonFactory != null ? this._buttonFactory : defaultButtonFactory;
		this._oldButtonFactory = factory;
		this.button = factory.create();
		if (this.button.variant == null) {
			this.button.variant = this.customButtonVariant != null ? this.customButtonVariant : PopUpListView.CHILD_VARIANT_BUTTON;
		}
		this.button.addEventListener(MouseEvent.MOUSE_DOWN, popUpListView_button_mouseDownHandler);
		this.button.addEventListener(TouchEvent.TOUCH_BEGIN, popUpListView_button_touchBeginHandler);
		this.button.addEventListener(KeyboardEvent.KEY_DOWN, popUpListView_button_keyDownHandler);
		this.button.initializeNow();
		this.buttonMeasurements.save(this.button);
		this.addChild(this.button);
	}

	private function destroyButton():Void {
		if (this.button == null) {
			return;
		}
		this.button.removeEventListener(MouseEvent.MOUSE_DOWN, popUpListView_button_mouseDownHandler);
		this.button.removeEventListener(TouchEvent.TOUCH_BEGIN, popUpListView_button_touchBeginHandler);
		this.button.removeEventListener(KeyboardEvent.KEY_DOWN, popUpListView_button_keyDownHandler);
		this.removeChild(this.button);
		if (this._oldButtonFactory.destroy != null) {
			this._oldButtonFactory.destroy(this.button);
		}
		this._oldButtonFactory = null;
		this.button = null;
	}

	private function createListView():Void {
		this.destroyListView();
		var factory = this._listViewFactory != null ? this._listViewFactory : defaultListViewFactory;
		this._oldListViewFactory = factory;
		this.listView = factory.create();
		if (this.listView.variant == null) {
			this.listView.variant = this.customListViewVariant != null ? this.customListViewVariant : PopUpListView.CHILD_VARIANT_LIST_VIEW;
		}
		this.listView.focusOwner = this;
		this.listView.addEventListener(Event.CHANGE, popUpListView_listView_changeHandler);
		this.listView.addEventListener(ListViewEvent.ITEM_TRIGGER, popUpListView_listView_itemTriggerHandler);
		this.listView.addEventListener(KeyboardEvent.KEY_UP, popUpListView_listView_keyUpHandler);
	}

	private function destroyListView():Void {
		if (this.listView == null) {
			return;
		}
		this.listView.removeEventListener(Event.CHANGE, popUpListView_listView_changeHandler);
		this.listView.removeEventListener(ListViewEvent.ITEM_TRIGGER, popUpListView_listView_itemTriggerHandler);
		this.listView.removeEventListener(KeyboardEvent.KEY_UP, popUpListView_listView_keyUpHandler);
		if (this._oldListViewFactory.destroy != null) {
			this._oldListViewFactory.destroy(this.listView);
		}
		this._oldListViewFactory = null;
		this.listView = null;
	}

	private function refreshListViewData():Void {
		var oldIgnoreListViewChange = this._ignoreListViewChange;
		this._ignoreListViewChange = true;
		// changing the data provider can make the ListView reset its selection,
		// but we already took care of the selection reset in our own
		// dataProvider setter, so ignore any changes from the ListView. our
		// selection changes will be propagated in refreshSelection().
		this.listView.dataProvider = this._dataProvider;
		this._ignoreListViewChange = oldIgnoreListViewChange;

		this.listView.itemRendererRecycler = this._itemRendererRecycler;
		this.listView.itemToEnabled = this.itemToEnabled;
		this.listView.itemToText = this.itemToText;
	}

	private function refreshSelection():Void {
		var oldIgnoreListViewChange = this._ignoreListViewChange;
		this._ignoreListViewChange = true;
		this.listView.selectedIndex = this._selectedIndex;
		this._ignoreListViewChange = oldIgnoreListViewChange;

		if (this._selectedItem != null) {
			this.button.text = this.itemToText(this._selectedItem);
		} else if (this._prompt != null) {
			this.button.text = this._prompt;
		} else {
			this.button.text = "";
		}
	}

	private function refreshEnabled():Void {
		this.button.enabled = this._enabled;
		this.listView.enabled = this._enabled;
	}

	private function measure():Bool {
		var needsWidth = this.explicitWidth == null;
		var needsHeight = this.explicitHeight == null;
		var needsMinWidth = this.explicitMinWidth == null;
		var needsMinHeight = this.explicitMinHeight == null;
		var needsMaxWidth = this.explicitMaxWidth == null;
		var needsMaxHeight = this.explicitMaxHeight == null;
		if (!needsWidth && !needsHeight && !needsMinWidth && !needsMinHeight && !needsMaxWidth && !needsMaxHeight) {
			return false;
		}

		MeasurementsUtil.resetFluidlyWithParent(this.buttonMeasurements, this.button, this);
		this.button.validateNow();

		var newWidth = this.explicitWidth;
		if (needsWidth) {
			newWidth = this.button.width;
		}

		var newHeight = this.explicitHeight;
		if (needsHeight) {
			newHeight = this.button.height;
		}

		var newMinWidth = this.explicitMinWidth;
		if (needsMinWidth) {
			newMinWidth = this.button.minWidth;
		}

		var newMinHeight = this.explicitMinHeight;
		if (needsMinHeight) {
			newMinHeight = this.button.minHeight;
		}

		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight);
	}

	private function layoutChildren():Void {
		this.button.validateNow();
		if (this.button.width != this.actualWidth) {
			this.button.width = this.actualWidth;
		}
		if (this.button.height != this.actualHeight) {
			this.button.height = this.actualHeight;
		}
		this.button.validateNow();
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

	private function popUpListView_button_keyDownHandler(event:KeyboardEvent):Void {
		if (!this._enabled) {
			return;
		}
		if (!open && event.keyLocation != 4 /* KeyLocation.D_PAD */) {
			this.navigateWithKeyboard(event);
		}
		if (event.keyCode != Keyboard.SPACE && event.keyCode != Keyboard.ENTER) {
			return;
		}
		if (this.open) {
			event.preventDefault();
			this.closeListView();
		} else {
			event.preventDefault();
			this.openListView();
		}
	}

	private function popUpListView_button_mouseDownHandler(event:MouseEvent):Void {
		if (!this._enabled) {
			return;
		}
		if (this.open) {
			this.closeListView();
		} else {
			this.openListView();
		}
	}

	private function popUpListView_button_touchBeginHandler(event:TouchEvent):Void {
		if (!this._enabled) {
			return;
		}
		if (event.isPrimaryTouchPoint #if air && Multitouch.mapTouchToMouse #end) {
			// ignore the primary one because MouseEvent.MOUSE_DOWN will catch it
			return;
		}
		if (this.open) {
			this.closeListView();
		} else {
			this.openListView();
		}
	}

	private function popUpListView_listView_itemTriggerHandler(event:ListViewEvent):Void {
		this.dispatchEvent(event);
		if (this.popUpAdapter == null || !this.popUpAdapter.persistent) {
			this.closeListView();
		}
	}

	private function popUpListView_listView_changeHandler(event:Event):Void {
		if (this._ignoreListViewChange) {
			return;
		}
		// skip the setters because we might be changing both index and item
		// and we want just one event
		this._selectedIndex = this.listView.selectedIndex;
		this._selectedItem = this.listView.selectedItem;
		this.setInvalid(SELECTION);
		FeathersEvent.dispatch(this, Event.CHANGE);
	}

	private function popUpListView_listView_removedFromStageHandler(event:Event):Void {
		this.button.removeEventListener(FocusEvent.FOCUS_OUT, popUpListView_button_focusOutHandler);
		this.listView.removeEventListener(Event.REMOVED_FROM_STAGE, popUpListView_listView_removedFromStageHandler);
		this.listView.removeEventListener(FocusEvent.FOCUS_OUT, popUpListView_listView_focusOutHandler);
		this.listView.removeEventListener(FocusEvent.KEY_FOCUS_CHANGE, popUpListView_listView_keyFocusChangeHandler);
		this.listView.removeEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, popUpListView_listView_mouseFocusChangeHandler);
		this.stage.removeEventListener(MouseEvent.MOUSE_DOWN, popUpListView_stage_mouseDownHandler);
		this.stage.removeEventListener(TouchEvent.TOUCH_BEGIN, popUpListView_stage_touchBeginHandler);
	}

	private function popUpListView_listView_mouseFocusChangeHandler(event:FocusEvent):Void {
		if (this.listView.focusManager != null
			|| event.isDefaultPrevented()
			|| event.target != this.listView
			|| (event.relatedObject != null && !this.listView.contains(event.relatedObject))) {
			return;
		}
		event.preventDefault();
	}

	private function popUpListView_listView_keyFocusChangeHandler(event:FocusEvent):Void {
		if (this.listView.focusManager != null || event.isDefaultPrevented() || event.target != this.listView) {
			return;
		}
		event.preventDefault();
		if (this.stage != null) {
			this.stage.focus = this.button;
		}
	}

	private function popUpListView_listView_focusOutHandler(event:FocusEvent):Void {
		// the list view can stay open of the focus is still inside
		if (event.relatedObject != null && (event.relatedObject == this.listView || this.listView.contains(event.relatedObject))) {
			return;
		}
		#if (flash || openfl > "9.1.0")
		this.closeListView();
		#end
	}

	private function popUpListView_focusInHandler(event:FocusEvent):Void {
		if (this.stage != null && this.stage.focus != this.button) {
			event.stopImmediatePropagation();
			this.stage.focus = this.button;
		}
	}

	private function popUpListView_button_focusOutHandler(event:FocusEvent):Void {
		if (event.relatedObject != null && (event.relatedObject == this.listView || this.listView.contains(event.relatedObject))) {
			return;
		}
		// when the ListView loses focus, it's supposed to close. however, some
		// versions of OpenFL had some focus bugs that would prevent this
		this.closeListView();
	}

	private function popUpListView_removedFromStageHandler(event:Event):Void {
		// if something went terribly wrong, at least make sure that the
		// ListView isn't still visible and blocking the rest of the app.
		// don't rely on the IPopUpAdapter to take care of it (though, it should
		// try to as well, without conflict)
		this.closeListView();
	}

	private function popUpListView_listView_keyUpHandler(event:KeyboardEvent):Void {
		if (!this._enabled) {
			return;
		}
		switch (event.keyCode) {
			case Keyboard.ESCAPE:
				if (event.isDefaultPrevented()) {
					return;
				}
				if (!this.open) {
					return;
				}
				event.preventDefault();
				this.closeListView();
			#if flash
			case Keyboard.BACK:
				if (event.isDefaultPrevented()) {
					return;
				}
				if (!this.open) {
					return;
				}
				event.preventDefault();
				this.closeListView();
			#end
			#if lime
			case KeyCode.APP_CONTROL_BACK:
				if (event.isDefaultPrevented()) {
					return;
				}
				if (!this.open) {
					return;
				}
				event.preventDefault();
				this.closeListView();
			#end
		}
	}

	private function popUpListView_stage_mouseDownHandler(event:MouseEvent):Void {
		if (this.button.hitTestPoint(event.stageX, event.stageY) || this.listView.hitTestPoint(event.stageX, event.stageY)) {
			return;
		}
		this.closeListView();
	}

	private function popUpListView_stage_touchBeginHandler(event:TouchEvent):Void {
		if (event.isPrimaryTouchPoint #if air && Multitouch.mapTouchToMouse #end) {
			// ignore the primary one because MouseEvent.MOUSE_DOWN will catch it
			return;
		}
		if (this.button.hitTestPoint(event.stageX, event.stageY) || this.listView.hitTestPoint(event.stageX, event.stageY)) {
			return;
		}
		this.closeListView();
	}

	private function popUpListView_popUpAdapter_openHandler(event:Event):Void {
		FeathersEvent.dispatch(this, Event.OPEN);
	}

	private function popUpListView_popUpAdapter_closeHandler(event:Event):Void {
		FeathersEvent.dispatch(this, Event.CLOSE);
	}

	private function popUpListView_dataProvider_removeAllHandler(event:Event):Void {
		// use the setter
		this.selectedIndex = -1;
	}

	private function popUpListView_dataProvider_updateItemHandler(event:FlatCollectionEvent):Void {
		if (event.index != this._selectedIndex) {
			return;
		}
		this.setInvalid(DATA);
	}

	private function popUpListView_dataProvider_updateAllHandler(event:FlatCollectionEvent):Void {
		this.setInvalid(DATA);
	}
}
