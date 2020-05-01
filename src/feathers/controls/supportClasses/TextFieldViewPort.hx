/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.supportClasses;

import feathers.core.FeathersControl;
import feathers.core.InvalidationFlag;
import feathers.events.FeathersEvent;
import feathers.utils.MathUtil;
import openfl.errors.ArgumentError;
import openfl.events.Event;
import openfl.events.FocusEvent;
import openfl.text.TextField;
import openfl.text.TextFieldType;
import openfl.text.TextFormat;

class TextFieldViewPort extends FeathersControl implements IViewPort {
	public function new() {
		super();
	}

	private var textField:TextField;

	public var textFieldType(default, set):TextFieldType = DYNAMIC;

	private function set_textFieldType(value:TextFieldType):TextFieldType {
		if (this.textFieldType == value) {
			return this.textFieldType;
		}
		this.textFieldType = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this.textFieldType;
	}

	public var text(default, set):String = null;

	private function set_text(value:String):String {
		if (this.text == value) {
			return this.text;
		}
		this.text = value;
		this.setInvalid(InvalidationFlag.DATA);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this.text;
	}

	public var wordWrap(default, set):Bool = false;

	private function set_wordWrap(value:Bool):Bool {
		if (this.wordWrap == value) {
			return this.wordWrap;
		}
		this.wordWrap = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this.wordWrap;
	}

	public var multiline(default, set):Bool = false;

	private function set_multiline(value:Bool):Bool {
		if (this.multiline == value) {
			return this.multiline;
		}
		this.multiline = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this.multiline;
	}

	public var restrict(default, set):String = null;

	private function set_restrict(value:String):String {
		if (this.restrict == value) {
			return this.restrict;
		}
		this.restrict = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this.restrict;
	}

	public var smoothScrolling(default, set):Bool = false;

	private function set_smoothScrolling(value:Bool):Bool {
		if (this.smoothScrolling == value) {
			return this.smoothScrolling;
		}
		this.smoothScrolling = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this.smoothScrolling;
	}

	private var _updatedTextStyles = false;
	private var _previousText:String = null;
	private var _previousTextFormat:TextFormat = null;
	private var _previousWidth:Null<Float> = null;
	private var _textMeasuredWidth:Float;
	private var _textMeasuredHeight:Float;

	public var textFormat(default, set):TextFormat = null;

	private function set_textFormat(value:TextFormat):TextFormat {
		if (this.textFormat == value) {
			return this.textFormat;
		}
		this.textFormat = value;
		this.setInvalid(InvalidationFlag.STYLES);
		return this.textFormat;
	}

	public var embedFonts(default, set):Bool = false;

	private function set_embedFonts(value:Bool):Bool {
		if (this.embedFonts == value) {
			return this.embedFonts;
		}
		this.embedFonts = value;
		this.setInvalid(InvalidationFlag.STYLES);
		return this.embedFonts;
	}

	public var paddingTop(default, set):Float = 0.0;

	private function set_paddingTop(value:Float):Float {
		if (this.paddingTop == value) {
			return this.paddingTop;
		}
		this.paddingTop = value;
		this.setInvalid(InvalidationFlag.STYLES);
		return this.paddingTop;
	}

	public var paddingRight(default, set):Float = 0.0;

	private function set_paddingRight(value:Float):Float {
		if (this.paddingRight == value) {
			return this.paddingRight;
		}
		this.paddingRight = value;
		this.setInvalid(InvalidationFlag.STYLES);
		return this.paddingRight;
	}

	public var paddingBottom(default, set):Float = 0.0;

	private function set_paddingBottom(value:Float):Float {
		if (this.paddingBottom == value) {
			return this.paddingBottom;
		}
		this.paddingBottom = value;
		this.setInvalid(InvalidationFlag.STYLES);
		return this.paddingBottom;
	}

	public var paddingLeft(default, set):Float = 0.0;

	private function set_paddingLeft(value:Float):Float {
		if (this.paddingLeft == value) {
			return this.paddingLeft;
		}
		this.paddingLeft = value;
		this.setInvalid(InvalidationFlag.STYLES);
		return this.paddingLeft;
	}

	private var _actualMinVisibleWidth:Float = 0.0;
	private var _explicitMinVisibleWidth:Null<Float> = null;

	/**
		@see `feathers.controls.supportClasses.IViewPort.minVisibleWidth`
	**/
	public var minVisibleWidth(get, set):Null<Float>;

