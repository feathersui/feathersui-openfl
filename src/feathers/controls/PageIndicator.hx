/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.core.FeathersControl;
import feathers.core.IFocusObject;
import feathers.core.IIndexSelector;
import feathers.core.IUIControl;
import feathers.core.IValidating;
import feathers.core.InvalidationFlag;
import feathers.data.PageIndicatorItemState;
import feathers.events.FeathersEvent;
import feathers.layout.HorizontalLayout;
import feathers.layout.ILayout;
import feathers.layout.LayoutBoundsResult;
import feathers.layout.Measurements;
import feathers.layout.VerticalLayout;
import feathers.skins.IProgrammaticSkin;
import feathers.utils.AbstractDisplayObjectRecycler;
import feathers.utils.DisplayObjectRecycler;
import openfl.display.DisplayObject;
import openfl.errors.ArgumentError;
import openfl.errors.IllegalOperationError;
import openfl.errors.RangeError;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.events.TouchEvent;
import openfl.ui.Keyboard;
#if air
import openfl.ui.Multitouch;
#end

/**
	Displays a series of dots or other symbols, usually corresponding to a page
	index in another UI control, such as `PageNavigator`.

	The following example creates a page indicator, sets its range and selected
	index, and lsitens for when the selection changes:

	```haxe
	var pages = new PageIndicator();

	pages.maxSelectedIndex = 5;
	pages.selectedIndex = 1;

	pages.addEventListener(Event.CHANGE, (event:Event) -> {
		var pages = cast(event.currentTarget, PageIndicator);
		trace("PageIndicator changed: " + pages.selectedIndex);
	});
	```

	@event openfl.events.Event.CHANGE Dispatched when
	`PageIndicator.selectedIndex` changes.

	@see [Tutorial: How to use the PageIndicator component](https://feathersui.com/learn/haxe-openfl/page-indicator/)
	@see `feathers.controls.navigators.PageNavigator`

	@since 1.0.0
**/
@:event(openfl.events.Event.CHANGE)
@:access(feathers.data.PageIndicatorItemState)
@:styleContext
class PageIndicator extends FeathersControl implements IIndexSelector implements IFocusObject {
	private static final INVALIDATION_FLAG_TOGGLE_BUTTON_FACTORY = InvalidationFlag.CUSTOM("toggleButtonFactory");

	/**
		The variant used to style the toggle button child components in a theme.

		To override this default variant, set the
		`PageIndicator.customToggleButtonVariant` property.

		@see `PageIndicator.customToggleButtonVariant`
		@see `feathers.style.IVariantStyleObject.variant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_TOGGLE_BUTTON = "pageIndicator_toggleButton";

	/**
		Creates a new `PageIndicator` object.

		@since 1.0.0
	**/
	public function new(maxSelectedIndex:Int = -1, ?changeListener:(Event) -> Void) {
		initializePageIndicatorTheme();

		super();

		this.mouseChildren = this._interactionMode == PRECISE;
		this.tabEnabled = true;
		this.tabChildren = false;

		this.maxSelectedIndex = maxSelectedIndex;

		this.addEventListener(MouseEvent.CLICK, pageIndicator_clickHandler);
		#if (openfl >= "9.0.0")
		this.addEventListener(TouchEvent.TOUCH_TAP, pageIndicator_touchTapHandler);
		#end
		this.addEventListener(KeyboardEvent.KEY_DOWN, pageIndicator_keyDownHandler);

		if (changeListener != null) {
			this.addEventListener(Event.CHANGE, changeListener);
		}
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
		if (this._selectedIndex == value) {
			return this._selectedIndex;
		}
		if (value < -1 || value > this._maxSelectedIndex) {
			throw new RangeError("Index " + value + " is out of range " + this._maxSelectedIndex + " for PageIndicator.");
		}

		this._selectedIndex = value;
		this.setInvalid(DATA);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._selectedIndex;
	}

	private var _maxSelectedIndex:Int = -1;

	/**
		@see `feathers.core.IIndexSelector.maxSelectedIndex`
	**/
	public var maxSelectedIndex(get, set):Int;

