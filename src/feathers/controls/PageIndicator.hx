/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import feathers.core.IFocusObject;
import openfl.errors.ArgumentError;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalLayout;
import openfl.events.TouchEvent;
import openfl.events.MouseEvent;
import feathers.data.PageIndicatorItemState;
import feathers.utils.DisplayObjectRecycler;
import openfl.errors.IllegalOperationError;
import feathers.core.IStateContext;
import feathers.core.IUIControl;
import feathers.core.IStateObserver;
import feathers.core.IValidating;
import feathers.layout.LayoutBoundsResult;
import feathers.layout.ILayout;
import feathers.layout.Measurements;
import openfl.display.DisplayObject;
import openfl.events.Event;
import openfl.errors.RangeError;
import feathers.events.FeathersEvent;
import feathers.core.InvalidationFlag;
import feathers.core.FeathersControl;
import feathers.core.IIndexSelector;
import feathers.themes.steel.components.SteelPageIndicatorStyles;
#if air
import openfl.ui.Multitouch;
#end

/**
	Displays a series of dots or other symbols, usually corresponding to a page
	index in another UI control, such as `PageNavigator`.

	The following example creates a page indicator, sets its range and selected
	index, and lsitens for when the selection changes:

	```hx
	var pages = new PageIndicator();

	pages.maxSelectedIndex = 5;
	pages.selectedIndex = 1;

	pages.addEventListener(Event.CHANGE, (event:Event) -> {
		var pages = cast(event.currentTarget, PageIndicator);
		trace("PageIndicator changed: " + pages.selectedIndex);
	});
	```

	@see [Tutorial: How to use the PageIndicator component](https://feathersui.com/learn/haxe-openfl/page-indicator/)
	@see `feathers.controls.navigators.PageNavigator`

	@since 1.0.0
**/
@:access(feathers.data.PageIndicatorItemState)
@:styleContext
class PageIndicator extends FeathersControl implements IIndexSelector implements IFocusObject {
	private static final INVALIDATION_FLAG_TOGGLE_BUTTON_FACTORY = "toggleButtonFactory";

	/**
		The variant used to style the toggle button child components in a theme.

		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)
	**/
	public static final CHILD_VARIANT_TOGGLE_BUTTON = "pageIndicator_toggleButton";

	/**
		Creates a new `PageIndicator` object.

		@since 1.0.0
	**/
	public function new() {
		initializePageIndicatorTheme();

		super();

		this.mouseChildren = this.interactionMode == PRECISE;
		this.addEventListener(MouseEvent.CLICK, pageIndicator_clickHandler);
		// TODO: temporarily disabled until isPrimaryTouchPoint bug is fixed
		// See commit: 43d659b6afa822873ded523395e2a2a1a4567a50
		// this.addEventListener(TouchEvent.TOUCH_TAP, pageIndicator_touchTapHandler);
		this.addEventListener(KeyboardEvent.KEY_DOWN, pageIndicator_keyDownHandler);
	}

	/**
		@see `feathers.core.IIndexSelector.selectedIndex`
	**/
	@:isVar
	public var selectedIndex(get, set):Int = -1;

	private function get_selectedIndex():Int {
		return this.selectedIndex;
	}

	private function set_selectedIndex(value:Int):Int {
		if (this.selectedIndex == value) {
			return this.selectedIndex;
		}
		if (value < -1 || value > this.maxSelectedIndex) {
			throw new RangeError("Index " + value + " is out of range " + this.maxSelectedIndex + " for PageIndicator.");
		}

		this.selectedIndex = value;
		this.setInvalid(InvalidationFlag.DATA);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this.selectedIndex;
	}

	/**
		@see `feathers.core.IIndexSelector.maxSelectedIndex`
	**/
	@:isVar
	public var maxSelectedIndex(get, set):Int;

	private function get_maxSelectedIndex():Int {
		return this.maxSelectedIndex;
	}

	private function set_maxSelectedIndex(value:Int):Int {
		if (this.maxSelectedIndex == value) {
			return this.maxSelectedIndex;
		}
		this.maxSelectedIndex = value;
		this.setInvalid(InvalidationFlag.DATA);
		if (this.maxSelectedIndex >= 0 && this.selectedIndex < 0) {
			this.selectedIndex = 0;
		} else if (this.selectedIndex > this.maxSelectedIndex) {
			this.selectedIndex = this.maxSelectedIndex;
		}
		return this.maxSelectedIndex;
	}

	/**
		Manages toggle buttons used by the page indicator.

		In the following example, the page indicator uses a custom toggle
		button:

		```hx
		pages.toggleButtonRecycler = DisplayObjectRecycler.withClass(ToggleButtonSubClass);
		```

		@since 1.0.0
	**/
	public var toggleButtonRecycler:DisplayObjectRecycler<Dynamic, PageIndicatorItemState, ToggleButton> = DisplayObjectRecycler.withClass(ToggleButton);

