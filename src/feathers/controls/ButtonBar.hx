/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.events.FeathersEvent;
import feathers.controls.dataRenderers.IDataRenderer;
import feathers.core.FeathersControl;
import feathers.core.IUIControl;
import feathers.core.IValidating;
import feathers.core.InvalidationFlag;
import feathers.data.ButtonBarItemState;
import feathers.data.IFlatCollection;
import feathers.events.ButtonBarEvent;
import feathers.events.FlatCollectionEvent;
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
#if (openfl >= "9.1.0")
import openfl.utils.ObjectPool;
#else
import openfl._internal.utils.ObjectPool;
#end

/**
	A grouping of buttons.

	The following example sets the data provider, tells the buttons how to
	interpret the data, and listens for when a button is triggered:

	```haxe
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
@defaultXmlProperty("dataProvider")
@:styleContext
class ButtonBar extends FeathersControl {
	private static final INVALIDATION_FLAG_BUTTON_FACTORY = InvalidationFlag.CUSTOM("buttonFactory");

	/**
		The variant used to style the button child components in a theme.

		To override this default variant, set the
		`ButtonBar.customButtonVariant` property.

		@see `ButtonBar.customButtonVariant`
		@see `feathers.style.IVariantStyleObject.variant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_BUTTON = "buttonBar_button";

	private static final RESET_BUTTON_STATE = new ButtonBarItemState();

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
	public function new(?dataProvider:IFlatCollection<Dynamic>, ?itemTriggerListener:(ButtonBarEvent) -> Void) {
		initializeButtonBarTheme();

		super();

		this.dataProvider = dataProvider;

		if (itemTriggerListener != null) {
			this.addEventListener(ButtonBarEvent.ITEM_TRIGGER, itemTriggerListener);
		}
	}

	private var _dataProvider:IFlatCollection<Dynamic>;

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

		```haxe
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
		FeathersEvent.dispatch(this, "dataChange");
		return this._dataProvider;
	}

	private var _previousCustomButtonVariant:String = null;

	/**
		A custom variant to set on all buttons, instead of
		`ButtonBar.CHILD_VARIANT_BUTTON`.

		The `customButtonVariant` will be not be used if the result of
		`buttonRecycler.create()` already has a variant set.

		@see `ButtonBar.CHILD_VARIANT_BUTTON`
		@see `feathers.style.IVariantStyleObject.variant`

		@since 1.0.0
	**/
	@:style
	public var customButtonVariant:String = null;

	/**
		Manages buttons used by the button bar.

		In the following example, the button bar uses a custom button renderer class:

		```haxe
		buttonBar.buttonRecycler = DisplayObjectRecycler.withClass(Button);
		```

		@since 1.0.0
	**/
	public var buttonRecycler(get, set):AbstractDisplayObjectRecycler<Dynamic, ButtonBarItemState, Button>;

	private function get_buttonRecycler():AbstractDisplayObjectRecycler<Dynamic, ButtonBarItemState, Button> {
		return this._defaultStorage.buttonRecycler;
	}

	private function set_buttonRecycler(value:AbstractDisplayObjectRecycler<Dynamic, ButtonBarItemState, Button>):AbstractDisplayObjectRecycler<Dynamic,
		ButtonBarItemState, Button> {
		if (this._defaultStorage.buttonRecycler == value) {
			return this._defaultStorage.buttonRecycler;
		}
		this._defaultStorage.oldButtonRecycler = this._defaultStorage.buttonRecycler;
		this._defaultStorage.buttonRecycler = value;
		this.setInvalid(INVALIDATION_FLAG_BUTTON_FACTORY);
		return this._defaultStorage.buttonRecycler;
	}

	private var _forceItemStateUpdate:Bool = false;

	/**
		Forces the `buttonRecycler.update()` method to be called with the
		`ButtonBarItemState` when the button bar validates, even if the item's
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

	private var _recyclerMap:Map<String, DisplayObjectRecycler<Dynamic, ButtonBarItemState, Button>> = null;

	private var _buttonRecyclerIDFunction:(state:ButtonBarItemState) -> String;

	/**
		When a button bar requires multiple button styles, this function is used
		to determine which style of button is required for a specific item.
		Returns the ID of the button recycler to use for the item, or `null` if
		the default `buttonRecycler` should be used.

		The following example provides an `buttonRecyclerIDFunction`:

		```haxe
		var regularButtonRecycler = DisplayObjectRecycler.withClass(Button);
		var firstButtonRecycler = DisplayObjectRecycler.withClass(MyCustomButton);

		buttonBar.setButtonRecycler("regular-button", regularButtonRecycler);
		buttonBar.setButtonRecycler("first-button", firstButtonRecycler);

		buttonBar.buttonRecyclerIDFunction = function(state:ButtonBarItemState):String {
			if(state.index == 0) {
				return "first-button";
			}
			return "regular-button";
		};
		```

		@default null

		@see `ButtonBar.setButtonRecycler()`
		@see `ButtonBar.buttonRecycler

		@since 1.0.0
	**/
	public var buttonRecyclerIDFunction(get, set):(state:ButtonBarItemState) -> String;

	private function get_buttonRecyclerIDFunction():(state:ButtonBarItemState) -> String {
		return this._buttonRecyclerIDFunction;
	}

	private function set_buttonRecyclerIDFunction(value:(state:ButtonBarItemState) -> String):(state:ButtonBarItemState) -> String {
		if (this._buttonRecyclerIDFunction == value) {
			return this._buttonRecyclerIDFunction;
		}
		this._buttonRecyclerIDFunction = value;
		this.setInvalid(INVALIDATION_FLAG_BUTTON_FACTORY);
		return this._buttonRecyclerIDFunction;
	}

	private var _defaultStorage:ButtonStorage = new ButtonStorage(null, DisplayObjectRecycler.withClass(Button));
	private var _additionalStorage:Array<ButtonStorage> = null;
	private var dataToButton = new ObjectMap<Dynamic, Button>();
	private var buttonToItemState = new ObjectMap<Button, ButtonBarItemState>();
	private var itemStatePool = new ObjectPool(() -> new ButtonBarItemState());
	private var _unrenderedData:Array<Dynamic> = [];
	private var _layoutItems:Array<DisplayObject> = [];

	private var _ignoreSelectionChange = false;

	/**
		Converts an item to text to display within button bar. By default, the
		`toString()` method is called to convert an item to text. This method
		may be replaced to provide custom text.

		For example, consider the following item:

		```haxe
		{ text: "Example Item" }
		```

		If the `ButtonBar` should display the text "Example Item", a custom
		implementation of `itemToText()` might look like this:

		```haxe
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
		Determines if a button should be enabled or disabled. By default, all
		items are enabled, unless the `ButtonBar` is disabled. This method
		may be replaced to provide a custom value for `enabled`.

		For example, consider the following item:

		```haxe
		{ text: "Example Item", disable: true }
		```

		If the `ButtonBar` should disable an item if the `disable` field is
		`true`, a custom implementation of `itemToEnabled()` might look like
		this:

		```haxe
		buttonBar.itemToEnabled = (item:Dynamic) -> {
			return !item.disable;
		};
		```

		@since 1.2.0
	**/
	public dynamic function itemToEnabled(data:Dynamic):Bool {
		return true;
	}

	/**
		The layout algorithm used to position and size the buttons.

		By default, if no layout is provided by the time that the button bar
		initializes, a default layout that displays items horizontally will be
		created.

		The following example tells the button bar to use a custom layout:

		```haxe
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

		```haxe
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

		```haxe
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

	/**
		Returns the current button used to render a specific item from the data
		provider. May return `null` if an item doesn't currently have a button.

		@since 1.0.0
	**/
	public function itemToButton(item:Dynamic):Button {
		if (item == null) {
			return null;
		}
		return this.dataToButton.get(item);
	}

	/**
		Returns the current button used to render the item at the specified
		index in the data provider. May return `null` if an item doesn't
		currently have a button.

		@since 1.0.0
	**/
	public function indexToButton(index:Int):Button {
		if (this._dataProvider == null || index < 0 || index >= this._dataProvider.length) {
			return null;
		}
		var item = this._dataProvider.get(index);
		return this.dataToButton.get(item);
	}

	/**
		Returns the button recycler associated with a specific ID. Returns
		`null` if no recycler is associated with the ID.

		@see `ButtonBar.buttonRecyclerIDFunction`
		@see `ButtonBar.setButtonRecycler()`

		@since 1.0.0
	**/
	public function getButtonRecycler(id:String):DisplayObjectRecycler<Dynamic, ButtonBarItemState, Button> {
		if (this._recyclerMap == null) {
			return null;
		}
		return this._recyclerMap.get(id);
	}

	/**
		Associates an button recycler with an ID to allow multiple types
		of buttons to be displayed in the button bar. A custom
		`buttonRecyclerIDFunction` may be specified to return the ID of the
		recycler to use for a specific item in the data provider.

		To clear a recycler, pass in `null` as the value.

		@see `ButtonBar.buttonRecyclerIDFunction`
		@see `ButtonBar.getButtonRecycler()`

		@since 1.0.0
	**/
	public function setButtonRecycler(id:String, recycler:AbstractDisplayObjectRecycler<Dynamic, ButtonBarItemState, Button>):Void {
		if (this._recyclerMap == null) {
			this._recyclerMap = [];
		}
		if (recycler == null) {
			this._recyclerMap.remove(id);
			return;
		}
		this._recyclerMap.set(id, recycler);
		this.setInvalid(INVALIDATION_FLAG_BUTTON_FACTORY);
	}

	override public function dispose():Void {
		this.refreshInactiveButtons(this._defaultStorage, true);
		if (this._additionalStorage != null) {
			for (i in 0...this._additionalStorage.length) {
				var storage = this._additionalStorage[i];
				this.refreshInactiveButtons(storage, true);
			}
		}
		this.dataProvider = null;
		super.dispose();
	}

	private function initializeButtonBarTheme():Void {
		#if !feathersui_disable_default_theme
		feathers.themes.steel.components.SteelButtonBarStyles.initialize();
		#end
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
		for (button in this._layoutItems) {
			if (!(button is IValidating)) {
				return;
			}
			(cast button : IValidating).validateNow();
		}
	}

	private function refreshButtons():Void {
		if (this.buttonRecycler.update == null) {
			this.buttonRecycler.update = defaultUpdateButton;
			if (this.buttonRecycler.reset == null) {
				this.buttonRecycler.reset = defaultResetButton;
			}
		}
		if (this._recyclerMap != null) {
			for (recycler in this._recyclerMap) {
				if (recycler.update == null) {
					if (recycler.update == null) {
						recycler.update = defaultUpdateButton;
						// don't replace reset if we didn't replace update too
						if (recycler.reset == null) {
							recycler.reset = defaultResetButton;
						}
					}
				}
			}
		}

		var buttonsInvalid = this.isInvalid(INVALIDATION_FLAG_BUTTON_FACTORY);
		this.refreshInactiveButtons(this._defaultStorage, buttonsInvalid);
		if (this._additionalStorage != null) {
			for (i in 0...this._additionalStorage.length) {
				var storage = this._additionalStorage[i];
				this.refreshInactiveButtons(storage, buttonsInvalid);
			}
		}
		this.findUnrenderedData();
		this.recoverInactiveButtons(this._defaultStorage);
		if (this._additionalStorage != null) {
			for (i in 0...this._additionalStorage.length) {
				var storage = this._additionalStorage[i];
				this.recoverInactiveButtons(storage);
			}
		}
		this.renderUnrenderedData();
		this.freeInactiveButtons(this._defaultStorage);
		if (this._defaultStorage.inactiveButtons.length > 0) {
			throw new IllegalOperationError('${Type.getClassName(Type.getClass(this))}: inactive buttons should be empty after updating.');
		}
		if (this._additionalStorage != null) {
			for (i in 0...this._additionalStorage.length) {
				var storage = this._additionalStorage[i];
				this.freeInactiveButtons(storage);
				if (storage.inactiveButtons.length > 0) {
					throw new IllegalOperationError('${Type.getClassName(Type.getClass(this))}: inactive buttons ${storage.id} should be empty after updating.');
				}
			}
		}
	}

	private function refreshInactiveButtons(storage:ButtonStorage, factoryInvalid:Bool):Void {
		var temp = storage.inactiveButtons;
		storage.inactiveButtons = storage.activeButtons;
		storage.activeButtons = temp;
		if (storage.activeButtons.length > 0) {
			throw new IllegalOperationError('${Type.getClassName(Type.getClass(this))}: active buttons should be empty before updating.');
		}
		if (factoryInvalid) {
			this.recoverInactiveButtons(storage);
			this.freeInactiveButtons(storage);
		}
	}

	private function recoverInactiveButtons(storage:ButtonStorage):Void {
		for (button in storage.inactiveButtons) {
			if (button == null) {
				continue;
			}
			var state = this.buttonToItemState.get(button);
			if (state == null) {
				continue;
			}
			var item = state.data;
			this.buttonToItemState.remove(button);
			this.dataToButton.remove(item);
			button.removeEventListener(TriggerEvent.TRIGGER, buttonBar_button_triggerHandler);
			this.resetButton(button, state);
			this.itemStatePool.release(state);
		}
	}

	private function freeInactiveButtons(storage:ButtonStorage):Void {
		for (button in storage.inactiveButtons) {
			if (button == null) {
				continue;
			}
			this.destroyButton(button);
		}
		#if (hl && haxe_ver < 4.3)
		storage.inactiveButtons.splice(0, storage.inactiveButtons.length);
		#else
		storage.inactiveButtons.resize(0);
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
		if (this._dataProvider == null || this._dataProvider.length == 0) {
			return;
		}
		this._layoutItems.resize(this._dataProvider.length);

		var depthOffset = this._currentBackgroundSkin != null ? 1 : 0;
		for (i in 0...this._dataProvider.length) {
			var item = this._dataProvider.get(i);
			var button = this.dataToButton.get(item);
			if (button != null) {
				var state = this.buttonToItemState.get(button);
				var changed = this.populateCurrentItemState(item, i, state, this._forceItemStateUpdate);
				var oldRecyclerID = state.recyclerID;
				var storage = this.itemStateToStorage(state);
				if (storage.id != oldRecyclerID) {
					this._unrenderedData.push(item);
					continue;
				}
				if (changed) {
					this.updateButton(button, state, storage);
				}
				this._layoutItems[i] = button;
				this.setChildIndex(button, i + depthOffset);
				var removed = storage.inactiveButtons.remove(button);
				if (!removed) {
					throw new IllegalOperationError('${Type.getClassName(Type.getClass(this))}: button renderer map contains bad data for item at index ${i}. This may be caused by duplicate items in the data provider, which is not allowed.');
				}
				storage.activeButtons.push(button);
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
			var button = this.createButton(state);
			this.addChildAt(button, index + depthOffset);
			this._layoutItems[index] = button;
		}
		#if (hl && haxe_ver < 4.3)
		this._unrenderedData.splice(0, this._unrenderedData.length);
		#else
		this._unrenderedData.resize(0);
		#end
	}

	private function createButton(state:ButtonBarItemState):Button {
		var storage = this.itemStateToStorage(state);
		var button:Button = null;
		if (storage.inactiveButtons.length == 0) {
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
			button = storage.inactiveButtons.shift();
		}
		this.updateButton(button, state, storage);
		button.addEventListener(TriggerEvent.TRIGGER, buttonBar_button_triggerHandler);
		this.buttonToItemState.set(button, state);
		this.dataToButton.set(state.data, button);
		storage.activeButtons.push(button);
		return button;
	}

	private function destroyButton(button:Button):Void {
		this.removeChild(button);
		if (this.buttonRecycler.destroy != null) {
			this.buttonRecycler.destroy(button);
		}
	}

	private function itemStateToStorage(state:ButtonBarItemState):ButtonStorage {
		var recyclerID:String = null;
		if (this._buttonRecyclerIDFunction != null) {
			recyclerID = this._buttonRecyclerIDFunction(state);
		}
		var recycler:DisplayObjectRecycler<Dynamic, ButtonBarItemState, Button> = null;
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
			if (storage.buttonRecycler == recycler) {
				return storage;
			}
		}
		var storage = new ButtonStorage(recyclerID, recycler);
		this._additionalStorage.push(storage);
		return storage;
	}

	private function populateCurrentItemState(item:Dynamic, index:Int, state:ButtonBarItemState, force:Bool):Bool {
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

	private function updateButton(button:Button, state:ButtonBarItemState, storage:ButtonStorage):Void {
		state.recyclerID = storage.id;
		var oldIgnoreSelectionChange = this._ignoreSelectionChange;
		this._ignoreSelectionChange = true;
		if (this.buttonRecycler.update != null) {
			this.buttonRecycler.update(button, state);
		}
		this._ignoreSelectionChange = oldIgnoreSelectionChange;
		this.refreshButtonProperties(button, state);
	}

	private function resetButton(button:Button, state:ButtonBarItemState):Void {
		var oldIgnoreSelectionChange = this._ignoreSelectionChange;
		this._ignoreSelectionChange = true;
		if (this.buttonRecycler != null && this.buttonRecycler.reset != null) {
			this.buttonRecycler.reset(button, state);
		}
		this._ignoreSelectionChange = oldIgnoreSelectionChange;
		this.refreshButtonProperties(button, RESET_BUTTON_STATE);
	}

	private function refreshButtonProperties(button:Button, state:ButtonBarItemState):Void {
		var oldIgnoreSelectionChange = this._ignoreSelectionChange;
		this._ignoreSelectionChange = true;
		if ((button is IUIControl)) {
			var uiControl:IUIControl = cast button;
			uiControl.enabled = state.enabled;
		}
		if ((button is IDataRenderer)) {
			var dataRenderer:IDataRenderer = cast button;
			// if the button is an IDataRenderer, this cannot be overridden
			dataRenderer.data = state.data;
		}
		if ((button is ILayoutIndexObject)) {
			var layoutObject:ILayoutIndexObject = cast button;
			layoutObject.layoutIndex = state.index;
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
		if (state.owner == null) {
			// a previous update is already pending
			return;
		}
		var storage = this.itemStateToStorage(state);
		this.populateCurrentItemState(item, index, state, true);
		// in order to display the same item with modified properties, this
		// hack tricks the item renderer into thinking that it has been given
		// a different item to render.
		this.resetButton(button, state);
		// ensures that the change is detected when we validate later
		state.owner = null;
		this.setInvalid(DATA);
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

private class ButtonStorage {
	public function new(?id:String, ?recycler:DisplayObjectRecycler<Dynamic, ButtonBarItemState, Button>) {
		this.id = id;
		this.buttonRecycler = recycler;
	}

	public var id:String;
	public var oldButtonRecycler:DisplayObjectRecycler<Dynamic, ButtonBarItemState, Button>;
	public var buttonRecycler:DisplayObjectRecycler<Dynamic, ButtonBarItemState, Button>;
	public var activeButtons:Array<Button> = [];
	public var inactiveButtons:Array<Button> = [];
}
