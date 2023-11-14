/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.core.IFocusObject;
import feathers.core.IHTMLTextControl;
import feathers.core.IMeasureObject;
import feathers.core.IStateObserver;
import feathers.core.ITextControl;
import feathers.core.IUIControl;
import feathers.core.IValidating;
import feathers.layout.HorizontalAlign;
import feathers.layout.Measurements;
import feathers.layout.RelativePosition;
import feathers.layout.VerticalAlign;
import feathers.skins.IProgrammaticSkin;
import feathers.text.TextFormat;
import feathers.utils.MeasurementsUtil;
import openfl.display.DisplayObject;
import openfl.events.Event;
import openfl.events.FocusEvent;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.text.TextField;
import openfl.ui.Keyboard;
#if (openfl >= "9.2.0")
import openfl.text.StyleSheet;
#elseif flash
import flash.text.StyleSheet;
#end

/**
	A button that may be selected and deselected when clicked.

	The following example creates a toggle button, programmatically selects it,
	and listens for when the selection changes:

	```haxe
	var button = new ToggleButton();
	button.text = "Click Me";
	button.selected = true;
	button.addEventListener(Event.CHANGE, (event) -> {
		var button = cast(event.currentTarget, ToggleButton);
		trace("toggle button changed: " + button.selected);
	});
	this.addChild(button);
	```

	@see [Tutorial: How to use the ToggleButton component](https://feathersui.com/learn/haxe-openfl/toggle-button/)

	@since 1.0.0
**/
@defaultXmlProperty("text")
@:styleContext
class ToggleButton extends BasicToggleButton implements ITextControl implements IHTMLTextControl implements IFocusObject {
	/**
		Creates a new `ToggleButton` object.

		@since 1.0.0
	**/
	public function new(?text:String, selected:Bool = false, ?changeListener:(Event) -> Void) {
		initializeToggleButtonTheme();

		super(changeListener);

		this.text = text;
		this.selected = selected;

		this.tabEnabled = true;
		this.tabChildren = false;

		this.addEventListener(KeyboardEvent.KEY_DOWN, toggleButton_keyDownHandler);
		this.addEventListener(FocusEvent.FOCUS_IN, toggleButton_focusInHandler);
		this.addEventListener(FocusEvent.FOCUS_OUT, toggleButton_focusOutHandler);
	}

	private var textField:TextField;

	private var _previousText:String = null;
	private var _previousHTMLText:String = null;
	private var _previousTextFormat:TextFormat = null;
	private var _previousSimpleTextFormat:openfl.text.TextFormat = null;
	private var _updatedTextStyles = false;

	private var _text:String;

	/**
		The text displayed by the button.

		The following example sets the button's text:

		```haxe
		button.text = "Click Me";
		```

		Note: If the `htmlText` property is not `null`, the `text` property will
		be ignored.

		@default null

		@see `ToggleButton.htmlText`
		@see `ToggleButton.textFormat`

		@since 1.0.0
	**/
	public var text(get, set):String;

	private function get_text():String {
		return this._text;
	}

	private function set_text(value:String):String {
		if (this._text == value) {
			return this._text;
		}
		this._text = value;
		this.setInvalid(DATA);
		return this._text;
	}

	private var _htmlText:String = null;

	/**
		Text displayed by the button that is parsed as a simple form of HTML.

		The following example sets the button's HTML text:

		```haxe
		button.htmlText = "<b>Hello</b> <i>World</i>";
		```

		@default null

		@see `ToggleButton.text`
		@see [`openfl.text.TextField.htmlText`](https://api.openfl.org/openfl/text/TextField.html#htmlText)

		@since 1.0.0
	**/
	public var htmlText(get, set):String;

	private function get_htmlText():String {
		return this._htmlText;
	}

	private function set_htmlText(value:String):String {
		if (this._htmlText == value) {
			return this._htmlText;
		}
		this._htmlText = value;
		this.setInvalid(DATA);
		return this._htmlText;
	}

	/**
		@see `feathers.controls.ITextControl.baseline`
	**/
	public var baseline(get, never):Float;

	private function get_baseline():Float {
		if (this.textField == null) {
			return 0.0;
		}
		// usually, hasText doesn't check the length, but TextField height may
		// not be accurate with an empty string
		var hasText = this._text != null && this._text.length > 0;
		var hasHTMLText = this._htmlText != null && this._htmlText.length > 0;
		if (!this.showText || (!hasText && !hasHTMLText)) {
			var textFieldY = this.textField.y;
			if (!this.showText || (this._text == null && this._htmlText == null)) {
				// this is a little strange, but measure the baseline as if
				// there were text so that instances of the same component have
				// the same baseline, even if some have text and others do not.
				if (this._currentIcon != null) {
					textFieldY = this._currentIcon.y + (this._currentIcon.height - this._textMeasuredHeight) / 2.0;
				} else if (this._currentBackgroundSkin != null) {
					textFieldY = (this._currentBackgroundSkin.height - this._textMeasuredHeight) / 2.0;
				} else {
					// we don't have anything to measure against
					return 0.0;
				}
			}
			this.textField.text = "\u200b";
			var textFieldBaseline = textFieldY + this.textField.getLineMetrics(0).ascent;
			this.textField.text = "";
			return textFieldBaseline;
		}
		return this.textField.y + this.textField.getLineMetrics(0).ascent;
	}

