/*
	Feathers UI
	Copyright 2024 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.core.FeathersControl;
import feathers.core.IFocusObject;
import feathers.core.IHTMLTextControl;
import feathers.core.IMeasureObject;
import feathers.core.IStageFocusDelegate;
import feathers.core.ITextControl;
import feathers.core.IUIControl;
import feathers.core.IValidating;
import feathers.layout.Measurements;
import feathers.layout.VerticalAlign;
import feathers.skins.IProgrammaticSkin;
import feathers.text.TextFormat;
import feathers.utils.MeasurementsUtil;
import openfl.display.DisplayObject;
import openfl.display.InteractiveObject;
import openfl.events.Event;
import openfl.events.FocusEvent;
import openfl.text.TextField;
#if (openfl >= "9.2.0")
import openfl.text.StyleSheet;
#elseif flash
import flash.text.StyleSheet;
#end

/**
	Displays text with an optional background.

	The following example creates a label and gives it text:

	```haxe
	var label = new Label();
	label.text = "Hello World";
	this.addChild(label);
	```

	@see [Tutorial: How to use the Label component](https://feathersui.com/learn/haxe-openfl/label/)

	@since 1.0.0
**/
@defaultXmlProperty("text")
@:styleContext
class Label extends FeathersControl implements ITextControl implements IHTMLTextControl implements IFocusObject implements IStageFocusDelegate {
	/**
		A variant used to style the label using a Larger text format for
		headings. Variants allow themes to provide an assortment of different
		appearances for the same type of UI component.

		The following example uses this variant:

		```haxe
		var label = new Label();
		label.variant = Label.VARIANT_HEADING;
		```

		@see `feathers.style.IVariantStyleObject.variant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final VARIANT_HEADING = "heading";

	/**
		A variant used to style the label using a smaller text format for
		details. Variants allow themes to provide an assortment of different
		appearances for the same type of UI component.

		The following example uses this variant:

		```haxe
		var label = new Label();
		label.variant = Label.VARIANT_DETAIL;
		```

		@see `feathers.style.IVariantStyleObject.variant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final VARIANT_DETAIL = "detail";

	/**
		A variant used to style the label using an appearance that indicates
		an error or warning.

		The following example uses this variant:

		```haxe
		var label = new Label();
		label.variant = Label.VARIANT_DANGER;
		```

		@see `feathers.style.IVariantStyleObject.variant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.1.0
	**/
	public static final VARIANT_DANGER = "danger";

	/**
		Creates a new `Label` object.

		@since 1.0.0
	**/
	public function new(text:String = "") {
		initializeLabelTheme();

		super();

		this.text = text;

		this.tabEnabled = false;
		this.tabChildren = false;

		this.addEventListener(FocusEvent.FOCUS_IN, label_focusInHandler);
	}

	private var textField:TextField;
	private var _previousText:String = null;
	private var _previousHTMLText:String = null;
	private var _previousTextFormat:TextFormat = null;
	private var _previousSimpleTextFormat:openfl.text.TextFormat = null;
	private var _updatedTextStyles = false;
	private var _textMeasuredWidth:Float;
	private var _textMeasuredHeight:Float;
	private var _wrappedOnMeasure:Bool = false;
	private var _text:String;

	/**
		The text displayed by the label.

		The following example sets the label's text:

		```haxe
		label.text = "Good afternoon!";
		```

		Note: If the `htmlText` property is not `null`, the `text` property will
		be ignored.

		@default ""

		@see `Label.htmlText`
		@see `Label.textFormat`

		@since 1.0.0
	**/
	public var text(get, set):String;

	private function get_text():String {
		return this._text;
	}

	private function set_text(value:String):String {
		if (value == null) {
			// null gets converted to an empty string
			if (this._text.length == 0) {
				// already an empty string
				return this._text;
			}
			value = "";
		}
		if (this._text == value) {
			return this._text;
		}
		this._text = value;
		this.setInvalid(DATA);
		return this._text;
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
		if (!hasText && !hasHTMLText) {
			this.textField.text = "\u200b";
			var result = this.textField.y + this.textField.getLineMetrics(0).ascent;
			this.textField.text = "";
			return result;
		}
		return this.textField.y + this.textField.getLineMetrics(0).ascent;
	}

