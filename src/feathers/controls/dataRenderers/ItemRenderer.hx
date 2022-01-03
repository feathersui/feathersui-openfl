/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.dataRenderers;

import feathers.core.IFocusContainer;
import feathers.core.IFocusObject;
import feathers.core.IPointerDelegate;
import feathers.core.IStateObserver;
import feathers.core.IUIControl;
import feathers.core.IValidating;
import feathers.layout.ILayoutIndexObject;
import feathers.layout.Measurements;
import feathers.skins.IProgrammaticSkin;
import feathers.text.TextFormat;
import feathers.themes.steel.components.SteelItemRendererStyles;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.InteractiveObject;
import openfl.errors.ArgumentError;
import openfl.events.Event;
import openfl.geom.Point;
import openfl.text.TextField;

/**
	A generic renderer for UI components that display data collections.

	@see [Tutorial: How to use the ItemRenderer component](https://feathersui.com/learn/haxe-openfl/item-renderer/)

	@since 1.0.0
**/
@:styleContext
class ItemRenderer extends ToggleButton implements IFocusContainer implements ILayoutIndexObject implements IDataRenderer implements IPointerDelegate {
	/**
		Creates a new `ItemRenderer` object.

		@since 1.0.0
	**/
	public function new() {
		initializeItemRendererTheme();

		super();

		// accessory views need to be accessible to mouse/touch
		this.mouseChildren = true;
		// for some reason, useHandCursor = false is not always respected
		// so buttonMode needs to be false
		this.buttonMode = false;

		// toggling is handled by the owner component, like ListView
		this.toggleable = false;

		this.tabEnabled = false;
		this.tabChildren = true;
	}

	private var _data:Dynamic;

	/**
		@see `feathers.controls.dataRenderers.IDataRenderer.data`
	**/
	@:flash.property
	public var data(get, set):Dynamic;

	private function get_data():Dynamic {
		return this._data;
	}

	private function set_data(value:Dynamic):Dynamic {
		if (this._data == value) {
			return this._data;
		}
		this._data = value;
		this.setInvalid(DATA);
		return this._data;
	}

	private var secondaryTextField:TextField;
	private var _secondaryTextMeasuredWidth:Float;
	private var _secondaryTextMeasuredHeight:Float;
	private var _previousSecondaryText:String = null;
	private var _previousSecondaryTextFormat:TextFormat = null;
	private var _previousSecondarySimpleTextFormat:openfl.text.TextFormat = null;
	private var _updatedSecondaryTextStyles = false;
	private var _secondaryText:String;

	/**
		The optional secondary text displayed by the item renderer.

		The following example sets the item renderer's secondary text:

		```hx
		itemRenderer.secondaryText = "Click Me";
		```

		@default null

		@see `ItemRenderer.secondaryTextFormat`

		@since 1.0.0
	**/
	@:flash.property
	public var secondaryText(get, set):String;

	private function get_secondaryText():String {
		return this._secondaryText;
	}

	private function set_secondaryText(value:String):String {
		if (this._secondaryText == value) {
			return this._secondaryText;
		}
		this._secondaryText = value;
		this.setInvalid(DATA);
		return this._secondaryText;
	}

	private var _childFocusEnabled:Bool = true;

	/**
		@see `feathers.core.IFocusContainer.childFocusEnabled`
	**/
	@:flash.property
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

	private var _layoutIndex:Int = -1;

	/**
		@see `feathers.layout.ILayoutIndexObject.layoutIndex`
	**/
	@:flash.property
	public var layoutIndex(get, set):Int;

	private function get_layoutIndex():Int {
		return this._layoutIndex;
	}

	private function set_layoutIndex(value:Int):Int {
		if (this._layoutIndex == value) {
			return this._layoutIndex;
		}
		this._layoutIndex = value;
		this.setInvalid(DATA);
		this.setInvalid(STYLES);
		return this._layoutIndex;
	}

	private var _pointerTarget:InteractiveObject;

	/**
		@see `feathers.core.IPointerDelegate.pointerTarget`
	**/
	@:flash.property
	public var pointerTarget(get, set):InteractiveObject;

	private function get_pointerTarget():InteractiveObject {
		return this._pointerTarget;
	}

	private function set_pointerTarget(value:InteractiveObject):InteractiveObject {
		if (this._pointerTarget == value) {
			return this._pointerTarget;
		}
		this._pointerTarget = value;
		this.setInvalid(DATA);
		return this._pointerTarget;
	}