	private var _stateToIcon:Map<ToggleButtonState, DisplayObject> = new Map();
	private var _iconMeasurements:Measurements = null;
	private var _currentIcon:DisplayObject = null;
	private var _ignoreIconResizes:Bool = false;

	/**
		The display object to use as the button's icon.

		To render a different icon depending on the button's current state,
		pass additional icons to `setIconForState()`.

		The following example gives the button an icon:

		```haxe
		button.icon = new Bitmap(bitmapData);
		```

		To change the position of the icon relative to the button's text, see
		`iconPosition` and `gap`.

		```haxe
		button.icon = new Bitmap(bitmapData);
		button.iconPosition = RIGHT;
		button.gap = 20.0;
		```

		@see `ToggleButton.getIconForState()`
		@see `ToggleButton.setIconForState()`
		@see `ToggleButton.iconPosition`
		@see `ToggleButton.gap`

		@since 1.0.0
	**/
	@:style
	public var icon:DisplayObject = null;

	/**
		The icon to display when the button is disabled, and no higher
		priority icon was passed to `setIconForState()` for the button's current
		state.

		In the following example, the button's disabled icon is changed:

		```haxe
		button.enabled = false;
		button.disabledIcon = new Bitmap(bitmapData);
		```

		The next example sets a disabled icon, but also provides an icon for
		the `ToggleButtonState.DISABLED(true)` state that will be used instead
		of the disabled icon:

		```haxe
		button.disabledIcon = new Bitmap(bitmapData);
		button.setIconForState(ToggleButtonState.DISABLED(true), new Bitmap(bitmapData2));
		```

		Note: If the current state is `ToggleButtonState.DISABLED(true)`, and
		both the `disabledIcon` and `selectedIcon` are set, the `disabledIcon`
		takes precedence over the `selectedIcon`.

		@see `ToggleButton.icon`

		@since 1.0.0
	**/
	@:style
	public var disabledIcon:DisplayObject = null;

	/**
		The icon to display when the button is selected, and no higher
		priority icon was passed to `setIconForState()` for the button's current
		state.

		In the following example, the button's selected icon is changed:

		```haxe
		button.selected = true;
		button.selectedIcon = new Bitmap(bitmapData);
		```

		The next example sets a selected icon, but also provides an icon for
		the `ToggleButtonState.DOWN(true)` state that will be used instead of
		the selected icon:

		```haxe
		button.selectedIcon = new Bitmap(bitmapData);
		button.setIconForState(ToggleButtonState.DOWN(true), new Bitmap(bitmapData2));
		```

		Note: If the current state is `ToggleButtonState.DISABLED(true)`, and
		both the `disabledIcon` and `selectedIcon` are set, the `disabledIcon`
		takes precedence over the `selectedIcon`.

		@see `ToggleButton.icon`
		@see `BasicToggleButton.selected`

		@since 1.0.0
	**/
	@:style
	public var selectedIcon:DisplayObject = null;

	/**
		The font styles used to render the button's text.

		In the following example, the button's text formatting is customized:

		```haxe
		button.textFormat = new TextFormat("Helvetica", 20, 0xcc0000);
		```

		@see `ToggleButton.text`
		@see `ToggleButton.getTextFormatForState()`
		@see `ToggleButton.setTextFormatForState()`
		@see `ToggleButton.embedFonts`

		@since 1.0.0
	**/
	@:style
	public var textFormat:AbstractTextFormat = null;

	#if (openfl >= "9.2.0" || flash)
	/**
		A custom stylesheet to use with `htmlText`.

		If the `styleSheet` style is not `null`, the `textFormat` style will
		be ignored.

		@see `ToggleButton.htmlText`

		@since 1.0.0
	**/
	@:style
	public var styleSheet:StyleSheet = null;
	#end

	/**
		Determines if an embedded font is used or not.

		In the following example, the button uses embedded fonts:

		```haxe
		button.embedFonts = true;
		```

		@see `ToggleButton.textFormat`

		@since 1.0.0
	**/
	@:style
	public var embedFonts:Bool = false;

