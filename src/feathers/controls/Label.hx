/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.utils.MeasurementsUtil;
import feathers.themes.steel.components.SteelLabelStyles;
import feathers.core.FeathersControl;
import feathers.core.IMeasureObject;
import feathers.core.InvalidationFlag;
import feathers.core.IStateContext;
import feathers.core.IStateObserver;
import feathers.core.ITextControl;
import feathers.core.IUIControl;
import feathers.core.IValidating;
import feathers.layout.Measurements;
import feathers.layout.VerticalAlign;
import openfl.display.DisplayObject;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;

/**
	Displays text with an optional background.

	The following example creates a label and gives it text:

	```hx
	var label = new Label();
	label.text = "Hello World";
	this.addChild(label);
	```

	@see [Tutorial: How to use the Label component](https://feathersui.com/learn/haxe-openfl/help/label/)

	@since 1.0.0
**/
@:styleContext
class Label extends FeathersControl implements ITextControl {
	/**
		A variant used to style the label using a Larger text format for
		headings. Variants allow themes to provide an assortment of different
		appearances for the same type of UI component.

		The following example uses this variant:

		```hx
		var label = new Label();
		label.variant = Label.VARIANT_HEADING;
		```

		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final VARIANT_HEADING = "heading";

	/**
		A variant used to style the label using a smaller text format for
		details. Variants allow themes to provide an assortment of different
		appearances for the same type of UI component.

		The following example uses this variant:

		```hx
		var label = new Label();
		label.variant = Label.VARIANT_DETAIL;
		```

		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final VARIANT_DETAIL = "detail";

	/**
		Creates a new `Label` object.

		@since 1.0.0
	**/
	public function new() {
		initializeLabelTheme();

		super();
	}

	private var textField:TextField;

	private var _previousText:String = null;
	private var _previousHTMLText:String = null;
	private var _previousTextFormat:TextFormat = null;
	private var _updatedTextStyles = false;
	private var _textMeasuredWidth:Float;
	private var _textMeasuredHeight:Float;

	/**
		The text displayed by the label.

		The following example sets the label's text:

		```hx
		label.text = "Good afternoon!";
		```

		Note: If the `htmlText` property is not `null`, the `text` property will
		be ignored.

		@default ""

		@see `Label.htmlText`
		@see `Label.textFormat`

		@since 1.0.0
	**/
	@:isVar
	public var text(get, set):String = "";

	private function get_text():String {
		return this.text;
	}

	private function set_text(value:String):String {
		if (value == null) {
			// null gets converted to an empty string
			if (this.text.length == 0) {
				// already an empty string
				return this.text;
			}
			value = "";
		}
		if (this.text == value) {
			return this.text;
		}
		this.text = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this.text;
	}

	/**
		Text displayed by the label that is parsed as a simple form of HTML.

		The following example sets the label's HTML text:

		```hx
		label.htmlText = "<b>Hello</b> <i>World</i>";
		```

		@default null

		@see `Label.text`
		@see `openfl.text.TextField.htmlText`

		@since 1.0.0
	**/
	@:isVar
	public var htmlText(default, set):String = null;

	private function set_htmlText(value:String):String {
		if (this.htmlText == value) {
			return this.htmlText;
		}
		this.htmlText = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this.htmlText;
	}

	/**
		The font styles used to render the label's text.

		In the following example, the label's text formatting is customized:

		```hx
		label.textFormat = new TextFormat("Helvetica", 20, 0xcc0000);
		```

		@see `Label.text`
		@see `Label.disabledTextFormat`
		@see `Label.embedFonts`

		@since 1.0.0
	**/
	@:style
	public var textFormat:TextFormat = null;

	/**
		Determines if an embedded font is used or not.

		In the following example, the label uses embedded fonts:

		```hx
		label.embedFonts = true;
		```

		@see `Label.textFormat`

		@since 1.0.0
	**/
	@:style
	public var embedFonts:Bool = false;

	/**
		Indicates if the label's text may be selected or not.

		In the following example, the label text is selectable:

		```hx
		label.selectable = true;
		```

		@since 1.0.0
	**/
	public var selectable(default, set):Bool = false;

	private function set_selectable(value:Bool):Bool {
		if (this.selectable == value) {
			return this.selectable;
		}
		this.selectable = value;
		this.setInvalid(InvalidationFlag.SELECTION);
		return this.selectable;
	}