	private function get_maxSelectedIndex():Int {
		return this._maxSelectedIndex;
	}

	private function set_maxSelectedIndex(value:Int):Int {
		if (this._maxSelectedIndex == value) {
			return this._maxSelectedIndex;
		}
		this._maxSelectedIndex = value;
		this.setInvalid(DATA);
		if (this._maxSelectedIndex >= 0 && this._selectedIndex < 0) {
			// use the setter
			this.selectedIndex = 0;
		} else if (this.selectedIndex > this._maxSelectedIndex) {
			// use the setter
			this.selectedIndex = this._maxSelectedIndex;
		}
		return this._maxSelectedIndex;
	}

	private var _previousCustomToggleButtonVariant:String = null;

	/**
		A custom variant to set on all toggle buttons, instead of
		`PageIndicator.CHILD_VARIANT_TOGGLE_BUTTON`.

		The `customToggleButtonVariant` will be not be used if the result of
		`toggleButtonRecycler.create()` already has a variant set.

		@see `PageIndicator.CHILD_VARIANT_TOGGLE_BUTTON`
		@see `feathers.style.IVariantStyleObject.variant`

		@since 1.0.0
	**/
	@:style
	public var customToggleButtonVariant:String = null;

	private var _oldToggleButtonRecycler:DisplayObjectRecycler<Dynamic, PageIndicatorItemState, ToggleButton>;

	private var _toggleButtonRecycler:DisplayObjectRecycler<Dynamic, PageIndicatorItemState, ToggleButton> = DisplayObjectRecycler.withClass(ToggleButton);

	/**
		Manages toggle buttons used by the page indicator.

		In the following example, the page indicator uses a custom toggle
		button:

		```haxe
		pages.toggleButtonRecycler = DisplayObjectRecycler.withClass(ToggleButtonSubClass);
		```

		@since 1.0.0
	**/
	public var toggleButtonRecycler(get, set):AbstractDisplayObjectRecycler<Dynamic, PageIndicatorItemState, ToggleButton>;

	private function get_toggleButtonRecycler():AbstractDisplayObjectRecycler<Dynamic, PageIndicatorItemState, ToggleButton> {
		return this._toggleButtonRecycler;
	}

	private function set_toggleButtonRecycler(value:AbstractDisplayObjectRecycler<Dynamic, PageIndicatorItemState,
		ToggleButton>):AbstractDisplayObjectRecycler<Dynamic, PageIndicatorItemState, ToggleButton> {
		if (this._toggleButtonRecycler == value) {
			return this._toggleButtonRecycler;
		}
		this._oldToggleButtonRecycler = this._toggleButtonRecycler;
		this._toggleButtonRecycler = value;
		this.setInvalid(INVALIDATION_FLAG_TOGGLE_BUTTON_FACTORY);
		return this._toggleButtonRecycler;
	}

	private var inactiveToggleButtons:Array<ToggleButton> = [];
	private var activeToggleButtons:Array<ToggleButton> = [];
	private var _layoutItems:Array<DisplayObject> = [];

	private var _ignoreSelectionChange = false;

	/**
		The layout algorithm used to position and size the buttons.

		By default, if no layout is provided by the time that the page indicator
		initializes, a default layout that displays items horizontally will be
		created.

		The following example tells the page indicator to use a custom layout:

		```haxe
		var layout = new HorizontalDistributedLayout();
		layout.maxItemWidth = 300.0;
		pages.layout = layout;
		```

		@since 1.0.0
	**/
	@:style
	public var layout:ILayout = null;

	private var _currentBackgroundSkin:DisplayObject = null;
	private var _backgroundSkinMeasurements:Measurements = null;

	/**
		The default background skin to display behind the buttons.

		The following example passes a bitmap for the page indicator to use as a
		background skin:

		```haxe
		pages.backgroundSkin = new Bitmap(bitmapData);
		```

		@default null

		@see `PageIndicator.disabledBackgroundSkin`

		@since 1.0.0
	**/
	@:style
	public var backgroundSkin:DisplayObject = null;

