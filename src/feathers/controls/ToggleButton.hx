/*
	Feathers
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.layout.RelativePosition;
import feathers.core.IUIControl;
import feathers.core.IStateObserver;
import openfl.display.DisplayObject;
import feathers.layout.Measurements;
import feathers.core.IMeasureObject;
import feathers.core.InvalidationFlag;
import feathers.core.IValidating;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalAlign;
import feathers.style.IStyleObject;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;

/**
	A button that may be selected and deselected when clicked.

	The following example creates a toggle button, and listens for when its
	selection changes:

	```hx
	var button:ToggleButton = new ToggleButton();
	button.text = "Click Me";
	button.addEventListener( Event.CHANGE, button_changeHandler );
	this.addChild( button );
	```

	@see [How to use the Feathers `ToggleButton` component](../../../help/toggle-button.html)

	@since 1.0.0
**/
class ToggleButton extends BasicToggleButton {
	public function new() {
		super();
	}

	override private function get_styleContext():Class<IStyleObject> {
		return ToggleButton;
	}

	private var textField:TextField;

	public var text(default, set):String;

	private function set_text(value:String):String {
		if (this.text == value) {
			return this.text;
		}
		this.text = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this.text;
	}

	private var _stateToIcon:Map<String, DisplayObject> = new Map();
	private var _iconMeasurements:Measurements = null;
	private var _currentIcon:DisplayObject = null;
	private var _ignoreIconResizes:Bool = false;

	/**

		@since 1.0.0
	**/
	@style
	public var icon(default, set):DisplayObject = null;

	private function set_icon(value:DisplayObject):DisplayObject {
		if (!this.setStyle("icon")) {
			return this.icon;
		}
		if (this.icon == value) {
			return this.icon;
		}
		if (this.icon != null && this.icon == this._currentIcon) {
			this.removeCurrentIcon(this.icon);
			this._currentIcon = null;
		}
		this.icon = value;
		this.setInvalid(InvalidationFlag.STYLES);
		return this.icon;
	}

	/**

		@since 1.0.0
	**/
	@style
	public var selectedIcon(default, set):DisplayObject = null;

	private function set_selectedIcon(value:DisplayObject):DisplayObject {
		if (!this.setStyle("selectedIcon")) {
			return this.selectedIcon;
		}
		if (this.selectedIcon == value) {
			return this.selectedIcon;
		}
		if (this.selectedIcon != null && this.selectedIcon == this._currentIcon) {
			this.removeCurrentIcon(this.selectedIcon);
			this._currentIcon = null;
		}
		this.selectedIcon = value;
		this.setInvalid(InvalidationFlag.STYLES);
		return this.selectedIcon;
	}

	@style
	public var textFormat(default, set):TextFormat = null;

	private function set_textFormat(value:TextFormat):TextFormat {
		if (!this.setStyle("textFormat")) {
			return this.textFormat;
		}
		if (this.textFormat == value) {
			return this.textFormat;
		}
		this.textFormat = value;
		this.setInvalid(InvalidationFlag.STYLES);
		return this.textFormat;
	}

	@style
	public var disabledTextFormat(default, set):TextFormat = null;

	private function set_disabledTextFormat(value:TextFormat):TextFormat {
		if (!this.setStyle("disabledTextFormat")) {
			return this.disabledTextFormat;
		}
		if (this.disabledTextFormat == value) {
			return this.disabledTextFormat;
		}
		this.disabledTextFormat = value;
		this.setInvalid(InvalidationFlag.STYLES);
		return this.disabledTextFormat;
	}

	@style
	public var selectedTextFormat(default, set):TextFormat = null;

	private function set_selectedTextFormat(value:TextFormat):TextFormat {
		if (!this.setStyle("selectedTextFormat")) {
			return this.selectedTextFormat;
		}
		if (this.selectedTextFormat == value) {
			return this.selectedTextFormat;
		}
		this.selectedTextFormat = value;
		this.setInvalid(InvalidationFlag.STYLES);
		return this.selectedTextFormat;
	}

	/**
		@since 1.0.0
	**/
	@style
	public var iconPosition(default, set):Null<RelativePosition> = RelativePosition.LEFT;