	/**
		Determines if the text is displayed on a single line, or if it wraps.

		In the following example, the button's text wraps at 150 pixels:

		```haxe
		button.width = 150.0;
		button.wordWrap = true;
		```

		@default false

		@since 1.0.0
	**/
	@:style
	public var wordWrap:Bool = false;

	/**
		The font styles used to render the button's text when the button is
		disabled.

		In the following example, the button's disabled text formatting is
		customized:

		```haxe
		button.enabled = false;
		button.disabledTextFormat = new TextFormat("Helvetica", 20, 0xee0000);
		```

		The next example sets a disabled text format, but also provides a text
		format for the `ToggleButtonState.DISABLED(true)` state that will be
		used instead of the disabled text format:

		```haxe
		button.disabledTextFormat = new TextFormat("Helvetica", 20, 0xee0000);
		button.setTextFormatForState(ToggleButtonState.DISABLED(true), new TextFormat("Helvetica", 20, 0xff0000));
		```

		Note: If the current state is `ToggleButtonState.DISABLED(true)`, and
		both the `disabledTextFormat` and `selectedTextFormat` are set, the
		`disabledTextFormat` takes precedence over the `selectedTextFormat`.

		@see `ToggleButton.textFormat`

		@since 1.0.0
	**/
	@:style
	public var disabledTextFormat:AbstractTextFormat = null;

	/**
		The font styles used to render the button's text when the button is
		selected.

		In the following example, the button's selected text formatting is
		customized:

		```haxe
		button.selected = true;
		button.selectedTextFormat = new TextFormat("Helvetica", 20, 0xff0000);
		```

		The next example sets a selected text format, but also provides a text
		format for the `ToggleButtonState.DOWN(true)` state that will be used
		instead of the selected text format:

		```haxe
		button.selectedTextFormat = new TextFormat("Helvetica", 20, 0xff0000);
		button.setTextFormatForState(ToggleButtonState.DOWN(true), new TextFormat("Helvetica", 20, 0xcc0000));
		```

		Note: If the current state is `ToggleButtonState.DISABLED(true)`, and
		both the `disabledTextFormat` and `selectedTextFormat` are set, the
		`disabledTextFormat` takes precedence over the `selectedTextFormat`.

		@see `ToggleButton.textFormat`
		@see `BasicToggleButton.selected`

		@since 1.0.0
	**/
	@:style
	public var selectedTextFormat:AbstractTextFormat = null;

	/**
		The location of the button's icon, relative to its text.

		The following example positions the icon to the right of the text:

		```haxe
		button.text = "Click Me";
		button.icon = new Bitmap(texture);
		button.iconPosition = RIGHT;
		```

		@see `ToggleButton.icon`

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

		```haxe
		button.text = "Click Me";
		button.icon = new Bitmap(bitmapData);
		button.gap = 20.0;
		```

		@see `ToggleButton.minGap`

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

		```haxe
		button.gap = Math.POSITIVE_INFINITY;
		button.minGap = 20.0;
		```

		@see `ToggleButton.gap`

		@since 1.0.0
	**/
	@:style
	public var minGap:Float = 0.0;

	/**
		The minimum space, in pixels, between the button's top edge and the
		button's content.

		In the following example, the button's top padding is set to 20 pixels:

		```haxe
		button.paddingTop = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:style
	public var paddingTop:Float = 0.0;

	/**
		The minimum space, in pixels, between the button's right edge and the
		button's content.

		In the following example, the button's right padding is set to 20
		pixels:

		```haxe
		button.paddingRight = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:style
	public var paddingRight:Float = 0.0;

	/**
		The minimum space, in pixels, between the button's bottom edge and the
		button's content.

		In the following example, the button's bottom padding is set to 20
		pixels:

		```haxe
		button.paddingBottom = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:style
	public var paddingBottom:Float = 0.0;

	/**
		The minimum space, in pixels, between the button's left edge and the
		button's content.

		In the following example, the button's left padding is set to 20
		pixels:

		```haxe
		button.paddingLeft = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:style
	public var paddingLeft:Float = 0.0;

	/**
		How the content is positioned horizontally (along the x-axis) within the
		button.

		The following example aligns the button's content to the left:

		```haxe
		button.verticalAlign = LEFT;
		```

		**Note:** The `HorizontalAlign.JUSTIFY` constant is not supported by this
		component.

		@see `feathers.layout.HorizontalAlign.LEFT`
		@see `feathers.layout.HorizontalAlign.CENTER`
		@see `feathers.layout.HorizontalAlign.RIGHT`

		@since 1.0.0
	**/
	@:style
	public var horizontalAlign:HorizontalAlign = CENTER;

