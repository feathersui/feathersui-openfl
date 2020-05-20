/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.events.ListViewEvent;
import openfl.events.FocusEvent;
import feathers.core.IFocusObject;
import feathers.core.IIndexSelector;
import feathers.utils.MeasurementsUtil;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.utils.DisplayObjectRecycler;
import feathers.data.ListViewItemState;
import openfl.display.DisplayObject;
import feathers.themes.steel.components.SteelPopUpListViewStyles;
import openfl.events.TouchEvent;
import lime.ui.KeyCode;
import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import feathers.events.FeathersEvent;
import openfl.events.Event;
import feathers.core.InvalidationFlag;
import feathers.data.IFlatCollection;
import feathers.layout.Measurements;
import feathers.core.PopUpManager;
import openfl.events.MouseEvent;
import feathers.controls.popups.IPopUpAdapter;
import feathers.core.FeathersControl;
import feathers.core.IDataSelector;
#if air
import openfl.ui.Multitouch;
#end

/**
	Displays a `Button` that may be triggered to display a `ListView` as a
	pop-up. The list view may be customized to display in different ways, such
	as a drop-down, inside a `Callout`, or as a modal overlay.

	The following example creates a pop-up list, gives it a data provider, tells
	the item renderer how to interpret the data, and listens for when the
	selection changes:

	```hx
	var listView = new PopUpListView();

	listView.dataProvider = new ArrayCollection([
		{ text: "Milk" },
		{ text: "Eggs" },
		{ text: "Bread" },
		{ text: "Steak" },
	]);

	listView.itemToText = (item:Dynamic) -> {
		return item.text;
	};

	listView.addEventListener(Event.CHANGE, (event:Event) -> {
		var list = cast(event.currentTarget, PopUpListView);
		trace("PopUpListView changed: " + listView.selectedIndex + " " + listView.selectedItem.text);
	});

	this.addChild(list);
	```

	@see [Tutorial: How to use the PopUpListView component](https://feathersui.com/learn/haxe-openfl/pop-up-list-view/)
	@see `feathers.controls.ComboBox`

	@since 1.0.0
**/
@:styleContext
class PopUpListView extends FeathersControl implements IIndexSelector implements IDataSelector<Dynamic> implements IFocusObject {
	private static final INVALIDATION_FLAG_BUTTON_FACTORY = "buttonFactory";
	private static final INVALIDATION_FLAG_LIST_VIEW_FACTORY = "listViewFactory";

	/**
		The variant used to style the `Button` child component in a theme.

		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)
	**/
	public static final CHILD_VARIANT_BUTTON = "popUpListView_button";

	/**
		The variant used to style the `ListView` child component in a theme.

		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)
	**/
	public static final CHILD_VARIANT_LIST_VIEW = "popUpListView_listView";

	private static function defaultButtonFactory():Button {
		return new Button();
	}

	private static function defaultListViewFactory():ListView {
		return new ListView();
	}

	/**
		Creates a new `PopUpListView` object.

		@since 1.0.0
	**/
	public function new() {
		initializePopUpListViewTheme();

		super();

		this.addEventListener(FocusEvent.FOCUS_IN, popUpListView_focusInHandler);
	}

	private var button:Button;
	private var listView:ListView;

	private var buttonMeasurements:Measurements = new Measurements();