	private function set_iconPosition(value:Null<RelativePosition>):Null<RelativePosition> {
		if (!this.setStyle("iconPosition")) {
			return this.iconPosition;
		}
		if (this.iconPosition == value) {
			return this.iconPosition;
		}
		this.iconPosition = value;
		this.setInvalid(InvalidationFlag.STYLES);
		return this.iconPosition;
	}

	/**
		@since 1.0.0
	**/
	@style
	public var gap(default, set):Null<Float> = null;

	private function set_gap(value:Null<Float>):Null<Float> {
		if (!this.setStyle("gap")) {
			return this.gap;
		}
		if (this.gap == value) {
			return this.gap;
		}
		this.gap = value;
		this.setInvalid(InvalidationFlag.STYLES);
		return this.gap;
	}

	/**
		@since 1.0.0
	**/
	@style
	public var minGap(default, set):Null<Float> = null;

	private function set_minGap(value:Null<Float>):Null<Float> {
		if (!this.setStyle("minGap")) {
			return this.minGap;
		}
		if (this.minGap == value) {
			return this.minGap;
		}
		this.minGap = value;
		this.setInvalid(InvalidationFlag.STYLES);
		return this.minGap;
	}

	/**
		The minimum space, in pixels, between the button's top edge and the
		button's content.

		In the following example, the button's top padding is set to 20 pixels:

		```hx
		button.paddingTop = 20;</listing>
		```

		@default 0

		@since 1.0.0
	**/
	@style
	public var paddingTop(default, set):Null<Float> = null;

	private function set_paddingTop(value:Null<Float>):Null<Float> {
		if (!this.setStyle("paddingTop")) {
			return this.paddingTop;
		}
		if (this.paddingTop == value) {
			return this.paddingTop;
		}
		this.paddingTop = value;
		this.setInvalid(InvalidationFlag.STYLES);
		return this.paddingTop;
	}

	/**
		The minimum space, in pixels, between the button's right edge and the
		button's content.

		In the following example, the button's right padding is set to 20
		pixels:

		```hx
		button.paddingRight = 20;</listing>
		```

		@default 0

		@since 1.0.0
	**/
	@style
	public var paddingRight(default, set):Null<Float> = null;

	private function set_paddingRight(value:Null<Float>):Null<Float> {
		if (!this.setStyle("paddingRight")) {
			return this.paddingRight;
		}
		if (this.paddingRight == value) {
			return this.paddingRight;
		}
		this.paddingRight = value;
		this.setInvalid(InvalidationFlag.STYLES);
		return this.paddingRight;
	}

	/**
		The minimum space, in pixels, between the button's bottom edge and the
		button's content.

		In the following example, the button's bottom padding is set to 20
		pixels:

		```hx
		button.paddingBottom = 20;</listing>
		```

		@default 0

		@since 1.0.0
	**/
	@style
	public var paddingBottom(default, set):Null<Float> = null;

	private function set_paddingBottom(value:Null<Float>):Null<Float> {
		if (!this.setStyle("paddingBottom")) {
			return this.paddingBottom;
		}
		if (this.paddingBottom == value) {
			return this.paddingBottom;
		}
		this.paddingBottom = value;
		this.setInvalid(InvalidationFlag.STYLES);
		return this.paddingBottom;
	}

	/**
		The minimum space, in pixels, between the button's left edge and the
		button's content.

		In the following example, the button's left padding is set to 20
		pixels:

		```hx
		button.paddingLeft = 20;</listing>
		```

		@default 0

		@since 1.0.0
	**/
	@style
	public var paddingLeft(default, set):Null<Float> = null;

	private function set_paddingLeft(value:Null<Float>):Null<Float> {
		if (!this.setStyle("paddingLeft")) {
			return this.paddingLeft;
		}
		if (this.paddingLeft == value) {
			return this.paddingLeft;
		}
		this.paddingLeft = value;
		this.setInvalid(InvalidationFlag.STYLES);
		return this.paddingLeft;
	}