	/**
		The font styles used to render the item renderer's secondary text.

		In the following example, the item renderer's secondary text formatting
		is customized:

		```hx
		itemRenderer.secondaryTextFormat = new TextFormat("Helvetica", 20, 0xcc0000);
		```

		@see `ToggleButton.secondaryText`

		@since 1.0.0
	**/
	@:style
	public var secondaryTextFormat:AbstractTextFormat = null;

	/**
		The font styles used to render the item renderer's secondary text when
		the item renderer is disabled.

		In the following example, the item renderer's secondary disabled text
		formatting is customized:

		```hx
		itemRenderer.enabled = false;
		itemRenderer.disabledSecondaryTextFormat = new TextFormat("Helvetica", 20, 0xee0000);
		```

		The next example sets a disabled secondary text format, but also
		provides a text format for the `ToggleButtonState.DISABLED(true)` state
		that will be used instead of the disabled secondary text format:

		```hx
		itemRenderer.disabledSecondaryTextFormat = new TextFormat("Helvetica", 20, 0xee0000);
		itemRenderer.setSecondaryTextFormatForState(ToggleButtonState.DISABLED(true), new TextFormat("Helvetica", 20, 0xff0000));
		```

		Note: If the current state is `ToggleButtonState.DISABLED(true)`, and
		both the `disabledSecondaryTextFormat` and `selectedSecondaryTextFormat`
		are set, the `disabledSecondaryTextFormat` takes precedence over the
		`selectedSecondaryTextFormat`.

		@see `ItemRenderer.secondaryTextFormat`

		@since 1.0.0
	**/
	@:style
	public var disabledSecondaryTextFormat:AbstractTextFormat = null;

	/**
		The font styles used to render the item renderer's secondary text when
		the item renderer is selected.

		In the following example, the item renderer's selected secondary text
		formatting is customized:

		```hx
		itemRenderer.selected = true;
		itemRenderer.selectedSecondaryTextFormat = new TextFormat("Helvetica", 20, 0xff0000);
		```

		The next example sets a selected secondary text format, but also
		provides a text format for the `ToggleButtonState.DOWN(true)` state that
		will be used instead of the selected secondary text format:

		```hx
		itemRenderer.selectedSecondaryTextFormat = new TextFormat("Helvetica", 20, 0xff0000);
		itemRenderer.setSecondaryTextFormatForState(ToggleButtonState.DOWN(true), new TextFormat("Helvetica", 20, 0xcc0000));
		```

		Note: If the current state is `ToggleButtonState.DISABLED(true)`, and
		both the `disabledSecondaryTextFormat` and `selectedSecondaryTextFormat`
		are set, the `disabledSecondaryTextFormat` takes precedence over the
		`selectedSecondaryTextFormat`.

		@see `ItemRenderer.secondaryTextFormat`
		@see `BasicToggleButton.selected`

		@since 1.0.0
	**/
	@:style
	public var selectedSecondaryTextFormat:AbstractTextFormat = null;

	/**
		The display object to use as the background skin when the alternate
		skin is enabled.

		The following example passes a bitmap to use as an alternate background
		skin:

		```hx
		itemRenderer.alternateBackgroundSkin = new Bitmap(bitmapData);
		```

		@default null

		@see `BasicButton.backgroundSkin`

		@since 1.0.0

	**/
	@:style
	public var alternateBackgroundSkin:DisplayObject = null;

	/**
		Shows or hides the item renderer's secondary text. If the secondary text
		is hidden, it will not affect the layout of other children, such as the
		primary text or the icon.

		@since 1.0.0
	**/
	@:style
	public var showSecondaryText:Bool = true;

	private var _ignoreAccessoryResizes = false;
	private var _accessoryViewMeasurements:Measurements;
	private var _currentAccessoryView:DisplayObject;

	/**
		An optional display object positioned on the right side of the item
		renderer.

		The following example passes a button to use as the accessory view:

		```hx
		itemRenderer.accessoryView = new Button("Info");
		```
	**/
	@:style
	public var accessoryView:DisplayObject = null;

	private var _stateToSecondaryTextFormat:Map<ToggleButtonState, AbstractTextFormat> = new Map();

	/**
		Gets the secondary text format to be used by the item renderer when its
		`currentState` property matches the specified state value.

		If a secondary text format is not defined for a specific state, returns
		`null`.

		@see `ToggleButton.setSecondaryTextFormatForState()`
		@see `ToggleButton.secondaryTextFormat`
		@see `ToggleButton.currentState`
		@see `feathers.controls.ToggleButtonState`

		@since 1.0.0
	**/
	public function getSecondaryTextFormatForState(state:ToggleButtonState):AbstractTextFormat {
		return this._stateToSecondaryTextFormat.get(state);
	}

