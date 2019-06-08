/*
	Feathers
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.core.FeathersControl;
import feathers.core.IMeasureObject;
import feathers.core.InvalidationFlag;
import feathers.core.IStateContext;
import feathers.core.IStateObserver;
import feathers.core.IUIControl;
import feathers.core.IValidating;
import feathers.layout.HorizontalAlign;
import feathers.layout.Measurements;
import feathers.layout.VerticalAlign;
import feathers.style.IStyleObject;
import openfl.display.DisplayObject;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;

/**
	Displays text with an optional background.

	The following example creates a label and gives it text:

	```hx
	var label:Label = new Label();
	label.text = "Hello World";
	this.addChild( label );</listing>
	```

	@see [How to use the Feathers `Label` component](../../../help/label.html)

	@since 1.0.0
**/
class Label extends FeathersControl {
	/**
		Larger text for headings.

		@since 1.0.0
	**/
	public static final VARIANT_HEADING = "heading";

	/**
		Smaller text for details.

		@since 1.0.0
	**/
	public static final VARIANT_DETAIL = "detail";

	public function new() {
		super();
	}

	override private function get_styleContext():Class<IStyleObject> {
		return Label;
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

	private var _currentBackgroundSkin:DisplayObject = null;
	private var _backgroundSkinMeasurements:Measurements = null;

	/**
		The default background skin to display behind the label's text.

		The following example gives the label a background skin:

		```hx
		label.backgroundSkin = new Bitmap(bitmapData);
		```

		@default null

		@see `Label.backgroundDisabledSkin`

		@since 1.0.0
	**/
	@style
	public var backgroundSkin(default, set):DisplayObject = null;

	private function set_backgroundSkin(value:DisplayObject):DisplayObject {
		if (!this.setStyle("backgroundSkin")) {
			return this.backgroundSkin;
		}
		if (this.backgroundSkin == value) {
			return this.backgroundSkin;
		}
		if (this.backgroundSkin != null && this.backgroundSkin == this._currentBackgroundSkin) {
			this.removeCurrentBackgroundSkin(this.backgroundSkin);
			this._currentBackgroundSkin = null;
		}
		this.backgroundSkin = value;
		this.setInvalid(InvalidationFlag.STYLES);
		return this.backgroundSkin;
	}

	/**
		A background skin to display behind the label's text when the label is
		disabled.

		The following example gives the label a disabled background skin:

		```hx
		label.backgroundDisabledSkin = new Bitmap(bitmapData);
		label.enabled = false;
		```

		@default null

		@see `Label.backgroundSkin`

		@since 1.0.0
	**/
	@style
	public var backgroundDisabledSkin(default, set):DisplayObject = null;

	private function set_backgroundDisabledSkin(value:DisplayObject):DisplayObject {
		if (!this.setStyle("backgroundDisabledSkin")) {
			return this.backgroundDisabledSkin;
		}
		if (this.backgroundDisabledSkin == value) {
			return this.backgroundDisabledSkin;
		}
		if (this.backgroundDisabledSkin != null && this.backgroundDisabledSkin == this._currentBackgroundSkin) {
			this.removeCurrentBackgroundSkin(this.backgroundDisabledSkin);
			this._currentBackgroundSkin = null;
		}
		this.backgroundDisabledSkin = value;
		this.setInvalid(InvalidationFlag.STYLES);
		return this.backgroundDisabledSkin;
	}

	override private function initialize():Void {
		super.initialize();
		if (this.textField == null) {
			this.textField = new TextField();
			this.textField.selectable = false;
			this.addChild(this.textField);
		}
	}

	private var _textMeasuredWidth:Float;
	private var _textMeasuredHeight:Float;

	override private function update():Void {
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);
		var stylesInvalid = this.isInvalid(InvalidationFlag.STYLES);
		var stateInvalid = this.isInvalid(InvalidationFlag.STATE);
		var sizeInvalid = this.isInvalid(InvalidationFlag.SIZE);

		if (stylesInvalid || stateInvalid) {
			this.refreshBackgroundSkin();
		}

		if (stylesInvalid || stateInvalid) {
			this.refreshTextStyles();
		}

		if (dataInvalid || stylesInvalid || stateInvalid) {
			this.refreshText();
		}

		this.autoSizeIfNeeded();

		if (stylesInvalid || stateInvalid || dataInvalid || sizeInvalid) {
			this.layoutContent();
		}
	}

