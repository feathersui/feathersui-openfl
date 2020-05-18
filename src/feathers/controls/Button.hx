/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.core.IFocusObject;
import feathers.core.IMeasureObject;
import feathers.core.IStateObserver;
import feathers.core.ITextControl;
import feathers.core.IUIControl;
import feathers.core.IValidating;
import feathers.core.InvalidationFlag;
import feathers.layout.HorizontalAlign;
import feathers.layout.Measurements;
import feathers.layout.RelativePosition;
import feathers.layout.VerticalAlign;
import feathers.themes.steel.components.SteelButtonStyles;
import feathers.utils.MeasurementsUtil;
import openfl.display.DisplayObject;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
import openfl.ui.Keyboard;

/**
	A push button control that may be triggered when pressed and released.

	The following example creates a button, gives it a label and listens
	for when the button is triggered:

	```hx
	var button = new Button();
	button.text = "Click Me";
	button.addEventListener(TriggerEvent.TRIGGER, (event) -> {
		trace("button triggered!");
	});
	this.addChild(button);
	```

	@see [Tutorial: How to use the Button component](https://feathersui.com/learn/haxe-openfl/button/)

	@since 1.0.0
**/
@:styleContext
class Button extends BasicButton implements ITextControl implements IFocusObject {
	/**
		Creates a new `Button` object.

		@since 1.0.0
	**/
	public function new() {
		initializeButtonTheme();

		super();

		this.tabEnabled = true;
		this.tabChildren = false;
		this.focusRect = false;

		this.addEventListener(KeyboardEvent.KEY_DOWN, button_keyDownHandler);
	}

	private var textField:TextField;

	private var _previousText:String = null;
	private var _previousTextFormat:TextFormat = null;
	private var _updatedTextStyles = false;

	/**
		The text displayed by the button.

		The following example sets the button's text:

		```hx
		button.text = "Click Me";
		```

		@default null

		@see `Button.textFormat`

		@since 1.0.0
	**/
	@:isVar
	public var text(get, set):String;

	private function get_text():String {
		return this.text;
	}

	private function set_text(value:String):String {
		if (this.text == value) {
			return this.text;
		}
		this.text = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this.text;
	}

	/**
		The font styles used to render the button's text.

		In the following example, the button's text formatting is customized:

		```hx
		button.textFormat = new TextFormat("Helvetica", 20, 0xcc0000);
		```

		@see `Button.text`
		@see `Button.getTextFormatForState()`
		@see `Button.setTextFormatForState()`
		@see `Button.embedFonts`

		@since 1.0.0
	**/
	@:style
	public var textFormat:TextFormat = null;

	/**
		Determines if an embedded font is used or not.

		In the following example, the button uses embedded fonts:

		```hx
		button.embedFonts = true;
		```

		@see `Button.textFormat`

		@since 1.0.0
	**/
	@:style
	public var embedFonts:Bool = false;

	private var _stateToIcon:Map<ButtonState, DisplayObject> = new Map();
	private var _iconMeasurements:Measurements = null;
	private var _currentIcon:DisplayObject = null;
	private var _ignoreIconResizes:Bool = false;

	/**
		The display object to use as the button's icon.

		To render a different icon depending on the button's current state,
		pass additional icons to `setIconForState()`.

		The following example gives the button an icon:

		```hx
		button.icon = new Bitmap(bitmapData);
		```

		To change the position of the icon relative to the button's text, see
		`iconPosition` and `gap`.

		```hx
		button.icon = new Bitmap(bitmapData);
		button.iconPosition = RIGHT;
		button.gap = 20.0;
		```

		@see `Button.getIconForState()`
		@see `Button.setIconForState()`
		@see `Button.iconPosition`
		@see `Button.gap`

		@since 1.0.0
	**/
	@:style
	public var icon:DisplayObject = null;

	/**
		The minimum space, in pixels, between the button's top edge and the
		button's content.

		In the following example, the button's top padding is set to 20 pixels:

		```hx
		button.paddingTop = 20.0;
		```

		@since 1.0.0
	**/
	@:style
	public var paddingTop:Float = 0.0;

