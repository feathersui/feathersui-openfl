/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.core.FeathersControl;
import feathers.core.IMeasureObject;
import feathers.core.ITextControl;
import feathers.core.IUIControl;
import feathers.core.IValidating;
import feathers.layout.Measurements;
import feathers.layout.VerticalAlign;
import feathers.skins.IProgrammaticSkin;
import feathers.text.TextFormat;
import feathers.themes.steel.components.SteelHeaderStyles;
import feathers.utils.MeasurementsUtil;
import openfl.display.DisplayObject;
import openfl.events.Event;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;

/**
	A header that displays a title in the center, and optional views on the left
	and right.

	In the following example, a header is created, given a title, and a back
	button:

	```hx
	var header = new Header();
	header.text = "I'm a header";

	var backButton = new Button();
	backButton.text = "Back";
	backButton.addEventListener(TriggerEvent.TRIGGER, (event) -> {
		trace("back button triggered!");
	});
	header.leftView = backButton;
	this.addChild(header);
	```

	@see [Tutorial: How to use the Header component](https://feathersui.com/learn/haxe-openfl/header/)

	@since 1.0.0
**/
class Header extends FeathersControl implements ITextControl {
	/**
		Creates a new `Header` object.

		@since 1.0.0
	**/
	public function new(text:String = "") {
		initializeHeaderTheme();

		super();

		this.text = text;
	}

	private var textField:TextField;
	private var _previousText:String = null;
	private var _previousHTMLText:String = null;
	private var _previousTextFormat:TextFormat = null;
	private var _previousSimpleTextFormat:openfl.text.TextFormat = null;
	private var _updatedTextStyles = false;
	private var _textMeasuredWidth:Float;
	private var _textMeasuredHeight:Float;
	private var _text:String;

	/**
		The text displayed by the header.

		The following example sets the header's text:

		```hx
		header.text = "Good afternoon!";
		```

		Note: If the `htmlText` property is not `null`, the `text` property will
		be ignored.

		@default ""

		@see `Header.htmlText`
		@see `Header.textFormat`

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
		return this.textField.y + this.textField.getLineMetrics(0).ascent;
	}

	private var _htmlText:String = null;

	/**
		Text displayed by the header that is parsed as a simple form of HTML.

		The following example sets the header's HTML text:

		```hx
		header.htmlText = "<b>Hello</b> <i>World</i>";
		```

		@default null

		@see `Header.text`
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
		The font styles used to render the header's text.

		In the following example, the header's text formatting is customized:

		```hx
		header.textFormat = new TextFormat("Helvetica", 20, 0xcc0000);
		```

		@see `Header.text`
		@see `Header.disabledTextFormat`
		@see `Header.embedFonts`

		@since 1.0.0
	**/
	@:style
	public var textFormat:AbstractTextFormat = null;

	/**
		Determines if an embedded font is used or not.

		In the following example, the header uses embedded fonts:

		```hx
		header.embedFonts = true;
		```

		@see `Header.textFormat`

		@since 1.0.0
	**/
	@:style
	public var embedFonts:Bool = false;

	/**
		The font styles used to render the header's text when the header is
		disabled.

		In the following example, the header's disabled text formatting is
		customized:

		```hx
		header.enabled = false;
		header.disabledTextFormat = new TextFormat("Helvetica", 20, 0xee0000);
		```

		@see `Header.textFormat`

		@since 1.0.0
	**/
	@:style
	public var disabledTextFormat:AbstractTextFormat = null;

	private var _currentBackgroundSkin:DisplayObject = null;
	private var _backgroundSkinMeasurements:Measurements = null;

	/**
		The default background skin to display behind the header's content.

		The following example passes a bitmap for the header to use as a
		background skin:

		```hx
		header.backgroundSkin = new Bitmap(bitmapData);
		```

		@default null

		@see `Header.disabledBackgroundSkin`

		@since 1.0.0
	**/
	@:style
	public var backgroundSkin:DisplayObject = null;

	/**
		A background skin to display behind the header's content when the header
		is disabled.

		The following example gives the header a disabled background skin:

		```hx
		header.disabledBackgroundSkin = new Bitmap(bitmapData);
		header.enabled = false;
		```

		@default null

		@see `Header.backgroundSkin`

		@since 1.0.0
	**/
	@:style
	public var disabledBackgroundSkin:DisplayObject = null;