	private function get_minVisibleWidth():Null<Float> {
		if (this._explicitMinVisibleWidth == null) {
			return this._actualMinVisibleWidth;
		}
		return this._explicitMinVisibleWidth;
	}

	private function set_minVisibleWidth(value:Null<Float>):Null<Float> {
		if (this._explicitMinVisibleWidth == value) {
			return this._explicitMinVisibleWidth;
		}
		var oldValue = this._explicitMinVisibleWidth;
		this._explicitMinVisibleWidth = value;
		if (value == null) {
			this._actualMinVisibleWidth = 0.0;
			this.setInvalid(InvalidationFlag.SIZE);
		} else {
			this._actualMinVisibleWidth = value;
			if (this._explicitVisibleWidth == null && (this._actualVisibleWidth < value || this._actualVisibleWidth == oldValue)) {
				// only invalidate if this change might affect the visibleWidth
				this.setInvalid(InvalidationFlag.SIZE);
			}
		}
		return this._explicitMinVisibleWidth;
	}

	/**
		@see `feathers.controls.supportClasses.IViewPort.maxVisibleWidth`
	**/
	public var maxVisibleWidth(default, set):Null<Float> = Math.POSITIVE_INFINITY;

	private function set_maxVisibleWidth(value:Null<Float>):Null<Float> {
		if (this.maxVisibleWidth == value) {
			return this.maxVisibleWidth;
		}
		if (value == null) {
			throw new ArgumentError("maxVisibleWidth cannot be null");
		}
		var oldValue = this.maxVisibleWidth;
		this.maxVisibleWidth = value;
		if (this._explicitVisibleWidth == null && (this._actualVisibleWidth > value || this._actualVisibleWidth == oldValue)) {
			// only invalidate if this change might affect the visibleWidth
			this.setInvalid(InvalidationFlag.SIZE);
		}
		return this.maxVisibleWidth;
	}

	private var _actualVisibleWidth:Float = 0.0;
	private var _explicitVisibleWidth:Null<Float> = null;

	/**
		@see `feathers.controls.supportClasses.IViewPort.visibleWidth`
	**/
	public var visibleWidth(get, set):Null<Float>;

	private function get_visibleWidth():Null<Float> {
		if (this._explicitVisibleWidth == null) {
			return this._actualVisibleWidth;
		}
		return this._explicitVisibleWidth;
	}

	private function set_visibleWidth(value:Null<Float>):Null<Float> {
		if (this._explicitVisibleWidth == value) {
			return this._explicitVisibleWidth;
		}
		this._explicitVisibleWidth = value;
		if (this._actualVisibleWidth != value) {
			this.setInvalid(InvalidationFlag.SIZE);
		}
		return this._explicitVisibleWidth;
	}

	private var _actualMinVisibleHeight:Float = 0.0;
	private var _explicitMinVisibleHeight:Null<Float>;

	/**
		@see `feathers.controls.supportClasses.IViewPort.minVisibleHeight`
	**/
	public var minVisibleHeight(get, set):Null<Float>;

	private function get_minVisibleHeight():Null<Float> {
		if (this._explicitMinVisibleHeight == null) {
			return this._actualMinVisibleHeight;
		}
		return this._explicitMinVisibleHeight;
	}

	private function set_minVisibleHeight(value:Null<Float>):Null<Float> {
		if (this._explicitMinVisibleHeight == value) {
			return this._explicitMinVisibleHeight;
		}
		var oldValue = this._explicitMinVisibleHeight;
		this._explicitMinVisibleHeight = value;
		if (value == null) {
			this._actualMinVisibleHeight = 0.0;
			this.setInvalid(InvalidationFlag.SIZE);
		} else {
			this._actualMinVisibleHeight = value;
			if (this._explicitVisibleHeight == null && (this._actualVisibleHeight < value || this._actualVisibleHeight == oldValue)) {
				// only invalidate if this change might affect the visibleHeight
				this.setInvalid(InvalidationFlag.SIZE);
			}
		}
		return this._explicitMinVisibleHeight;
	}

	/**
		@see `feathers.controls.supportClasses.IViewPort.maxVisibleHeight`
	**/
	public var maxVisibleHeight(default, set):Null<Float> = Math.POSITIVE_INFINITY;

	private function get_maxVisibleHeight():Null<Float> {
		return this.maxVisibleHeight;
	}

