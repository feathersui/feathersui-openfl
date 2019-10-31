/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.controls.dataRenderers.ItemRenderer;
import feathers.utils.DisplayObjectRecycler;
import feathers.data.ListBoxItemState;
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

/**


	@since 1.0.0
**/
@:styleContext
class PopUpList extends FeathersControl {
	private static final INVALIDATION_FLAG_BUTTON_FACTORY = "buttonFactory";
	private static final INVALIDATION_FLAG_LIST_BOX_FACTORY = "listBoxFactory";

	public static final CHILD_VARIANT_BUTTON = "popUpButton";

	public function new() {
		initializePopUpListTheme();

		super();
		this.addEventListener(KeyboardEvent.KEY_UP, popUpList_keyUpHandler);
	}

	private var button:Button;
	private var listBox:ListBox;

	private var buttonMeasurements:Measurements = new Measurements();

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

	public var selectedIndex(default, set):Int = -1;

	private function set_selectedIndex(value:Int):Int {
		if (this.selectedIndex == value) {
			return this.selectedIndex;
		}
		this.selectedIndex = value;
		this.setInvalid(InvalidationFlag.SELECTION);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this.selectedIndex;
	}

	@:isVar
	public var selectedItem(get, null):Dynamic = null;

	private function get_selectedItem():Dynamic {
		if (this.selectedIndex == -1) {
			return null;
		}
		return this.dataProvider.get(this.selectedIndex);
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

		@since 1.0.0
	**/
	public var itemRendererRecycler(default, set):DisplayObjectRecycler<Dynamic, ListBoxItemState>;

	private function set_itemRendererRecycler(value:DisplayObjectRecycler<Dynamic, ListBoxItemState>):DisplayObjectRecycler<Dynamic, ListBoxItemState> {
		if (this.itemRendererRecycler == value) {
			return this.itemRendererRecycler;
		}
		this.itemRendererRecycler = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this.itemRendererRecycler;
	}

	@:style
	public var popUpAdapter:IPopUpAdapter = null;

	public var open(get, never):Bool;

	private function get_open():Bool {
		return this.listBox.parent != null;
	}

	public function openList():Void {
		if (this.open || this.stage == null) {
			return;
		}
		if (this.popUpAdapter != null) {
			this.popUpAdapter.open(this.listBox, this.button);
		} else {
			PopUpManager.addPopUp(this.listBox, this.button);
		}
		this.listBox.addEventListener(Event.REMOVED_FROM_STAGE, popUpList_listBox_removedFromStageHandler);
		this.stage.addEventListener(MouseEvent.MOUSE_DOWN, popUpList_stage_mouseDownHandler, false, 0, true);
		this.stage.addEventListener(TouchEvent.TOUCH_BEGIN, popUpList_stage_touchBeginHandler, false, 0, true);
	}

	public function closeList():Void {
		if (!this.open) {
			return;
		}
		if (this.popUpAdapter != null) {
			this.popUpAdapter.close();
		} else {
			this.listBox.parent.removeChild(this.listBox);
			// TODO: fix this when focus manager is implemented
			this.stage.focus = this;
		}
	}

	private function initializePopUpListTheme():Void {
		SteelPopUpListStyles.initialize();
	}

	override private function initialize():Void {
		super.initialize();

		if (this.itemRendererRecycler == null) {
			this.itemRendererRecycler = new DisplayObjectRecycler<ItemRenderer, ListBoxItemState>(ItemRenderer);
		}
	}

	override private function update():Void {
		var buttonFactoryInvalid = this.isInvalid(INVALIDATION_FLAG_BUTTON_FACTORY);
		var listBoxFactoryInvalid = this.isInvalid(INVALIDATION_FLAG_LIST_BOX_FACTORY);
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);
		var selectionInvalid = this.isInvalid(InvalidationFlag.SELECTION);
		var stateInvalid = this.isInvalid(InvalidationFlag.STATE);

		if (buttonFactoryInvalid) {
			this.createButton();
		}
		if (listBoxFactoryInvalid) {
			this.createListBox();
		}

		if (dataInvalid || listBoxFactoryInvalid) {
			this.refreshData();
		}

		if (selectionInvalid || listBoxFactoryInvalid || buttonFactoryInvalid) {
			this.refreshSelection();
		}

		if (stateInvalid || listBoxFactoryInvalid || buttonFactoryInvalid) {
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

	private function createListBox():Void {
		if (this.listBox != null) {
			this.listBox.removeEventListener(FeathersEvent.TRIGGERED, listBox_triggeredHandler);
			this.listBox.removeEventListener(Event.CHANGE, listBox_changeHandler);
			this.listBox = null;
		}
		this.listBox = new ListBox();
		this.listBox.addEventListener(FeathersEvent.TRIGGERED, listBox_triggeredHandler);
		this.listBox.addEventListener(Event.CHANGE, listBox_changeHandler);
	}

	private function refreshData():Void {
		this.listBox.dataProvider = this.dataProvider;
		this.listBox.itemRendererRecycler = this.itemRendererRecycler;
	}

	private function refreshSelection():Void {
		this.listBox.selectedIndex = this.selectedIndex;

		this.button.text = this.dataProvider.get(this.selectedIndex).text;
	}

	private function refreshEnabled():Void {
		this.button.enabled = this.enabled;
		this.listBox.enabled = this.enabled;
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

	private function listBox_triggeredHandler(event:Event):Void {
		if (this.popUpAdapter == null) {
			this.closeList();
		}
	}

	private function listBox_changeHandler(event:Event):Void {
		this.selectedIndex = this.listBox.selectedIndex;
	}

	private function popUpList_listBox_removedFromStageHandler(event:Event):Void {
		this.listBox.removeEventListener(Event.REMOVED_FROM_STAGE, popUpList_listBox_removedFromStageHandler);
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
		if (this.listBox.hitTestPoint(event.stageX, event.stageY)) {
			return;
		}
		this.closeList();
	}

	private function popUpList_stage_touchBeginHandler(event:TouchEvent):Void {
		if (event.isPrimaryTouchPoint) {
			// ignore the primary one because MouseEvent.MOUSE_DOWN will catch it
			return;
		}
		if (this.listBox.hitTestPoint(event.stageX, event.stageY)) {
			return;
		}
		this.closeList();
	}
}