	/**
		The collection of data displayed by the list view.

		The following example passes in a data provider and tells the item
		renderer how to interpret the data:

		```hx
		listView.dataProvider = new ArrayCollection([
			{ text: "Milk" },
			{ text: "Eggs" },
			{ text: "Bread" },
			{ text: "Chicken" },
		]);

		listView.itemToText = (item:Dynamic) -> {
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
		var oldSelectedIndex = this.selectedIndex;
		var oldSelectedItem = this.selectedItem;
		this.dataProvider = value;
		if (this.dataProvider == null || this.dataProvider.length == 0) {
			this.selectedIndex = -1;
		} else {
			this.selectedIndex = 0;
		}
		// this ensures that Event.CHANGE will dispatch for selectedItem
		// changing, even if selectedIndex has not changed.
		if (this.selectedIndex == oldSelectedIndex && this.selectedItem != oldSelectedItem) {
			this.setInvalid(InvalidationFlag.SELECTION);
			FeathersEvent.dispatch(this, Event.CHANGE);
		}
		this.setInvalid(InvalidationFlag.DATA);
		return this.dataProvider;
	}

	private var _ignoreListViewChange = false;

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
		Manages item renderers used by the pop-up list view.

		In the following example, the pop-up list view uses a custom item
		renderer class:

		```hx
		listView.itemRendererRecycler = DisplayObjectRecycler.withClass(CustomItemRenderer);
		```

		@since 1.0.0
	**/
	public var itemRendererRecycler(default,
		set):DisplayObjectRecycler<Dynamic, ListViewItemState, DisplayObject> = DisplayObjectRecycler.withClass(ItemRenderer);

	private function set_itemRendererRecycler(value:DisplayObjectRecycler<Dynamic, ListViewItemState, DisplayObject>):DisplayObjectRecycler<Dynamic,
		ListViewItemState, DisplayObject> {
		if (this.itemRendererRecycler == value) {
			return this.itemRendererRecycler;
		}
		this.itemRendererRecycler = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this.itemRendererRecycler;
	}

	/**
		Converts an item to text to display within the pop-up `ListView`, or
		within the `Button`, if the item is selected. By default, the
		`toString()` method is called to convert an item to text. This method
		may be replaced to provide custom text.

		For example, consider the following item:

		```hx
		{ text: "Example Item" }
		```

		If the `ListView` should display the text "Example Item", a custom
		implementation of `itemToText()` might look like this:

		```hx
		listView.itemToText = (item:Dynamic) -> {
			return item.text;
		};
		```

		@since 1.0.0
	**/
	public dynamic function itemToText(data:Dynamic):String {
		return Std.string(data);
	}

	/**
		Manages how the list view is displayed when it is opened and closed.

		In the following example, a custom pop-up adapter is provided:

		```hx
		comboBox.popUpAdapter = new DropDownPopUpAdapter();
		```

		@since 1.0.0
	**/
	@:style
	public var popUpAdapter:IPopUpAdapter = null;

	/**
		Creates the button, which must be of type `feathers.controls.Button`.

		In the following example, a custom button factory is provided:

		```hx
		listView.buttonFactory = () ->
		{
			return new Button();
		};
		```

		@see `feathers.controls.Button`

		@since 1.0.0
	**/
	public var buttonFactory(default, set):() -> Button;

	private function set_buttonFactory(value:() -> Button):() -> Button {
		if (this.buttonFactory == value) {
			return this.buttonFactory;
		}
		this.buttonFactory = value;
		this.setInvalid(INVALIDATION_FLAG_BUTTON_FACTORY);
		return this.buttonFactory;
	}

	/**
		Creates the list view that is displayed as a pop-up. The list view must
		be of type `feathers.controls.ListView`.

		In the following example, a custom list view factory is provided:

		```hx
		listView.listViewFactory = () ->
		{
			return new ListView();
		};
		```

		@see `feathers.controls.ListView`

		@since 1.0.0
	**/
	public var listViewFactory(default, set):() -> ListView;