	/**
		The minimum space, in pixels, between the button's right edge and the
		button's content.

		In the following example, the button's right padding is set to 20
		pixels:

		```hx
		button.paddingRight = 20.0;
		```

		@since 1.0.0
	**/
	@:style
	public var paddingRight:Float = 0.0;

	/**
		The minimum space, in pixels, between the button's bottom edge and the
		button's content.

		In the following example, the button's bottom padding is set to 20
		pixels:

		```hx
		button.paddingBottom = 20.0;
		```

		@since 1.0.0
	**/
	@:style
	public var paddingBottom:Float = 0.0;

	/**
		The minimum space, in pixels, between the button's left edge and the
		button's content.

		In the following example, the button's left padding is set to 20
		pixels:

		```hx
		button.paddingLeft = 20.0;
		```

		@since 1.0.0
	**/
	@:style
	public var paddingLeft:Float = 0.0;

	/**
		How the content is positioned horizontally (along the x-axis) within the
		button.

		The following example aligns the button's content to the left:

		```hx
		button.verticalAlign = LEFT;
		```

		**Note:** The `HorizontalAlign.JUSTIFY` constant is not supported by this
		component.

		@see `feathers.layout.HorizontalAlign.LEFT`
		@see `feathers.layout.HorizontalAlign.CENTER`
		@see `feathers.layout.HorizontalAlign.RIGHT`
	**/
	@:style
	public var horizontalAlign:HorizontalAlign = CENTER;

	/**
		How the content is positioned vertically (along the y-axis) within the
		button.

		The following example aligns the button's content to the top:

		```hx
		button.verticalAlign = TOP;
		```

		**Note:** The `VerticalAlign.JUSTIFY` constant is not supported by this
		component.

		@see `feathers.layout.VerticalAlign.TOP`
		@see `feathers.layout.VerticalAlign.MIDDLE`
		@see `feathers.layout.VerticalAlign.BOTTOM`
	**/
	@:style
	public var verticalAlign:VerticalAlign = MIDDLE;

	/**
		The location of the button's icon, relative to its text.

		The following example positions the icon to the right of the text:

		```hx
		button.text = "Click Me";
		button.icon = new Bitmap(texture);
		button.iconPosition = RIGHT;
		```

		@see `Button.icon`

		@since 1.0.0
	**/
	@:style
	public var iconPosition:RelativePosition = LEFT;

	/**
		The space, measured in pixels, between the button's icon and its text.
		Applies to either horizontal or vertical spacing, depending on the value
		of `iconPosition`.

		If the `gap` is set to `Math.POSITIVE_INFINITY`, the icon and the text
		will be positioned as far apart as possible. In other words, they will
		be positioned at the edges of the button (adjusted for padding).

		The following example creates a gap of 20 pixels between the icon and
		the text:

		```hx
		button.text = "Click Me";
		button.icon = new Bitmap(bitmapData);
		button.gap = 20.0;
		```

		@see `Button.minGap`

		@since 1.0.0
	**/
	@:style
	public var gap:Float = 0.0;

	/**
		If the value of the `gap` property is `Math.POSITIVE_INFINITY`, meaning
		that the gap will fill as much space as possible and position the icon
		and text on the edges of the button, the final calculated value of the
		gap will not be smaller than the value of the `minGap` property.

		The following example ensures that the gap is never smaller than 20
		pixels:

		```hx
		button.gap = Math.POSITIVE_INFINITY;
		button.minGap = 20.0;
		```

		@see `Button.gap`

		@since 1.0.0
	**/
	@:style
	public var minGap:Float = 0.0;

	private var _textMeasuredWidth:Float;
	private var _textMeasuredHeight:Float;
	private var _stateToTextFormat:Map<ButtonState, TextFormat> = new Map();