	private function set_maxVisibleHeight(value:Null<Float>):Null<Float> {
		if (this.maxVisibleHeight == value) {
			return this.maxVisibleHeight;
		}
		if (value == null) {
			throw new ArgumentError("maxVisibleHeight cannot be null");
		}
		var oldValue = this.maxVisibleHeight;
		this.maxVisibleHeight = value;
		if (this._explicitVisibleHeight == null && (this._actualVisibleHeight > value || this._actualVisibleHeight == oldValue)) {
			// only invalidate if this change might affect the visibleHeight
			this.setInvalid(InvalidationFlag.SIZE);
		}
		return this.maxVisibleHeight;
	}

	private var _actualVisibleHeight:Float = 0.0;
	private var _explicitVisibleHeight:Null<Float> = null;

	/**
		@see `feathers.controls.supportClasses.IViewPort.visibleHeight`
	**/
	public var visibleHeight(get, set):Null<Float>;

	private function get_visibleHeight():Null<Float> {
		if (this._explicitVisibleHeight == null) {
			return this._actualVisibleHeight;
		}
		return this._explicitVisibleHeight;
	}

	private function set_visibleHeight(value:Null<Float>):Null<Float> {
		if (this._explicitVisibleHeight == value) {
			return this._explicitVisibleHeight;
		}
		this._explicitVisibleHeight = value;
		if (this._actualVisibleHeight != value) {
			this.setInvalid(InvalidationFlag.SIZE);
		}
		return this._explicitVisibleWidth;
	}

	/**
		@see `feathers.controls.supportClasses.IViewPort.requiresMeasurementOnScroll`
	**/
	public var requiresMeasurementOnScroll(get, never):Bool;

	private function get_requiresMeasurementOnScroll():Bool {
		return !this.smoothScrolling;
	}

	/**
		@see `feathers.controls.supportClasses.IViewPort.scrollX`
	**/
	@:isVar
	public var scrollX(get, set):Float = 0.0;

	private function get_scrollX():Float {
		return this.scrollX;
	}

	private function set_scrollX(value:Float):Float {
		if (this.scrollX == value) {
			return this.scrollX;
		}
		this.scrollX = value;
		this.setInvalid(InvalidationFlag.SCROLL);
		return this.scrollX;
	}

	/**
		@see `feathers.controls.supportClasses.IViewPort.scrollY`
	**/
	@:isVar
	public var scrollY(get, set):Float = 0.0;

	private function get_scrollY():Float {
		return this.scrollY;
	}

	private function set_scrollY(value:Float):Float {
		if (this.scrollY == value) {
			return this.scrollY;
		}
		this.scrollY = value;
		this.setInvalid(InvalidationFlag.SCROLL);
		return this.scrollY;
	}

	private var _textFieldHasFocus:Bool = false;

	private var _ignoreTextFieldScroll:Bool = false;

	override private function initialize():Void {
		super.initialize();

		if (this.textField == null) {
			this.textField = new TextField();
			this.addChild(this.textField);
		}

		this.textField.mouseWheelEnabled = false;
		this.textField.addEventListener(Event.CHANGE, textField_changeHandler);
		this.textField.addEventListener(Event.SCROLL, textField_scrollHandler);
		this.textField.addEventListener(FocusEvent.FOCUS_IN, textField_focusInHandler);
		this.textField.addEventListener(FocusEvent.FOCUS_OUT, textField_focusOutHandler);
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);
		var sizeInvalid = this.isInvalid(InvalidationFlag.SIZE);
		var stylesInvalid = this.isInvalid(InvalidationFlag.STYLES);

		this._updatedTextStyles = false;

		var oldIgnoreTextFieldScroll = this._ignoreTextFieldScroll;
		this._ignoreTextFieldScroll = true;

		if (stylesInvalid) {
			this.refreshTextStyles();
		}

		if (dataInvalid || sizeInvalid || stylesInvalid) {
			this.refreshText();
		}

		this.measure();

		this.layoutTextField();