	/**
		Set the secondary text format to be used by the item renderer when its
		`currentState` property matches the specified state value.

		If a secondary text format is not defined for a specific state, the
		value of the `secondaryTextFormat` property will be used instead.

		@see `ItemRenderer.getSecondaryTextFormatForState()`
		@see `ItemRenderer.secondaryTextFormat`
		@see `ItemRenderer.currentState`
		@see `feathers.controls.ToggleButtonState`

		@since 1.0.0
	**/
	@style
	public function setSecondaryTextFormatForState(state:ToggleButtonState, textFormat:AbstractTextFormat):Void {
		if (!this.setStyle("setSecondaryTextFormatForState", state)) {
			return;
		}
		if (textFormat == null) {
			this._stateToSecondaryTextFormat.remove(state);
		} else {
			this._stateToSecondaryTextFormat.set(state, textFormat);
		}
		this.setInvalid(STYLES);
	}

	private function initializeItemRendererTheme():Void {
		SteelItemRendererStyles.initialize();
	}

	override private function initialize():Void {
		super.initialize();
		this._pointerToState.customHitTest = this.customHitTest;
		this._pointerTrigger.customHitTest = this.customHitTest;
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(DATA);
		var sizeInvalid = this.isInvalid(SIZE);
		var stateInvalid = this.isInvalid(STATE);
		var stylesInvalid = this.isInvalid(STYLES);

		this._updatedSecondaryTextStyles = false;

		if (dataInvalid) {
			this._pointerToState.target = (this._pointerTarget != null) ? this._pointerTarget : this;
			this.refreshSecondaryTextField();
		}

		if (stylesInvalid || stateInvalid) {
			this.refreshSecondaryTextStyles();
			this.refreshAccessoryView();
		}

		if (dataInvalid || stylesInvalid || stateInvalid || sizeInvalid) {
			this.refreshSecondaryText(sizeInvalid);
		}

		super.update();
	}

	private function refreshSecondaryTextField():Void {
		if (this._secondaryText == null) {
			if (this.secondaryTextField != null) {
				this.removeChild(this.secondaryTextField);
				this.secondaryTextField = null;
			}
			return;
		}
		if (this.secondaryTextField != null) {
			return;
		}
		this.secondaryTextField = new TextField();
		this.secondaryTextField.selectable = false;
		this.secondaryTextField.multiline = true;
		this.addChild(this.secondaryTextField);
	}

	private function refreshSecondaryTextStyles():Void {
		if (this.secondaryTextField == null) {
			return;
		}
		if (this.secondaryTextField.embedFonts != this.embedFonts) {
			this.secondaryTextField.embedFonts = this.embedFonts;
			this._updatedSecondaryTextStyles = true;
		}
		var textFormat = this.getCurrentSecondaryTextFormat();
		var simpleTextFormat = textFormat != null ? textFormat.toSimpleTextFormat() : null;
		if (simpleTextFormat == this._previousSecondarySimpleTextFormat) {
			// nothing to refresh
			return;
		}
		if (this._previousTextFormat != null) {
			this._previousTextFormat.removeEventListener(Event.CHANGE, itemRenderer_secondaryTextFormat_changeHandler);
		}
		if (textFormat != null) {
			textFormat.addEventListener(Event.CHANGE, itemRenderer_secondaryTextFormat_changeHandler, false, 0, true);
			this.secondaryTextField.defaultTextFormat = simpleTextFormat;
			this._updatedSecondaryTextStyles = true;
		}
		this._previousSecondaryTextFormat = textFormat;
		this._previousSecondarySimpleTextFormat = simpleTextFormat;
	}

	private function refreshSecondaryText(forceMeasurement:Bool):Void {
		if (this.secondaryTextField == null) {
			return;
		}
		var hasSecondaryText = this.showSecondaryText && this._secondaryText != null && this._secondaryText.length > 0;
		this.secondaryTextField.visible = hasSecondaryText;
		if (this._secondaryText == this._previousSecondaryText && !this._updatedSecondaryTextStyles && !forceMeasurement) {
			// nothing to refresh
			return;
		}
		// set autoSize before text because setting text first can trigger an
		// extra text engine reflow
		this.secondaryTextField.autoSize = LEFT;
		if (hasSecondaryText) {
			this.secondaryTextField.text = this._secondaryText;
		} else {
			this.secondaryTextField.text = "\u200b"; // zero-width space
		}
		this._secondaryTextMeasuredWidth = this.secondaryTextField.width;
		this._secondaryTextMeasuredHeight = this.secondaryTextField.height;
		this.secondaryTextField.autoSize = NONE;
		if (!hasSecondaryText) {
			this.secondaryTextField.text = "";
		}
		this._previousSecondaryText = this._secondaryText;
	}