	/**
		A background skin to display behind the buttons when the page indicator
		is disabled.

		The following example gives the page indicator a disabled background skin:

		```haxe
		pages.disabledBackgroundSkin = new Bitmap(bitmapData);
		pages.enabled = false;
		```

		@default null

		@see `PageIndicator.backgroundSkin`

		@since 1.0.0
	**/
	@:style
	public var disabledBackgroundSkin:DisplayObject = null;

	private var _interactionMode:PageIndicatorInteractionMode = PREVIOUS_NEXT;

	/**
		Determines how the selected index changes when the page indicator is
		clicked or tapped. If precise, the exact page must be chosen. If
		previous/next, the selection increases or decreases by one.
		Previous/next interaction is recommended on mobile, due to the low
		precision of touches.

		In the following example, the interaction mode is changed to precise:

		```haxe
		pages.interactionMode = PRECISE;
		```

		@since 1.0.0
	**/
	public var interactionMode(get, set):PageIndicatorInteractionMode;

	private function get_interactionMode():PageIndicatorInteractionMode {
		return this._interactionMode;
	}

	private function set_interactionMode(value:PageIndicatorInteractionMode):PageIndicatorInteractionMode {
		if (this._interactionMode == value) {
			return this._interactionMode;
		}
		this._interactionMode = value;
		this.mouseChildren = this._interactionMode == PRECISE;
		return this._interactionMode;
	}

	private var _layoutMeasurements = new Measurements();
	private var _layoutResult = new LayoutBoundsResult();
	private var _ignoreChildChanges = false;

	private var _currentItemState = new PageIndicatorItemState();

	/**
		Returns the current toggle button used to render the item at the
		specified index in the data provider. May return `null` if an item
		doesn't currently have a toggle button.

		@since 1.0.0
	**/
	public function indexToToggleButton(index:Int):ToggleButton {
		if (index < 0 || index >= this.activeToggleButtons.length) {
			return null;
		}
		return this.activeToggleButtons[index];
	}

	override public function dispose():Void {
		this.refreshInactiveToggleButtons(true);
		this.maxSelectedIndex = -1;
		super.dispose();
	}

	private function initializePageIndicatorTheme():Void {
		#if !feathersui_disable_default_theme
		feathers.themes.steel.components.SteelPageIndicatorStyles.initialize();
		#end
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(DATA);
		var dataInvalid = this.isInvalid(DATA);
		var layoutInvalid = this.isInvalid(LAYOUT);
		var selectionInvalid = this.isInvalid(SELECTION);
		var stateInvalid = this.isInvalid(STATE);
		var stylesInvalid = this.isInvalid(STYLES);
		if (this._previousCustomToggleButtonVariant != this.customToggleButtonVariant) {
			this.setInvalidationFlag(INVALIDATION_FLAG_TOGGLE_BUTTON_FACTORY);
		}
		var buttonsInvalid = this.isInvalid(INVALIDATION_FLAG_TOGGLE_BUTTON_FACTORY);

		if (stylesInvalid || stateInvalid) {
			this.refreshBackgroundSkin();
		}

		if (buttonsInvalid || selectionInvalid || stateInvalid || dataInvalid) {
			this.refreshToggleButtons();
		}

		this.refreshViewPortBounds();
		this.handleLayout();
		this.handleLayoutResult();

		this.layoutBackgroundSkin();

		// final invalidation to avoid juggler next frame issues
		this.validateChildren();

		this._previousCustomToggleButtonVariant = this.customToggleButtonVariant;
	}

	private function refreshViewPortBounds():Void {
		this._layoutMeasurements.save(this);
	}

	private function handleLayout():Void {
		if (!(this.layout is HorizontalLayout) && !(this.layout is VerticalLayout)) {
			throw new ArgumentError("PageIndicator must use HorizontalLayout or VerticalLayout");
		}
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
		for (button in this.activeToggleButtons) {
			button.validateNow();
		}
	}

