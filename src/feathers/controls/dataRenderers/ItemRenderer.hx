/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.dataRenderers;

import openfl.display.InteractiveObject;
import feathers.core.IFocusObject;
import feathers.core.IPointerDelegate;
import feathers.core.IValidating;
import feathers.layout.ILayoutIndexObject;
import feathers.text.TextFormat;
import feathers.themes.steel.components.SteelItemRendererStyles;
import openfl.display.DisplayObject;
import openfl.events.Event;
import openfl.geom.Point;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;

/**
	A generic renderer for UI components that display data collections.

	@see [Tutorial: How to use the ItemRenderer component](https://feathersui.com/learn/haxe-openfl/item-renderer/)

	@since 1.0.0
**/
@:styleContext
class ItemRenderer extends ToggleButton implements ILayoutIndexObject implements IDataRenderer implements IPointerDelegate {
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
		var stateInvalid = this.isInvalid(STATE);
		var stylesInvalid = this.isInvalid(STYLES);

		this._updatedSecondaryTextStyles = false;

		if (dataInvalid) {
			this._pointerToState.target = (this._pointerTarget != null) ? this._pointerTarget : this;
			this.refreshSecondaryTextField();
		}

		if (stylesInvalid || stateInvalid) {
			this.refreshSecondaryTextStyles();
		}