	/**
		The minimum space, in pixels, between the header's top edge and the
		header's content.

		In the following example, the header's top padding is set to 20 pixels:

		```hx
		header.paddingTop = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:style
	public var paddingTop:Float = 0.0;

	/**
		The minimum space, in pixels, between the header's right edge and the
		header's content.

		In the following example, the header's right padding is set to 20
		pixels:

		```hx
		header.paddingRight = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:style
	public var paddingRight:Float = 0.0;

	/**
		The minimum space, in pixels, between the header's bottom edge and the
		header's content.

		In the following example, the header's bottom padding is set to 20
		pixels:

		```hx
		header.paddingBottom = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:style
	public var paddingBottom:Float = 0.0;

	/**
		The minimum space, in pixels, between the header's left edge and the
		header's content.

		In the following example, the header's left padding is set to 20
		pixels:

		```hx
		header.paddingLeft = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:style
	public var paddingLeft:Float = 0.0;

	/**
		The space between the header's title and its left and right views must
		not be smaller than the value of the `minGap` property.

		The following example ensures that the gap is never smaller than 20
		pixels:

		```hx
		header.minGap = 20.0;
		```

		@since 1.0.0
	**/
	@:style
	public var minGap:Float = 0.0;

	/**
		How the content is positioned vertically (along the y-axis) within the
		header.

		The following example aligns the header's content to the top:

		```hx
		header.verticalAlign = TOP;
		```

		**Note:** The `VerticalAlign.JUSTIFY` constant is not supported by this
		component.

		@see `feathers.layout.VerticalAlign.TOP`
		@see `feathers.layout.VerticalAlign.MIDDLE`
		@see `feathers.layout.VerticalAlign.BOTTOM`
	**/
	@:style
	public var verticalAlign:VerticalAlign = MIDDLE;

	private var _ignoreLeftViewResize:Bool = false;

	private var _leftView:DisplayObject = null;

	/**
		The view to display on the left side of the header. To display multiple
		views, create a `LayoutGroup` and add the views as children.

		@since 1.0.0
	**/
	public var leftView(get, set):DisplayObject;

	private function get_leftView():DisplayObject {
		return this._leftView;
	}

	private function set_leftView(value:DisplayObject):DisplayObject {
		if (this._leftView == value) {
			return this._leftView;
		}
		if (this._leftView != null) {
			this._leftView.removeEventListener(Event.RESIZE, header_leftView_resizeHandler);
			if (this._leftView.parent == this) {
				this.removeChild(this._leftView);
			}
		}
		this._leftView = value;
		if (this._leftView != null) {
			this.addChild(this._leftView);
			this._leftView.addEventListener(Event.RESIZE, header_leftView_resizeHandler, false, 0, true);
		}
		this.setInvalid(LAYOUT);
		return this._leftView;
	}

	private var _ignoreRightViewResize:Bool = false;

	private var _rightView:DisplayObject = null;

	/**
		The view to display on the right side of the header. To display multiple
		views, create a `LayoutGroup` and add the views as children.

		@since 1.0.0
	**/
	public var rightView(get, set):DisplayObject;

	private function get_rightView():DisplayObject {
		return this._rightView;
	}

	private function set_rightView(value:DisplayObject):DisplayObject {
		if (this._rightView == value) {
			return this._rightView;
		}
		if (this._rightView != null) {
			this._rightView.removeEventListener(Event.RESIZE, header_rightView_resizeHandler);
			if (this._rightView.parent == this) {
				this.removeChild(this._rightView);
			}
		}
		this._rightView = value;
		if (this._rightView != null) {
			this.addChild(this._rightView);
			this._rightView.addEventListener(Event.RESIZE, header_rightView_resizeHandler, false, 0, true);
		}
		this.setInvalid(LAYOUT);
		return this._rightView;
	}

	private function initializeHeaderTheme():Void {
		SteelHeaderStyles.initialize();
	}

