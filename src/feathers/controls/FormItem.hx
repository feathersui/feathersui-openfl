/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.core.FeathersControl;
import feathers.core.IFocusManagerAware;
import feathers.core.IFocusObject;
import feathers.core.IMeasureObject;
import feathers.core.ITextControl;
import feathers.core.IUIControl;
import feathers.core.IValidating;
import feathers.layout.HorizontalAlign;
import feathers.layout.Measurements;
import feathers.layout.RelativePosition;
import feathers.layout.VerticalAlign;
import feathers.skins.IProgrammaticSkin;
import feathers.text.TextFormat;
import feathers.themes.steel.components.SteelFormItemStyles;
import feathers.utils.MeasurementsUtil;
import openfl.display.DisplayObject;
import openfl.errors.ArgumentError;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.text.TextField;

/**
	Displays text next to a control in a form.

	@since 1.0.0
**/
@:meta(DefaultProperty("content"))
@defaultXmlProperty("content")
@:styleContext
class FormItem extends FeathersControl implements ITextControl implements IFocusManagerAware {
	/**
		Creates a new `FormItem` object.

		@since 1.0.0
	**/
	public function new() {
		initializeFormItemTheme();
		super();
	}

	private var textField:TextField;
	private var _previousText:String = null;
	private var _previousTextFormat:TextFormat = null;
	private var _previousSimpleTextFormat:openfl.text.TextFormat = null;
	private var _updatedTextStyles = false;
	private var _textMeasuredWidth:Float;
	private var _textMeasuredHeight:Float;
	private var _text:String = "";

	/**
		The text displayed by the form item.

		The following example sets the form item's text:

		```hx
		formItem.text = "Address";
		```

		@default ""

		@see `FormItem.textFormat`

		@since 1.0.0
	**/
	@:flash.property
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
	@:flash.property
	public var baseline(get, never):Float;

	private function get_baseline():Float {
		if (this.textField == null) {
			return 0.0;
		}
		var textFieldBaseline = this.textField.y + this.textField.getLineMetrics(0).ascent;
		var contentBaseline = 0.0;
		if (Std.is(this._currentContent, ITextControl)) {
			contentBaseline = this._currentContent.y + cast(this._currentContent, ITextControl).baseline;
		}
		return Math.max(textFieldBaseline, contentBaseline);
	}

	private var _contentMeasurements:Measurements = null;
	private var _currentContent:DisplayObject = null;

	private var _content:DisplayObject = null;

	/**
		The content displayed by the form item.

		The following example sets the form item's content:

		```hx
		var nameInput = new TextInput();
		nameInput.prompt = "First and last name";
		formItem.content = nameInput;
		```

		@see `FormItem.text`

		@since 1.0.0
	**/
	@:flash.property
	public var content(get, set):DisplayObject;

	private function get_content():DisplayObject {
		return this._content;
	}

	private function set_content(value:DisplayObject):DisplayObject {
		if (this._content == value) {
			return this._content;
		}
		this._content = value;
		this.setInvalid(DATA);
		return this._content;
	}

	private var _selectable:Bool = false;

	/**
		Indicates if the form item's text may be selected or not.

		In the following example, the form item's text is selectable:

		```hx
		formItem.selectable = true;
		```

		@since 1.0.0
	**/
	@:flash.property
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

	/**
		The start index of the selection.

		If `selectable` is `false`, returns `-1`.

		@since 1.0.0
	**/
	@:flash.property
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
	@:flash.property
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
		The font styles used to render the form item's text.

		In the following example, the form item's text formatting is customized:

		```hx
		formItem.textFormat = new TextFormat("Helvetica", 20, 0xcc0000);
		```

		@see `FormItem.text`
		@see `FormItem.disabledTextFormat`
		@see `FormItem.embedFonts`

		@since 1.0.0
	**/
	@:style
	public var textFormat:AbstractTextFormat = null;

	/**
		The font styles used to render the form item's text when the form item
		is disabled.

		In the following example, the form item's disabled text formatting is
		customized:

		```hx
		formItem.enabled = false;
		formItem.disabledTextFormat = new TextFormat("Helvetica", 20, 0xee0000);
		```

		@see `FormItem.textFormat`

		@since 1.0.0
	**/
	@:style
	public var disabledTextFormat:AbstractTextFormat = null;