		if (dataInvalid || stylesInvalid || stateInvalid) {
			this.refreshSecondaryText();
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

	private function refreshSecondaryText():Void {
		if (this.secondaryTextField == null) {
			return;
		}
		var hasText = this._secondaryText != null && this._secondaryText.length > 0;
		this.secondaryTextField.visible = hasText;
		if (this._secondaryText == this._previousSecondaryText && !this._updatedSecondaryTextStyles) {
			// nothing to refresh
			return;
		}
		// set autoSize before text because setting text first can trigger an
		// extra text engine reflow
		this.secondaryTextField.autoSize = TextFieldAutoSize.LEFT;
		if (hasText) {
			this.secondaryTextField.text = this._secondaryText;
		} else {
			this.secondaryTextField.text = "\u200b"; // zero-width space
		}
		this._secondaryTextMeasuredWidth = this.secondaryTextField.width;
		this._secondaryTextMeasuredHeight = this.secondaryTextField.height;
		this.secondaryTextField.autoSize = TextFieldAutoSize.NONE;
		if (!hasText) {
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

	private function customHitTest(stageX:Float, stageY:Float):Bool {
		var objects = this.getObjectsUnderPoint(new Point(stageX, stageY));
		if (objects.length > 0) {
			var lastObject = objects[objects.length - 1];
			while (lastObject != null && lastObject != this) {
				if (Std.is(lastObject, IFocusObject)) {
					var focusable = cast(lastObject, IFocusObject);
					if (focusable.focusEnabled) {
						return false;
					}
				}
				lastObject = lastObject.parent;
			}
		}
		return true;
	}

	override private function refreshTextFieldDimensions(forMeasurement:Bool):Void {
		var oldIgnoreIconResizes = this._ignoreIconResizes;
		this._ignoreIconResizes = true;
		if (Std.is(this._currentIcon, IValidating)) {
			cast(this._currentIcon, IValidating).validateNow();
		}
		this._ignoreIconResizes = oldIgnoreIconResizes;
		if (this._text == null || this._text.length == 0) {
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
			if (adjustedGap == Math.POSITIVE_INFINITY) {
				adjustedGap = this.minGap;
			}
			if (this.iconPosition == LEFT || this.iconPosition == RIGHT) {
				calculatedWidth -= (this._currentIcon.width + adjustedGap);
			}
			if (this.iconPosition == TOP || this.iconPosition == BOTTOM) {
				calculatedHeight -= (this._currentIcon.height + adjustedGap);
			}
		}
		if (this.secondaryTextField != null) {
			var adjustedGap = this.gap;
			if (adjustedGap == Math.POSITIVE_INFINITY) {
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
		this.textField.height = calculatedHeight;
	}

	override private function measureContentWidth():Float {
		var adjustedGap = this.gap;
		if (adjustedGap == Math.POSITIVE_INFINITY) {
			adjustedGap = this.minGap;
		}
		var contentWidth = this._text != null ? this._textMeasuredWidth : 0.0;
		if (this._secondaryText != null) {
			contentWidth = Math.max(contentWidth, this._secondaryTextMeasuredWidth);
		}
		if (this._currentIcon != null) {
			if (this.iconPosition == LEFT || this.iconPosition == RIGHT) {
				if (this._text != null) {
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
		if (adjustedGap == Math.POSITIVE_INFINITY) {
			adjustedGap = this.minGap;
		}

		var contentHeight = this._text != null ? this._textMeasuredHeight : 0.0;
		if (this._secondaryText != null) {
			contentHeight += this._secondaryTextMeasuredHeight;
			if (this._text != null) {
				contentHeight += adjustedGap;
			}
		}
		if (this._currentIcon != null) {
			if (this.iconPosition == TOP || this.iconPosition == BOTTOM) {
				if (this._text != null) {
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
		if (adjustedGap == Math.POSITIVE_INFINITY) {
			adjustedGap = this.minGap;
		}
		var contentMinWidth = this._text != null ? this._textMeasuredWidth : 0.0;
		if (this._secondaryText != null) {
			contentMinWidth = Math.max(contentMinWidth, this._secondaryTextMeasuredWidth);
		}
		if (this._currentIcon != null) {
			if (this.iconPosition == LEFT || this.iconPosition == RIGHT) {
				if (this._text != null) {
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
		if (adjustedGap == Math.POSITIVE_INFINITY) {
			adjustedGap = this.minGap;
		}
		var contentMinHeight = this._text != null ? this._textMeasuredHeight : 0.0;
		if (this._secondaryText != null) {
			contentMinHeight += this._secondaryTextMeasuredHeight;
			if (this._text != null) {
				contentMinHeight += adjustedGap;
			}
		}
		if (this._currentIcon != null) {
			if (this.iconPosition == TOP || this.iconPosition == BOTTOM) {
				if (this._text != null) {
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

	override private function layoutContent():Void {
		this.refreshTextFieldDimensions(false);
		var availableTextWidth = this.actualWidth - this.paddingLeft - this.paddingRight;
		var currentX = this.paddingLeft;
		if (this._currentIcon != null) {
			if (Std.is(this._currentIcon, IValidating)) {
				cast(this._currentIcon, IValidating).validateNow();
			}
			this._currentIcon.x = currentX;
			currentX += this._currentIcon.width + this.gap;
			this._currentIcon.y = this.paddingTop + (this.actualHeight - this.paddingTop - this.paddingBottom - this._currentIcon.height) / 2.0;
			availableTextWidth -= this._currentIcon.width - this.gap;
		}

		var totalTextHeight = this._textMeasuredHeight;
		if (this.secondaryTextField != null) {
			totalTextHeight += this.gap + this._secondaryTextMeasuredHeight;
		}

		var currentY = this.paddingTop + (this.actualHeight - this.paddingTop - this.paddingBottom - totalTextHeight) / 2.0;
		if (currentY < this.paddingTop) {
			currentY = this.paddingTop;
		}

		this.textField.x = currentX;
		this.textField.y = currentY;
		this.textField.width = this._textMeasuredWidth < availableTextWidth ? this._textMeasuredWidth : availableTextWidth;
		if (this.secondaryTextField != null) {
			this.secondaryTextField.x = currentX;
			this.secondaryTextField.y = this.textField.y + this._textMeasuredHeight + this.gap;
			this.secondaryTextField.width = this._secondaryTextMeasuredWidth < availableTextWidth ? this._secondaryTextMeasuredWidth : availableTextWidth;
		}
	}

	private function itemRenderer_secondaryTextFormat_changeHandler(event:Event):Void {
		this.setInvalid(STYLES);
	}
}