	/**
		If the component's dimensions have not been set explicitly, it will
		measure its content and determine an ideal size for itself. For
		instance, if the `explicitWidth` property is set, that value will be
		used without additional measurement. If `explicitWidth` is set, but
		`explicitHeight` is not (or the other way around), the dimension with
		the explicit value will not be measured, but the other non-explicit
		dimension will still require measurement.

		Calls `saveMeasurements()` to set up the `actualWidth` and
		`actualHeight` member variables used for layout.

		Meant for internal use, and subclasses may override this function with a
		custom implementation.

		@see `FeathersControl.saveMeasurements()`
		@see `FeathersControl.explicitWidth`
		@see `FeathersControl.explicitHeight`
		@see `FeathersControl.actualWidth`
		@see `FeathersControl.actualHeight`

		@since 1.0.0
	**/
	@:dox(show)
	private function autoSizeIfNeeded():Bool {
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
			this._backgroundSkinMeasurements.resetTargetFluidlyForParent(this._currentBackgroundSkin, this);
		}

		var measureSkin:IMeasureObject = null;
		if (Std.is(this._currentBackgroundSkin, IMeasureObject)) {
			measureSkin = cast(this._currentBackgroundSkin, IMeasureObject);
		}

		if (Std.is(this._currentBackgroundSkin, IValidating)) {
			cast(this._currentBackgroundSkin, IValidating).validateNow();
		}

		// uninitialized styles need some defaults
		var paddingTop = this.paddingTop != null ? this.paddingTop : 0.0;
		var paddingRight = this.paddingRight != null ? this.paddingRight : 0.0;
		var paddingBottom = this.paddingBottom != null ? this.paddingBottom : 0.0;
		var paddingLeft = this.paddingLeft != null ? this.paddingLeft : 0.0;

		var newWidth = this.explicitWidth;
		if (needsWidth) {
			newWidth = this._textMeasuredWidth + paddingLeft + paddingRight;
			if (this._currentBackgroundSkin != null) {
				newWidth = Math.max(this._currentBackgroundSkin.width, newWidth);
			}
		}

		var newHeight = this.explicitHeight;
		if (needsHeight) {
			newHeight = this._textMeasuredHeight + paddingTop + paddingBottom;
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
		if (this.textFormat != null) {
			this.textField.defaultTextFormat = this.textFormat;
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
			cast(this._currentBackgroundSkin, IStateObserver).stateContext = cast(this, IStateContext);
		}
		this.addChildAt(this._currentBackgroundSkin, 0);
	}

	private function getCurrentBackgroundSkin():DisplayObject {
		if (!this.enabled && this.backgroundDisabledSkin != null) {
			return this.backgroundDisabledSkin;
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
		if (skin.parent == this) {
			// we need to restore these values so that they won't be lost the
			// next time that this skin is used for measurement
			this.removeChild(skin);
		}
	}

	private function layoutContent() {
		this.layoutBackgroundSkin();

		// uninitialized styles need some defaults
		var paddingTop = this.paddingTop != null ? this.paddingTop : 0.0;
		var paddingRight = this.paddingRight != null ? this.paddingRight : 0.0;
		var paddingBottom = this.paddingBottom != null ? this.paddingBottom : 0.0;
		var paddingLeft = this.paddingLeft != null ? this.paddingLeft : 0.0;

		var maxWidth = this.actualWidth - paddingLeft - paddingRight;
		var maxHeight = this.actualHeight - paddingTop - paddingBottom;
		if (this._textMeasuredWidth > maxWidth) {
			this.textField.width = maxWidth;
		} else {
			this.textField.width = this._textMeasuredWidth;
		}
		if (this._textMeasuredHeight > maxHeight) {
			this.textField.height = maxHeight;
		} else {
			this.textField.height = this._textMeasuredHeight;
		}
		switch (this.horizontalAlign) {
			case LEFT:
				this.textField.x = paddingLeft;
			case RIGHT:
				this.textField.x = this.actualWidth - paddingRight - this.textField.width;
			default: // center or null
				this.textField.x = paddingLeft + (maxWidth - this.textField.width) / 2;
		}
		switch (this.verticalAlign) {
			case TOP:
				this.textField.y = paddingTop;
			case BOTTOM:
				this.textField.y = this.actualHeight - paddingBottom - this.textField.height;
			default: // middle or null
				this.textField.y = paddingTop + (maxHeight - this.textField.height) / 2;
		}
	}

	private function layoutBackgroundSkin():Void {
		if (this._currentBackgroundSkin == null) {
			return;
		}
		this._currentBackgroundSkin.x = 0;
		this._currentBackgroundSkin.y = 0;

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