	private var inactiveToggleButtons:Array<ToggleButton> = [];
	private var activeToggleButtons:Array<ToggleButton> = [];

	private var _ignoreSelectionChange = false;

	/**
		The layout algorithm used to position and size the buttons.

		By default, if no layout is provided by the time that the page indicator
		initializes, a default layout that displays items horizontally will be
		created.

		The following example tells the page indicator to use a custom layout:

		```hx
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

		```hx
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

		```hx
		pages.disabledBackgroundSkin = new Bitmap(bitmapData);
		pages.enabled = false;
		```

		@default null

		@see `PageIndicator.backgroundSkin`

		@since 1.0.0
	**/
	@:style
	public var disabledBackgroundSkin:DisplayObject = null;

	/**
		Determines how the selected index changes when the page indicator is
		clicked or tapped. If precise, the exact page must be chosen. If
		previous/next, the selection increases or decreases by one.
		Previous/next interaction is recommended on mobile, due to the low
		precision of touches.

		In the following example, the interaction mode is changed to precise:

		```hx
		pages.interactionMode = PRECISE;
		```

		@since 1.0.0
	**/
	public var interactionMode(default, set):PageIndicatorInteractionMode = PREVIOUS_NEXT;

	private function set_interactionMode(value:PageIndicatorInteractionMode):PageIndicatorInteractionMode {
		if (this.interactionMode == value) {
			return this.interactionMode;
		}
		this.interactionMode = value;
		this.mouseChildren = this.interactionMode == PRECISE;
		return this.interactionMode;
	}

	private var _layoutMeasurements = new Measurements();
	private var _layoutResult = new LayoutBoundsResult();
	private var _ignoreChildChanges = false;

	private var _currentItemState = new PageIndicatorItemState();

