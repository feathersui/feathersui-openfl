/*
	Feathers UI
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
import feathers.core.ITextControl;
import feathers.core.IUIControl;
import feathers.core.IValidating;
import feathers.layout.HorizontalAlign;
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
	var label:Label = new Label();
	label.text = "Hello World";
	this.addChild( label );
	```

	@see [Tutorial: How to use the Label component](https://feathersui.com/learn/haxe-openfl/help/label/)

	@since 1.0.0
**/
@:styleContext
class Label extends FeathersControl implements ITextControl {
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

	private var textField:TextField;

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

	@:style
	public var textFormat:TextFormat = null;

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
	public var paddingTop:Null<Float> = 0.0;

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
	public var paddingRight:Null<Float> = 0.0;

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
	public var paddingBottom:Null<Float> = 0.0;

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
	public var paddingLeft:Null<Float> = 0.0;

	/**
		How the content is positioned horizontally (along the x-axis) within the
		button.

		The following example aligns the button's content to the left:

		```hx
		button.verticalAlign = HorizontalAlign.LEFT;
		```

		**Note:** The `HorizontalAlign.JUSTIFY` constant is not supported by this
		component.

		@default `feathers.layout.HorizontalAlign.CENTER`

		@see `feathers.layout.HorizontalAlign.LEFT`
		@see `feathers.layout.HorizontalAlign.CENTER`
		@see `feathers.layout.HorizontalAlign.RIGHT`
	**/
	@:style
	public var horizontalAlign:HorizontalAlign = HorizontalAlign.CENTER;

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
	@:style
	public var verticalAlign:VerticalAlign = VerticalAlign.MIDDLE;

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
	@:style
	public var backgroundSkin:DisplayObject = null;

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
	@:style
	public var backgroundDisabledSkin:DisplayObject = null;

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
			this.textField.text = "";
		}
		this.textField.visible = hasText;
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

		var maxWidth = this.actualWidth - this.paddingLeft - this.paddingRight;
		var maxHeight = this.actualHeight - this.paddingTop - this.paddingBottom;
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
				this.textField.x = this.paddingLeft;
			case RIGHT:
				this.textField.x = this.actualWidth - this.paddingRight - this.textField.width;
			default: // center or null
				this.textField.x = this.paddingLeft + (maxWidth - this.textField.width) / 2;
		}
		switch (this.verticalAlign) {
			case TOP:
				this.textField.y = this.paddingTop;
			case BOTTOM:
				this.textField.y = this.actualHeight - this.paddingBottom - this.textField.height;
			default: // middle or null
				this.textField.y = this.paddingTop + (maxHeight - this.textField.height) / 2;
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