	private function set_listViewFactory(value:() -> ListView):() -> ListView {
		if (this.listViewFactory == value) {
			return this.listViewFactory;
		}
		this.listViewFactory = value;
		this.setInvalid(INVALIDATION_FLAG_LIST_VIEW_FACTORY);
		return this.listViewFactory;
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

		```hx
		if(!listView.open)
		{
			listView.openListView();
		}
		```

		When the pop-up list opens, the component will dispatch an event of type
		`Event.OPEN`.

		@see `PopUpListView.open`
		@see `PopUpListView.closeListView()`
		@see `openfl.events.Event.OPEN`

		@since 1.0.0
	**/
	public function openListView():Void {
		if (this.open || this.stage == null) {
			return;
		}
		if (this.popUpAdapter != null) {
			this.popUpAdapter.addEventListener(Event.OPEN, popUpListView_popUpAdapter_openHandler);
			this.popUpAdapter.addEventListener(Event.CLOSE, popUpListView_popUpAdapter_closeHandler);
			this.popUpAdapter.open(this.listView, this.button);
		} else {
			PopUpManager.addPopUp(this.listView, this.button);
			FeathersEvent.dispatch(this, Event.OPEN);
		}
		this.listView.validateNow();
		this.stage.focus = this.listView;
		this.listView.addEventListener(Event.REMOVED_FROM_STAGE, popUpListView_listView_removedFromStageHandler);
		this.stage.addEventListener(MouseEvent.MOUSE_DOWN, popUpListView_stage_mouseDownHandler, false, 0, true);
		this.stage.addEventListener(TouchEvent.TOUCH_BEGIN, popUpListView_stage_touchBeginHandler, false, 0, true);
		this.listView.scrollToIndex(this.selectedIndex);
	}

	/**
		Closes the pop-up list, if it is open.

		The following example closes the pop-up list:

		```hx
		if(listView.open)
		{
			listView.closeListView();
		}
		```

		When the pop-up list closes, the component will dispatch an event of
		type `Event.CLOSE`.

		@see `PopUpListView.open`
		@see `PopUpListView.openListView()`
		@see `openfl.events.Event.CLOSE`

		@since 1.0.0
	**/
	public function closeListView():Void {
		if (!this.open) {
			return;
		}
		// TODO: fix this when focus manager is implemented
		this.stage.focus = this;
		if (this.popUpAdapter != null) {
			this.popUpAdapter.close();
		} else {
			this.listView.parent.removeChild(this.listView);
			FeathersEvent.dispatch(this, Event.CLOSE);
		}
	}

	private function initializePopUpListViewTheme():Void {
		SteelPopUpListViewStyles.initialize();
	}

	override private function update():Void {
		var buttonFactoryInvalid = this.isInvalid(INVALIDATION_FLAG_BUTTON_FACTORY);
		var listViewFactoryInvalid = this.isInvalid(INVALIDATION_FLAG_LIST_VIEW_FACTORY);
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);
		var selectionInvalid = this.isInvalid(InvalidationFlag.SELECTION);
		var stateInvalid = this.isInvalid(InvalidationFlag.STATE);

		if (buttonFactoryInvalid) {
			this.createButton();
		}
		if (listViewFactoryInvalid) {
			this.createListView();
		}

		if (dataInvalid || listViewFactoryInvalid) {
			this.refreshData();
		}

		if (selectionInvalid || listViewFactoryInvalid || buttonFactoryInvalid) {
			this.refreshSelection();
		}

		if (stateInvalid || listViewFactoryInvalid || buttonFactoryInvalid) {
			this.refreshEnabled();
		}

		this.measure();
		this.layoutChildren();
	}

	private function createButton():Void {
		if (this.button != null) {
			this.button.removeEventListener(MouseEvent.MOUSE_DOWN, button_mouseDownHandler);
			this.button.removeEventListener(TouchEvent.TOUCH_BEGIN, button_touchBeginHandler);
			this.button.removeEventListener(KeyboardEvent.KEY_DOWN, button_keyDownHandler);
			this.button = null;
		}
		var factory = this.buttonFactory != null ? this.buttonFactory : defaultButtonFactory;
		this.button = factory();
		if (this.button.variant == null) {
			this.button.variant = PopUpListView.CHILD_VARIANT_BUTTON;
		}
		this.button.addEventListener(MouseEvent.MOUSE_DOWN, button_mouseDownHandler);
		this.button.addEventListener(TouchEvent.TOUCH_BEGIN, button_touchBeginHandler);
		this.button.addEventListener(KeyboardEvent.KEY_DOWN, button_keyDownHandler);
		this.button.initializeNow();
		this.buttonMeasurements.save(this.button);
		this.addChild(this.button);
	}