	/**
		How the content is positioned horizontally (along the x-axis) within the
		button.

		The following example aligns the button's content to the left:

		```hx
		button.verticalAlign = HorizontalAlign.LEFT;
		```

		**Note:** The `HorizontalAlign.JUSTIFY` constant is not supported by this
		component.

		@default `feathers.layout.HorizontalAlign.MIDDLE`

		@see `feathers.layout.HorizontalAlign.TOP`
		@see `feathers.layout.HorizontalAlign.MIDDLE`
		@see `feathers.layout.HorizontalAlign.BOTTOM`
	**/
	@style
	public var horizontalAlign(default, set):HorizontalAlign = null;

	private function set_horizontalAlign(value:HorizontalAlign):HorizontalAlign {
		if (!this.setStyle("horizontalAlign")) {
			return this.horizontalAlign;
		}
		if (this.horizontalAlign == value) {
			return this.horizontalAlign;
		}
		this.horizontalAlign = value;
		this.setInvalid(InvalidationFlag.STYLES);
		return this.horizontalAlign;
	}

	/**
		How the content is positioned vertically (along the y-axis) within the
		button.

		The following example aligns the button's content to the top:

		```hx
		button.verticalAlign = VerticalAlign.TOP;
		```

		**Note:** The `VerticalAlign.JUSTIFY` constant is not supported by this
		component.

		@default `feathers.layout.VerticalAlign.MIDDLE`

		@see `feathers.layout.VerticalAlign.TOP`
		@see `feathers.layout.VerticalAlign.MIDDLE`
		@see `feathers.layout.VerticalAlign.BOTTOM`
	**/
	@style
	public var verticalAlign(default, set):VerticalAlign = null;

	private function set_verticalAlign(value:VerticalAlign):VerticalAlign {
		if (!this.setStyle("verticalAlign")) {
			return this.verticalAlign;
		}
		if (this.verticalAlign == value) {
			return this.verticalAlign;
		}
		this.verticalAlign = value;
		this.setInvalid(InvalidationFlag.STYLES);
		return this.verticalAlign;
	}

	private var _textMeasuredWidth:Float;
	private var _textMeasuredHeight:Float;
	private var _stateToTextFormat:Map<String, TextFormat> = new Map();

	/**
		Gets the text format to be used by the button when its `currentState`
		property matches the specified state value.

		If a text format is not defined for a specific state, returns `null`.

		@see `Button.textFormat`
		@see `Button.setTextFormatForState()`
		@see `Button.currentState`

		@since 1.0.0
	**/
	public function getTextFormatForState(state:ToggleButtonState):TextFormat {
		return this._stateToTextFormat.get(state);
	}

	/**
		Set the text format to be used by the button when its `currentState`
		property matches the specified state value.

		If a text format is not defined for a specific state, the value of the
		`textFormat` property will be used instead.

		@see `Button.textFormat`
		@see `Button.getTextFormatForState()`
		@see `Button.currentState`

		@since 1.0.0
	**/
	@style
	public function setTextFormatForState(state:ToggleButtonState, textFormat:TextFormat):Void {
		if (!this.setStyle("setTextFormatForState", state)) {
			return;
		}
		if (textFormat == null) {
			this._stateToTextFormat.remove(state);
		} else {
			this._stateToTextFormat.set(state, textFormat);
		}
		this.setInvalid(InvalidationFlag.STYLES);
	}

	/**
		@since 1.0.0
	**/
	public function getSkinForIcon(state:ToggleButtonState):DisplayObject {
		return this._stateToIcon.get(state);
	}

	/**
		@since 1.0.0
	**/
	@style
	public function setIconForState(state:ToggleButtonState, icon:DisplayObject):Void {
		if (!this.setStyle("setIconForState", state)) {
			return;
		}
		var oldIcon = this._stateToIcon.get(state);
		if (oldIcon != null && oldIcon == this._currentIcon) {
			this.removeCurrentIcon(oldIcon);
			this._currentIcon = null;
		}
		if (icon == null) {
			this._stateToIcon.remove(state);
		} else {
			this._stateToIcon.set(state, icon);
		}
		this.setInvalid(InvalidationFlag.STYLES);
	}

	override private function initialize():Void {
		super.initialize();
		if (this.textField == null) {
			this.textField = new TextField();
			this.textField.selectable = false;
			this.addChild(this.textField);
		}
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);
		var stylesInvalid = this.isInvalid(InvalidationFlag.STYLES);
		var stateInvalid = this.isInvalid(InvalidationFlag.STATE);
		var sizeInvalid = this.isInvalid(InvalidationFlag.SIZE);