	private function refreshToggleButtons():Void {
		// remove all old items, then fill with null
		#if (hl && haxe_ver < 4.3)
		this._layoutItems.splice(0, this._layoutItems.length);
		#else
		this._layoutItems.resize(0);
		#end
		this._layoutItems.resize(this._maxSelectedIndex + 1);

		var buttonsInvalid = this.isInvalid(INVALIDATION_FLAG_TOGGLE_BUTTON_FACTORY);
		this.refreshInactiveToggleButtons(buttonsInvalid);

		this.recoverInactiveToggleButtons();
		for (i in 0...this._maxSelectedIndex + 1) {
			var button = this.createToggleButton(i);
			this._layoutItems[i] = button;
		}
		this.freeInactiveToggleButtons();
		if (this.inactiveToggleButtons.length > 0) {
			throw new IllegalOperationError(Type.getClassName(Type.getClass(this)) + ": inactive item renderers should be empty after updating.");
		}
	}

	private function refreshInactiveToggleButtons(factoryInvalid:Bool):Void {
		var temp = this.inactiveToggleButtons;
		this.inactiveToggleButtons = this.activeToggleButtons;
		this.activeToggleButtons = temp;
		if (this.activeToggleButtons.length > 0) {
			throw new IllegalOperationError(Type.getClassName(Type.getClass(this)) + ": active item renderers should be empty before updating.");
		}
		if (factoryInvalid) {
			this.recoverInactiveToggleButtons();
			this.freeInactiveToggleButtons();
			this._oldToggleButtonRecycler = null;
		}
	}

	private function recoverInactiveToggleButtons():Void {
		var recycler = this._oldToggleButtonRecycler != null ? this._oldToggleButtonRecycler : this._toggleButtonRecycler;
		for (button in this.inactiveToggleButtons) {
			if (button == null) {
				continue;
			}
			button.removeEventListener(Event.CHANGE, pageIndicator_toggleButton_changeHandler);
			this._currentItemState.owner = this;
			this._currentItemState.index = -1;
			this._currentItemState.selected = false;
			this._currentItemState.enabled = true;
			var oldIgnoreSelectionChange = this._ignoreSelectionChange;
			this._ignoreSelectionChange = true;
			if (recycler.reset != null) {
				recycler.reset(button, this._currentItemState);
			}
			button.selected = this._currentItemState.selected;
			button.enabled = this._currentItemState.enabled;
			this._ignoreSelectionChange = oldIgnoreSelectionChange;
		}
	}

