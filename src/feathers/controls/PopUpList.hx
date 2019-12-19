/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.controls.dataRenderers.ItemRenderer;
import feathers.utils.DisplayObjectRecycler;
import feathers.data.ListViewItemState;
import openfl.display.DisplayObject;
import feathers.themes.steel.components.SteelPopUpListStyles;
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

/**
	Displays a button that may be triggered to display list view as a pop-up.
	The list view may be customized to display in different ways, such as a
	drop-down, inside a `Callout`, or as a modal overlay.

	The following example creates a pop-up list, gives it a data provider, tells
	the item renderer how to interpret the data, and listens for when the
	selection changes:

	```hx
	var list = new PopUpList();

	list.dataProvider = new ArrayCollection(
	[
		{ text: "Milk" },
		{ text: "Eggs" },
		{ text: "Bread" },
		{ text: "Steak" },
	]);

	list.itemToText = (item:Dynamic) ->
	{
		return item.text;
	};

	list.addEventListener(Event.CHANGE, (event:Event) ->
	{
		trace("PopUpList changed: " + list.selectedIndex + " " + list.selectedItem.text);
	});

	this.addChild(list);
	```

	@see [Tutorial: How to use the PopUpList component](https://feathersui.com/learn/haxe-openfl/pop-up-list/)
	@see `feathers.controls.ComboBox`

	@since 1.0.0
**/
@:styleContext
class PopUpList extends FeathersControl implements IDataSelector<Dynamic> {
	private static final INVALIDATION_FLAG_BUTTON_FACTORY = "buttonFactory";
	private static final INVALIDATION_FLAG_LIST_VIEW_FACTORY = "listViewFactory";

	public static final CHILD_VARIANT_BUTTON = "popUpButton";

	/**
		Creates a new `PopUpList` object.

		@since 1.0.0
	**/
	public function new() {
		initializePopUpListTheme();

		super();
		this.addEventListener(KeyboardEvent.KEY_UP, popUpList_keyUpHandler);
	}

	private var button:Button;
	private var listView:ListView;

	private var buttonMeasurements:Measurements = new Measurements();

	/**
		The collection of data displayed by the list.

		The following example passes in a data provider and tells the item
		renderer how to interpret the data:

		```hx
		list.dataProvider = new ArrayCollection(
		[
			{ text: "Milk" },
			{ text: "Eggs" },
			{ text: "Bread" },
			{ text: "Chicken" },
		]);

		list.itemToText = (item:Dynamic) ->
		{
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
		@see `feathers.core.IDataSelector.selectedIndex`
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
		@see `feathers.core.IDataSelector.selectedItem`
	**/
	@:isVar
	public var selectedItem(get, set):Dynamic = null;