	/**
		How the content is positioned vertically (along the y-axis) within the
		button.

		The following example aligns the button's content to the top:

		```haxe
		button.verticalAlign = TOP;
		```

		**Note:** The `VerticalAlign.JUSTIFY` constant is not supported by this
		component.

		@see `feathers.layout.VerticalAlign.TOP`
		@see `feathers.layout.VerticalAlign.MIDDLE`
		@see `feathers.layout.VerticalAlign.BOTTOM`

		@since 1.0.0
	**/
	@:style
	public var verticalAlign:VerticalAlign = MIDDLE;

	/**
		Offsets the x position of the icon by a certain number of pixels.
		This does not affect the measurement of the button. The button's width
		will not get smaller or larger when the icon is offset from its default
		x position.

		The following example offsets the x position of the button's icon by
		20 pixels:

		```haxe
		button.iconOffsetX = 20.0;
		```

		@see `ToggleButton.iconOffsetY`

		@since 1.0.0
	**/
	@:style
	public var iconOffsetX:Float = 0.0;

	/**
		Offsets the y position of the icon by a certain number of pixels.
		This does not affect the measurement of the button. The button's height
		will not get smaller or larger when the icon is offset from its default
		y position.

		The following example offsets the y position of the button's icon by
		20 pixels:

		```haxe
		button.iconOffsetY = 20.0;
		```

		@see `ToggleButton.iconOffsetX`

		@since 1.0.0
	**/
	@:style
	public var iconOffsetY:Float = 0.0;

	/**
		Offsets the x position of the text by a certain number of pixels.
		This does not affect the measurement of the button. The button's width
		will not get smaller or larger when the text is offset from its default
		x position. Nor does it change the size of the text, so the text may
		appear outside of the button's bounds if the offset is large enough.

		The following example offsets the x position of the button's text by
		20 pixels:

		```haxe
		button.textOffsetX = 20.0;
		```

		@see `ToggleButton.textOffsetY`

		@since 1.0.0
	**/
	@:style
	public var textOffsetX:Float = 0.0;

	/**
		Offsets the y position of the text by a certain number of pixels.
		This does not affect the measurement of the button. The button's height
		will not get smaller or larger when the text is offset from its default
		y position. Nor does it change the size of the text, so the text may
		appear outside of the button's bounds if the offset is large enough.

		The following example offsets the y position of the button's text by
		20 pixels:

		```haxe
		button.textOffsetY = 20.0;
		```

		@see `ToggleButton.textOffsetX`

		@since 1.0.0
	**/
	@:style
	public var textOffsetY:Float = 0.0;

	/**
		Shows or hides the button text. If the text is hidden, it will not
		affect the layout of other children, such as the icon.

		@since 1.0.0
	**/
	@:style
	public var showText:Bool = true;

	private var _textMeasuredWidth:Float;
	private var _textMeasuredHeight:Float;
	private var _wrappedOnMeasure:Bool;
	private var _stateToTextFormat:Map<ToggleButtonState, AbstractTextFormat> = new Map();

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
	public function getTextFormatForState(state:ToggleButtonState):AbstractTextFormat {
		return this._stateToTextFormat.get(state);
	}

	/**
		Set the text format to be used by the button when its `currentState`
		property matches the specified state value.

		If a text format is not defined for a specific state, the value of the
		`textFormat` property will be used instead.

		@see `ToggleButton.getTextFormatForState()`
		@see `ToggleButton.textFormat`
		@see `ToggleButton.currentState`
		@see `feathers.controls.ToggleButtonState`

		@since 1.0.0
	**/
	@style
	public function setTextFormatForState(state:ToggleButtonState, textFormat:AbstractTextFormat):Void {
		if (!this.setStyle("setTextFormatForState", state)) {
			return;
		}
		if (textFormat == null) {
			this._stateToTextFormat.remove(state);
		} else {
			this._stateToTextFormat.set(state, textFormat);
		}
		this.setInvalid(STYLES);
	}

	/**
		Gets the icon to be used by the button when its `currentState` property
		matches the specified state value.

		If an icon is not defined for a specific state, returns `null`.

		@see `ToggleButton.setIconForState()`
		@see `ToggleButton.icon`
		@see `ToggleButton.currentState`
		@see `feathers.controls.ToggleButtonState`

		@since 1.0.0
	**/
	public function getIconForState(state:ToggleButtonState):DisplayObject {
		return this._stateToIcon.get(state);
	}

	/**
		Set the icon to be used by the button when its `currentState` property
		matches the specified state value.

		If an icon is not defined for a specific state, the value of the
		`textFormat` property will be used instead.

		@see `ToggleButton.getIconForState()`
		@see `ToggleButton.icon`
		@see `ToggleButton.currentState`
		@see `feathers.controls.ToggleButtonState`

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
		this.setInvalid(STYLES);
	}

	/**
		Sets all four padding properties to the same value.

		@see `ToggleButton.paddingTop`
		@see `ToggleButton.paddingRight`
		@see `ToggleButton.paddingBottom`
		@see `ToggleButton.paddingLeft`

		@since 1.0.0
	**/
	public function setPadding(value:Float):Void {
		this.paddingTop = value;
		this.paddingRight = value;
		this.paddingBottom = value;
		this.paddingLeft = value;
	}

