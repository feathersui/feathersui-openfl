/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.dataRenderers;

import feathers.core.IFocusObject;
import feathers.core.IValidating;
import feathers.core.InvalidationFlag;
import feathers.events.TriggerEvent;
import feathers.themes.steel.components.SteelItemRendererStyles;
import openfl.geom.Point;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;

/**
	A generic renderer for UI components that display data collections.

	@since 1.0.0
**/
@:styleContext
class ItemRenderer extends ToggleButton {
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
	}

	private var secondaryTextField:TextField;

	private var _secondaryTextMeasuredWidth:Float;
	private var _secondaryTextMeasuredHeight:Float;
	private var _previousSecondaryText:String = null;
	private var _previousSecondaryTextFormat:TextFormat = null;
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
		this.setInvalid(InvalidationFlag.DATA);
		return this._secondaryText;
	}

	/**
		The font styles used to render the item renderer's secondary text.

		In the following example, the item renderer's secondary text formatting
		is customized:

		```hx
		button.secondaryTextFormat = new TextFormat("Helvetica", 20, 0xcc0000);
		```

		@see `ToggleButton.secondaryText`

		@since 1.0.0
	**/
	@:style
	public var secondaryTextFormat:TextFormat = null;

	/**
		The font styles used to render the button's text when the button is
		disabled.

		In the following example, the button's disabled text formatting is
		customized:

		```hx
		button.enabled = false;
		button.disabledTextFormat = new TextFormat("Helvetica", 20, 0xee0000);
		```

		The next example sets a disabled text format, but also provides a text
		format for the `ToggleButtonState.DISABLED(true)` state that will be
		used instead of the disabled text format:

		```hx
		button.disabledTextFormat = new TextFormat("Helvetica", 20, 0xee0000);
		button.setTextFormatForState(ToggleButtonState.DISABLED(true), new TextFormat("Helvetica", 20, 0xff0000));
		```

		Note: If the current state is `ToggleButtonState.DISABLED(true)`, and
		both the `disabledTextFormat` and `selectedTextFormat` are set, the
		`disabledTextFormat` takes precedence over the `selectedTextFormat`.

		@see `ItemRenderer.secondaryTextFormat`

		@since 1.0.0
	**/
	@:style
	public var disabledSecondaryTextFormat:TextFormat = null;

	/**
		The font styles used to render the button's text when the button is
		selected.

		In the following example, the button's selected text formatting is
		customized:

		```hx
		button.selected = true;
		button.selectedTextFormat = new TextFormat("Helvetica", 20, 0xff0000);
		```

		The next example sets a selected text format, but also provides a text
		format for the `ToggleButtonState.DOWN(true)` state that will be used
		instead of the selected text format:

		```hx
		button.selectedTextFormat = new TextFormat("Helvetica", 20, 0xff0000);
		button.setTextFormatForState(ToggleButtonState.DOWN(true), new TextFormat("Helvetica", 20, 0xcc0000));
		```

		Note: If the current state is `ToggleButtonState.DISABLED(true)`, and
		both the `disabledTextFormat` and `selectedTextFormat` are set, the
		`disabledTextFormat` takes precedence over the `selectedTextFormat`.

		@see `ItemRenderer.secondaryTextFormat`
		@see `BasicToggleButton.selected`

		@since 1.0.0
	**/
	@:style
	public var selectedSecondaryTextFormat:TextFormat = null;

	private var _stateToSecondaryTextFormat:Map<ToggleButtonState, TextFormat> = new Map();

	/**
		Gets the text format to be used by the button when its `currentState`
		property matches the specified state value.

		If a text format is not defined for a specific state, returns `null`.

		@see `ToggleButton.setTextFormatForState()`
		@see `ToggleButton.textFormat`
		@see `ToggleButton.currentState`
		@see `feathers.controls.ToggleButtonState`

		@since 1.0.0
	**/
	public function getSecondaryTextFormatForState(state:ToggleButtonState):TextFormat {
		return this._stateToSecondaryTextFormat.get(state);
	}

	/**
		Set the text format to be used by the button when its `currentState`
		property matches the specified state value.

		If a text format is not defined for a specific state, the value of the
		`textFormat` property will be used instead.

		@see `ItemRenderer.getSecondaryTextFormatForState()`
		@see `ItemRenderer.secondaryextFormat`
		@see `ItemRenderer.currentState`
		@see `feathers.controls.ToggleButtonState`

		@since 1.0.0
	**/
	@style
	public function setSecondaryTextFormatForState(state:ToggleButtonState, textFormat:TextFormat):Void {
		if (!this.setStyle("setSecondaryTextFormatForState", state)) {
			return;
		}
		if (textFormat == null) {
			this._stateToSecondaryTextFormat.remove(state);
		} else {
			this._stateToSecondaryTextFormat.set(state, textFormat);
		}
		this.setInvalid(InvalidationFlag.STYLES);
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
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);
		var stateInvalid = this.isInvalid(InvalidationFlag.STATE);
		var stylesInvalid = this.isInvalid(InvalidationFlag.STYLES);

		this._updatedSecondaryTextStyles = false;

		if (dataInvalid) {
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
		if (textFormat == this._previousSecondaryTextFormat) {
			// nothing to refresh
			return;
		}
		if (textFormat != null) {
			this.secondaryTextField.defaultTextFormat = textFormat;
			this._updatedSecondaryTextStyles = true;
			this._previousSecondaryTextFormat = textFormat;
		}
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
			this.secondaryTextField.text = "\u8203"; // zero-width space
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

	override private function basicToggleButton_triggerHandler(event:TriggerEvent):Void {
		if (!this._enabled) {
			event.stopImmediatePropagation();
			return;
		}
		if (!this.toggleable || this._selected) {
			return;
		}
		this.selected = !this._selected;
	}
}