	private function getCurrentSecondaryTextFormat():TextFormat {
		var result = this._stateToSecondaryTextFormat.get(this._currentState);
		if (result != null) {
			return result;
		}
		if (!this._enabled && this.disabledSecondaryTextFormat != null) {
			return this.disabledSecondaryTextFormat;
		}
		if (this._selected && this.selectedSecondaryTextFormat != null) {
			return this.selectedSecondaryTextFormat;
		}
		return this.secondaryTextFormat;
	}

	private function refreshAccessoryView():Void {
		var oldView = this._currentAccessoryView;
		this._currentAccessoryView = this.getCurrentAccessoryView();
		if (this._currentAccessoryView == oldView) {
			return;
		}
		this.removeCurrentAccessoryView(oldView);
		this.addCurrentAccessoryView(this._currentAccessoryView);
	}

	private function getCurrentAccessoryView():DisplayObject {
		return this.accessoryView;
	}

	private function removeCurrentAccessoryView(view:DisplayObject):Void {
		if (view == null) {
			return;
		}
		view.removeEventListener(Event.RESIZE, itemRenderer_accessoryView_resizeHandler);
		if ((view is IProgrammaticSkin)) {
			cast(view, IProgrammaticSkin).uiContext = null;
		}
		if ((view is IStateObserver)) {
			cast(view, IStateObserver).stateContext = null;
		}
		// we need to restore these values so that they won't be lost the
		// next time that this skin is used for measurement
		this._accessoryViewMeasurements.restore(view);
		if (view.parent == this) {
			this.removeChild(view);
		}
	}

	private function addCurrentAccessoryView(view:DisplayObject):Void {
		if (view == null) {
			this._accessoryViewMeasurements = null;
			return;
		}
		if ((view is IUIControl)) {
			cast(view, IUIControl).initializeNow();
		}
		if (this._accessoryViewMeasurements == null) {
			this._accessoryViewMeasurements = new Measurements(view);
		} else {
			this._accessoryViewMeasurements.save(view);
		}
		if ((view is IProgrammaticSkin)) {
			cast(view, IProgrammaticSkin).uiContext = this;
		}
		if ((view is IStateObserver)) {
			cast(view, IStateObserver).stateContext = this;
		}
		view.addEventListener(Event.RESIZE, itemRenderer_accessoryView_resizeHandler, false, 0, true);
		this.addChild(view);
	}

	private function customHitTest(stageX:Float, stageY:Float):Bool {
		var pointerTargetContainer:DisplayObjectContainer = Std.downcast(this._pointerTarget, DisplayObjectContainer);
		if (pointerTargetContainer == null) {
			pointerTargetContainer = this;
		}
		if (pointerTargetContainer.stage == null) {
			return false;
		}
		if (pointerTargetContainer.mouseChildren) {
			var objects = pointerTargetContainer.stage.getObjectsUnderPoint(new Point(stageX, stageY));
			if (objects.length > 0) {
				var lastObject = objects[objects.length - 1];
				if (pointerTargetContainer.contains(lastObject)) {
					while (lastObject != null && lastObject != pointerTargetContainer) {
						if ((lastObject is InteractiveObject)) {
							var interactive = cast(lastObject, InteractiveObject);
							if (!interactive.mouseEnabled) {
								lastObject = lastObject.parent;
								continue;
							}
						}
						if ((lastObject is IFocusObject)) {
							var focusable = cast(lastObject, IFocusObject);
							if (focusable.parent != this._pointerTarget && focusable.focusEnabled) {
								return false;
							}
						}
						lastObject = lastObject.parent;
					}
				}
			}
		}
		return true;
	}