		this._ignoreTextFieldScroll = oldIgnoreTextFieldScroll;
	}

	private function measureSelf():Bool {
		var needsWidth = this.explicitWidth == null;
		var needsHeight = this.explicitHeight == null;
		var needsMinWidth = this.explicitMinWidth == null;
		var needsMinHeight = this.explicitMinHeight == null;
		var needsMaxWidth = this.explicitMaxWidth == null;
		var needsMaxHeight = this.explicitMaxHeight == null;
		if (!needsWidth && !needsHeight && !needsMinWidth && !needsMinHeight && !needsMaxWidth && !needsMaxHeight) {
			return false;
		}

		var newWidth = this.explicitWidth;
		if (needsWidth) {
			newWidth = this._textMeasuredWidth + this.paddingLeft + this.paddingRight;
		}

		var newHeight = this.explicitHeight;
		if (needsHeight) {
			newHeight = this._textMeasuredHeight + this.paddingTop + this.paddingBottom;
		}

		var newMinWidth = this.explicitMinWidth;
		if (needsMinWidth) {
			newMinWidth = this._textMeasuredWidth + this.paddingLeft + this.paddingRight;
		}

		var newMinHeight = this.explicitMinHeight;
		if (needsMinHeight) {
			newMinHeight = this._textMeasuredHeight + this.paddingTop + this.paddingBottom;
		}
		var newMaxWidth = this.explicitMaxWidth;
		if (needsMaxWidth) {
			newMaxWidth = Math.POSITIVE_INFINITY;
		}

		var newMaxHeight = this.explicitMaxHeight;
		if (needsMaxHeight) {
			newMaxHeight = Math.POSITIVE_INFINITY;
		}

		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight, newMaxWidth, newMaxHeight);
	}

	private function measure():Bool {
		var result = this.measureSelf();

		var needsVisibleWidth = this._explicitVisibleWidth == null;
		var needsVisibleHeight = this._explicitVisibleHeight == null;
		var needsVisibleMinWidth = this._explicitMinVisibleWidth == null;
		var needsVisibleMinHeight = this._explicitMinVisibleHeight == null;

		if (needsVisibleWidth) {
			this._actualVisibleWidth = this.actualWidth;
		} else {
			this._actualVisibleWidth = this._explicitVisibleWidth;
		}

		if (needsVisibleHeight) {
			this._actualVisibleHeight = this.actualHeight;
		} else {
			this._actualVisibleHeight = this._explicitVisibleHeight;
		}

		if (needsVisibleMinWidth) {
			this._actualMinVisibleWidth = this.actualMinWidth;
		} else {
			this._actualMinVisibleWidth = this._explicitMinVisibleWidth;
		}

		if (needsVisibleMinHeight) {
			this._actualMinVisibleHeight = this.actualMinHeight;
		} else {
			this._actualMinVisibleHeight = this._explicitMinVisibleHeight;
		}

		return result;
	}

	private function refreshTextStyles():Void {
		if (this.textField.embedFonts != this.embedFonts) {
			this.textField.embedFonts = this.embedFonts;
			this._updatedTextStyles = true;
		}
		if (this.textFormat != this._previousTextFormat) {
			this.textField.defaultTextFormat = textFormat;
			this._updatedTextStyles = true;
			this._previousTextFormat = textFormat;
		}
	}

	private function refreshText():Void {
		var textFieldType = this.enabled ? this.textFieldType : TextFieldType.DYNAMIC;
		if (this.textField.type != textFieldType) {
			this.textField.type = textFieldType;
		}
		var calculatedWordWrap = this._explicitVisibleWidth != null ? this.wordWrap : false;
		if (this.textField.wordWrap != calculatedWordWrap) {
			this.textField.wordWrap = calculatedWordWrap;
			this._updatedTextStyles = true;
		}
		if (this.textField.multiline != this.multiline) {
			this.textField.multiline = this.multiline;
			this._updatedTextStyles = true;
		}
		this.textField.restrict = this.restrict;
		var calculatedWidth = this._explicitVisibleWidth;
		if (calculatedWidth != null) {
			calculatedWidth -= (this.paddingLeft + this.paddingRight);
		}
		if (this.text == this._previousText && !this._updatedTextStyles && calculatedWidth != this._previousWidth) {
			// nothing to refresh
			return;
		}
		var hasText = this.text != null && this.text.length > 0;
		if (hasText) {
			this.textField.text = this.text;
		} else {
			this.textField.text = "\u8203"; // zero-width space
		}
		if (calculatedWidth != null) {
			this.textField.width = calculatedWidth - this.paddingLeft - this.paddingRight;
		}
		this.textField.autoSize = LEFT;
		this._textMeasuredWidth = this.textField.width;
		this._textMeasuredHeight = this.textField.height;
		this.textField.autoSize = NONE;
		if (!hasText) {
			this.textField.text = "";
		}
		this._previousText = this.text;
		this._previousWidth = calculatedWidth;
	}

	private function layoutTextField():Void {
		if (this.smoothScrolling) {
			this.textField.x = this.paddingLeft;
			this.textField.y = this.paddingTop;
			var calculatedWidth = Math.max(this.actualWidth, this._actualVisibleWidth);
			var calculatedHeight = Math.max(this.actualHeight, this._actualVisibleHeight);
			this.textField.width = calculatedWidth - this.paddingLeft - this.paddingRight;
			this.textField.height = calculatedHeight - this.paddingTop - this.paddingBottom;
			this.textField.scrollV = 1;
		} else {
			this.textField.x = this.paddingLeft + this.scrollX;
			this.textField.y = this.paddingTop + this.scrollY;
			this.textField.width = this._actualVisibleWidth - this.paddingLeft - this.paddingRight;
			this.textField.height = this._actualVisibleHeight - this.paddingTop - this.paddingBottom;
			// for some reason, in flash, after changing the TextField's height,
			// you need to access textHeight to get a valid maxScrollV
			var textFieldHeight = this.textField.textHeight;
			var container = cast(this.parent, BaseScrollContainer);
			if (this.textField.maxScrollV == 1 || container.maxScrollY == container.minScrollY) {
				this.textField.scrollV = 1;
			} else {
				this.textField.scrollV = 1 + Math.round(((this.textField.maxScrollV - 1.0) * (this.scrollY / container.maxScrollY)));
			}
			if (this.textField.maxScrollH == 0 || container.maxScrollX == container.minScrollX) {
				this.textField.scrollH = 0;
			} else {
				this.textField.scrollH = Math.round(this.textField.maxScrollH * (this.scrollX / container.maxScrollX));
			}
		}
	}

	private inline function calculateStepSize():Float {
		var metrics = this.textField.getLineMetrics(0);
		return metrics.height + metrics.leading;
	}

	private function textField_changeHandler(event:Event):Void {
		// don't let this event bubble. Feathers UI components don't bubble their
		// events — especially not Event.CHANGE!
		event.stopPropagation();

		// don't try to use @:bypassAccessor here because we need to measure
		// again just in case it affected the maximum y scroll position
		this.text = this.textField.text;

		if (this._textFieldHasFocus) {
			// if we have focus, we should update the scroll position so that
			// the caret is visible

			// first, validate the parent container so that the scroll bars are
			// made visible, if they weren't before
			var container = cast(this.parent, BaseScrollContainer);
			container.validateNow();

			if (container.maxScrollY > 0.0 && this.textField.maxScrollV > 1) {
				var caretIndex = this.textField.caretIndex;
				if (caretIndex == this.textField.length) {
					caretIndex--;
				}
				var lineIndex = this.textField.getLineIndexOfChar(this.textField.caretIndex - 1);
				var minScrollVForLine = this.textField.maxScrollV - (this.textField.numLines - lineIndex - 1);
				var numLinesAtMinScrollV = this.textField.numLines - this.textField.maxScrollV;
				var maxScrollVForLine = minScrollVForLine + (this.textField.numLines - this.textField.maxScrollV);
				if (maxScrollVForLine > this.textField.maxScrollV) {
					maxScrollVForLine = this.textField.maxScrollV;
				}

				var targetScrollV = this.textField.scrollV;
				if ((minScrollVForLine - this.textField.scrollV) > 0) {
					targetScrollV = minScrollVForLine;
				} else if ((this.textField.scrollV - maxScrollVForLine) > 0) {
					targetScrollV = maxScrollVForLine;
				}

				if (targetScrollV != this.textField.scrollV) {
					var calculatedScrollY = container.maxScrollY * (targetScrollV - 1) / (this.textField.maxScrollV - 1);
					container.scrollY = MathUtil.roundToNearest(calculatedScrollY, this.calculateStepSize());
				}
			}
		}
	}

	private function textField_focusInHandler(event:FocusEvent):Void {
		this._textFieldHasFocus = true;
	}

	private function textField_focusOutHandler(event:FocusEvent):Void {
		this._textFieldHasFocus = false;
	}

	private function textField_scrollHandler(event:Event):Void {
		if (this._ignoreTextFieldScroll) {
			return;
		}
		var container = cast(this.parent, BaseScrollContainer);
		if (container.maxScrollY > 0.0 && this.textField.maxScrollV > 1) {
			var calculatedScrollY = container.maxScrollY * (this.textField.scrollV - 1) / (this.textField.maxScrollV - 1);
			container.scrollY = MathUtil.roundToNearest(calculatedScrollY, this.calculateStepSize());
		}
	}
}