	/**
		Determines if an embedded font is used or not.

		In the following example, the form item uses embedded fonts:

		```hx
		formItem.embedFonts = true;
		```

		@see `FormItem.textFormat`

		@since 1.0.0
	**/
	@:style
	public var embedFonts:Bool = false;

	/**
		The minimum space, in pixels, between the form item's top edge and the
		form item's content.

		In the following example, the form item's top padding is set to 20
		pixels:

		```hx
		formItem.paddingTop = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:style
	public var paddingTop:Float = 0.0;

	/**
		The minimum space, in pixels, between the form item's right edge and the
		form item's content.

		In the following example, the form item's right padding is set to 20
		pixels:

		```hx
		formItem.paddingRight = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:style
	public var paddingRight:Float = 0.0;

	/**
		The minimum space, in pixels, between the form item's bottom edge and
		the form item's content.

		In the following example, the form item's bottom padding is set to 20
		pixels:

		```hx
		formItem.paddingBottom = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:style
	public var paddingBottom:Float = 0.0;

	/**
		The minimum space, in pixels, between the form item's left edge and the
		form item's content.

		In the following example, the form item's left padding is set to 20
		pixels:

		```hx
		formItem.paddingLeft = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:style
	public var paddingLeft:Float = 0.0;

	/**
		The space, measured in pixels, between the form item's text and its
		content. Applies to either horizontal or vertical spacing, depending on
		the value of `textPosition`.

		The following example creates a gap of 20 pixels between the text and
		the content:

		```hx
		formItem.text = "Name";
		formItem.content = new TextInput();
		formItem.gap = 20.0;
		```

		@since 1.0.0
	**/
	@:style
	public var gap:Float = 0.0;

	/**
		How the `content` is positioned horizontally (along the x-axis) within
		the available space next to the form item's text.

		The following example aligns the form item's content to the right:

		```hx
		formItem.verticalAlign = RIGHT;
		```

		@see `feathers.layout.HorizontalAlign.LEFT`
		@see `feathers.layout.HorizontalAlign.CENTER`
		@see `feathers.layout.HorizontalAlign.RIGHT`
		@see `feathers.layout.HorizontalAlign.JUSTIFY`

		@since 1.0.0
	**/
	@:style
	public var horizontalAlign:HorizontalAlign = LEFT;

	/**
		How the `content` is positioned vertically (along the y-axis) within the
		available space next to the form item's text.

		The following example aligns the form item's content to the bottom:

		```hx
		formItem.verticalAlign = BOTTOM;
		```

		@see `feathers.layout.VerticalAlign.TOP`
		@see `feathers.layout.VerticalAlign.MIDDLE`
		@see `feathers.layout.VerticalAlign.BOTTOM`
		@see `feathers.layout.VerticalAlign.JUSTIFY`

		@since 1.0.0
	**/
	@:style
	public var verticalAlign:VerticalAlign = TOP;

	/**
		Determines if the text is displayed on a single line, or if it wraps.

		In the following example, the form item's text wraps:

		```hx
		formItem.wordWrap = true;
		```

		@default false

		@since 1.0.0
	**/
	@:style
	public var wordWrap:Bool = false;

	private var _customTextWidth:Null<Float> = null;

	private var customTextWidth(get, set):Null<Float>;

	private function get_customTextWidth():Null<Float> {
		return this._customTextWidth;
	}

	private function set_customTextWidth(value:Null<Float>):Null<Float> {
		if (this._customTextWidth == value) {
			return this._customTextWidth;
		}
		this._customTextWidth = value;
		this.setInvalid(SIZE);
		return this._customTextWidth;
	}

	private var _currentBackgroundSkin:DisplayObject = null;
	private var _backgroundSkinMeasurements:Measurements = null;

	/**
		The default background skin to display behind the form item's content.

		The following example passes a bitmap for the form item to use as a
		background skin:

		```hx
		formItem.backgroundSkin = new Bitmap(bitmapData);
		```

		@default null

		@see `FormItem.disabledBackgroundSkin`

		@since 1.0.0
	**/
	@:style
	public var backgroundSkin:DisplayObject = null;

	/**
		A background skin to display behind the form item's content when the
		form item is disabled.

		The following example gives the form item a disabled background skin:

		```hx
		formItem.disabledBackgroundSkin = new Bitmap(bitmapData);
		formItem.enabled = false;
		```

		@default null

		@see `FormItem.backgroundSkin`

		@since 1.0.0
	**/
	@:style
	public var disabledBackgroundSkin:DisplayObject = null;

