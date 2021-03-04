/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.events.ButtonBarEvent;
import feathers.controls.dataRenderers.IDataRenderer;
import feathers.core.FeathersControl;
import feathers.core.IDataSelector;
import feathers.core.IFocusObject;
import feathers.core.IIndexSelector;
import feathers.core.IUIControl;
import feathers.core.IValidating;
import feathers.core.InvalidationFlag;
import feathers.data.IFlatCollection;
import feathers.data.ButtonBarItemState;
import feathers.events.FeathersEvent;
import feathers.events.FlatCollectionEvent;
import feathers.events.TriggerEvent;
import feathers.layout.ILayout;
import feathers.layout.LayoutBoundsResult;
import feathers.layout.Measurements;
import feathers.skins.IProgrammaticSkin;
import feathers.themes.steel.components.SteelButtonBarStyles;
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
	A grouping of buttons.

	The following example sets the data provider, tells the buttons how to
	interpret the data, and listens for when a button is triggered:

	```hx
	var buttonBar = new ButtonBar();
	buttonBar.dataProvider = new ArrayCollection([
		{ text: "Latest Posts" },
		{ text: "Profile" },
		{ text: "Settings" }
	]);

	buttonBar.itemToText = (item:Dynamic) -> {
		return item.text;
	};

	buttonBar.addEventListener(ButtonBarEvent.ITEM_TRIGGER, buttons_itemTriggerHandler);

	this.addChild(buttonBar);
	```

	@event feathers.events.ButtonBarEvent.ITEM_TRIGGER Dispatched when the user
	taps or clicks a button. The pointer must remain within the bounds of the tab
	on release, or the gesture will be ignored.

	@see [Tutorial: How to use the ButtonBar component](https://feathersui.com/learn/haxe-openfl/button-bar/)

	@since 1.0.0
**/
@:event(feathers.events.ButtonBarEvent.ITEM_TRIGGER)
@:access(feathers.data.ButtonBarItemState)
@:meta(DefaultProperty("dataProvider"))
@defaultXmlProperty("dataProvider")
@:styleContext
class ButtonBar extends FeathersControl {
	private static final INVALIDATION_FLAG_BUTTON_FACTORY = InvalidationFlag.CUSTOM("buttonFactory");

	/**
		The variant used to style the button child components in a theme.

		To override this default variant, set the
		`ButtonBar.customButtonVariant` property.

		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@see `ButtonBar.customButtonVariant`

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_BUTTON = "buttonBar_button";

	private static function defaultUpdateButton(button:Button, state:ButtonBarItemState):Void {
		button.text = state.text;
	}

	private static function defaultResetButton(button:Button, state:ButtonBarItemState):Void {
		button.text = null;
	}

	/**
		Creates a new `ButtonBar` object.

		@since 1.0.0
	**/
	public function new() {
		initializeButtonBarTheme();

		super();
	}

	private var _dataProvider:IFlatCollection<Dynamic> = null;

	/**
		The collection of data displayed by the button bar.

		Items in the collection must be class instances or anonymous structures.
		Do not add primitive values (such as strings, booleans, or numeric
		values) directly to the collection.

		Additionally, all items in the collection must be unique object
		instances. Do not add the same instance to the collection more than
		once because a runtime exception will be thrown.

		The following example passes in a data provider and tells the buttons
		how to interpret the data:

		```hx
		buttonBar.dataProvider = new ArrayCollection([
			{ text: "Latest Posts" },
			{ text: "Profile" },
			{ text: "Settings" }
		]);

		buttonBar.itemToText = (item:Dynamic) -> {
			return item.text;
		};
		```

		@default null

		@see `feathers.data.ArrayCollection`

		@since 1.0.0
	**/
	@:flash.property
	public var dataProvider(get, set):IFlatCollection<Dynamic>;

	private function get_dataProvider():IFlatCollection<Dynamic> {
		return this._dataProvider;
	}

	private function set_dataProvider(value:IFlatCollection<Dynamic>):IFlatCollection<Dynamic> {
		if (this._dataProvider == value) {
			return this._dataProvider;
		}
		if (this._dataProvider != null) {
			this._dataProvider.removeEventListener(Event.CHANGE, buttonBar_dataProvider_changeHandler);
			this._dataProvider.removeEventListener(FlatCollectionEvent.UPDATE_ITEM, buttonBar_dataProvider_updateItemHandler);
			this._dataProvider.removeEventListener(FlatCollectionEvent.UPDATE_ALL, buttonBar_dataProvider_updateAllHandler);
		}
		this._dataProvider = value;
		if (this._dataProvider != null) {
			this._dataProvider.addEventListener(Event.CHANGE, buttonBar_dataProvider_changeHandler);
			this._dataProvider.addEventListener(FlatCollectionEvent.UPDATE_ITEM, buttonBar_dataProvider_updateItemHandler);
			this._dataProvider.addEventListener(FlatCollectionEvent.UPDATE_ALL, buttonBar_dataProvider_updateAllHandler);
		}
		this.setInvalid(DATA);
		return this._dataProvider;
	}

	private var _previousCustomButtonVariant:String = null;

	/**
		A custom variant to set on all buttons, instead of
		`ButtonBar.CHILD_VARIANT_BUTTON`.

		The `customButtonVariant` will be not be used if the result of
		`buttonRecycler.create()` already has a variant set.

		@see `ButtonBar.CHILD_VARIANT_BUTTON`

		@since 1.0.0
	**/
	@:style
	public var customButtonVariant:String = null;

	/**
		Manages buttons used by the button bar.

		In the following example, the button bar uses a custom button renderer class:

		```hx
		buttonBar.buttonRecycler = DisplayObjectRecycler.withClass(Button);
		```

		@since 1.0.0
	**/
	public var buttonRecycler:DisplayObjectRecycler<Dynamic, ButtonBarItemState, Button> = DisplayObjectRecycler.withClass(Button);

	private var inactiveButtons:Array<Button> = [];
	private var activeButtons:Array<Button> = [];
	private var dataToButton = new ObjectMap<Dynamic, Button>();
	private var buttonToItemState = new ObjectMap<Button, ButtonBarItemState>();
	private var itemStatePool = new ObjectPool(() -> new ButtonBarItemState());
	private var _unrenderedData:Array<Dynamic> = [];

	private var _ignoreSelectionChange = false;

	/**
		Converts an item to text to display within button bar. By default, the
		`toString()` method is called to convert an item to text. This method
		may be replaced to provide custom text.

		For example, consider the following item:

		```hx
		{ text: "Example Item" }
		```

		If the `ButtonBar` should display the text "Example Item", a custom
		implementation of `itemToText()` might look like this:

		```hx
		buttonBar.itemToText = (item:Dynamic) -> {
			return item.text;
		};
		```

		@since 1.0.0
	**/
	public dynamic function itemToText(data:Dynamic):String {
		return Std.string(data);
	}

	/**
		The layout algorithm used to position and size the buttons.

		By default, if no layout is provided by the time that the button bar
		initializes, a default layout that displays items horizontally will be
		created.

		The following example tells the button bar to use a custom layout:

		```hx
		var layout = new HorizontalDistributedLayout();
		layout.maxItemWidth = 300.0;
		buttonBar.layout = layout;
		```

		@since 1.0.0
	**/
	@:style
	public var layout:ILayout = null;

	private var _currentBackgroundSkin:DisplayObject = null;
	private var _backgroundSkinMeasurements:Measurements = null;

	/**
		The default background skin to display behind the buttons.

		The following example passes a bitmap for the button bar to use as a
		background skin:

		```hx
		buttonBar.backgroundSkin = new Bitmap(bitmapData);
		```

		@default null

		@see `ButtonBar.disabledBackgroundSkin`

		@since 1.0.0
	**/
	@:style
	public var backgroundSkin:DisplayObject = null;

	/**
		A background skin to display behind the buttons when the button bar is
		disabled.

		The following example gives the button bar a disabled background skin:

		```hx
		buttonBar.disabledBackgroundSkin = new Bitmap(bitmapData);
		buttonBar.enabled = false;
		```

		@default null

		@see `ButtonBar.backgroundSkin`

		@since 1.0.0
	**/
	@:style
	public var disabledBackgroundSkin:DisplayObject = null;

	private var _layoutMeasurements = new Measurements();
	private var _layoutResult = new LayoutBoundsResult();
	private var _ignoreChildChanges = false;

	private function initializeButtonBarTheme():Void {
		SteelButtonBarStyles.initialize();
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(DATA);
		var layoutInvalid = this.isInvalid(LAYOUT);
		var selectionInvalid = this.isInvalid(SELECTION);
		var stateInvalid = this.isInvalid(STATE);
		var stylesInvalid = this.isInvalid(STYLES);
		if (this._previousCustomButtonVariant != this.customButtonVariant) {
			this.setInvalidationFlag(INVALIDATION_FLAG_BUTTON_FACTORY);
		}
		var buttonsInvalid = this.isInvalid(INVALIDATION_FLAG_BUTTON_FACTORY);

		if (stylesInvalid || stateInvalid) {
			this.refreshBackgroundSkin();
		}

		if (buttonsInvalid || selectionInvalid || stateInvalid || dataInvalid) {
			this.refreshButtons();
		}

		this.refreshViewPortBounds();
		this.handleLayout();
		this.handleLayoutResult();

		this.layoutBackgroundSkin();

		// final invalidation to avoid juggler next frame issues
		this.validateChildren();

		this._previousCustomButtonVariant = this.customButtonVariant;
	}

	private function refreshViewPortBounds():Void {
		this._layoutMeasurements.save(this);
	}

	private function handleLayout():Void {
		var oldIgnoreChildChanges = this._ignoreChildChanges;
		this._ignoreChildChanges = true;
		this._layoutResult.reset();
		this.layout.layout(cast this.activeButtons, this._layoutMeasurements, this._layoutResult);
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
			var state = this.buttonToItemState.get(button);
			if (state == null) {
				return;
			}
			var item = state.data;
			this.buttonToItemState.remove(button);
			this.dataToButton.remove(item);
			button.removeEventListener(TriggerEvent.TRIGGER, buttonBar_button_triggerHandler);
			state.owner = this;
			state.data = item;
			state.index = -1;
			state.enabled = true;
			state.text = null;
			var oldIgnoreSelectionChange = this._ignoreSelectionChange;
			this._ignoreSelectionChange = true;
			if (this.buttonRecycler != null && this.buttonRecycler.reset != null) {
				this.buttonRecycler.reset(button, state);
			}
			this._ignoreSelectionChange = oldIgnoreSelectionChange;
			this.refreshButtonProperties(button, state);
			this.itemStatePool.release(state);
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
		if (Std.is(skin, IUIControl)) {
			cast(skin, IUIControl).initializeNow();
		}
		if (this._backgroundSkinMeasurements == null) {
			this._backgroundSkinMeasurements = new Measurements(skin);
		} else {
			this._backgroundSkinMeasurements.save(skin);
		}
		if (Std.is(skin, IProgrammaticSkin)) {
			cast(skin, IProgrammaticSkin).uiContext = this;
		}
		this.addChildAt(skin, 0);
	}

	private function removeCurrentBackgroundSkin(skin:DisplayObject):Void {
		if (skin == null) {
			return;
		}
		if (Std.is(skin, IProgrammaticSkin)) {
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
		if (Std.is(this._currentBackgroundSkin, IValidating)) {
			cast(this._currentBackgroundSkin, IValidating).validateNow();
		}
	}

	private function findUnrenderedData():Void {
		if (this._dataProvider == null || this._dataProvider.length == 0) {
			return;
		}
		var depthOffset = this._currentBackgroundSkin != null ? 1 : 0;
		for (i in 0...this._dataProvider.length) {
			var item = this._dataProvider.get(i);
			var button = this.dataToButton.get(item);
			if (button != null) {
				var state = this.buttonToItemState.get(button);
				this.populateCurrentItemState(item, i, state);
				this.updateButton(button, state);
				this.addChildAt(button, i + depthOffset);
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
		var depthOffset = this._currentBackgroundSkin != null ? 1 : 0;
		for (item in this._unrenderedData) {
			var index = this._dataProvider.indexOf(item);
			var state = this.itemStatePool.get();
			this.populateCurrentItemState(item, index, state);
			var button = this.createButton(state);
			this.activeButtons.push(button);
			this.addChildAt(button, index + depthOffset);
		}
		this._unrenderedData.resize(0);
	}

	private function createButton(state:ButtonBarItemState):Button {
		var button:Button = null;
		if (this.inactiveButtons.length == 0) {
			button = this.buttonRecycler.create();
			if (button.variant == null) {
				// if the factory set a variant already, don't use the default
				var variant = this.customButtonVariant != null ? this.customButtonVariant : ButtonBar.CHILD_VARIANT_BUTTON;
				button.variant = variant;
			}
			// for consistency, initialize before passing to the recycler's
			// update function
			button.initializeNow();
		} else {
			button = this.inactiveButtons.shift();
		}
		this.updateButton(button, state);
		button.addEventListener(TriggerEvent.TRIGGER, buttonBar_button_triggerHandler);
		this.buttonToItemState.set(button, state);
		this.dataToButton.set(state.data, button);
		return button;
	}

	private function destroyButton(button:Button):Void {
		this.removeChild(button);
		if (this.buttonRecycler.destroy != null) {
			this.buttonRecycler.destroy(button);
		}
	}

	private function populateCurrentItemState(item:Dynamic, index:Int, state:ButtonBarItemState):Void {
		state.owner = this;
		state.data = item;
		state.index = index;
		state.enabled = this._enabled;
		state.text = itemToText(item);
	}

	private function updateButton(button:Button, state:ButtonBarItemState):Void {
		var oldIgnoreSelectionChange = this._ignoreSelectionChange;
		this._ignoreSelectionChange = true;
		if (this.buttonRecycler.update != null) {
			this.buttonRecycler.update(button, state);
		}
		this._ignoreSelectionChange = oldIgnoreSelectionChange;
		this.refreshButtonProperties(button, state);
	}

	private function refreshButtonProperties(button:Button, state:ButtonBarItemState):Void {
		var oldIgnoreSelectionChange = this._ignoreSelectionChange;
		this._ignoreSelectionChange = true;
		if (Std.is(button, IUIControl)) {
			var uiControl = cast(button, IUIControl);
			uiControl.enabled = state.enabled;
		}
		if (Std.is(button, IDataRenderer)) {
			var dataRenderer = cast(button, IDataRenderer);
			// if the button is an IDataRenderer, this cannot be overridden
			dataRenderer.data = state.data;
		}
		button.enabled = state.enabled;
		this._ignoreSelectionChange = oldIgnoreSelectionChange;
	}

	private function buttonBar_button_triggerHandler(event:TriggerEvent):Void {
		var button = cast(event.currentTarget, Button);
		var state = this.buttonToItemState.get(button);
		ButtonBarEvent.dispatch(this, ButtonBarEvent.ITEM_TRIGGER, state);
	}

	private function buttonBar_dataProvider_changeHandler(event:Event):Void {
		this.setInvalid(DATA);
	}

	private function updateButtonForIndex(index:Int):Void {
		var item = this._dataProvider.get(index);
		var button = this.dataToButton.get(item);
		if (button == null) {
			// doesn't exist yet, so we need to do a full invalidation
			this.setInvalid(DATA);
			return;
		}
		var state = this.buttonToItemState.get(button);
		this.updateButton(button, state);
	}

	private function buttonBar_dataProvider_updateItemHandler(event:FlatCollectionEvent):Void {
		this.updateButtonForIndex(event.index);
	}

	private function buttonBar_dataProvider_updateAllHandler(event:FlatCollectionEvent):Void {
		for (i in 0...this._dataProvider.length) {
			this.updateButtonForIndex(i);
		}
	}
}