	private function initializeToggleButtonTheme():Void {
		#if !feathersui_disable_default_theme
		feathers.themes.steel.components.SteelToggleButtonStyles.initialize();
		#end
	}

	override private function initialize():Void {
		super.initialize();
		if (this.textField == null) {
			this.textField = new TextField();
			this.textField.selectable = false;
			this.textField.multiline = true;
			this.addChild(this.textField);
		}
	}

	override private function commitChanges():Void {
		super.commitChanges();

		var dataInvalid = this.isInvalid(DATA);
		var sizeInvalid = this.isInvalid(SIZE);
		var stateInvalid = this.isInvalid(STATE);
		var stylesInvalid = this.isInvalid(STYLES);

		this._updatedTextStyles = false;

		if (stylesInvalid || stateInvalid) {
			this.refreshIcon();
		}

		if (stylesInvalid || stateInvalid) {
			this.refreshTextStyles();
		}

		if (dataInvalid || stylesInvalid || stateInvalid || sizeInvalid) {
			this.refreshText(sizeInvalid);
		}
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

		var hasText = this.showText && this._text != null;
		var hasHTMLText = this.showText && this._htmlText != null && this._htmlText.length > 0;
		if (hasText || hasHTMLText) {
			this.refreshTextFieldDimensions(true);
		}

		if (this._currentBackgroundSkin != null) {
			MeasurementsUtil.resetFluidlyWithParent(this._backgroundSkinMeasurements, this._currentBackgroundSkin, this);
		}

		var measureSkin:IMeasureObject = null;
		if ((this._currentBackgroundSkin is IMeasureObject)) {
			measureSkin = cast(this._currentBackgroundSkin, IMeasureObject);
		}

		if ((this._currentBackgroundSkin is IValidating)) {
			cast(this._currentBackgroundSkin, IValidating).validateNow();
		}

		if ((this._currentIcon is IValidating)) {
			var oldIgnoreIconResizes = this._ignoreIconResizes;
			this._ignoreIconResizes = true;
			cast(this._currentIcon, IValidating).validateNow();
			this._ignoreIconResizes = oldIgnoreIconResizes;
		}

		var newWidth = this.explicitWidth;
		if (needsWidth) {
			newWidth = this.measureContentWidth();
			newWidth += this.paddingLeft + this.paddingRight;
			if (this._currentBackgroundSkin != null) {
				newWidth = Math.max(this._currentBackgroundSkin.width, newWidth);
			}
		}

		var newHeight = this.explicitHeight;
		if (needsHeight) {
			newHeight = this.measureContentHeight();
			newHeight += this.paddingTop + this.paddingBottom;
			if (this._currentBackgroundSkin != null) {
				newHeight = Math.max(this._currentBackgroundSkin.height, newHeight);
			}
		}

		var newMinWidth = this.explicitMinWidth;
		if (needsMinWidth) {
			newMinWidth = this.measureContentMinWidth();
			newMinWidth += this.paddingLeft + this.paddingRight;
			if (measureSkin != null) {
				newMinWidth = Math.max(measureSkin.minWidth, newMinWidth);
			} else if (this._backgroundSkinMeasurements != null) {
				newMinWidth = Math.max(this._backgroundSkinMeasurements.minWidth, newMinWidth);
			}
		}

		var newMinHeight = this.explicitMinHeight;
		if (needsMinHeight) {
			newMinHeight = this.measureContentMinHeight();
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
				newMaxWidth = 1.0 / 0.0; // Math.POSITIVE_INFINITY bug workaround for swf
			}
		}