	override private function initialize():Void {
		super.initialize();
		if (this.textField == null) {
			this.textField = new TextField();
			this.textField.multiline = true;
			this.textField.selectable = false;
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

		var oldIgnoreLeftViewResize = this._ignoreLeftViewResize;
		this._ignoreLeftViewResize = true;
		var oldIgnoreRightViewResize = this._ignoreRightViewResize;
		this._ignoreRightViewResize = true;

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

		if ((this._leftView is IValidating)) {
			cast(this._leftView, IValidating).validateNow();
		}

		if ((this._rightView is IValidating)) {
			cast(this._rightView, IValidating).validateNow();
		}

		var newWidth = this.explicitWidth;
		if (needsWidth) {
			newWidth = this._textMeasuredWidth + this.paddingLeft + this.paddingRight;
			if (this._leftView != null) {
				newWidth += this._leftView.width + this.minGap;
			}
			if (this._rightView != null) {
				newWidth += this._rightView.width + this.minGap;
			}
			if (this._currentBackgroundSkin != null) {
				newWidth = Math.max(this._currentBackgroundSkin.width, newWidth);
			}
		}

		var newHeight = this.explicitHeight;
		if (needsHeight) {
			newHeight = this._textMeasuredHeight;
			if (this._leftView != null) {
				newHeight = Math.max(newHeight, this._leftView.height);
			}
			if (this._rightView != null) {
				newHeight = Math.max(newHeight, this._rightView.height);
			}
			newHeight += this.paddingTop + this.paddingBottom;
			if (this._currentBackgroundSkin != null) {
				newHeight = Math.max(this._currentBackgroundSkin.height, newHeight);
			}
		}

		var newMinWidth = this.explicitMinWidth;
		if (needsMinWidth) {
			newMinWidth = this._textMeasuredWidth + this.paddingLeft + this.paddingRight;
			if (this._leftView != null) {
				newMinWidth += this._leftView.width + this.minGap;
			}
			if (this._rightView != null) {
				newMinWidth += this._rightView.width + this.minGap;
			}
			if (measureSkin != null) {
				newMinWidth = Math.max(measureSkin.minWidth, newMinWidth);
			} else if (this._backgroundSkinMeasurements != null) {
				newMinWidth = Math.max(this._backgroundSkinMeasurements.minWidth, newMinWidth);
			}
		}

		var newMinHeight = this.explicitMinHeight;
		if (needsMinHeight) {
			newMinHeight = this._textMeasuredHeight;
			if (this._leftView != null) {
				newMinHeight = Math.max(newMinHeight, this._leftView.height);
			}
			if (this._rightView != null) {
				newMinHeight = Math.max(newMinHeight, this._rightView.height);
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

		this._ignoreLeftViewResize = oldIgnoreLeftViewResize;
		this._ignoreRightViewResize = oldIgnoreRightViewResize;

		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight, newMaxWidth, newMaxHeight);
	}

	private function refreshTextStyles():Void {
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
			this._previousTextFormat.removeEventListener(Event.CHANGE, header_textFormat_changeHandler);
		}
		if (textFormat != null) {
			textFormat.addEventListener(Event.CHANGE, header_textFormat_changeHandler, false, 0, true);
			this.textField.defaultTextFormat = simpleTextFormat;
			this._updatedTextStyles = true;
		}
		this._previousTextFormat = textFormat;
		this._previousSimpleTextFormat = simpleTextFormat;
	}

	private function refreshText(forceMeasurement:Bool):Void {
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
			this.textField.text = "\u200b"; // zero-width space
		}
		var textFieldWidth:Null<Float> = null;
		if (this.explicitWidth != null) {
			textFieldWidth = this.explicitWidth;
		} else if (this.explicitMaxWidth != null) {
			textFieldWidth = this.explicitMaxWidth;
		}
		if (textFieldWidth != null) {
			this.textField.width = textFieldWidth;
		}
		this._textMeasuredWidth = this.textField.width;
		this._textMeasuredHeight = this.textField.height;
		this.textField.autoSize = NONE;
		if (!hasText && !hasHTMLText) {
			this.textField.text = "";
		}
		this._previousText = this._text;
		this._previousHTMLText = this._htmlText;
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
		if ((skin is IUIControl)) {
			cast(skin, IUIControl).initializeNow();
		}
		if (this._backgroundSkinMeasurements == null) {
			this._backgroundSkinMeasurements = new Measurements(skin);
		} else {
			this._backgroundSkinMeasurements.save(skin);
		}
		if ((skin is IProgrammaticSkin)) {
			cast(skin, IProgrammaticSkin).uiContext = this;
		}
		this.addChildAt(skin, 0);
	}