	override private function refreshTextFieldDimensions(forMeasurement:Bool):Void {
		var oldIgnoreIconResizes = this._ignoreIconResizes;
		this._ignoreIconResizes = true;
		if ((this._currentIcon is IValidating)) {
			cast(this._currentIcon, IValidating).validateNow();
		}
		this._ignoreIconResizes = oldIgnoreIconResizes;
		var oldIgnoreAccessoryResizes = this._ignoreAccessoryResizes;
		this._ignoreAccessoryResizes = true;
		if ((this._currentAccessoryView is IValidating)) {
			cast(this._currentAccessoryView, IValidating).validateNow();
		}
		this._ignoreAccessoryResizes = oldIgnoreAccessoryResizes;
		var hasText = this.showText && this._text != null;
		if (!hasText) {
			return;
		}

		var calculatedWidth = this.actualWidth;
		var calculatedHeight = this.actualHeight;
		if (forMeasurement) {
			calculatedWidth = 0.0;
			var explicitCalculatedWidth = this.explicitWidth;
			if (explicitCalculatedWidth == null) {
				explicitCalculatedWidth = this.explicitMaxWidth;
			}
			if (explicitCalculatedWidth != null) {
				calculatedWidth = explicitCalculatedWidth;
			}
			calculatedHeight = 0.0;
			var explicitCalculatedHeight = this.explicitHeight;
			if (explicitCalculatedHeight == null) {
				explicitCalculatedHeight = this.explicitMaxHeight;
			}
			if (explicitCalculatedHeight != null) {
				calculatedHeight = explicitCalculatedHeight;
			}
		}
		calculatedWidth -= (this.paddingLeft + this.paddingRight);
		calculatedHeight -= (this.paddingTop + this.paddingBottom);
		if (this._currentIcon != null) {
			var adjustedGap = this.gap;
			// Math.POSITIVE_INFINITY bug workaround
			if (adjustedGap == (1.0 / 0.0)) {
				adjustedGap = this.minGap;
			}
			if (this.iconPosition == LEFT || this.iconPosition == RIGHT) {
				calculatedWidth -= (this._currentIcon.width + adjustedGap);
			}
			if (this.iconPosition == TOP || this.iconPosition == BOTTOM) {
				calculatedHeight -= (this._currentIcon.height + adjustedGap);
			}
		}
		if (this._currentAccessoryView != null) {
			var adjustedGap = this.gap;
			// Math.POSITIVE_INFINITY bug workaround
			if (adjustedGap == (1.0 / 0.0)) {
				adjustedGap = this.minGap;
			}
			calculatedWidth -= (this._currentAccessoryView.width + adjustedGap);
		}
		if (this.secondaryTextField != null) {
			var adjustedGap = this.gap;
			// Math.POSITIVE_INFINITY bug workaround
			if (adjustedGap == (1.0 / 0.0)) {
				adjustedGap = this.minGap;
			}
			calculatedHeight -= (this._secondaryTextMeasuredHeight + adjustedGap);
		}
		if (calculatedWidth < 0.0) {
			calculatedWidth = 0.0;
		}
		if (calculatedHeight < 0.0) {
			calculatedHeight = 0.0;
		}
		if (calculatedWidth > this._textMeasuredWidth) {
			calculatedWidth = this._textMeasuredWidth;
		}
		if (calculatedHeight > this._textMeasuredHeight) {
			calculatedHeight = this._textMeasuredHeight;
		}
		this.textField.width = calculatedWidth;
		var wordWrap = this.wordWrap;
		if (wordWrap && !this._wrappedOnMeasure && calculatedWidth >= this._textMeasuredWidth) {
			// sometimes, using the width measured with wrapping disabled
			// will still cause the final rendered result to wrap, but we
			// can skip wrapping forcefully as a workaround
			// this happens with the flash target sometimes
			wordWrap = false;
		}
		if (this.textField.wordWrap != wordWrap) {
			this.textField.wordWrap = wordWrap;
		}

		this.textField.height = calculatedHeight;
	}

	override private function calculateExplicitWidthForTextMeasurement():Null<Float> {
		var textFieldExplicitWidth = super.calculateExplicitWidthForTextMeasurement();
		if (textFieldExplicitWidth == null) {
			return textFieldExplicitWidth;
		}
		var adjustedGap = this.gap;
		// Math.POSITIVE_INFINITY bug workaround
		if (adjustedGap == (1.0 / 0.0)) {
			adjustedGap = this.minGap;
		}
		if (this._currentAccessoryView != null) {
			var oldIgnoreAccessoryResizes = this._ignoreAccessoryResizes;
			this._ignoreAccessoryResizes = true;
			if ((this._currentAccessoryView is IValidating)) {
				cast(this._currentAccessoryView, IValidating).validateNow();
			}
			this._ignoreAccessoryResizes = oldIgnoreAccessoryResizes;
			textFieldExplicitWidth -= (this._currentAccessoryView.width + adjustedGap);
		}
		if (textFieldExplicitWidth < 0.0) {
			textFieldExplicitWidth = 0.0;
		}
		return textFieldExplicitWidth;
	}