	/**
		The start index of the selection.

		If `selectable` is `false`, returns `-1`.

		@since 1.0.0
	**/
	public var selectionBeginIndex(get, null):Int;

	private function get_selectionBeginIndex():Int {
		if (!this.selectable) {
			return -1;
		}
		if (this.textField == null) {
			return 0;
		}
		return this.textField.selectionBeginIndex;
	}

	/**
		The end index of the selection.

		If `selectable` is `false`, returns `-1`.

		@since 1.0.0
	**/
	public var selectionEndIndex(get, null):Int;

	private function get_selectionEndIndex():Int {
		if (!this.selectable) {
			return -1;
		}
		if (this.textField == null) {
			return 0;
		}
		return this.textField.selectionEndIndex;
	}

	/**
		The font styles used to render the label's text when the label is
		disabled.

		In the following example, the label's disabled text formatting is
		customized:

		```hx
		label.enabled = false;
		label.disabledTextFormat = new TextFormat("Helvetica", 20, 0xee0000);
		```

		@see `Label.textFormat`

		@since 1.0.0
	**/
	@:style
	public var disabledTextFormat:TextFormat = null;

	/**
		The minimum space, in pixels, between the button's top edge and the
		button's content.

		In the following example, the button's top padding is set to 20 pixels:

		```hx
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

		```hx
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

		```hx
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

		```hx
		button.paddingLeft = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:style
	public var paddingLeft:Float = 0.0;

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
		Determines if the text is displayed on a single line, or if it wraps.

		In the following example, the label's text wraps at 150 pixels:

		```hx
		label.width = 150.0;
		label.wordWrap = true;
		```

		@default false

		@since 1.0.0
	**/
	@:style
	public var wordWrap:Bool = false;

	private var _currentBackgroundSkin:DisplayObject = null;
	private var _backgroundSkinMeasurements:Measurements = null;

	/**
		The default background skin to display behind the label's text.

		The following example passes a bitmap for the label to use as a
		background skin:

		```hx
		label.backgroundSkin = new Bitmap(bitmapData);
		```

		@default null

		@see `Label.disabledBackgroundSkin`

		@since 1.0.0
	**/
	@:style
	public var backgroundSkin:DisplayObject = null;

	/**
		A background skin to display behind the label's text when the label is
		disabled.

		The following example gives the label a disabled background skin:

		```hx
		label.disabledBackgroundSkin = new Bitmap(bitmapData);
		label.enabled = false;
		```

		@default null

		@see `Label.backgroundSkin`

		@since 1.0.0
	**/
	@:style
	public var disabledBackgroundSkin:DisplayObject = null;

	private function initializeLabelTheme():Void {
		SteelLabelStyles.initialize();
	}

	override private function initialize():Void {
		super.initialize();
		if (this.textField == null) {
			this.textField = new TextField();
			this.addChild(this.textField);
		}
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);
		var selectionInvalid = this.isInvalid(InvalidationFlag.SELECTION);
		var sizeInvalid = this.isInvalid(InvalidationFlag.SIZE);
		var stateInvalid = this.isInvalid(InvalidationFlag.STATE);
		var stylesInvalid = this.isInvalid(InvalidationFlag.STYLES);

		this._updatedTextStyles = false;

		if (stylesInvalid || stateInvalid) {
			this.refreshBackgroundSkin();
		}

		if (stylesInvalid || stateInvalid) {
			this.refreshTextStyles();
		}

		if (dataInvalid || stylesInvalid || stateInvalid || sizeInvalid) {
			this.refreshText(sizeInvalid);
		}

		if (dataInvalid || stylesInvalid || selectionInvalid) {
			this.refreshSelection();
		}

		sizeInvalid = this.measure() || sizeInvalid;

