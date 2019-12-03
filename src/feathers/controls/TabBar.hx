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
	private static final INVALIDATION_FLAG_BUTTON_FACTORY = "buttonFactory";

	private static function defaultUpdateButton(button:ToggleButton, state:TabBarItemState):Void {
		button.text = state.text;
	}

	private static function defaultResetButton(button:ToggleButton, state:TabBarItemState):Void {
		button.text = null;
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
	public var buttonRecycler:DisplayObjectRecycler<Dynamic, TabBarItemState, ToggleButton> = new DisplayObjectRecycler(ToggleButton);

	private var inactiveButtons:Array<ToggleButton> = [];
	private var activeButtons:Array<ToggleButton> = [];
	private var dataToButton = new ObjectMap<Dynamic, ToggleButton>();
	private var buttonToData = new ObjectMap<ToggleButton, Dynamic>();
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
		var buttonsInvalid = this.isInvalid(INVALIDATION_FLAG_BUTTON_FACTORY);

		if (buttonsInvalid || selectionInvalid || stateInvalid || dataInvalid) {
			this.refreshButtons();
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
		this._layout.layout(cast this.activeButtons, this._layoutMeasurements, this._layoutResult);
		this._ignoreChildChanges = oldIgnoreChildChanges;
	}

	private function handleLayoutResult():Void {
		var viewPortWidth = this._layoutResult.viewPortWidth;
		var viewPortHeight = this._layoutResult.viewPortHeight;
		this.saveMeasurements(viewPortWidth, viewPortHeight, viewPortWidth, viewPortHeight);
	}

	private function validateChildren():Void {
		for (button in this.activeButtons) {
			button.validateNow();
		}
	}

	private function refreshButtons():Void {
		if (this.buttonRecycler.update == null) {
			this.buttonRecycler.update = defaultUpdateButton;
			if (this.buttonRecycler.reset == null) {
				this.buttonRecycler.reset = defaultResetButton;
			}
		}

		var buttonsInvalid = this.isInvalid(INVALIDATION_FLAG_BUTTON_FACTORY);
		this.refreshInactiveButtons(buttonsInvalid);
		if (this.dataProvider == null) {
			return;
		}

		this.findUnrenderedData();
		this.recoverInactiveButtons();
		this.renderUnrenderedData();
		this.freeInactiveButtons();
		if (this.inactiveButtons.length > 0) {
			throw new IllegalOperationError(Type.getClassName(Type.getClass(this)) + ": inactive item renderers should be empty after updating.");
		}
	}

	private function refreshInactiveButtons(factoryInvalid:Bool):Void {
		var temp = this.inactiveButtons;
		this.inactiveButtons = this.activeButtons;
		this.activeButtons = temp;
		if (this.activeButtons.length > 0) {
			throw new IllegalOperationError(Type.getClassName(Type.getClass(this)) + ": active item renderers should be empty before updating.");
		}
		if (factoryInvalid) {
			this.recoverInactiveButtons();
			this.freeInactiveButtons();
		}
	}

	private function recoverInactiveButtons():Void {
		for (button in this.inactiveButtons) {
			if (button == null) {
				continue;
			}
			var item = this.buttonToData.get(button);
			if (item == null) {
				return;
			}
			this.buttonToData.remove(button);
			this.dataToButton.remove(item);
			button.removeEventListener(FeathersEvent.TRIGGERED, button_triggeredHandler);
			button.removeEventListener(Event.CHANGE, button_changeHandler);
			this._currentItemState.data = item;
			this._currentItemState.index = -1;
			this._currentItemState.selected = false;
			this._currentItemState.text = null;
			var oldIgnoreSelectionChange = this._ignoreSelectionChange;
			this._ignoreSelectionChange = true;
			if (this.buttonRecycler.reset != null) {
				this.buttonRecycler.reset(button, this._currentItemState);
			}
			if (Std.is(button, IDataRenderer)) {
				var dataRenderer = cast(button, IDataRenderer);
				dataRenderer.data = null;
			}
			button.selected = this._currentItemState.selected;
			this._ignoreSelectionChange = oldIgnoreSelectionChange;
		}
	}

	private function freeInactiveButtons():Void {
		for (button in this.inactiveButtons) {
			if (button == null) {
				continue;
			}
			this.destroyButton(button);
		}
		this.inactiveButtons.resize(0);
	}

	private var _currentItemState = new TabBarItemState();

	private function findUnrenderedData():Void {
		for (i in 0...this.dataProvider.length) {
			var item = this.dataProvider.get(i);
			var button = this.dataToButton.get(item);
			if (button != null) {
				this._currentItemState.data = item;
				this._currentItemState.index = i;
				this._currentItemState.selected = item == this.selectedItem;
				this._currentItemState.text = itemToText(item);
				var oldIgnoreSelectionChange = this._ignoreSelectionChange;
				this._ignoreSelectionChange = true;
				if (this.buttonRecycler.update != null) {
					this.buttonRecycler.update(button, this._currentItemState);
				}
				if (Std.is(button, IDataRenderer)) {
					var dataRenderer = cast(button, IDataRenderer);
					// if the button is an IDataRenderer, this cannot be overridden
					dataRenderer.data = this._currentItemState.data;
				}
				button.selected = this._currentItemState.selected;
				this._ignoreSelectionChange = oldIgnoreSelectionChange;
				// if this item renderer used to be the typical layout item, but
				// it isn't anymore, it may have been set invisible
				button.visible = true;
				this.addChildAt(button, i);
				var removed = this.inactiveButtons.remove(button);
				if (!removed) {
					throw new IllegalOperationError(Type.getClassName(Type.getClass(this))
						+ ": data renderer map contains bad data. This may be caused by duplicate items in the data provider, which is not allowed.");
				}
				this.activeButtons.push(button);
			} else {
				this._unrenderedData.push(item);
			}
		}
	}

	private function renderUnrenderedData():Void {
		for (item in this._unrenderedData) {
			var index = this.dataProvider.indexOf(item);
			var button = this.createButton(item, index);
			button.visible = true;
			this.activeButtons.push(button);
			this.addChildAt(button, index);
		}
		this._unrenderedData.resize(0);
	}

	private function createButton(item:Dynamic, index:Int):ToggleButton {
		var button:ToggleButton = null;
		if (this.inactiveButtons.length == 0) {
			button = this.buttonRecycler.create();
		} else {
			button = this.inactiveButtons.shift();
		}
		this._currentItemState.data = item;
		this._currentItemState.index = index;
		this._currentItemState.selected = item == this.selectedItem;
		this._currentItemState.text = itemToText(item);
		if (this.buttonRecycler.update != null) {
			this.buttonRecycler.update(button, this._currentItemState);
		}
		button.selected = this._currentItemState.selected;
		button.addEventListener(FeathersEvent.TRIGGERED, button_triggeredHandler);
		button.addEventListener(Event.CHANGE, button_changeHandler);
		this.buttonToData.set(button, item);
		this.dataToButton.set(item, button);
		return button;
	}

	private function destroyButton(button:ToggleButton):Void {
		this.removeChild(button);
		if (this.buttonRecycler.destroy != null) {
			this.buttonRecycler.destroy(button);
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

	private function button_triggeredHandler(event:FeathersEvent):Void {
		var button = cast(event.currentTarget, ToggleButton);
		var item = this.buttonToData.get(button);
		// trigger before change
		FeathersEvent.dispatch(this, FeathersEvent.TRIGGERED);
	}

	private function button_changeHandler(event:Event):Void {
		if (this._ignoreSelectionChange) {
			return;
		}
		var button = cast(event.currentTarget, ToggleButton);
		if (!button.selected) {
			// no toggle off!
			button.selected = true;
			return;
		}
		var item = this.buttonToData.get(button);
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