	/**
		Gets the text format to be used by the button when its `currentState`
		property matches the specified state value.

		If a text format is not defined for a specific state, returns `null`.

		@see `Button.setTextFormatForState()`
		@see `Button.textFormat`
		@see `Button.currentState`
		@see `feathers.controls.ButtonState`

		@since 1.0.0
	**/
	public function getTextFormatForState(state:ButtonState):TextFormat {
		return this._stateToTextFormat.get(state);
	}

	/**
		Set the text format to be used by the button when its `currentState`
		property matches the specified state value.

		If a text format is not defined for a specific state, the value of the
		`textFormat` property will be used instead.

		@see `Button.getTextFormatForState()`
		@see `Button.textFormat`
		@see `Button.currentState`
		@see `feathers.controls.ButtonState`

		@since 1.0.0
	**/
	@style
	public function setTextFormatForState(state:ButtonState, textFormat:TextFormat):Void {
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
		Gets the icon to be used by the button when its `currentState` property
		matches the specified state value.

		If an icon is not defined for a specific state, returns `null`.

		@see `Button.setIconForState()`
		@see `Button.icon`
		@see `Button.currentState`
		@see `feathers.controls.ButtonState`

		@since 1.0.0
	**/
	public function getIconForState(state:ButtonState):DisplayObject {
		return this._stateToIcon.get(state);
	}

	/**
		Set the icon to be used by the button when its `currentState` property
		matches the specified state value.

		If an icon is not defined for a specific state, the value of the
		`textFormat` property will be used instead.

		@see `Button.getIconForState()`
		@see `Button.icon`
		@see `Button.currentState`
		@see `feathers.controls.ButtonState`

		@since 1.0.0
	**/
	@style
	public function setIconForState(state:ButtonState, icon:DisplayObject):Void {
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

	private function initializeButtonTheme():Void {
		SteelButtonStyles.initialize();
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
		var stateInvalid = this.isInvalid(InvalidationFlag.STATE);
		var stylesInvalid = this.isInvalid(InvalidationFlag.STYLES);

		this._updatedTextStyles = false;

		if (stylesInvalid || stateInvalid) {
			this.refreshIcon();
		}

		if (stylesInvalid || stateInvalid) {
			this.refreshTextStyles();
		}

		if (dataInvalid || stylesInvalid || stateInvalid) {
			this.refreshText();
		}

		super.update();

		this.layoutContent();
	}

	override private function measure():Bool {
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
			MeasurementsUtil.resetFluidlyWithParent(this._backgroundSkinMeasurements, this._currentBackgroundSkin, this);
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

		var adjustedGap = this.gap;
		if (adjustedGap == Math.POSITIVE_INFINITY) {
			adjustedGap = this.minGap;
		}

		var newWidth = this.explicitWidth;
		if (needsWidth) {
			if (hasText) {
				newWidth = this._textMeasuredWidth;
			} else {
				newWidth = 0.0;
			}
			if (this._currentIcon != null) {
				if (this.iconPosition == LEFT || this.iconPosition == RIGHT) {
					if (hasText) {
						newWidth += adjustedGap;
					}
					newWidth += this._currentIcon.width;
				} else if (this.iconPosition == TOP || this.iconPosition == BOTTOM) {
					newWidth = Math.max(newWidth, this._currentIcon.width);
				}
			}
			newWidth += this.paddingLeft + this.paddingRight;
			if (this._currentBackgroundSkin != null) {
				newWidth = Math.max(this._currentBackgroundSkin.width, newWidth);
			}
		}

		var newHeight = this.explicitHeight;
		if (needsHeight) {
			if (hasText) {
				newHeight = this._textMeasuredHeight;
			} else {
				newHeight = 0.0;
			}
			if (this._currentIcon != null) {
				if (this.iconPosition == TOP || this.iconPosition == BOTTOM) {
					if (hasText) {
						newHeight += adjustedGap;
					}
					newHeight += this._currentIcon.height;
				} else if (this.iconPosition == LEFT || this.iconPosition == RIGHT) {
					newHeight = Math.max(newHeight, this._currentIcon.height);
				}
			}
			newHeight += this.paddingTop + this.paddingBottom;
			if (this._currentBackgroundSkin != null) {
				newHeight = Math.max(this._currentBackgroundSkin.height, newHeight);
			}
		}

		var newMinWidth = this.explicitMinWidth;
		if (needsMinWidth) {
			if (hasText) {
				newMinWidth = this._textMeasuredWidth;
			} else {
				newMinWidth = 0.0;
			}
			if (this._currentIcon != null) {
				if (this.iconPosition == LEFT || this.iconPosition == RIGHT) {
					if (hasText) {
						newMinWidth += adjustedGap;
					}
					newMinWidth += this._currentIcon.width;
				} else if (this.iconPosition == TOP || this.iconPosition == BOTTOM) {
					newMinWidth = Math.max(newMinWidth, this._currentIcon.width);
				}
			}
			newMinWidth += this.paddingLeft + this.paddingRight;
			if (measureSkin != null) {
				newMinWidth = Math.max(measureSkin.minWidth, newMinWidth);
			} else if (this._backgroundSkinMeasurements != null) {
				newMinWidth = Math.max(this._backgroundSkinMeasurements.minWidth, newMinWidth);
			}
		}

		var newMinHeight = this.explicitMinHeight;
		if (needsMinHeight) {
			if (hasText) {
				newMinHeight = this._textMeasuredHeight;
			} else {
				newMinHeight = 0.0;
			}
			if (this._currentIcon != null) {
				if (this.iconPosition == TOP || this.iconPosition == BOTTOM) {
					if (hasText) {
						newMinHeight += adjustedGap;
					}
					newMinHeight += this._currentIcon.height;
				} else if (this.iconPosition == LEFT || this.iconPosition == RIGHT) {
					newMinHeight = Math.max(newMinHeight, this._currentIcon.height);
				}
			}
			newMinHeight += this.paddingTop + this.paddingBottom;
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
		if (this.textField.embedFonts != this.embedFonts) {
			this.textField.embedFonts = this.embedFonts;
			this._updatedTextStyles = true;
		}
		var textFormat = this.getCurrentTextFormat();
		if (textFormat == this._previousTextFormat) {
			// nothing to refresh
			return;
		}
		if (textFormat != null) {
			this.textField.defaultTextFormat = textFormat;
			this._updatedTextStyles = true;
			this._previousTextFormat = textFormat;
		}
	}

	private function refreshText():Void {
		var hasText = this.text != null && this.text.length > 0;
		this.textField.visible = hasText;
		if (this.text == this._previousText && !this._updatedTextStyles) {
			// nothing to refresh
			return;
		}
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
			this.textField.text = "";
		}
		this._previousText = this.text;
	}

	private function getCurrentTextFormat():TextFormat {
		var result = this._stateToTextFormat.get(this.currentState);
		if (result != null) {
			return result;
		}
		return this.textFormat;
	}

	private function layoutContent():Void {
		this.refreshTextFieldDimensions(false);

		var hasText = this.text != null && this.text.length > 0;
		var iconIsInLayout = this._currentIcon != null && this.iconPosition != MANUAL;
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

	private function positionSingleChild(displayObject:DisplayObject):Void {
		if (this.horizontalAlign == LEFT) {
			displayObject.x = this.paddingLeft;
		} else if (this.horizontalAlign == RIGHT) {
			displayObject.x = this.actualWidth - this.paddingRight - displayObject.width;
		} else // center
		{
			displayObject.x = this.paddingLeft + (this.actualWidth - this.paddingLeft - this.paddingRight - displayObject.width) / 2.0;
		}
		if (this.verticalAlign == TOP) {
			displayObject.y = this.paddingTop;
		} else if (this.verticalAlign == BOTTOM) {
			displayObject.y = this.actualHeight - this.paddingBottom - displayObject.height;
		} else // middle
		{
			displayObject.y = this.paddingTop + (this.actualHeight - this.paddingTop - this.paddingBottom - displayObject.height) / 2.0;
		}
	}

	private function positionTextAndIcon():Void {
		if (this.iconPosition == TOP) {
			if (this.gap == Math.POSITIVE_INFINITY) {
				this._currentIcon.y = this.paddingTop;
				this.textField.y = this.actualHeight - this.paddingBottom - this.textField.height;
			} else {
				if (this.verticalAlign == TOP) {
					this.textField.y += this._currentIcon.height + this.gap;
				} else if (this.verticalAlign == MIDDLE) {
					this.textField.y += (this._currentIcon.height + this.gap) / 2.0;
				}
				this._currentIcon.y = this.textField.y - this._currentIcon.height - this.gap;
			}
		} else if (this.iconPosition == RIGHT) {
			if (this.gap == Math.POSITIVE_INFINITY) {
				this.textField.x = this.paddingLeft;
				this._currentIcon.x = this.actualWidth - this.paddingRight - this._currentIcon.width;
			} else {
				if (this.horizontalAlign == RIGHT) {
					this.textField.x -= this._currentIcon.width + this.gap;
				} else if (this.horizontalAlign == CENTER) {
					this.textField.x -= (this._currentIcon.width + this.gap) / 2.0;
				}
				this._currentIcon.x = this.textField.x + this.textField.width + this.gap;
			}
		} else if (this.iconPosition == BOTTOM) {
			if (this.gap == Math.POSITIVE_INFINITY) {
				this.textField.y = this.paddingTop;
				this._currentIcon.y = this.actualHeight - this.paddingBottom - this._currentIcon.height;
			} else {
				if (this.verticalAlign == BOTTOM) {
					this.textField.y -= this._currentIcon.height + this.gap;
				} else if (this.verticalAlign == MIDDLE) {
					this.textField.y -= (this._currentIcon.height + this.gap) / 2.0;
				}
				this._currentIcon.y = this.textField.y + this.textField.height + this.gap;
			}
		} else if (this.iconPosition == LEFT) {
			if (this.gap == Math.POSITIVE_INFINITY) {
				this._currentIcon.x = this.paddingLeft;
				this.textField.x = this.actualWidth - this.paddingRight - this.textField.width;
			} else {
				if (this.horizontalAlign == LEFT) {
					this.textField.x += this.gap + this._currentIcon.width;
				} else if (this.horizontalAlign == CENTER) {
					this.textField.x += (this.gap + this._currentIcon.width) / 2.0;
				}
				this._currentIcon.x = this.textField.x - this.gap - this._currentIcon.width;
			}
		}

		if (this.iconPosition == LEFT || this.iconPosition == RIGHT) {
			if (this.verticalAlign == TOP) {
				this._currentIcon.y = this.paddingTop;
			} else if (this.verticalAlign == BOTTOM) {
				this._currentIcon.y = this.actualHeight - this.paddingBottom - this._currentIcon.height;
			} else {
				this._currentIcon.y = this.paddingTop + (this.actualHeight - this.paddingTop - this.paddingBottom - this._currentIcon.height) / 2.0;
			}
		} else // top or bottom
		{
			if (this.horizontalAlign == LEFT) {
				this._currentIcon.x = this.paddingLeft;
			} else if (this.horizontalAlign == RIGHT) {
				this._currentIcon.x = this.actualWidth - this.paddingRight - this._currentIcon.width;
			} else {
				this._currentIcon.x = this.paddingLeft + (this.actualWidth - this.paddingLeft - this.paddingRight - this._currentIcon.width) / 2.0;
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
		return this.icon;
	}

	private function removeCurrentIcon(icon:DisplayObject):Void {
		if (icon == null) {
			return;
		}
		if (Std.is(icon, IStateObserver)) {
			cast(icon, IStateObserver).stateContext = null;
		}
		this._iconMeasurements.restore(icon);
		if (icon.parent == this) {
			// we need to restore these values so that they won't be lost the
			// next time that this icon is used for measurement
			this.removeChild(icon);
		}
	}

	private function button_keyDownHandler(event:KeyboardEvent):Void {
		if (!this.enabled || (this.buttonMode && this.focusRect == true)) {
			return;
		}
		if (event.keyCode != Keyboard.SPACE && event.keyCode != Keyboard.ENTER) {
			return;
		}
		this.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
	}
}