		if (stylesInvalid || stateInvalid) {
			this.refreshIcon();
			this.refreshTextStyles();
		}

		if (dataInvalid || stylesInvalid || stateInvalid) {
			this.refreshText();
		}

		super.update();

		if (stylesInvalid || stateInvalid || dataInvalid || sizeInvalid) {
			this.layoutContent();
		}
	}

	override private function autoSizeIfNeeded():Bool {
		var needsWidth = this.explicitWidth == null;
		var needsHeight = this.explicitHeight == null;
		var needsMinWidth = this.explicitMinWidth == null;
		var needsMinHeight = this.explicitMinHeight == null;
		var needsMaxWidth = this.explicitMaxWidth == null;
		var needsMaxHeight = this.explicitMaxHeight == null;
		if (!needsWidth && !needsHeight && !needsMinWidth && !needsMinHeight && !needsMaxWidth && !needsMaxHeight) {
			return false;
		}

		var hasText = this.text != null && this.text.length > 0;
		if (hasText) {
			this.refreshTextFieldDimensions(true);
		}

		if (this._currentBackgroundSkin != null) {
			this._backgroundSkinMeasurements.resetTargetFluidlyForParent(this._currentBackgroundSkin, this);
		}

		var measureSkin:IMeasureObject = null;
		if (Std.is(this._currentBackgroundSkin, IMeasureObject)) {
			measureSkin = cast(this._currentBackgroundSkin, IMeasureObject);
		}

		if (Std.is(this._currentBackgroundSkin, IValidating)) {
			cast(this._currentBackgroundSkin, IValidating).validateNow();
		}

		if (Std.is(this._currentIcon, IValidating)) {
			cast(this._currentIcon, IValidating).validateNow();
		}

		// uninitialized styles need some defaults
		var paddingTop = this.paddingTop != null ? this.paddingTop : 0.0;
		var paddingRight = this.paddingRight != null ? this.paddingRight : 0.0;
		var paddingBottom = this.paddingBottom != null ? this.paddingBottom : 0.0;
		var paddingLeft = this.paddingLeft != null ? this.paddingLeft : 0.0;
		var gap = this.gap != null ? this.gap : 0.0;
		var minGap = this.minGap != null ? this.minGap : 0.0;

		var adjustedGap = gap;
		if (adjustedGap == Math.POSITIVE_INFINITY) {
			adjustedGap = minGap;
		}

		var newWidth = this.explicitWidth;
		if (needsWidth) {
			if (hasText) {
				newWidth = this._textMeasuredWidth;
			} else {
				newWidth = 0;
			}
			if (this._currentIcon != null && (this.iconPosition == RelativePosition.LEFT || this.iconPosition == RelativePosition.RIGHT)) {
				if (hasText) {
					newWidth += adjustedGap;
				}
				newWidth += this._currentIcon.width;
			}
			newWidth += paddingLeft + paddingRight;
			if (this._currentBackgroundSkin != null) {
				newWidth = Math.max(this._currentBackgroundSkin.width, newWidth);
			}
		}

		var newHeight = this.explicitHeight;
		if (needsHeight) {
			if (hasText) {
				newHeight = this._textMeasuredHeight;
			} else {
				newHeight = 0;
			}
			if (this._currentIcon != null && (this.iconPosition == RelativePosition.TOP || this.iconPosition == RelativePosition.BOTTOM)) {
				if (hasText) {
					newHeight += adjustedGap;
				}
				newHeight += this._currentIcon.height;
			}
			newHeight += paddingTop + paddingBottom;
			if (this._currentBackgroundSkin != null) {
				newHeight = Math.max(this._currentBackgroundSkin.height, newHeight);
			}
		}

		var newMinWidth = this.explicitMinWidth;
		if (needsMinWidth) {
			newMinWidth = this._textMeasuredWidth + paddingLeft + paddingRight;
			if (measureSkin != null) {
				newMinWidth = Math.max(measureSkin.minWidth, newMinWidth);
			} else if (this._backgroundSkinMeasurements != null) {
				newMinWidth = Math.max(this._backgroundSkinMeasurements.minWidth, newMinWidth);
			}
		}

		var newMinHeight = this.explicitMinHeight;
		if (needsMinHeight) {
			newMinHeight = this._textMeasuredHeight + paddingTop + paddingBottom;
			if (measureSkin != null) {
				newMinHeight = Math.max(measureSkin.minHeight, newMinHeight);
			} else if (this._backgroundSkinMeasurements != null) {
				newMinHeight = Math.max(this._backgroundSkinMeasurements.minHeight, newMinHeight);
			}
		}
		var newMaxWidth = this.explicitMaxWidth;
		if (needsMaxWidth) {
			if (measureSkin != null) {
				newMaxWidth = measureSkin.maxWidth;
			} else if (this._backgroundSkinMeasurements != null) {
				newMaxWidth = this._backgroundSkinMeasurements.maxWidth;
			} else {
				newMaxWidth = Math.POSITIVE_INFINITY;
			}
		}

		var newMaxHeight = this.explicitMaxHeight;
		if (needsMaxHeight) {
			if (measureSkin != null) {
				newMaxHeight = measureSkin.maxHeight;
			} else if (this._backgroundSkinMeasurements != null) {
				newMaxHeight = this._backgroundSkinMeasurements.maxHeight;
			} else {
				newMaxHeight = Math.POSITIVE_INFINITY;
			}
		}

		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight, newMaxWidth, newMaxHeight);
	}

	private function refreshTextStyles():Void {
		var textFormat = this.getCurrentTextFormat();
		if (textFormat != null) {
			this.textField.defaultTextFormat = textFormat;
		}
	}

	private function refreshText():Void {
		var hasText = this.text != null && this.text.length > 0;
		if (hasText) {
			this.textField.text = this.text;
		} else {
			this.textField.text = "\u8203"; // zero-width space
		}
		this.textField.autoSize = TextFieldAutoSize.LEFT;
		this._textMeasuredWidth = this.textField.width;
		this._textMeasuredHeight = this.textField.height;
		this.textField.autoSize = TextFieldAutoSize.NONE;
		if (!hasText) {
			this.textField.text = this.text;
		}
		this.textField.visible = hasText;
	}

	private function getCurrentTextFormat():TextFormat {
		var result = this._stateToTextFormat.get(this.currentState);
		if (result != null) {
			return result;
		}
		if (!this.enabled && this.disabledTextFormat != null) {
			return this.disabledTextFormat;
		}
		if (this.selected && this.selectedTextFormat != null) {
			return this.selectedTextFormat;
		}
		return this.textFormat;
	}

	private function layoutContent():Void {
		this.refreshTextFieldDimensions(false);

		var hasText = this.text != null && this.text.length > 0;
		var iconIsInLayout = this._currentIcon != null && this.iconPosition != RelativePosition.MANUAL;
		if (hasText && iconIsInLayout) {
			this.positionSingleChild(this.textField);
			this.positionTextAndIcon();
		} else if (hasText) {
			this.positionSingleChild(this.textField);
		} else if (iconIsInLayout) {
			this.positionSingleChild(this._currentIcon);
		}
	}

	private function refreshTextFieldDimensions(forMeasurement:Bool):Void {
		var oldIgnoreIconResizes = this._ignoreIconResizes;
		this._ignoreIconResizes = true;
		if (Std.is(this._currentIcon, IValidating)) {
			cast(this._currentIcon, IValidating).validateNow();
		}
		this._ignoreIconResizes = oldIgnoreIconResizes;
		if (this.text == null || this.text.length == 0) {
			return;
		}

		// uninitialized styles need some defaults
		var paddingTop = this.paddingTop != null ? this.paddingTop : 0.0;
		var paddingRight = this.paddingRight != null ? this.paddingRight : 0.0;
		var paddingBottom = this.paddingBottom != null ? this.paddingBottom : 0.0;
		var paddingLeft = this.paddingLeft != null ? this.paddingLeft : 0.0;
		var gap = this.gap != null ? this.gap : 0.0;
		var minGap = this.minGap != null ? this.minGap : 0.0;

		var calculatedWidth = this.actualWidth;
		var calculatedHeight = this.actualHeight;
		if (forMeasurement) {
			calculatedWidth = this.explicitWidth;
			if (explicitWidth == null) {
				calculatedWidth = this.explicitMaxWidth;
			}
			calculatedHeight = this.explicitHeight;
			if (explicitHeight == null) {
				calculatedHeight = this.explicitMaxHeight;
			}
		}
		calculatedWidth -= (paddingLeft + paddingRight);
		calculatedHeight -= (paddingTop + paddingBottom);
		if (this._currentIcon != null) {
			var adjustedGap = gap;
			if (adjustedGap == Math.POSITIVE_INFINITY) {
				adjustedGap = minGap;
			}
			if (this.iconPosition == RelativePosition.LEFT || this.iconPosition == RelativePosition.RIGHT) {
				calculatedWidth -= (this._currentIcon.width + adjustedGap);
			}
			if (this.iconPosition == RelativePosition.TOP || this.iconPosition == RelativePosition.BOTTOM) {
				calculatedHeight -= (this._currentIcon.height + adjustedGap);
			}
		}
		if (calculatedWidth < 0) {
			calculatedWidth = 0;
		}
		if (calculatedHeight < 0) {
			calculatedHeight = 0;
		}
		if (calculatedWidth > this._textMeasuredWidth) {
			calculatedWidth = this._textMeasuredWidth;
		}
		if (calculatedHeight > this._textMeasuredWidth) {
			calculatedHeight = this._textMeasuredHeight;
		}
		this.textField.width = calculatedWidth;
		this.textField.height = calculatedHeight;
	}

	private function positionSingleChild(displayObject:DisplayObject):Void {
		// uninitialized styles need some defaults
		var paddingTop = this.paddingTop != null ? this.paddingTop : 0.0;
		var paddingRight = this.paddingRight != null ? this.paddingRight : 0.0;
		var paddingBottom = this.paddingBottom != null ? this.paddingBottom : 0.0;
		var paddingLeft = this.paddingLeft != null ? this.paddingLeft : 0.0;

		if (this.horizontalAlign == HorizontalAlign.LEFT) {
			displayObject.x = paddingLeft;
		} else if (this.horizontalAlign == HorizontalAlign.RIGHT) {
			displayObject.x = this.actualWidth - paddingRight - displayObject.width;
		} else // center
		{
			displayObject.x = paddingLeft + Math.round((this.actualWidth - paddingLeft - paddingRight - displayObject.width) / 2);
		}
		if (this.verticalAlign == VerticalAlign.TOP) {
			displayObject.y = paddingTop;
		} else if (this.verticalAlign == VerticalAlign.BOTTOM) {
			displayObject.y = this.actualHeight - paddingBottom - displayObject.height;
		} else // middle
		{
			displayObject.y = paddingTop + Math.round((this.actualHeight - paddingTop - paddingBottom - displayObject.height) / 2);
		}
	}

	private function positionTextAndIcon():Void {
		// uninitialized styles need some defaults
		var paddingTop = this.paddingTop != null ? this.paddingTop : 0.0;
		var paddingRight = this.paddingRight != null ? this.paddingRight : 0.0;
		var paddingBottom = this.paddingBottom != null ? this.paddingBottom : 0.0;
		var paddingLeft = this.paddingLeft != null ? this.paddingLeft : 0.0;
		var gap = this.gap != null ? this.gap : 0.0;

		if (this.iconPosition == RelativePosition.TOP) {
			if (gap == Math.POSITIVE_INFINITY) {
				this._currentIcon.y = paddingTop;
				this.textField.y = this.actualHeight - paddingBottom - this.textField.height;
			} else {
				if (this.verticalAlign == VerticalAlign.TOP) {
					this.textField.y += this._currentIcon.height + gap;
				} else if (this.verticalAlign == VerticalAlign.MIDDLE) {
					this.textField.y += Math.round((this._currentIcon.height + gap) / 2);
				}
				this._currentIcon.y = this.textField.y - this._currentIcon.height - gap;
			}
		} else if (this.iconPosition == RelativePosition.RIGHT) {
			if (gap == Math.POSITIVE_INFINITY) {
				this.textField.x = paddingLeft;
				this._currentIcon.x = this.actualWidth - paddingRight - this._currentIcon.width;
			} else {
				if (this.horizontalAlign == HorizontalAlign.RIGHT) {
					this.textField.x -= this._currentIcon.width + gap;
				} else if (this.horizontalAlign == HorizontalAlign.CENTER) {
					this.textField.x -= Math.round((this._currentIcon.width + gap) / 2);
				}
				this._currentIcon.x = this.textField.x + this.textField.width + gap;
			}
		} else if (this.iconPosition == RelativePosition.BOTTOM) {
			if (gap == Math.POSITIVE_INFINITY) {
				this.textField.y = paddingTop;
				this._currentIcon.y = this.actualHeight - paddingBottom - this._currentIcon.height;
			} else {
				if (this.verticalAlign == VerticalAlign.BOTTOM) {
					this.textField.y -= this._currentIcon.height + gap;
				} else if (this.verticalAlign == VerticalAlign.MIDDLE) {
					this.textField.y -= Math.round((this._currentIcon.height + gap) / 2);
				}
				this._currentIcon.y = this.textField.y + this.textField.height + gap;
			}
		} else if (this.iconPosition == RelativePosition.LEFT) {
			if (gap == Math.POSITIVE_INFINITY) {
				this._currentIcon.x = paddingLeft;
				this.textField.x = this.actualWidth - paddingRight - this.textField.width;
			} else {
				if (this.horizontalAlign == HorizontalAlign.LEFT) {
					this.textField.x += gap + this._currentIcon.width;
				} else if (this.horizontalAlign == HorizontalAlign.CENTER) {
					this.textField.x += Math.round((gap + this._currentIcon.width) / 2);
				}
				this._currentIcon.x = this.textField.x - gap - this._currentIcon.width;
			}
		}

		if (this.iconPosition == RelativePosition.LEFT || this.iconPosition == RelativePosition.RIGHT) {
			if (this.verticalAlign == VerticalAlign.TOP) {
				this._currentIcon.y = paddingTop;
			} else if (this.verticalAlign == VerticalAlign.BOTTOM) {
				this._currentIcon.y = this.actualHeight - paddingBottom - this._currentIcon.height;
			} else {
				this._currentIcon.y = paddingTop + Math.round((this.actualHeight - paddingTop - paddingBottom - this._currentIcon.height) / 2);
			}
		} else // top or bottom
		{
			if (this.horizontalAlign == HorizontalAlign.LEFT) {
				this._currentIcon.x = paddingLeft;
			} else if (this.horizontalAlign == HorizontalAlign.RIGHT) {
				this._currentIcon.x = this.actualWidth - paddingRight - this._currentIcon.width;
			} else {
				this._currentIcon.x = paddingLeft + Math.round((this.actualWidth - paddingLeft - paddingRight - this._currentIcon.width) / 2);
			}
		}
	}

	private function refreshIcon():Void {
		var oldIcon = this._currentIcon;
		this._currentIcon = this.getCurrentIcon();
		if (this._currentIcon == oldIcon) {
			return;
		}
		this.removeCurrentIcon(oldIcon);
		if (this._currentIcon == null) {
			this._iconMeasurements = null;
			return;
		}
		if (Std.is(this._currentIcon, IUIControl)) {
			cast(this._currentIcon, IUIControl).initializeNow();
		}
		if (this._iconMeasurements == null) {
			this._iconMeasurements = new Measurements(this._currentIcon);
		} else {
			this._iconMeasurements.save(this._currentIcon);
		}
		if (Std.is(this._currentIcon, IStateObserver)) {
			cast(this._currentIcon, IStateObserver).stateContext = this;
		}
		this.addChild(this._currentIcon);
	}

	private function getCurrentIcon():DisplayObject {
		var result = this._stateToIcon.get(this.currentState);
		if (result != null) {
			return result;
		}
		if (this.selected && this.selectedIcon != null) {
			return this.selectedIcon;
		}
		return this.icon;
	}

	private function removeCurrentIcon(icon:DisplayObject):Void {
		if (icon == null) {
			return;
		}
		if (Std.is(icon, IStateObserver)) {
			cast(icon, IStateObserver).stateContext = null;
		}
		if (icon.parent == this) {
			// we need to restore these values so that they won't be lost the
			// next time that this icon is used for measurement
			this.removeChild(icon);
		}
	}
}