	/**
		The location of the form item's text, relative to its content.

		The following example positions the text to the left of the text:

		```hx
		formItem.text = "Click Me";
		formItem.content = new TextInput();
		formItem.textPosition = LEFT;
		```

		@see `FormItem.text`

		@since 1.0.0
	**/
	@:style
	public var textPosition:RelativePosition = TOP;

	public function getTextMeasuredWidth():Float {
		return this._textMeasuredWidth;
	}

	/**
		Sets all four padding properties to the same value.

		@see `FormItem.paddingTop`
		@see `FormItem.paddingRight`
		@see `FormItem.paddingBottom`
		@see `FormItem.paddingLeft`

		@since 1.0.0
	**/
	public function setPadding(value:Float):Void {
		this.paddingTop = value;
		this.paddingRight = value;
		this.paddingBottom = value;
		this.paddingLeft = value;
	}

	private function initializeFormItemTheme():Void {
		SteelFormItemStyles.initialize();
	}

	override private function initialize():Void {
		super.initialize();
		if (this.textField == null) {
			this.textField = new TextField();
			this.textField.multiline = true;
			this.addChild(this.textField);
		}
		this.textField.addEventListener(MouseEvent.CLICK, formItem_textField_clickHandler);
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

		if (dataInvalid) {
			this.refreshContent();
		}

		sizeInvalid = this.measure() || sizeInvalid;

		this.layoutContent();
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

		var measureContent:IMeasureObject = null;
		if (Std.is(this._currentContent, IMeasureObject)) {
			measureContent = cast(this._currentContent, IMeasureObject);
		}

		if (Std.is(this._currentContent, IValidating)) {
			cast(this._currentContent, IValidating).validateNow();
		}

		var newWidth = this.explicitWidth;
		if (needsWidth) {
			newWidth = this._textMeasuredWidth;
			if (this._customTextWidth != null && (this.textPosition == LEFT || this.textPosition == RIGHT)) {
				newWidth = this._customTextWidth;
			}
			newWidth += this.paddingLeft + this.paddingRight;
			if (this._currentContent != null) {
				if (this.textPosition == LEFT || this.textPosition == RIGHT) {
					newWidth += this.gap + this._currentContent.width;
				} else {
					newWidth = Math.max(newWidth, this._currentContent.width + this.paddingLeft + this.paddingRight);
				}
			}
			if (this._currentBackgroundSkin != null) {
				newWidth = Math.max(this._currentBackgroundSkin.width, newWidth);
			}
		}

		var newHeight = this.explicitHeight;
		if (needsHeight) {
			newHeight = this._textMeasuredHeight + this.paddingTop + this.paddingBottom;
			if (this._currentContent != null) {
				if (this.textPosition == LEFT || this.textPosition == RIGHT) {
					newHeight = Math.max(newHeight, this._currentContent.height + this.paddingTop + this.paddingBottom);
				} else // TOP or BOTTOM
				{
					newHeight += this.gap + this._currentContent.height;
				}
			}
			if (this._currentBackgroundSkin != null) {
				newHeight = Math.max(this._currentBackgroundSkin.height, newHeight);
			}
		}

		var newMinWidth = this.explicitMinWidth;
		if (needsMinWidth) {
			newMinWidth = this._textMeasuredWidth;
			if (this._customTextWidth != null && (this.textPosition == LEFT || this.textPosition == RIGHT)) {
				newMinWidth = this._customTextWidth;
			}
			newMinWidth += this.paddingLeft + this.paddingRight;
			if (this._currentContent != null) {
				if (this.textPosition == LEFT || this.textPosition == RIGHT) {
					if (measureContent != null) {
						newMinWidth += measureContent.minWidth;
					} else {
						newMinWidth += this._currentContent.width;
					}
					newMinWidth += this.gap;
				} else // TOP or BOTTOM
				{
					if (measureContent != null) {
						newMinWidth = Math.max(newMinWidth, measureContent.minWidth + this.paddingLeft + this.paddingRight);
					} else {
						newMinWidth = Math.max(newMinWidth, this._currentContent.width + this.paddingLeft + this.paddingRight);
					}
				}
			}
			if (measureSkin != null) {
				newMinWidth = Math.max(measureSkin.minWidth, newMinWidth);
			} else if (this._backgroundSkinMeasurements != null) {
				newMinWidth = Math.max(this._backgroundSkinMeasurements.minWidth, newMinWidth);
			}
		}

		var newMinHeight = this.explicitMinHeight;
		if (needsMinHeight) {
			newMinHeight = this._textMeasuredHeight + this.paddingTop + this.paddingBottom;
			if (this._currentContent != null) {
				if (this.textPosition == LEFT || this.textPosition == RIGHT) {
					if (measureContent != null) {
						newMinHeight = Math.max(newMinHeight, measureContent.minHeight);
					} else {
						newMinHeight = Math.max(newMinHeight, this._currentContent.height);
					}
				} else // TOP or BOTTOM
				{
					if (measureContent != null) {
						newMinHeight += measureContent.minHeight;
					} else {
						newMinHeight += this._currentContent.height;
					}
					newMinHeight += this.gap;
				}
			}
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
		var simpleTextFormat = textFormat != null ? textFormat.toSimpleTextFormat() : null;
		if (simpleTextFormat == this._previousSimpleTextFormat) {
			// nothing to refresh
			return;
		}
		if (this._previousTextFormat != null) {
			this._previousTextFormat.removeEventListener(Event.CHANGE, formItem_textFormat_changeHandler);
		}
		if (textFormat != null) {
			textFormat.addEventListener(Event.CHANGE, formItem_textFormat_changeHandler, false, 0, true);
			this.textField.defaultTextFormat = simpleTextFormat;
			this._updatedTextStyles = true;
		}
		this._previousTextFormat = textFormat;
		this._previousSimpleTextFormat = simpleTextFormat;
	}

	private function refreshText(sizeInvalid:Bool):Void {
		var hasText = this._text != null && this._text.length > 0;
		this.textField.visible = hasText;
		if (this._text == this._previousText && !this._updatedTextStyles && !sizeInvalid) {
			// nothing to refresh
			return;
		}
		// set autoSize before text because setting text first can trigger an
		// extra text engine reflow
		this.textField.autoSize = LEFT;
		if (hasText) {
			this.textField.text = this._text;
		} else {
			this.textField.text = "\u200b"; // zero-width space
		}
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
		this.textField.autoSize = NONE;
		if (textFieldWidth == null && this.wordWrap) {
			this.textField.wordWrap = true;
		}
		if (!hasText) {
			this.textField.text = "";
		}
		this._previousText = this._text;
	}

	private function refreshSelection():Void {
		var selectable = this._selectable && this._enabled;
		if (this.textField.selectable != selectable) {
			this.textField.selectable = selectable;
		}
	}

	private function getCurrentTextFormat():TextFormat {
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
		if (Std.is(skin, IUIControl)) {
			cast(skin, IUIControl).initializeNow();
		}
		if (this._backgroundSkinMeasurements == null) {
			this._backgroundSkinMeasurements = new Measurements(skin);
		} else {
			this._backgroundSkinMeasurements.save(skin);
		}
		if (Std.is(skin, IProgrammaticSkin)) {
			cast(skin, IProgrammaticSkin).uiContext = this;
		}
		this.addChildAt(skin, 0);
	}

	private function removeCurrentBackgroundSkin(skin:DisplayObject):Void {
		if (skin == null) {
			return;
		}
		if (Std.is(skin, IProgrammaticSkin)) {
			cast(skin, IProgrammaticSkin).uiContext = null;
		}
		// we need to restore these values so that they won't be lost the
		// next time that this skin is used for measurement
		this._backgroundSkinMeasurements.restore(skin);
		if (skin.parent == this) {
			this.removeChild(skin);
		}
	}

	private function refreshContent():Void {
		var oldContent = this._currentContent;
		this._currentContent = this._content;
		if (this._currentContent == oldContent) {
			return;
		}
		if (oldContent != null) {
			this.removeChild(oldContent);
		}
		if (this._currentContent == null) {
			this._contentMeasurements = null;
			return;
		}
		if (Std.is(this._currentContent, IUIControl)) {
			cast(this._currentContent, IUIControl).initializeNow();
		}
		if (this._contentMeasurements == null) {
			this._contentMeasurements = new Measurements(this._currentContent);
		} else {
			this._contentMeasurements.save(this._currentContent);
		}
		this.addChild(this._currentContent);
	}

	private function layoutContent():Void {
		this.layoutBackgroundSkin();

		var textFieldWidth = this._textMeasuredWidth;
		if (this._customTextWidth != null && (this.textPosition == LEFT || this.textPosition == RIGHT)) {
			textFieldWidth = this._customTextWidth;
		}
		var textFieldHeight = this._textMeasuredHeight;
		var remainingWidth = this.actualWidth - this.paddingLeft - this.paddingRight;
		if (this.textPosition == LEFT || this.textPosition == RIGHT) {
			remainingWidth -= this.gap;
		}
		if (textFieldWidth > remainingWidth) {
			textFieldWidth = remainingWidth;
		}
		var remainingHeight = this.actualHeight - this.paddingTop - this.paddingBottom;
		if (this.textPosition != LEFT && this.textPosition != RIGHT) {
			remainingHeight -= this.gap;
		}
		if (textFieldHeight > remainingHeight) {
			textFieldHeight = remainingHeight;
		}

		switch (this.textPosition) {
			case TOP:
				this.textField.x = this.paddingLeft;
				this.textField.y = this.paddingTop;
				remainingHeight -= textFieldHeight;
			case RIGHT:
				this.textField.x = this.actualWidth - textFieldWidth - this.paddingRight;
				remainingWidth -= textFieldWidth;
			case BOTTOM:
				this.textField.x = this.paddingLeft;
				this.textField.y = this.actualHeight - textFieldHeight - this.paddingBottom;
				remainingHeight -= textFieldHeight;
			case LEFT:
				this.textField.x = this.paddingLeft;
				remainingWidth -= textFieldWidth;
			default:
				throw new ArgumentError("Unknown text position: " + this.textPosition);
		}
		this.textField.width = textFieldWidth;
		this.textField.height = textFieldHeight;

		if (this._currentContent != null) {
			var contentStartX = this.paddingLeft;
			var contentStartY = this.paddingRight;
			switch (this.textPosition) {
				case TOP:
					contentStartY = this.textField.y + textFieldHeight + this.gap;
				case RIGHT:
				case BOTTOM:
				case LEFT:
					contentStartX = this.textField.x + textFieldWidth + this.gap;
				default:
					throw new ArgumentError("Unknown text position: " + this.textPosition);
			}
			if (this._currentContent.width > remainingWidth) {
				this._currentContent.width = remainingWidth;
			}
			if (this._currentContent.height > remainingHeight) {
				this._currentContent.height = remainingHeight;
			}
			switch (this.horizontalAlign) {
				case LEFT:
					this._currentContent.x = contentStartX;
				case CENTER:
					this._currentContent.x = contentStartX + (remainingWidth - this._currentContent.width) / 2.0;
				case RIGHT:
					this._currentContent.x = contentStartX + remainingWidth - this._currentContent.width;
				case JUSTIFY:
					this._currentContent.x = contentStartX;
					this._currentContent.width = remainingWidth;
				default:
					throw new ArgumentError("Unknown horizontal align: " + this.horizontalAlign);
			}
			switch (this.verticalAlign) {
				case TOP:
					this._currentContent.y = contentStartY;
				case MIDDLE:
					this._currentContent.y = contentStartY + (remainingHeight - this._currentContent.height) / 2.0;
				case BOTTOM:
					this._currentContent.y = contentStartY + remainingHeight - this._currentContent.height;
				case JUSTIFY:
					this._currentContent.y = contentStartY;
					this._currentContent.height = remainingHeight;
				default:
					throw new ArgumentError("Unknown vertical align: " + this.verticalAlign);
			}
		}

		if (this.textPosition == LEFT || this.textPosition == RIGHT) {
			var textFieldBaseline = this.textField.getLineMetrics(0).ascent;
			var contentBaseline = textFieldBaseline;
			if (Std.is(this._currentContent, ITextControl)) {
				contentBaseline = cast(this._currentContent, ITextControl).baseline;
			}
			var maxBaseline = Math.max(contentBaseline, textFieldBaseline);

			var startY = (this._currentContent != null) ? this._currentContent.y : this.paddingTop;

			this.textField.y = startY + (maxBaseline - textFieldBaseline);
			if (this._currentContent != null) {
				this._currentContent.y = startY + (maxBaseline - contentBaseline);
			}
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

	private function formItem_textFormat_changeHandler(event:Event):Void {
		this.setInvalid(STYLES);
	}

	private function formItem_textField_clickHandler(event:MouseEvent):Void {
		if (this._focusManager == null) {
			return;
		}
		var newFocus:IFocusObject = null;
		if (Std.is(this._currentContent, IFocusObject)) {
			newFocus = cast(this._currentContent, IFocusObject);
		}
		this._focusManager.focus = newFocus;
	}
}