	private function createListView():Void {
		if (this.listView != null) {
			this.listView.removeEventListener(Event.CHANGE, listView_changeHandler);
			this.listView.removeEventListener(ListViewEvent.ITEM_TRIGGER, listView_itemTriggerHandler);
			this.listView.removeEventListener(KeyboardEvent.KEY_UP, popUpListView_listView_keyUpHandler);
			this.listView = null;
		}
		var factory = this.listViewFactory != null ? this.listViewFactory : defaultListViewFactory;
		this.listView = factory();
		if (this.listView.variant == null) {
			this.listView.variant = PopUpListView.CHILD_VARIANT_LIST_VIEW;
		}
		this.listView.addEventListener(Event.CHANGE, listView_changeHandler);
		this.listView.addEventListener(ListViewEvent.ITEM_TRIGGER, listView_itemTriggerHandler);
		this.listView.addEventListener(KeyboardEvent.KEY_UP, popUpListView_listView_keyUpHandler);
	}

	private function refreshData():Void {
		this.listView.dataProvider = this.dataProvider;
		this.listView.itemRendererRecycler = this.itemRendererRecycler;
		this.listView.itemToText = this.itemToText;
	}

	private function refreshSelection():Void {
		var oldIgnoreListViewChange = this._ignoreListViewChange;
		this._ignoreListViewChange = true;
		this.listView.selectedIndex = this.selectedIndex;
		this._ignoreListViewChange = oldIgnoreListViewChange;

		if (this.selectedItem != null) {
			this.button.text = this.itemToText(this.selectedItem);
		} else {
			this.button.text = "";
		}
	}

	private function refreshEnabled():Void {
		this.button.enabled = this.enabled;
		this.listView.enabled = this.enabled;
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

	private function button_keyDownHandler(event:KeyboardEvent):Void {
		if (!this.enabled) {
			return;
		}
		if (!open) {
			this.navigateWithKeyboard(event);
		}
		if (event.keyCode != Keyboard.SPACE && event.keyCode != Keyboard.ENTER) {
			return;
		}
		if (this.open) {
			this.closeListView();
		} else {
			this.openListView();
		}
	}

	private function button_mouseDownHandler(event:MouseEvent):Void {
		if (this.open) {
			this.closeListView();
		} else {
			this.openListView();
		}
	}

	private function button_touchBeginHandler(event:TouchEvent):Void {
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

	private function listView_itemTriggerHandler(event:ListViewEvent):Void {
		this.dispatchEvent(event);
		if (this.popUpAdapter == null || !this.popUpAdapter.persistent) {
			this.closeListView();
		}
	}

	private function listView_changeHandler(event:Event):Void {
		if (this._ignoreListViewChange) {
			return;
		}
		this.selectedIndex = this.listView.selectedIndex;
	}

	private function popUpListView_listView_removedFromStageHandler(event:Event):Void {
		this.listView.removeEventListener(Event.REMOVED_FROM_STAGE, popUpListView_listView_removedFromStageHandler);
		this.stage.removeEventListener(MouseEvent.MOUSE_DOWN, popUpListView_stage_mouseDownHandler);
		this.stage.removeEventListener(TouchEvent.TOUCH_BEGIN, popUpListView_stage_touchBeginHandler);
	}

	private function popUpListView_focusInHandler(event:FocusEvent):Void {
		if (Reflect.compare(event.target, this) == 0) {
			this.stage.focus = this.button;
		}
	}

	private function popUpListView_listView_keyUpHandler(event:KeyboardEvent):Void {
		if (!this.enabled) {
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
			case KeyCode.APP_CONTROL_BACK:
				if (event.isDefaultPrevented()) {
					return;
				}
				if (!this.open) {
					return;
				}
				event.preventDefault();
				this.closeListView();
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
}