	private var _htmlText:String = null;

	/**
		Text displayed by the label that is parsed as a simple form of HTML.

		The following example sets the label's HTML text:

		```haxe
		label.htmlText = "<b>Hello</b> <i>World</i>";
		```

		@default null

		@see `Label.text`
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
		The font styles used to render the label's text.

		In the following example, the label's text formatting is customized:

		```haxe
		label.textFormat = new TextFormat("Helvetica", 20, 0xcc0000);
		```

		@see `Label.text`
		@see `Label.disabledTextFormat`
		@see `Label.embedFonts`

		@since 1.0.0
	**/
	@:style
	public var textFormat:AbstractTextFormat = null;

	#if (openfl >= "9.2.0" || flash)
	/**
		A custom stylesheet to use with `htmlText`.

		If the `styleSheet` style is not `null`, the `textFormat` style will
		be ignored.

		@see `Label.htmlText`

		@since 1.0.0
	**/
	@:style
	public var styleSheet:StyleSheet = null;
	#end

	/**
		Determines if an embedded font is used or not.

		In the following example, the label uses embedded fonts:

		```haxe
		label.embedFonts = true;
		```

		@see `Label.textFormat`

		@since 1.0.0
	**/
	@:style
	public var embedFonts:Bool = false;

	private var _selectable:Bool = false;

	/**
		Indicates if the label's text may be selected or not.

		In the following example, the label text is selectable:

		```haxe
		label.selectable = true;
		```

		@since 1.0.0
	**/
	public var selectable(get, set):Bool;

	private function get_selectable():Bool {
		return this._selectable;
	}

	private function set_selectable(value:Bool):Bool {
		if (this._selectable == value) {
			return this._selectable;
		}
		this._selectable = value;
		this.setInvalid(SELECTION);
		return this._selectable;
	}

	#if (flash && haxe_ver < 4.3) @:getter(tabEnabled) #end
	override private function get_tabEnabled():Bool {
		return this._selectable && this._enabled && this.rawTabEnabled;
	}

	@:dox(hide)
	public var stageFocusTarget(get, never):InteractiveObject;

	private function get_stageFocusTarget():InteractiveObject {
		return this.textField;
	}

	/**
		The start index of the selection.

		If `selectable` is `false`, returns `-1`.

		@since 1.0.0
	**/
	public var selectionBeginIndex(get, never):Int;