	private function get_selectedItem():Int {
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
		renderer:

		```hx
		list.itemRendererRecycler = new DisplayObjectRecycler(CustomItemRenderer);
		```

		@since 1.0.0
	**/
	public var itemRendererRecycler(default, set):DisplayObjectRecycler<Dynamic, ListViewItemState, DisplayObject> = new DisplayObjectRecycler(ItemRenderer);

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
		list.itemToText = (item:Dynamic) ->
		{
			return item.text;
		};
		```

		@since 1.0.0
	**/
	public dynamic function itemToText(data:Dynamic):String {
		return Std.string(data);
	}

	/**
		Manages how the pop-up list is displayed when it is opened and closed.

		In the following example, a custom pop-up adapter is provided:

		```hx
		comboBox.popUpAdapter = new DropDownPopUpAdapter();
		```

		@since 1.0.0
	**/
	@:style
	public var popUpAdapter:IPopUpAdapter = null;

	/**
		Indicates if the pop-up list is open or closed.

		@see `PopUpList.openList()`
		@see `PopUpList.closeList()`

		@since 1.0.0
	**/
	public var open(get, never):Bool;

	private function get_open():Bool {
		return this.listView.parent != null;
	}

	/**
		Opens the pop-up list, if it is not already open.

		The following example opens the pop-up list:

		```hx
		if(!list.open)
		{
			list.openList();
		}
		```

		@see `PopUpList.open`
		@see `PopUpList.closeList()`

		@since 1.0.0
	**/
	public function openList():Void {
		if (this.open || this.stage == null) {
			return;
		}
		if (this.popUpAdapter != null) {
			this.popUpAdapter.open(this.listView, this.button);
		} else {
			PopUpManager.addPopUp(this.listView, this.button);
		}
		this.listView.addEventListener(Event.REMOVED_FROM_STAGE, popUpList_listView_removedFromStageHandler);
		this.stage.addEventListener(MouseEvent.MOUSE_DOWN, popUpList_stage_mouseDownHandler, false, 0, true);
		this.stage.addEventListener(TouchEvent.TOUCH_BEGIN, popUpList_stage_touchBeginHandler, false, 0, true);
	}

	/**
		Closes the pop-up list, if it is open.

		The following example closes the pop-up list:

		```hx
		if(list.open)
		{
			list.closeList();
		}
		```

		@see `PopUpList.open`
		@see `PopUpList.openList()`

		@since 1.0.0
	**/
	public function closeList():Void {
		if (!this.open) {
			return;
		}
		if (this.popUpAdapter != null) {
			this.popUpAdapter.close();
		} else {
			this.listView.parent.removeChild(this.listView);
			// TODO: fix this when focus manager is implemented
			this.stage.focus = this;
		}
	}

	private function initializePopUpListTheme():Void {
		SteelPopUpListStyles.initialize();
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

		this.autoSizeIfNeeded();
		this.layoutChildren();
	}

	private function createButton():Void {
		if (this.button != null) {
			this.button.removeEventListener(FeathersEvent.TRIGGERED, button_triggeredHandler);
			this.button = null;
		}
		this.button = new Button();
		this.button.variant = PopUpList.CHILD_VARIANT_BUTTON;
		this.button.addEventListener(FeathersEvent.TRIGGERED, button_triggeredHandler);
		this.buttonMeasurements.save(this.button);
		this.addChild(this.button);
	}

	private function createListView():Void {
		if (this.listView != null) {
			this.listView.removeEventListener(FeathersEvent.TRIGGERED, listView_triggeredHandler);
			this.listView.removeEventListener(Event.CHANGE, listView_changeHandler);
			this.listView = null;
		}
		this.listView = new ListView();
		this.listView.addEventListener(FeathersEvent.TRIGGERED, listView_triggeredHandler);
		this.listView.addEventListener(Event.CHANGE, listView_changeHandler);
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

		if (this.dataProvider == null || this.dataProvider.length == 0) {
			this.button.text = "";
		} else {
			this.button.text = this.dataProvider.get(this.selectedIndex).text;
		}
	}

	private function refreshEnabled():Void {
		this.button.enabled = this.enabled;
		this.listView.enabled = this.enabled;
	}

	private function autoSizeIfNeeded():Bool {
		var needsWidth = this.explicitWidth == null;
		var needsHeight = this.explicitHeight == null;
		var needsMinWidth = this.explicitMinWidth == null;
		var needsMinHeight = this.explicitMinHeight == null;
		var needsMaxWidth = this.explicitMaxWidth == null;
		var needsMaxHeight = this.explicitMaxHeight == null;
		if (!needsWidth && !needsHeight && !needsMinWidth && !needsMinHeight && !needsMaxWidth && !needsMaxHeight) {
			return false;
		}

		this.buttonMeasurements.resetTargetFluidlyForParent(this.button, this);
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

	private function button_triggeredHandler(event:FeathersEvent):Void {
		if (this.open) {
			this.closeList();
		} else {
			this.openList();
		}
	}

	private function listView_triggeredHandler(event:Event):Void {
		if (this.popUpAdapter == null || !this.popUpAdapter.persistent) {
			this.closeList();
		}
	}

	private function listView_changeHandler(event:Event):Void {
		if (this._ignoreListViewChange) {
			return;
		}
		this.selectedIndex = this.listView.selectedIndex;
	}

	private function popUpList_listView_removedFromStageHandler(event:Event):Void {
		this.listView.removeEventListener(Event.REMOVED_FROM_STAGE, popUpList_listView_removedFromStageHandler);
		this.stage.removeEventListener(MouseEvent.MOUSE_DOWN, popUpList_stage_mouseDownHandler);
		this.stage.removeEventListener(TouchEvent.TOUCH_BEGIN, popUpList_stage_touchBeginHandler);
	}

	private function popUpList_keyUpHandler(event:KeyboardEvent):Void {
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
				this.closeList();
			case KeyCode.APP_CONTROL_BACK:
				if (event.isDefaultPrevented()) {
					return;
				}
				if (!this.open) {
					return;
				}
				event.preventDefault();
				this.closeList();
		}
	}

	private function popUpList_stage_mouseDownHandler(event:MouseEvent):Void {
		if (this.button.hitTestPoint(event.stageX, event.stageY) || this.listView.hitTestPoint(event.stageX, event.stageY)) {
			return;
		}
		this.closeList();
	}

	private function popUpList_stage_touchBeginHandler(event:TouchEvent):Void {
		if (event.isPrimaryTouchPoint) {
			// ignore the primary one because MouseEvent.MOUSE_DOWN will catch it
			return;
		}
		if (this.button.hitTestPoint(event.stageX, event.stageY) || this.listView.hitTestPoint(event.stageX, event.stageY)) {
			return;
		}
		this.closeList();
	}
}