	override private function measureContentWidth():Float {
		var adjustedGap = this.gap;
		// Math.POSITIVE_INFINITY bug workaround
		if (adjustedGap == (1.0 / 0.0)) {
			adjustedGap = this.minGap;
		}
		var hasText = this.showText && this._text != null;
		var contentWidth = hasText ? this._textMeasuredWidth : 0.0;
		var hasSecondaryText = this.showSecondaryText && this._secondaryText != null;
		if (hasSecondaryText) {
			contentWidth = Math.max(contentWidth, this._secondaryTextMeasuredWidth);
		}
		if (this._currentAccessoryView != null) {
			var oldIgnoreAccessoryResizes = this._ignoreAccessoryResizes;
			this._ignoreAccessoryResizes = true;
			if ((this._currentAccessoryView is IValidating)) {
				cast(this._currentAccessoryView, IValidating).validateNow();
			}
			this._ignoreAccessoryResizes = oldIgnoreAccessoryResizes;
			if (hasText || hasSecondaryText) {
				contentWidth += adjustedGap;
			}
			contentWidth += this._currentAccessoryView.width;
		}
		if (this._currentIcon != null) {
			if (this.iconPosition == LEFT || this.iconPosition == RIGHT) {
				if (hasText || hasSecondaryText || this._currentAccessoryView != null) {
					contentWidth += adjustedGap;
				}
				contentWidth += this._currentIcon.width;
			} else if (this.iconPosition == TOP || this.iconPosition == BOTTOM) {
				contentWidth = Math.max(contentWidth, this._currentIcon.width);
			}
		}
		return contentWidth;
	}

	override private function measureContentHeight():Float {
		var adjustedGap = this.gap;
		// Math.POSITIVE_INFINITY bug workaround
		if (adjustedGap == (1.0 / 0.0)) {
			adjustedGap = this.minGap;
		}

		var hasText = this.showText && this._text != null;
		var contentHeight = hasText ? this._textMeasuredHeight : 0.0;
		var hasSecondaryText = this.showSecondaryText && this._secondaryText != null;
		if (hasSecondaryText) {
			contentHeight += this._secondaryTextMeasuredHeight;
			if (hasText) {
				contentHeight += adjustedGap;
			}
		}
		if (this._currentAccessoryView != null) {
			var oldIgnoreAccessoryResizes = this._ignoreAccessoryResizes;
			this._ignoreAccessoryResizes = true;
			if ((this._currentAccessoryView is IValidating)) {
				cast(this._currentAccessoryView, IValidating).validateNow();
			}
			this._ignoreAccessoryResizes = oldIgnoreAccessoryResizes;
			contentHeight = Math.max(contentHeight, this._currentAccessoryView.height);
		}
		if (this._currentIcon != null) {
			if (this.iconPosition == TOP || this.iconPosition == BOTTOM) {
				if (hasText || hasSecondaryText) {
					contentHeight += adjustedGap;
				}
				contentHeight += this._currentIcon.height;
			} else if (this.iconPosition == LEFT || this.iconPosition == RIGHT) {
				contentHeight = Math.max(contentHeight, this._currentIcon.height);
			}
		}
		return contentHeight;
	}

	override private function measureContentMinWidth():Float {
		var adjustedGap = this.gap;
		// Math.POSITIVE_INFINITY bug workaround
		if (adjustedGap == (1.0 / 0.0)) {
			adjustedGap = this.minGap;
		}
		var hasText = this.showText && this._text != null;
		var contentMinWidth = hasText ? this._textMeasuredWidth : 0.0;
		var hasSecondaryText = this.showSecondaryText && this._secondaryText != null;
		if (hasSecondaryText) {
			contentMinWidth = Math.max(contentMinWidth, this._secondaryTextMeasuredWidth);
		}
		if (this._currentAccessoryView != null) {
			var oldIgnoreAccessoryResizes = this._ignoreAccessoryResizes;
			this._ignoreAccessoryResizes = true;
			if ((this._currentAccessoryView is IValidating)) {
				cast(this._currentAccessoryView, IValidating).validateNow();
			}
			this._ignoreAccessoryResizes = oldIgnoreAccessoryResizes;
			if (hasText || hasSecondaryText) {
				contentMinWidth += adjustedGap;
			}
			contentMinWidth += this._currentAccessoryView.width;
		}
		if (this._currentIcon != null) {
			if (this.iconPosition == LEFT || this.iconPosition == RIGHT) {
				if (hasText || hasSecondaryText || this._currentAccessoryView != null) {
					contentMinWidth += adjustedGap;
				}
				contentMinWidth += this._currentIcon.width;
			} else if (this.iconPosition == TOP || this.iconPosition == BOTTOM) {
				contentMinWidth = Math.max(contentMinWidth, this._currentIcon.width);
			}
		}
		return contentMinWidth;
	}