	private function get_selectionBeginIndex():Int {
		if (!this._selectable) {
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
	public var selectionEndIndex(get, never):Int;

	private function get_selectionEndIndex():Int {
		if (!this._selectable) {
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

		```haxe
		label.enabled = false;
		label.disabledTextFormat = new TextFormat("Helvetica", 20, 0xee0000);
		```

		@see `Label.textFormat`

		@since 1.0.0
	**/
	@:style
	public var disabledTextFormat:AbstractTextFormat = null;

	/**
		The minimum space, in pixels, between the label's top edge and the
		label's content.

		In the following example, the label's top padding is set to 20 pixels:

		```haxe
		label.paddingTop = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:style
	public var paddingTop:Float = 0.0;

	/**
		The minimum space, in pixels, between the label's right edge and the
		label's content.

		In the following example, the label's right padding is set to 20
		pixels:

		```haxe
		label.paddingRight = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:style
	public var paddingRight:Float = 0.0;

	/**
		The minimum space, in pixels, between the label's bottom edge and the
		label's content.

		In the following example, the label's bottom padding is set to 20
		pixels:

		```haxe
		label.paddingBottom = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:style
	public var paddingBottom:Float = 0.0;

	/**
		The minimum space, in pixels, between the label's left edge and the
		label's content.

		In the following example, the label's left padding is set to 20
		pixels:

		```haxe
		label.paddingLeft = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:style
	public var paddingLeft:Float = 0.0;

	/**
		How the content is positioned vertically (along the y-axis) within the
		label.

		The following example aligns the label's content to the top:

		```haxe
		label.verticalAlign = TOP;
		```

		**Note:** The `VerticalAlign.JUSTIFY` constant is not supported by this
		component.

		@see `feathers.layout.VerticalAlign.TOP`
		@see `feathers.layout.VerticalAlign.MIDDLE`
		@see `feathers.layout.VerticalAlign.BOTTOM`

		@since 1.0.0
	**/
	@:style
	public var verticalAlign:VerticalAlign = TOP;

	/**
		Determines if the text is displayed on a single line, or if it wraps.

		In the following example, the label's text wraps at 150 pixels:

		```haxe
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

		```haxe
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

		```haxe
		label.disabledBackgroundSkin = new Bitmap(bitmapData);
		label.enabled = false;
		```

		@default null

		@see `Label.backgroundSkin`

		@since 1.0.0
	**/
	@:style
	public var disabledBackgroundSkin:DisplayObject = null;

	/**
		Sets all four padding properties to the same value.

		@see `Label.paddingTop`
		@see `Label.paddingRight`
		@see `Label.paddingBottom`
		@see `Label.paddingLeft`

		@since 1.0.0
	**/
	public function setPadding(value:Float):Void {
		this.paddingTop = value;
		this.paddingRight = value;
		this.paddingBottom = value;
		this.paddingLeft = value;
	}

	private function initializeLabelTheme():Void {
		#if !feathersui_disable_default_theme
		feathers.themes.steel.components.SteelLabelStyles.initialize();
		#end
	}

	override private function initialize():Void {
		super.initialize();
		if (this.textField == null) {
			this.textField = new TextField();
			this.textField.multiline = true;
			this.addChild(this.textField);
		}
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(DATA);
		var selectionInvalid = this.isInvalid(SELECTION);
		var sizeInvalid = this.isInvalid(SIZE);
		var stateInvalid = this.isInvalid(STATE);
		var stylesInvalid = this.isInvalid(STYLES);

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
		if ((this._currentBackgroundSkin is IMeasureObject)) {
			measureSkin = cast this._currentBackgroundSkin;
		}

		if ((this._currentBackgroundSkin is IValidating)) {
			(cast this._currentBackgroundSkin : IValidating).validateNow();
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
			} else if (this._backgroundSkinMeasurements != null && this._backgroundSkinMeasurements.minWidth != null) {
				newMinWidth = Math.max(this._backgroundSkinMeasurements.minWidth, newMinWidth);
			}
		}

		var newMinHeight = this.explicitMinHeight;
		if (needsMinHeight) {
			newMinHeight = this._textMeasuredHeight + this.paddingTop + this.paddingBottom;
			if (measureSkin != null) {
				newMinHeight = Math.max(measureSkin.minHeight, newMinHeight);
			} else if (this._backgroundSkinMeasurements != null && this._backgroundSkinMeasurements.minHeight != null) {
				newMinHeight = Math.max(this._backgroundSkinMeasurements.minHeight, newMinHeight);
			}
		}
		var newMaxWidth = this.explicitMaxWidth;
		if (needsMaxWidth) {
			if (measureSkin != null) {
				newMaxWidth = measureSkin.maxWidth;
			} else if (this._backgroundSkinMeasurements != null && this._backgroundSkinMeasurements.maxWidth != null) {
				newMaxWidth = this._backgroundSkinMeasurements.maxWidth;
			} else {
				newMaxWidth = 1.0 / 0.0; // Math.POSITIVE_INFINITY bug workaround for swf
			}
		}

		var newMaxHeight = this.explicitMaxHeight;
		if (needsMaxHeight) {
			if (measureSkin != null) {
				newMaxHeight = measureSkin.maxHeight;
			} else if (this._backgroundSkinMeasurements != null && this._backgroundSkinMeasurements.maxHeight != null) {
				newMaxHeight = this._backgroundSkinMeasurements.maxHeight;
			} else {
				newMaxHeight = 1.0 / 0.0; // Math.POSITIVE_INFINITY bug workaround for swf
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
			this._previousTextFormat.removeEventListener(Event.CHANGE, label_textFormat_changeHandler);
		}
		// clear the selection before setting defaultTextFormat because any
		// selection seems to prevent the defaultTextFormat from fully applying
		if (this.textField.caretIndex != -1 && this.textField.selectionBeginIndex != this.textField.selectionEndIndex) {
			// check for caretIndex != -1 first due to a bug in OpenFL
			this.textField.setSelection(0, 0);
		}
		if (textFormat != null) {
			textFormat.addEventListener(Event.CHANGE, label_textFormat_changeHandler, false, 0, true);
			this.textField.defaultTextFormat = simpleTextFormat;
			this._updatedTextStyles = true;
		}
		this._previousTextFormat = textFormat;
		this._previousSimpleTextFormat = simpleTextFormat;
	}

	private function refreshText(forceMeasurement:Bool):Void {
		// usually, hasText doesn't check the length, but TextField height may
		// not be accurate with an empty string
		var hasText = this._text != null && this._text.length > 0;
		var hasHTMLText = this._htmlText != null && this._htmlText.length > 0;
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
		if (textFieldExplicitWidth < 0.0) {
			// flash may sometimes render a TextField with negative width
			// so make sure it is never smaller than 0.0
			textFieldExplicitWidth = 0.0;
		}
		return textFieldExplicitWidth;
	}

	private function refreshSelection():Void {
		var selectable = this._selectable && this._enabled;
		if (this.textField.selectable != selectable) {
			this.textField.selectable = selectable;
		}
	}

	private function getCurrentTextFormat():TextFormat {
		#if (openfl >= "9.2.0" || flash)
		if (this.styleSheet != null) {
			// TextField won't let us use TextFormat if we have a StyleSheet
			return null;
		}
		#end
		if (!this._enabled && this.disabledTextFormat != null) {
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

	private function layoutContent() {
		this.layoutBackgroundSkin();

		var textFieldLayoutWidth = this.actualWidth - this.paddingLeft - this.paddingRight;
		if (textFieldLayoutWidth < 0.0) {
			// flash may sometimes render a TextField with negative width
			// so make sure it is never smaller than 0.0
			textFieldLayoutWidth = 0.0;
		}
		this.textField.x = this.paddingLeft;
		this.textField.width = textFieldLayoutWidth;
		var wordWrap = this.wordWrap;
		if (wordWrap && !this._wrappedOnMeasure && textFieldLayoutWidth >= this._textMeasuredWidth) {
			// sometimes, using the width measured with wrapping disabled
			// will still cause the final rendered result to wrap, but we
			// can skip wrapping forcefully as a workaround
			// this happens with the flash target sometimes
			wordWrap = false;
		}
		if (this.textField.wordWrap != wordWrap) {
			this.textField.wordWrap = wordWrap;
		}

		var textFieldHeight = this._textMeasuredHeight;
		var maxHeight = this.actualHeight - this.paddingTop - this.paddingBottom;
		if (textFieldHeight > maxHeight) {
			textFieldHeight = maxHeight;
		}
		if (textFieldHeight < 0.0) {
			textFieldHeight = 0.0;
		}
		this.textField.height = textFieldHeight;

		// performance: use the textFieldHeight variable instead of calling the
		// TextField height getter, which can trigger a text engine reflow
		switch (this.verticalAlign) {
			case TOP:
				this.textField.y = this.paddingTop;
			case BOTTOM:
				this.textField.y = this.actualHeight - this.paddingBottom - textFieldHeight;
			default: // middle or null
				this.textField.y = this.paddingTop + (maxHeight - textFieldHeight) / 2.0;
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

	private function label_focusInHandler(event:FocusEvent):Void {
		if (this.stage != null && this.stage.focus != this.textField) {
			event.stopImmediatePropagation();
			this.stage.focus = this.textField;
		}
	}

	private function label_textFormat_changeHandler(event:Event):Void {
		this.setInvalid(STYLES);
	}
}