	private function freeInactiveToggleButtons():Void {
		var recycler = this._oldToggleButtonRecycler != null ? this._oldToggleButtonRecycler : this._toggleButtonRecycler;
		for (button in this.inactiveToggleButtons) {
			if (button == null) {
				continue;
			}
			this.destroyToggleButton(button, recycler);
		}
		#if (hl && haxe_ver < 4.3)
		this.inactiveToggleButtons.splice(0, this.inactiveToggleButtons.length);
		#else
		this.inactiveToggleButtons.resize(0);
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
			this.graphics.clear();
			this.graphics.beginFill(0xff00ff, 0.0);
			this.graphics.drawRect(0, 0, this.actualWidth, this.actualHeight);
			this.graphics.endFill();
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

	private function createToggleButton(index:Int):ToggleButton {
		var depthOffset = this._currentBackgroundSkin != null ? 1 : 0;
		var button:ToggleButton = null;
		if (this.inactiveToggleButtons.length == 0) {
			button = this._toggleButtonRecycler.create();
			if (button.variant == null) {
				// if the factory set a variant already, don't use the default
				var variant = this.customToggleButtonVariant != null ? this.customToggleButtonVariant : PageIndicator.CHILD_VARIANT_TOGGLE_BUTTON;
				button.variant = variant;
			}
			// for consistency, initialize before passing to the recycler's
			// update function
			button.initializeNow();
			this.addChildAt(button, index + depthOffset);
		} else {
			button = this.inactiveToggleButtons.shift();
			this.setChildIndex(button, index + depthOffset);
		}
		this.refreshToggleButtonProperties(button, index);
		button.addEventListener(Event.CHANGE, pageIndicator_toggleButton_changeHandler);
		this.activeToggleButtons.push(button);
		return button;
	}

	private function destroyToggleButton(button:ToggleButton, recycler:DisplayObjectRecycler<Dynamic, PageIndicatorItemState, ToggleButton>):Void {
		this.removeChild(button);
		if (recycler.destroy != null) {
			recycler.destroy(button);
		}
	}

	private function populateCurrentItemState(index:Int):Void {
		this._currentItemState.owner = this;
		this._currentItemState.index = index;
		this._currentItemState.selected = index == this._selectedIndex;
		this._currentItemState.enabled = this._enabled;
	}

	private function refreshToggleButtonProperties(button:ToggleButton, index:Int):Void {
		this.populateCurrentItemState(index);
		var oldIgnoreSelectionChange = this._ignoreSelectionChange;
		this._ignoreSelectionChange = true;
		if (this._toggleButtonRecycler.update != null) {
			this._toggleButtonRecycler.update(button, this._currentItemState);
		}
		button.selected = this._currentItemState.selected;
		button.enabled = this._currentItemState.enabled;
		this._ignoreSelectionChange = oldIgnoreSelectionChange;
	}

	private function navigateWithKeyboard(event:KeyboardEvent):Void {
		if (event.isDefaultPrevented()) {
			return;
		}
		var result = this._selectedIndex;
		switch (event.keyCode) {
			case Keyboard.UP:
				if (event.keyLocation == 4 /* KeyLocation.D_PAD */) {
					return;
				}
				result = result + 1;
			case Keyboard.DOWN:
				if (event.keyLocation == 4 /* KeyLocation.D_PAD */) {
					return;
				}
				result = result - 1;
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
				result = this._maxSelectedIndex;
			default:
				// not keyboard navigation
				return;
		}
		if (result < 0) {
			result = 0;
		} else if (result > this._maxSelectedIndex) {
			result = this._maxSelectedIndex;
		}
		event.preventDefault();
		// use the setter
		this.selectedIndex = result;
	}

	private function pageIndicator_keyDownHandler(event:KeyboardEvent):Void {
		if (!this._enabled) {
			return;
		}
		this.navigateWithKeyboard(event);
	}

	private function pageIndicator_toggleButton_changeHandler(event:Event):Void {
		if (this._ignoreSelectionChange) {
			return;
		}
		var button = cast(event.currentTarget, ToggleButton);
		if (!button.selected) {
			// no toggle off!
			button.selected = true;
			return;
		}
		// use the setter
		this.selectedIndex = this.activeToggleButtons.indexOf(button);
	}

	private function handleClickOrTap(localX:Float, localY:Float):Void {
		var selectedIndex = this._selectedIndex;
		if (selectedIndex != -1) {
			var button = this.activeToggleButtons[selectedIndex];
			if ((this.layout is VerticalLayout)) {
				if (localY < button.y) {
					selectedIndex--;
				} else if (localY > (button.y + button.height)) {
					selectedIndex++;
				}
			} else {
				if (localX < button.x) {
					selectedIndex--;
				} else if (localX > (button.x + button.width)) {
					selectedIndex++;
				}
			}
		}
		if (selectedIndex < 0) {
			selectedIndex = 0;
		} else if (selectedIndex > this._maxSelectedIndex) {
			selectedIndex = this._maxSelectedIndex;
		}
		// use the setter
		this.selectedIndex = selectedIndex;
	}

	private function pageIndicator_clickHandler(event:MouseEvent):Void {
		if (!this._enabled || this._interactionMode != PREVIOUS_NEXT) {
			return;
		}
		this.handleClickOrTap(event.localX, event.localY);
	}

	private function pageIndicator_touchTapHandler(event:TouchEvent):Void {
		if (!this._enabled || this._interactionMode != PREVIOUS_NEXT) {
			return;
		}
		if (event.isPrimaryTouchPoint #if air && Multitouch.mapTouchToMouse #end) {
			// ignore the primary one because MouseEvent.CLICK will catch it
			return;
		}

		this.handleClickOrTap(event.localX, event.localY);
	}
}