	override private function measureContentMinHeight():Float {
		var adjustedGap = this.gap;
		// Math.POSITIVE_INFINITY bug workaround
		if (adjustedGap == (1.0 / 0.0)) {
			adjustedGap = this.minGap;
		}
		var hasText = this.showText && this._text != null;
		var contentMinHeight = hasText ? this._textMeasuredHeight : 0.0;
		var hasSecondaryText = this.showSecondaryText && this._secondaryText != null;
		if (hasSecondaryText) {
			contentMinHeight += this._secondaryTextMeasuredHeight;
			if (hasText) {
				contentMinHeight += adjustedGap;
			}
		}
		if (this._currentAccessoryView != null) {
			var oldIgnoreAccessoryResizes = this._ignoreAccessoryResizes;
			this._ignoreAccessoryResizes = true;
			if ((this._currentAccessoryView is IValidating)) {
				cast(this._currentAccessoryView, IValidating).validateNow();
			}
			this._ignoreAccessoryResizes = oldIgnoreAccessoryResizes;
			contentMinHeight = Math.max(contentMinHeight, this._currentAccessoryView.height);
		}
		if (this._currentIcon != null) {
			if (this.iconPosition == TOP || this.iconPosition == BOTTOM) {
				if (hasText || hasSecondaryText) {
					contentMinHeight += adjustedGap;
				}
				contentMinHeight += this._currentIcon.height;
			} else if (this.iconPosition == LEFT || this.iconPosition == RIGHT) {
				contentMinHeight = Math.max(contentMinHeight, this._currentIcon.height);
			}
		}
		return contentMinHeight;
	}

	override private function getCurrentBackgroundSkin():DisplayObject {
		var result = this._stateToSkin.get(this._currentState);
		if (result != null) {
			return result;
		}
		if (this.alternateBackgroundSkin != null && (this._layoutIndex % 2) == 1) {
			return this.alternateBackgroundSkin;
		}
		return this.backgroundSkin;
	}