		var newMaxHeight = this.explicitMaxHeight;
		if (needsMaxHeight) {
			if (measureSkin != null) {
				newMaxHeight = measureSkin.maxHeight;
			} else if (this._backgroundSkinMeasurements != null) {
				newMaxHeight = this._backgroundSkinMeasurements.maxHeight;
			} else {
				newMaxHeight = 1.0 / 0.0; // Math.POSITIVE_INFINITY bug workaround for swf
			}
		}

		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight, newMaxWidth, newMaxHeight);
	}

	private function calculateExplicitWidthForTextMeasurement():Null<Float> {
		var textFieldExplicitWidth:Null<Float> = null;
		if (this.explicitWidth != null) {
			textFieldExplicitWidth = this.explicitWidth;
		} else if (this.explicitMaxWidth != null) {
			textFieldExplicitWidth = this.explicitMaxWidth;
		} else if (this._backgroundSkinMeasurements != null && this._backgroundSkinMeasurements.maxWidth != null) {
			textFieldExplicitWidth = this._backgroundSkinMeasurements.maxWidth;
		}

		if (textFieldExplicitWidth == null) {
			return textFieldExplicitWidth;
		}
		textFieldExplicitWidth -= (this.paddingLeft + this.paddingRight);
		var adjustedGap = this.gap;
		// Math.POSITIVE_INFINITY bug workaround for swf
		if (adjustedGap == (1.0 / 0.0)) {
			adjustedGap = this.minGap;
		}
		if (this._currentIcon != null) {
			if (this.iconPosition == LEFT || this.iconPosition == RIGHT) {
				if ((this._currentIcon is IValidating)) {
					cast(this._currentIcon, IValidating).validateNow();
				}
				textFieldExplicitWidth -= (this._currentIcon.width + adjustedGap);
			}
		}
		if (textFieldExplicitWidth < 0.0) {
			textFieldExplicitWidth = 0.0;
		}
		return textFieldExplicitWidth;
	}

	private function measureContentWidth():Float {
		var adjustedGap = this.gap;
		// Math.POSITIVE_INFINITY bug workaround for swf
		if (adjustedGap == (1.0 / 0.0)) {
			adjustedGap = this.minGap;
		}
		var hasText = this.showText && this._text != null;
		var hasHTMLText = this.showText && this._htmlText != null && this._htmlText.length > 0;
		var contentWidth = (hasText || hasHTMLText) ? this._textMeasuredWidth : 0.0;
		if (this._currentIcon != null) {
			if (this.iconPosition == LEFT || this.iconPosition == RIGHT) {
				if (hasText || hasHTMLText) {
					contentWidth += adjustedGap;
				}
				contentWidth += this._currentIcon.width;
			} else if (this.iconPosition == TOP || this.iconPosition == BOTTOM) {
				contentWidth = Math.max(contentWidth, this._currentIcon.width);
			}
		}
		return contentWidth;
	}

	private function measureContentHeight():Float {
		var adjustedGap = this.gap;
		// Math.POSITIVE_INFINITY bug workaround for swf
		if (adjustedGap == (1.0 / 0.0)) {
			adjustedGap = this.minGap;
		}

		var hasText = this.showText && this._text != null;
		var hasHTMLText = this.showText && this._htmlText != null && this._htmlText.length > 0;
		var contentHeight = (hasText || hasHTMLText) ? this._textMeasuredHeight : 0.0;
		if (this._currentIcon != null) {
			if (this.iconPosition == TOP || this.iconPosition == BOTTOM) {
				if (hasText || hasHTMLText) {
					contentHeight += adjustedGap;
				}
				contentHeight += this._currentIcon.height;
			} else if (this.iconPosition == LEFT || this.iconPosition == RIGHT) {
				contentHeight = Math.max(contentHeight, this._currentIcon.height);
			}
		}
		return contentHeight;
	}

	private function measureContentMinWidth():Float {
		var adjustedGap = this.gap;
		// Math.POSITIVE_INFINITY bug workaround for swf
		if (adjustedGap == (1.0 / 0.0)) {
			adjustedGap = this.minGap;
		}
		var hasText = this.showText && this._text != null;
		var hasHTMLText = this.showText && this._htmlText != null && this._htmlText.length > 0;
		var contentMinWidth = (hasText || hasHTMLText) ? this._textMeasuredWidth : 0.0;
		if (this._currentIcon != null) {
			if (this.iconPosition == LEFT || this.iconPosition == RIGHT) {
				if (hasText || hasHTMLText) {
					contentMinWidth += adjustedGap;
				}
				contentMinWidth += this._currentIcon.width;
			} else if (this.iconPosition == TOP || this.iconPosition == BOTTOM) {
				contentMinWidth = Math.max(contentMinWidth, this._currentIcon.width);
			}
		}
		return contentMinWidth;
	}

	private function measureContentMinHeight():Float {
		var adjustedGap = this.gap;
		// Math.POSITIVE_INFINITY bug workaround for swf
		if (adjustedGap == (1.0 / 0.0)) {
			adjustedGap = this.minGap;
		}
		var hasText = this.showText && this._text != null;
		var hasHTMLText = this.showText && this._htmlText != null && this._htmlText.length > 0;
		var contentMinHeight = (hasText || hasHTMLText) ? this._textMeasuredHeight : 0.0;
		if (this._currentIcon != null) {
			if (this.iconPosition == TOP || this.iconPosition == BOTTOM) {
				if (hasText || hasHTMLText) {
					contentMinHeight += adjustedGap;
				}
				contentMinHeight += this._currentIcon.height;
			} else if (this.iconPosition == LEFT || this.iconPosition == RIGHT) {
				contentMinHeight = Math.max(contentMinHeight, this._currentIcon.height);
			}
		}
		return contentMinHeight;
	}

	private function refreshTextStyles():Void {
		if (this.textField.wordWrap != this.wordWrap) {
			this.textField.wordWrap = this.wordWrap;
			this._updatedTextStyles = true;
		}
		if (this.textField.embedFonts != this.embedFonts) {
			this.textField.embedFonts = this.embedFonts;
			this._updatedTextStyles = true;
		}
		#if (openfl >= "9.2.0" || flash)
		if (this.textField.styleSheet != this.styleSheet) {
			this.textField.styleSheet = this.styleSheet;
			this._updatedTextStyles = true;
		}
		#end
		var textFormat = this.getCurrentTextFormat();
		var simpleTextFormat = textFormat != null ? textFormat.toSimpleTextFormat() : null;
		if (simpleTextFormat == this._previousSimpleTextFormat) {
			// nothing to refresh
			return;
		}
		if (this._previousTextFormat != null) {
			this._previousTextFormat.removeEventListener(Event.CHANGE, toggleButton_textFormat_changeHandler);
		}
		if (textFormat != null) {
			textFormat.addEventListener(Event.CHANGE, toggleButton_textFormat_changeHandler, false, 0, true);
			this.textField.defaultTextFormat = simpleTextFormat;
			this._updatedTextStyles = true;
		}
		this._previousTextFormat = textFormat;
		this._previousSimpleTextFormat = simpleTextFormat;
	}

	private function refreshText(forceMeasurement:Bool):Void {
		// usually, hasText doesn't check the length, but TextField height may
		// not be accurate with an empty string
		var hasText = this.showText && this._text != null && this._text.length > 0;
		var hasHTMLText = this.showText && this._htmlText != null && this._htmlText.length > 0;
		this.textField.visible = hasText || hasHTMLText;
		if (this._text == this._previousText
			&& this._htmlText == this._previousHTMLText
			&& !this._updatedTextStyles
			&& !forceMeasurement) {
			// nothing to refresh
			return;
		}
		// set autoSize before text because setting text first can trigger an
		// extra text engine reflow
		this.textField.autoSize = LEFT;
		if (hasHTMLText) {
			this.textField.htmlText = this._htmlText;
		} else if (hasText) {
			this.textField.text = this._text;
		} else {
			// zero-width space results in a more accurate height measurement
			// than we'd get with an empty string
			this.textField.text = "\u200b";
		}
		if (this.wordWrap) {
			// temporarily disable wrapping for an accurate width measurement
			this.textField.wordWrap = false;
		}
		this._textMeasuredWidth = this.textField.textWidth + 4;
		this._wrappedOnMeasure = false;
		if (this.wordWrap) {
			var textFieldExplicitWidth = this.calculateExplicitWidthForTextMeasurement();
			if (textFieldExplicitWidth != null && this._textMeasuredWidth > textFieldExplicitWidth) {
				// enable wrapping only if we definitely need it
				this.textField.wordWrap = true;
				this.textField.width = textFieldExplicitWidth;
				this._textMeasuredWidth = this.textField.width;
				this._wrappedOnMeasure = true;
			}
		}
		this._textMeasuredHeight = this.textField.height;
		this.textField.autoSize = NONE;
		if (this.textField.wordWrap != this.wordWrap) {
			this.textField.wordWrap = this.wordWrap;
		}
		if (!hasText && !hasHTMLText) {
			this.textField.text = "";
		}
		this._previousText = this._text;
		this._previousHTMLText = this._htmlText;
	}

	private function getCurrentTextFormat():TextFormat {
		#if (openfl >= "9.2.0" || flash)
		if (this.styleSheet != null) {
			// TextField won't let us use TextFormat if we have a StyleSheet
			return null;
		}
		#end
		var result = this._stateToTextFormat.get(this._currentState);
		if (result != null) {
			return result;
		}
		if (!this._enabled && this.disabledTextFormat != null) {
			return this.disabledTextFormat;
		}
		if (this._selected && this.selectedTextFormat != null) {
			return this.selectedTextFormat;
		}
		return this.textFormat;
	}

	override private function layoutContent():Void {
		super.layoutContent();
		this.layoutChildren();
	}

	private function layoutChildren():Void {
		this.refreshTextFieldDimensions(false);

		var hasText = this.showText && this._text != null;
		var hasHTMLText = this.showText && this._htmlText != null && this._htmlText.length > 0;
		var iconIsInLayout = this._currentIcon != null && this.iconPosition != MANUAL;
		if ((hasText || hasHTMLText) && iconIsInLayout) {
			this.positionSingleChild(this.textField);
			this.positionTextAndIcon();
		} else if (hasText || hasHTMLText) {
			this.positionSingleChild(this.textField);
		} else if (iconIsInLayout) {
			this.positionSingleChild(this._currentIcon);
		}

		if (this._currentIcon != null) {
			if (this.iconPosition == MANUAL) {
				this._currentIcon.x = this.paddingLeft;
				this._currentIcon.y = this.paddingTop;
			}
			this._currentIcon.x += this.iconOffsetX;
			this._currentIcon.y += this.iconOffsetY;
		}
		if (hasText) {
			this.textField.x += this.textOffsetX;
			this.textField.y += this.textOffsetY;
		}
	}

	private function refreshTextFieldDimensions(forMeasurement:Bool):Void {
		var oldIgnoreIconResizes = this._ignoreIconResizes;
		this._ignoreIconResizes = true;
		if ((this._currentIcon is IValidating)) {
			cast(this._currentIcon, IValidating).validateNow();
		}
		this._ignoreIconResizes = oldIgnoreIconResizes;
		var hasText = this.showText && this._text != null;
		var hasHTMLText = this.showText && this._htmlText != null && this._htmlText.length > 0;
		if (!hasText && !hasHTMLText) {
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
			// Math.POSITIVE_INFINITY bug workaround for swf
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
			// Math.POSITIVE_INFINITY bug workaround for swf
			if (this.gap == (1.0 / 0.0)) {
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
			// Math.POSITIVE_INFINITY bug workaround for swf
			if (this.gap == (1.0 / 0.0)) {
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
			// Math.POSITIVE_INFINITY bug workaround for swf
			if (this.gap == (1.0 / 0.0)) {
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
			// Math.POSITIVE_INFINITY bug workaround for swf
			if (this.gap == (1.0 / 0.0)) {
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
		this.addCurrentIcon(this._currentIcon);
	}

	private function getCurrentIcon():DisplayObject {
		var result = this._stateToIcon.get(this._currentState);
		if (result != null) {
			return result;
		}
		if (!this._enabled && this.disabledIcon != null) {
			return this.disabledIcon;
		}
		if (this._selected && this.selectedIcon != null) {
			return this.selectedIcon;
		}
		return this.icon;
	}

	private function addCurrentIcon(icon:DisplayObject):Void {
		if (icon == null) {
			this._iconMeasurements = null;
			return;
		}
		if ((icon is IUIControl)) {
			cast(icon, IUIControl).initializeNow();
		}
		if (this._iconMeasurements == null) {
			this._iconMeasurements = new Measurements(icon);
		} else {
			this._iconMeasurements.save(icon);
		}
		if ((icon is IProgrammaticSkin)) {
			cast(icon, IProgrammaticSkin).uiContext = this;
		}
		if ((icon is IStateObserver)) {
			cast(icon, IStateObserver).stateContext = this;
		}
		icon.addEventListener(Event.RESIZE, toggleButton_icon_resizeHandler, false, 0, true);
		var index = this.getChildIndex(this.textField);
		// the icon should be below the text
		this.addChildAt(icon, index);
	}

	private function removeCurrentIcon(icon:DisplayObject):Void {
		if (icon == null) {
			return;
		}
		icon.removeEventListener(Event.RESIZE, toggleButton_icon_resizeHandler);
		if ((icon is IProgrammaticSkin)) {
			cast(icon, IProgrammaticSkin).uiContext = null;
		}
		if ((icon is IStateObserver)) {
			cast(icon, IStateObserver).stateContext = null;
		}
		// we need to restore these values so that they won't be lost the
		// next time that this icon is used for measurement
		this._iconMeasurements.restore(icon);
		if (icon.parent == this) {
			this.removeChild(icon);
		}
	}

	private function toggleButton_keyDownHandler(event:KeyboardEvent):Void {
		if (!this._enabled || (this.buttonMode && this.focusRect == true)) {
			return;
		}
		if (this._focusManager != null && this._focusManager.focus != this) {
			return;
		}
		if (event.keyCode != Keyboard.SPACE && event.keyCode != Keyboard.ENTER) {
			return;
		}
		// ensure that other components cannot use this key event
		event.preventDefault();
		this.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
	}

	private function toggleButton_focusInHandler(event:FocusEvent):Void {
		this._keyToState.enabled = this._enabled;
	}

	private function toggleButton_focusOutHandler(event:FocusEvent):Void {
		this._keyToState.enabled = false;
	}

	private function toggleButton_textFormat_changeHandler(event:Event):Void {
		this.setInvalid(STYLES);
	}

	private function toggleButton_icon_resizeHandler(event:Event):Void {
		if (this._ignoreIconResizes) {
			return;
		}
		this.setInvalid(STYLES);
	}
}