		if (stylesInvalid || stateInvalid || dataInvalid || sizeInvalid) {
			this.layoutContent();
		}
	}

	private function measure():Bool {
		var needsWidth = this.explicitWidth == null;
		var needsHeight = this.explicitHeight == null;
		var needsMinWidth = this.explicitMinWidth == null;
		var needsMinHeight = this.explicitMinHeight == null;
		var needsMaxWidth = this.explicitMaxWidth == null;
		var needsMaxHeight = this.explicitMaxHeight == null;
		if (!needsWidth && !needsHeight && !needsMinWidth && !needsMinHeight && !needsMaxWidth && !needsMaxHeight) {
			return false;
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

		var newWidth = this.explicitWidth;
		if (needsWidth) {
			newWidth = this._textMeasuredWidth + this.paddingLeft + this.paddingRight;
			if (this._currentBackgroundSkin != null) {
				newWidth = Math.max(this._currentBackgroundSkin.width, newWidth);
			}
		}

		var newHeight = this.explicitHeight;
		if (needsHeight) {
			newHeight = this._textMeasuredHeight + this.paddingTop + this.paddingBottom;
			if (this._currentBackgroundSkin != null) {
				newHeight = Math.max(this._currentBackgroundSkin.height, newHeight);
			}
		}

		var newMinWidth = this.explicitMinWidth;
		if (needsMinWidth) {
			newMinWidth = this._textMeasuredWidth + this.paddingLeft + this.paddingRight;
			if (measureSkin != null) {
				newMinWidth = Math.max(measureSkin.minWidth, newMinWidth);
			} else if (this._backgroundSkinMeasurements != null) {
				newMinWidth = Math.max(this._backgroundSkinMeasurements.minWidth, newMinWidth);
			}
		}

		var newMinHeight = this.explicitMinHeight;
		if (needsMinHeight) {
			newMinHeight = this._textMeasuredHeight + this.paddingTop + this.paddingBottom;
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
		if (this.textField.wordWrap != this.wordWrap) {
			this.textField.wordWrap = this.wordWrap;
			this._updatedTextStyles = true;
		}
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

	private function refreshText(sizeInvalid:Bool):Void {
		var hasText = this.text != null && this.text.length > 0;
		var hasHTMLText = this.htmlText != null && this.htmlText.length > 0;
		this.textField.visible = hasText || hasHTMLText;
		if (this.text == this._previousText && this.htmlText == this._previousHTMLText && !this._updatedTextStyles && !sizeInvalid) {
			// nothing to refresh
			return;
		}
		if (hasHTMLText) {
			this.textField.htmlText = this.htmlText;
		} else if (hasText) {
			this.textField.text = this.text;
		} else {
			this.textField.text = "\u8203"; // zero-width space
		}
		this.textField.autoSize = TextFieldAutoSize.LEFT;
		var textFieldWidth:Null<Float> = null;
		if (this.explicitWidth != null) {
			textFieldWidth = this.explicitWidth;
		} else if (this.explicitMaxWidth != null) {
			textFieldWidth = this.explicitMaxWidth;
		}
		if (textFieldWidth == null && this.wordWrap) {
			// to get an accurate measurement, we need to temporarily disable
			// wrapping to multiple lines
			this.textField.wordWrap = false;
		} else if (textFieldWidth != null) {
			this.textField.width = textFieldWidth;
		}
		this._textMeasuredWidth = this.textField.width;
		this._textMeasuredHeight = this.textField.height;
		this.textField.autoSize = TextFieldAutoSize.NONE;
		if (textFieldWidth == null && this.wordWrap) {
			this.textField.wordWrap = true;
		}
		if (!hasText && !hasHTMLText) {
			this.textField.text = "";
		}
		this._previousText = this.text;
		this._previousHTMLText = this.htmlText;
	}

	private function refreshSelection():Void {
		var selectable = this.selectable && this.enabled;
		if (this.textField.selectable != selectable) {
			this.textField.selectable = selectable;
		}
	}

	private function getCurrentTextFormat():TextFormat {
		if (!this.enabled && this.disabledTextFormat != null) {
			return this.disabledTextFormat;
		}
		return this.textFormat;
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

	private function layoutContent() {
		this.layoutBackgroundSkin();

		this.textField.x = this.paddingLeft;
		this.textField.width = this.actualWidth - this.paddingLeft - this.paddingRight;

		var maxHeight = this.actualHeight - this.paddingTop - this.paddingBottom;
		if (this._textMeasuredHeight > maxHeight) {
			this.textField.height = maxHeight;
		} else {
			this.textField.height = this._textMeasuredHeight;
		}
		switch (this.verticalAlign) {
			case TOP:
				this.textField.y = this.paddingTop;
			case BOTTOM:
				this.textField.y = this.actualHeight - this.paddingBottom - this.textField.height;
			default: // middle or null
				this.textField.y = this.paddingTop + (maxHeight - this.textField.height) / 2.0;
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
}