	override private function layoutChildren():Void {
		this.refreshTextFieldDimensions(false);

		var adjustedGap = this.gap;
		// Math.POSITIVE_INFINITY bug workaround
		if (adjustedGap == (1.0 / 0.0)) {
			adjustedGap = this.minGap;
		}

		var hasText = this.showText && this._text != null;
		var hasSecondaryText = this.showSecondaryText && this._secondaryText != null;
		var availableContentWidth = this.actualWidth - this.paddingLeft - this.paddingRight;
		var availableContentHeight = this.actualHeight - this.paddingTop - this.paddingBottom;
		var totalContentWidth = hasText ? this._textMeasuredWidth : 0.0;
		var totalContentHeight = hasText ? this._textMeasuredHeight : 0.0;
		if (hasSecondaryText && this.secondaryTextField != null) {
			totalContentWidth = Math.max(totalContentWidth, this._secondaryTextMeasuredWidth);
			totalContentHeight += (this._secondaryTextMeasuredHeight + adjustedGap);
		}
		if (this._currentIcon != null) {
			if (this.iconPosition == LEFT || this.iconPosition == RIGHT) {
				totalContentWidth += adjustedGap + this._currentIcon.width;
			}
			if (this.iconPosition == TOP || this.iconPosition == BOTTOM) {
				totalContentHeight += adjustedGap + this._currentIcon.height;
			}
		}

		if (this._currentAccessoryView != null) {
			// the accessory view is always positioned on the far right
			this._currentAccessoryView.x = this.actualWidth - this.paddingRight - this._currentAccessoryView.width;
			switch (this.verticalAlign) {
				case TOP:
					this._currentAccessoryView.y = this.paddingTop;
				case BOTTOM:
					this._currentAccessoryView.y = Math.max(this.paddingTop, this.paddingTop + availableContentHeight - this._currentAccessoryView.height);
				case MIDDLE:
					this._currentAccessoryView.y = Math.max(this.paddingTop,
						this.paddingTop + (availableContentHeight - this._currentAccessoryView.height) / 2.0);
				default:
					throw new ArgumentError("Unknown vertical align: " + this.verticalAlign);
			}
			availableContentWidth -= (this._currentAccessoryView.width + adjustedGap);
		}
		if (this._currentIcon != null) {
			if (this.iconPosition == TOP || iconPosition == BOTTOM) {
				switch (this.horizontalAlign) {
					case LEFT:
						this._currentIcon.x = this.paddingLeft;
					case RIGHT:
						this._currentIcon.x = Math.max(this.paddingLeft, this.paddingLeft + availableContentWidth - this._currentIcon.width);
					case CENTER:
						this._currentIcon.x = Math.max(this.paddingLeft, this.paddingLeft + (availableContentWidth - this._currentIcon.height) / 2.0);
					default:
						throw new ArgumentError("Unknown horizontal align: " + this.horizontalAlign);
				}
			}
			if (this.iconPosition == LEFT || iconPosition == RIGHT) {
				switch (this.verticalAlign) {
					case TOP:
						this._currentIcon.y = this.paddingTop;
					case BOTTOM:
						this._currentIcon.y = Math.max(this.paddingTop, this.paddingTop + availableContentHeight - this._currentIcon.height);
					case MIDDLE:
						this._currentIcon.y = Math.max(this.paddingTop, this.paddingTop + (availableContentHeight - this._currentIcon.height) / 2.0);
					default:
						throw new ArgumentError("Unknown vertical align: " + this.verticalAlign);
				}
			}
		}

		var currentX = this.paddingLeft;
		var currentY = this.paddingTop;
		switch (this.horizontalAlign) {
			case LEFT:
				currentX = this.paddingLeft;
			case RIGHT:
				currentX = Math.max(this.paddingLeft, this.paddingLeft + availableContentWidth - totalContentWidth);
			case CENTER:
				currentX = Math.max(this.paddingLeft, this.paddingLeft + (availableContentWidth - totalContentWidth) / 2.0);
			default:
				throw new ArgumentError("Unknown horizontal align: " + this.horizontalAlign);
		}
		switch (this.verticalAlign) {
			case TOP:
				currentY = this.paddingTop;
			case BOTTOM:
				currentY = Math.max(this.paddingTop, this.paddingTop + availableContentHeight - totalContentHeight);
			case MIDDLE:
				currentY = Math.max(this.paddingTop, this.paddingTop + (availableContentHeight - totalContentHeight) / 2.0);
			default:
				throw new ArgumentError("Unknown vertical align: " + this.verticalAlign);
		}

		if (this._currentIcon != null) {
			if (this.iconPosition == LEFT) {
				this._currentIcon.x = currentX;
				currentX += adjustedGap + this._currentIcon.width;
			}
			if (this.iconPosition == TOP) {
				this._currentIcon.y = currentY;
				currentY += adjustedGap + this._currentIcon.height;
			}
		}

		var totalTextWidth = 0.0;
		var availableTextWidth = availableContentWidth;
		if (this._currentIcon != null && (this.iconPosition == LEFT || this.iconPosition == RIGHT)) {
			availableTextWidth -= (adjustedGap + this._currentIcon.width);
		}
		if (hasText) {
			this.textField.x = currentX;
			this.textField.y = currentY;
			currentY += this._textMeasuredHeight + adjustedGap;
			totalTextWidth = Math.max(totalTextWidth, this.textField.width);
		}
		if (hasSecondaryText && this.secondaryTextField != null) {
			this.secondaryTextField.x = currentX;
			this.secondaryTextField.y = currentY;
			this.secondaryTextField.width = this._secondaryTextMeasuredWidth < availableTextWidth ? this._secondaryTextMeasuredWidth : availableTextWidth;
			currentY += this._secondaryTextMeasuredHeight + adjustedGap;
			totalTextWidth = Math.max(totalTextWidth, this.secondaryTextField.width);
		}
		if (hasText || hasSecondaryText) {
			currentX += totalTextWidth + adjustedGap;
		}

		if (this._currentIcon != null) {
			if (this.iconPosition == RIGHT) {
				this._currentIcon.x = currentX;
			}
			if (this.iconPosition == BOTTOM) {
				this._currentIcon.y = currentY;
			}
		}
	}

	private function itemRenderer_secondaryTextFormat_changeHandler(event:Event):Void {
		this.setInvalid(STYLES);
	}

	private function itemRenderer_accessoryView_resizeHandler(event:Event):Void {
		if (this._ignoreAccessoryResizes) {
			return;
		}
		this.setInvalid(STYLES);
	}
}