	private function removeCurrentBackgroundSkin(skin:DisplayObject):Void {
		if (skin == null) {
			return;
		}
		if ((skin is IProgrammaticSkin)) {
			cast(skin, IProgrammaticSkin).uiContext = null;
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

		var textFieldMinX = this.paddingLeft;
		var textFieldMaxX = this.actualWidth - this.paddingRight;
		var maxContentWidth = this.actualWidth - this.paddingLeft - this.paddingRight;
		var maxContentHeight = this.actualHeight - this.paddingTop - this.paddingBottom;
		var textFieldMaxWidth = maxContentWidth;

		if (this._leftView != null) {
			if ((this._leftView is IValidating)) {
				cast(this._leftView, IValidating).validateNow();
			}
			this._leftView.x = this.paddingLeft;
			switch (this.verticalAlign) {
				case TOP:
					this._leftView.y = this.paddingTop;
				case BOTTOM:
					this._leftView.y = this.actualHeight - this.paddingBottom - this._leftView.height;
				default: // middle or null
					this._leftView.y = this.paddingTop + (maxContentHeight - this._leftView.height) / 2.0;
			}
			textFieldMaxWidth -= (this._leftView.width + this.minGap);
			textFieldMinX = this._leftView.x + this._leftView.width + this.minGap;
		}

		if (this._rightView != null) {
			if ((this._rightView is IValidating)) {
				cast(this._rightView, IValidating).validateNow();
			}
			this._rightView.x = this.actualWidth - this.paddingRight - this._rightView.width;
			switch (this.verticalAlign) {
				case TOP:
					this._rightView.y = this.paddingTop;
				case BOTTOM:
					this._rightView.y = this.actualHeight - this.paddingBottom - this._rightView.height;
				default: // middle or null
					this._rightView.y = this.paddingTop + (maxContentHeight - this._rightView.height) / 2.0;
			}
			textFieldMaxWidth -= (this._rightView.width + this.minGap);
			textFieldMaxX = this._rightView.x - this.minGap;
		}

		var textFieldWidth = this._textMeasuredWidth;
		if (textFieldWidth > textFieldMaxWidth) {
			textFieldWidth = textFieldMaxWidth;
		}
		this.textField.width = textFieldWidth;
		textFieldMaxX -= textFieldWidth;

		var textFieldHeight = this._textMeasuredHeight;
		if (textFieldHeight > maxContentHeight) {
			textFieldHeight = maxContentHeight;
		}
		this.textField.height = textFieldHeight;

		// ideally, the TextField will be positioned in the exact center of
		// the header. we'll move it left or right if the side views are large.
		// this is how native iOS headers work, when centered
		var textFieldX = this.paddingLeft + (maxContentWidth - textFieldWidth) / 2.0;
		if (textFieldX < textFieldMinX) {
			textFieldX = textFieldMinX;
		} else if (textFieldX > textFieldMaxX) {
			textFieldX = textFieldMaxX;
		}
		this.textField.x = textFieldX;

		// performance: use the textFieldHeight variable instead of calling the
		// TextField height getter, which can trigger a text engine reflow
		switch (this.verticalAlign) {
			case TOP:
				this.textField.y = this.paddingTop;
			case BOTTOM:
				this.textField.y = this.actualHeight - this.paddingBottom - textFieldHeight;
			default: // middle or null
				this.textField.y = this.paddingTop + (maxContentHeight - textFieldHeight) / 2.0;
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
			cast(this._currentBackgroundSkin, IValidating).validateNow();
		}
	}

	private function header_textFormat_changeHandler(event:Event):Void {
		this.setInvalid(STYLES);
	}

	private function header_leftView_resizeHandler(event:Event):Void {
		if (this._ignoreLeftViewResize) {
			return;
		}
		this.setInvalid(LAYOUT);
	}

	private function header_rightView_resizeHandler(event:Event):Void {
		if (this._ignoreRightViewResize) {
			return;
		}
		this.setInvalid(LAYOUT);
	}
}