	private function initializePageIndicatorTheme():Void {
		SteelPageIndicatorStyles.initialize();
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);
		var layoutInvalid = this.isInvalid(InvalidationFlag.LAYOUT);
		var selectionInvalid = this.isInvalid(InvalidationFlag.SELECTION);
		var stateInvalid = this.isInvalid(InvalidationFlag.STATE);
		var stylesInvalid = this.isInvalid(InvalidationFlag.STYLES);
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
	}

	private function refreshViewPortBounds():Void {
		this._layoutMeasurements.save(this);
	}

	private function handleLayout():Void {
		if (!Std.is(this.layout, HorizontalLayout) && !Std.is(this.layout, VerticalLayout)) {
			throw new ArgumentError("PageIndicator must use HorizontalLayout or VerticalLayout");
		}
		var oldIgnoreChildChanges = this._ignoreChildChanges;
		this._ignoreChildChanges = true;
		this.layout.layout(cast this.activeToggleButtons, this._layoutMeasurements, this._layoutResult);
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
		var buttonsInvalid = this.isInvalid(INVALIDATION_FLAG_TOGGLE_BUTTON_FACTORY);
		this.refreshInactiveToggleButtons(buttonsInvalid);

		this.recoverInactiveToggleButtons();
		for (i in 0...this.maxSelectedIndex + 1) {
			this.createToggleButton(i);
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
		}
	}

	private function recoverInactiveToggleButtons():Void {
		for (button in this.inactiveToggleButtons) {
			if (button == null) {
				continue;
			}
			button.removeEventListener(Event.CHANGE, pageIndicator_toggleButton_changeHandler);
			this._currentItemState.index = -1;
			this._currentItemState.selected = false;
			var oldIgnoreSelectionChange = this._ignoreSelectionChange;
			this._ignoreSelectionChange = true;
			if (this.toggleButtonRecycler.reset != null) {
				this.toggleButtonRecycler.reset(button, this._currentItemState);
			}
			button.selected = this._currentItemState.selected;
			this._ignoreSelectionChange = oldIgnoreSelectionChange;
		}
	}

	private function freeInactiveToggleButtons():Void {
		for (button in this.inactiveToggleButtons) {
			if (button == null) {
				continue;
			}
			this.destroyToggleButton(button);
		}
		this.inactiveToggleButtons.resize(0);
	}

	private function refreshBackgroundSkin():Void {
		var oldSkin = this._currentBackgroundSkin;
		this._currentBackgroundSkin = this.getCurrentBackgroundSkin();
		if (this._currentBackgroundSkin == oldSkin) {
			return;
		}
		this.removeCurrentBackgroundSkin(oldSkin);
		if (this._currentBackgroundSkin == null) {
			this._backgroundSkinMeasurements = null;
			return;
		}
		if (Std.is(this._currentBackgroundSkin, IUIControl)) {
			cast(this._currentBackgroundSkin, IUIControl).initializeNow();
		}
		if (this._backgroundSkinMeasurements == null) {
			this._backgroundSkinMeasurements = new Measurements(this._currentBackgroundSkin);
		} else {
			this._backgroundSkinMeasurements.save(this._currentBackgroundSkin);
		}
		if (Std.is(this, IStateContext) && Std.is(this._currentBackgroundSkin, IStateObserver)) {
			cast(this._currentBackgroundSkin, IStateObserver).stateContext = cast(this, IStateContext<Dynamic>);
		}
		this.addChildAt(this._currentBackgroundSkin, 0);
	}

	private function getCurrentBackgroundSkin():DisplayObject {
		if (!this.enabled && this.disabledBackgroundSkin != null) {
			return this.disabledBackgroundSkin;
		}
		return this.backgroundSkin;
	}

	private function removeCurrentBackgroundSkin(skin:DisplayObject):Void {
		if (skin == null) {
			return;
		}
		if (Std.is(skin, IStateObserver)) {
			cast(skin, IStateObserver).stateContext = null;
		}
		this._backgroundSkinMeasurements.restore(skin);
		if (skin.parent == this) {
			// we need to restore these values so that they won't be lost the
			// next time that this skin is used for measurement
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
		if (Std.is(this._currentBackgroundSkin, IValidating)) {
			cast(this._currentBackgroundSkin, IValidating).validateNow();
		}
	}

	private function createToggleButton(index:Int):ToggleButton {
		var depthOffset = this._currentBackgroundSkin != null ? 1 : 0;
		var button:ToggleButton = null;
		if (this.inactiveToggleButtons.length == 0) {
			button = this.toggleButtonRecycler.create();
			this.addChildAt(button, index + depthOffset);
		} else {
			button = this.inactiveToggleButtons.shift();
			this.setChildIndex(button, index + depthOffset);
		}
		if (button.variant == null) {
			// if the factory set a variant already, don't use the default
			button.variant = PageIndicator.CHILD_VARIANT_TOGGLE_BUTTON;
		}
		this._currentItemState.index = index;
		this._currentItemState.selected = index == this.selectedIndex;
		var oldIgnoreSelectionChange = this._ignoreSelectionChange;
		this._ignoreSelectionChange = true;
		if (this.toggleButtonRecycler.update != null) {
			this.toggleButtonRecycler.update(button, this._currentItemState);
		}
		button.selected = this._currentItemState.selected;
		this._ignoreSelectionChange = oldIgnoreSelectionChange;
		button.addEventListener(Event.CHANGE, pageIndicator_toggleButton_changeHandler);
		this.activeToggleButtons.push(button);
		return button;
	}

	private function destroyToggleButton(button:ToggleButton):Void {
		this.removeChild(button);
		if (this.toggleButtonRecycler.destroy != null) {
			this.toggleButtonRecycler.destroy(button);
		}
	}

	private function navigateWithKeyboard(event:KeyboardEvent):Void {
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
				result = this.maxSelectedIndex;
			default:
				// not keyboard navigation
				return;
		}
		if (result < 0) {
			result = 0;
		} else if (result > this.maxSelectedIndex) {
			result = this.maxSelectedIndex;
		}
		event.stopPropagation();
		this.selectedIndex = result;
	}

	private function pageIndicator_keyDownHandler(event:KeyboardEvent):Void {
		if (!this.enabled) {
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
		this.selectedIndex = this.activeToggleButtons.indexOf(button);
	}

	private function handleClickOrTap(localX:Float, localY:Float):Void {
		var selectedIndex = this.selectedIndex;
		if (selectedIndex != -1) {
			var button = this.activeToggleButtons[selectedIndex];
			if (Std.is(this.layout, VerticalLayout)) {
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
		} else if (selectedIndex > this.maxSelectedIndex) {
			selectedIndex = this.maxSelectedIndex;
		}
		this.selectedIndex = selectedIndex;
	}

	private function pageIndicator_clickHandler(event:MouseEvent):Void {
		if (!this.enabled || this.interactionMode != PREVIOUS_NEXT) {
			return;
		}
		this.handleClickOrTap(event.localX, event.localY);
	}

	private function pageIndicator_touchTapHandler(event:TouchEvent):Void {
		if (!this.enabled || this.interactionMode != PREVIOUS_NEXT) {
			return;
		}
		if (event.isPrimaryTouchPoint #if air && Multitouch.mapTouchToMouse #end) {
			// ignore the primary one because MouseEvent.CLICK will catch it
			return;
		}

		this.handleClickOrTap(event.localX, event.localY);
	}
}
