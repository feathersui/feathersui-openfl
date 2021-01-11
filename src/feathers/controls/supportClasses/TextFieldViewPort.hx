/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.supportClasses;

import feathers.core.FeathersControl;
import feathers.core.ITextControl;
import feathers.events.FeathersEvent;
import openfl.display.InteractiveObject;
import openfl.errors.ArgumentError;
import openfl.events.Event;
import openfl.events.FocusEvent;
import openfl.text.TextField;
import openfl.text.TextFieldType;
import openfl.text.TextFormat;
import openfl.text.TextLineMetrics;

/**
	An implementation of `IViewPort` for `TextArea`.

	@see `feathers.controls.TextArea`

	@since 1.0.0
**/
@:event(openfl.events.Event.CHANGE)
class TextFieldViewPort extends FeathersControl implements IViewPort implements ITextControl {
	public function new() {
		super();

		this.addEventListener(FocusEvent.FOCUS_IN, textFieldViewPort_focusInHandler);
	}

	private var textField:TextField;

	private var _textFieldType:TextFieldType = DYNAMIC;

	/**
		Indicates if it's a dynamic or input text field.

		@see `openfl.text.TextField.type`

		@since 1.0.0
	**/
	@:flash.property
	public var textFieldType(get, set):TextFieldType;

	private function get_textFieldType():TextFieldType {
		return this._textFieldType;
	}

	private function set_textFieldType(value:TextFieldType):TextFieldType {
		if (this._textFieldType == value) {
			return this._textFieldType;
		}
		this._textFieldType = value;
		this.setInvalid(DATA);
		return this._textFieldType;
	}

	private var _text:String;

	/**
		The text to display.

		@since 1.0.0
	**/
	@:flash.property
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
		FeathersEvent.dispatch(this, Event.CHANGE);
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
		return this.textField.y + this.textField.getLineMetrics(0).ascent;
	}

	private var _wordWrap:Bool = false;

	/**
		Determines if the text will wrap when reaching the right edge, or if
		horizontal scrolling will be required.

		@since 1.0.0
	**/
	@:flash.property
	public var wordWrap(get, set):Bool;

	private function get_wordWrap():Bool {
		return this._wordWrap;
	}

	private function set_wordWrap(value:Bool):Bool {
		if (this._wordWrap == value) {
			return this._wordWrap;
		}
		this._wordWrap = value;
		this.setInvalid(DATA);
		return this._wordWrap;
	}

	private var _multiline:Bool = false;

	/**
		Indicates if the multiple lines of text may be displayed.

		@since 1.0.0
	**/
	@:flash.property
	public var multiline(get, set):Bool;

	private function get_multiline():Bool {
		return this._multiline;
	}

	private function set_multiline(value:Bool):Bool {
		if (this._multiline == value) {
			return this._multiline;
		}
		this._multiline = value;
		this.setInvalid(DATA);
		return this._multiline;
	}

	// for some reason, naming this _restrict fails in hxcpp
	private var __restrict:String;

	/**
		Limits the set of characters that may be typed with the keyboard.

		@since 1.0.0
	**/
	@:flash.property
	public var restrict(get, set):String;

	private function get_restrict():String {
		return this.__restrict;
	}

	private function set_restrict(value:String):String {
		if (this.__restrict == value) {
			return this.__restrict;
		}
		this.__restrict = value;
		this.setInvalid(DATA);
		return this.__restrict;
	}

	private var _maxChars:Int = 0;

	/**
		Limits the set of characters that may be typed with the keyboard.

		@since 1.0.0
	**/
	@:flash.property
	public var maxChars(get, set):Int;

	private function get_maxChars():Int {
		return this._maxChars;
	}

	private function set_maxChars(value:Int):Int {
		if (this._maxChars == value) {
			return this._maxChars;
		}
		this._maxChars = value;
		this.setInvalid(DATA);
		return this._maxChars;
	}

	private var _smoothScrolling:Bool = false;

	/**
		Determines if scrolling is smooth or line by line.

		@since 1.0.0
	**/
	@:flash.property
	public var smoothScrolling(get, set):Bool;

	private function get_smoothScrolling():Bool {
		return this._smoothScrolling;
	}

	private function set_smoothScrolling(value:Bool):Bool {
		if (this._smoothScrolling == value) {
			return this._smoothScrolling;
		}
		this._smoothScrolling = value;
		this.setInvalid(DATA);
		return this._smoothScrolling;
	}

	private var _updatedTextStyles = false;
	private var _previousText:String = null;
	private var _previousTextFormat:TextFormat = null;
	private var _previousWidth:Null<Float> = null;
	private var _savedLineMetrics:TextLineMetrics = null;
	private var _textMeasuredWidth:Float;
	private var _textMeasuredHeight:Float;

	private var _textFormat:TextFormat;

	/**
		The font styles used to render the text.

		@since 1.0.0
	**/
	@:flash.property
	public var textFormat(get, set):TextFormat;

	private function get_textFormat():TextFormat {
		return this._textFormat;
	}

	private function set_textFormat(value:TextFormat):TextFormat {
		if (this._textFormat == value) {
			return this._textFormat;
		}
		this._textFormat = value;
		this.setInvalid(STYLES);
		return this._textFormat;
	}

	private var _embedFonts:Bool = false;

	/**
		Determines if an embedded font is used or not.

		@since 1.0.0
	**/
	@:flash.property
	public var embedFonts(get, set):Bool;

	private function get_embedFonts():Bool {
		return this._embedFonts;
	}

	private function set_embedFonts(value:Bool):Bool {
		if (this._embedFonts == value) {
			return this._embedFonts;
		}
		this._embedFonts = value;
		this.setInvalid(STYLES);
		return this._embedFonts;
	}

	private var _paddingTop:Float = 0.0;

	/**
		The minimum space, in pixels, between the view port's top edge and the
		text.

		@since 1.0.0
	**/
	@:flash.property
	public var paddingTop(get, set):Float;

	private function get_paddingTop():Float {
		return this._paddingTop;
	}

	private function set_paddingTop(value:Float):Float {
		if (this._paddingTop == value) {
			return this._paddingTop;
		}
		this._paddingTop = value;
		this.setInvalid(STYLES);
		return this._paddingTop;
	}

	private var _paddingRight:Float = 0.0;

	/**
		The minimum space, in pixels, between the view port's right edge and the
		text.

		@since 1.0.0
	**/
	@:flash.property
	public var paddingRight(get, set):Float;

	private function get_paddingRight():Float {
		return this._paddingRight;
	}

	private function set_paddingRight(value:Float):Float {
		if (this._paddingRight == value) {
			return this._paddingRight;
		}
		this._paddingRight = value;
		this.setInvalid(STYLES);
		return this._paddingRight;
	}

	private var _paddingBottom:Float = 0.0;

	/**
		The minimum space, in pixels, between the view port's bottom edge and
		the text.

		@since 1.0.0
	**/
	@:flash.property
	public var paddingBottom(get, set):Float;

	private function get_paddingBottom():Float {
		return this._paddingBottom;
	}

	private function set_paddingBottom(value:Float):Float {
		if (this._paddingBottom == value) {
			return this._paddingBottom;
		}
		this._paddingBottom = value;
		this.setInvalid(STYLES);
		return this._paddingBottom;
	}

	private var _paddingLeft:Float = 0.0;

	/**
		The minimum space, in pixels, between the view port's left edge and the
		text.

		@since 1.0.0
	**/
	@:flash.property
	public var paddingLeft(get, set):Float;

	private function get_paddingLeft():Float {
		return this._paddingLeft;
	}

	private function set_paddingLeft(value:Float):Float {
		if (this._paddingLeft == value) {
			return this._paddingLeft;
		}
		this._paddingLeft = value;
		this.setInvalid(STYLES);
		return this._paddingLeft;
	}

	@:flash.property
	public var stageFocusTarget(get, never):InteractiveObject;

	private function get_stageFocusTarget():InteractiveObject {
		return this.textField;
	}

	private var _actualMinVisibleWidth:Float = 0.0;
	private var _explicitMinVisibleWidth:Null<Float> = null;

	/**
		@see `feathers.controls.supportClasses.IViewPort.minVisibleWidth`
	**/
	@:flash.property
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
			this.setInvalid(SIZE);
		} else {
			this._actualMinVisibleWidth = value;
			if (this._explicitVisibleWidth == null && (this._actualVisibleWidth < value || this._actualVisibleWidth == oldValue)) {
				// only invalidate if this change might affect the visibleWidth
				this.setInvalid(SIZE);
			}
		}
		return this._explicitMinVisibleWidth;
	}

	private var _maxVisibleWidth:Null<Float> = Math.POSITIVE_INFINITY;

	/**
		@see `feathers.controls.supportClasses.IViewPort.maxVisibleWidth`
	**/
	@:flash.property
	public var maxVisibleWidth(get, set):Null<Float>;

	private function get_maxVisibleWidth():Null<Float> {
		return this._maxVisibleWidth;
	}

	private function set_maxVisibleWidth(value:Null<Float>):Null<Float> {
		if (this._maxVisibleWidth == value) {
			return this._maxVisibleWidth;
		}
		if (value == null) {
			throw new ArgumentError("maxVisibleWidth cannot be null");
		}
		var oldValue = this._maxVisibleWidth;
		this._maxVisibleWidth = value;
		if (this._explicitVisibleWidth == null && (this._actualVisibleWidth > value || this._actualVisibleWidth == oldValue)) {
			// only invalidate if this change might affect the visibleWidth
			this.setInvalid(SIZE);
		}
		return this._maxVisibleWidth;
	}

	private var _actualVisibleWidth:Float = 0.0;
	private var _explicitVisibleWidth:Null<Float> = null;

	/**
		@see `feathers.controls.supportClasses.IViewPort.visibleWidth`
	**/
	@:flash.property
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
			this.setInvalid(SIZE);
		}
		return this._explicitVisibleWidth;
	}

	private var _actualMinVisibleHeight:Float = 0.0;
	private var _explicitMinVisibleHeight:Null<Float>;

	/**
		@see `feathers.controls.supportClasses.IViewPort.minVisibleHeight`
	**/
	@:flash.property
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
			this.setInvalid(SIZE);
		} else {
			this._actualMinVisibleHeight = value;
			if (this._explicitVisibleHeight == null && (this._actualVisibleHeight < value || this._actualVisibleHeight == oldValue)) {
				// only invalidate if this change might affect the visibleHeight
				this.setInvalid(SIZE);
			}
		}
		return this._explicitMinVisibleHeight;
	}

	private var _maxVisibleHeight:Null<Float> = Math.POSITIVE_INFINITY;

	/**
		@see `feathers.controls.supportClasses.IViewPort.maxVisibleHeight`
	**/
	@:flash.property
	public var maxVisibleHeight(get, set):Null<Float>;

	private function get_maxVisibleHeight():Null<Float> {
		return this._maxVisibleHeight;
	}

	private function set_maxVisibleHeight(value:Null<Float>):Null<Float> {
		if (this._maxVisibleHeight == value) {
			return this._maxVisibleHeight;
		}
		if (value == null) {
			throw new ArgumentError("maxVisibleHeight cannot be null");
		}
		var oldValue = this._maxVisibleHeight;
		this._maxVisibleHeight = value;
		if (this._explicitVisibleHeight == null && (this._actualVisibleHeight > value || this._actualVisibleHeight == oldValue)) {
			// only invalidate if this change might affect the visibleHeight
			this.setInvalid(SIZE);
		}
		return this._maxVisibleHeight;
	}

	private var _actualVisibleHeight:Float = 0.0;
	private var _explicitVisibleHeight:Null<Float> = null;

	/**
		@see `feathers.controls.supportClasses.IViewPort.visibleHeight`
	**/
	@:flash.property
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
			this.setInvalid(SIZE);
		}
		return this._explicitVisibleWidth;
	}

	/**
		@see `feathers.controls.supportClasses.IViewPort.requiresMeasurementOnScroll`
	**/
	@:flash.property
	public var requiresMeasurementOnScroll(get, never):Bool;

	private function get_requiresMeasurementOnScroll():Bool {
		return !this._smoothScrolling;
	}

	private var _scrollX:Float = 0.0;

	/**
		@see `feathers.controls.supportClasses.IViewPort.scrollX`
	**/
	@:flash.property
	public var scrollX(get, set):Float;

	private function get_scrollX():Float {
		return this._scrollX;
	}

	private function set_scrollX(value:Float):Float {
		if (this._scrollX == value) {
			return this._scrollX;
		}
		this._scrollX = value;
		this.setInvalid(SCROLL);
		return this._scrollX;
	}

	private var _scrollY:Float = 0.0;

	/**
		@see `feathers.controls.supportClasses.IViewPort.scrollY`
	**/
	@:flash.property
	public var scrollY(get, set):Float;

	private function get_scrollY():Float {
		return this._scrollY;
	}

	private function set_scrollY(value:Float):Float {
		if (this._scrollY == value) {
			return this._scrollY;
		}
		this._scrollY = value;
		this.setInvalid(SCROLL);
		return this._scrollY;
	}

	private var _pendingSelectionAnchorIndex:Int = -1;

	/**
		@see `feathers.controls.TextArea.selectionAnchorIndex`
	**/
	@:flash.property
	public var selectionAnchorIndex(get, never):Int;

	private function get_selectionAnchorIndex():Int {
		if (this.textField != null && this._pendingSelectionAnchorIndex == -1) {
			// return the opposite of the caret index
			if (this.textField.caretIndex == this.textField.selectionBeginIndex) {
				return this.textField.selectionEndIndex;
			}
			return this.textField.selectionBeginIndex;
		}
		return this._pendingSelectionAnchorIndex;
	}

	private var _pendingSelectionActiveIndex:Int = -1;

	/**
		@see `feathers.controls.TextArea.selectionActiveIndex`
	**/
	@:flash.property
	public var selectionActiveIndex(get, never):Int;

	private function get_selectionActiveIndex():Int {
		if (this.textField != null && this._pendingSelectionActiveIndex == -1) {
			// always the same as caret index
			return this.textField.caretIndex;
		}
		return this._pendingSelectionActiveIndex;
	}

	private var _textFieldHasFocus:Bool = false;

	private var _ignoreTextFieldScroll:Bool = false;

	/**
		@see `feathers.controls.TextArea.selectRange()`
	**/
	public function selectRange(anchorIndex:Int, activeIndex:Int):Void {
		// we can't call textField.setSelection() directly here because the
		// TextField may not have been updated yet
		this._pendingSelectionAnchorIndex = anchorIndex;
		this._pendingSelectionActiveIndex = activeIndex;
		this.setInvalid(SELECTION);
	}

	override private function initialize():Void {
		super.initialize();

		if (this.textField == null) {
			this.textField = new TextField();
			this.addChild(this.textField);
		}

		this.textField.selectable = true;
		this.textField.tabEnabled = false;
		this.textField.mouseWheelEnabled = false;
		this.textField.addEventListener(Event.CHANGE, textField_changeHandler);
		this.textField.addEventListener(Event.SCROLL, textField_scrollHandler);
		this.textField.addEventListener(FocusEvent.FOCUS_IN, textField_focusInHandler);
		this.textField.addEventListener(FocusEvent.FOCUS_OUT, textField_focusOutHandler);
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(DATA);
		var selectionInvalid = this.isInvalid(SELECTION);
		var sizeInvalid = this.isInvalid(SIZE);
		var stylesInvalid = this.isInvalid(STYLES);

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

		if (selectionInvalid) {
			this.refreshSelection();
		}

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
			newWidth = this._textMeasuredWidth + this._paddingLeft + this._paddingRight;
		}

		var newHeight = this.explicitHeight;
		if (needsHeight) {
			newHeight = this._textMeasuredHeight + this._paddingTop + this._paddingBottom;
		}

		var newMinWidth = this.explicitMinWidth;
		if (needsMinWidth) {
			newMinWidth = this._textMeasuredWidth + this._paddingLeft + this._paddingRight;
		}

		var newMinHeight = this.explicitMinHeight;
		if (needsMinHeight) {
			newMinHeight = this._textMeasuredHeight + this._paddingTop + this._paddingBottom;
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
		if (this.textField.embedFonts != this._embedFonts) {
			this.textField.embedFonts = this._embedFonts;
			this._updatedTextStyles = true;
		}
		if (this._textFormat != this._previousTextFormat) {
			this.textField.defaultTextFormat = this._textFormat;
			this._updatedTextStyles = true;
			this._previousTextFormat = this._textFormat;
		}
	}

	private function refreshText():Void {
		var textFieldType = this._enabled ? this._textFieldType : TextFieldType.DYNAMIC;
		if (this.textField.type != textFieldType) {
			this.textField.type = textFieldType;
		}
		var calculatedWordWrap = this._explicitVisibleWidth != null ? this._wordWrap : false;
		if (this.textField.wordWrap != calculatedWordWrap) {
			this.textField.wordWrap = calculatedWordWrap;
			this._updatedTextStyles = true;
		}
		if (this.textField.multiline != this._multiline) {
			this.textField.multiline = this._multiline;
			this._updatedTextStyles = true;
		}
		this.textField.restrict = this.__restrict;
		this.textField.maxChars = this._maxChars;
		var calculatedWidth = this._explicitVisibleWidth;
		if (calculatedWidth != null) {
			calculatedWidth -= (this._paddingLeft + this._paddingRight);
		}
		if (this._text == this._previousText && !this._updatedTextStyles && calculatedWidth == this._previousWidth) {
			// nothing to refresh
			return;
		}
		if (calculatedWidth != null) {
			this.textField.width = calculatedWidth;
		}
		// set autoSize before text because setting text first can trigger an
		// extra text engine reflow
		this.textField.autoSize = LEFT;
		var hasText = this._text != null && this._text.length > 0;
		if (hasText) {
			this.textField.text = this._text;
		} else {
			this.textField.text = "\u200b"; // zero-width space
		}
		this._savedLineMetrics = this.textField.getLineMetrics(0);
		this._textMeasuredWidth = this.textField.width;
		this._textMeasuredHeight = 4 + (this._savedLineMetrics.height + this._savedLineMetrics.leading) * this.textField.numLines;
		this.textField.autoSize = NONE;
		if (!hasText) {
			this.textField.text = "";
		}
		this._previousText = this._text;
		this._previousWidth = calculatedWidth;
	}

	private function refreshSelection():Void {
		if (this._pendingSelectionActiveIndex == -1 && this._pendingSelectionAnchorIndex == -1) {
			return;
		}
		var anchorIndex = this._pendingSelectionAnchorIndex;
		var activeIndex = this._pendingSelectionActiveIndex;
		this._pendingSelectionAnchorIndex = -1;
		this._pendingSelectionActiveIndex = -1;
		this.textField.setSelection(anchorIndex, activeIndex);
	}

	private function layoutTextField():Void {
		if (this._smoothScrolling) {
			this.textField.x = this._paddingLeft;
			this.textField.y = this._paddingTop;
			var calculatedWidth = Math.max(this.actualWidth, this._actualVisibleWidth);
			var calculatedHeight = Math.max(this.actualHeight, this._actualVisibleHeight);
			this.textField.width = calculatedWidth - this._paddingLeft - this._paddingRight;
			this.textField.height = calculatedHeight - this._paddingTop - this._paddingBottom;
			this.textField.scrollV = 1;
		} else {
			this.textField.x = this._paddingLeft + this._scrollX;
			this.textField.y = this._paddingTop + this._scrollY;
			this.textField.width = this._actualVisibleWidth - this._paddingLeft - this._paddingRight;
			this.textField.height = this._actualVisibleHeight - this._paddingTop - this._paddingBottom;
			// for some reason, in flash, after changing the TextField's height,
			// you need to access textHeight to get a valid maxScrollV
			var textFieldHeight = this.textField.textHeight;
			var maxScrollX = this.actualWidth - this._actualVisibleWidth;
			var maxScrollY = this.actualHeight - this._actualVisibleHeight;
			if (this.textField.maxScrollV == 1 || maxScrollY == 0.0) {
				this.textField.scrollV = 1;
			} else {
				this.textField.scrollV = 1 + Math.ceil(this._scrollY / (this._savedLineMetrics.height + this._savedLineMetrics.leading));
			}
			if (this.textField.maxScrollH == 0 || maxScrollX == 0.0) {
				this.textField.scrollH = 0;
			} else {
				this.textField.scrollH = Math.round(this.textField.maxScrollH * (this._scrollX / maxScrollX));
			}
		}
	}

	private function textField_changeHandler(event:Event):Void {
		// don't let this event bubble. Feathers UI components don't bubble their
		// events — especially not Event.CHANGE!
		event.stopPropagation();

		// don't try to set the variable directly here because we need to
		// measure again just in case it affected the maximum y scroll position
		this.text = this.textField.text;

		if (this._textFieldHasFocus) {
			// if we have focus, we should update the scroll position so that
			// the caret is visible

			// first, validate the parent container so that the scroll bars are
			// made visible, if they weren't before
			var container = cast(this.parent, BaseScrollContainer);
			container.validateNow();

			if (container.maxScrollY > 0.0) {
				var caretIndex = this.textField.caretIndex;
				if (caretIndex == this.textField.length) {
					caretIndex--;
				}
				var lineIndex = this.textField.getLineIndexOfChar(this.textField.caretIndex - 1);
				if (this._smoothScrolling) {
					var lineHeight = this._savedLineMetrics.height + this._savedLineMetrics.leading;
					var minScrollYForLine = container.maxScrollY - (this.textField.numLines - lineIndex - 1) * lineHeight;
					var maxScrollYForLine = minScrollYForLine + ((this.textField.numLines - Math.floor(this.visibleHeight / lineHeight)) * lineHeight);

					var targetScrollY = this._scrollY;
					if ((minScrollYForLine - targetScrollY) > 0.0) {
						targetScrollY = minScrollYForLine;
					} else if ((targetScrollY - maxScrollYForLine) > 0.0) {
						targetScrollY = maxScrollYForLine;
					}

					container.scrollY = targetScrollY;
				} else if (this.textField.maxScrollV > 1) {
					var minScrollVForLine = this.textField.maxScrollV - (this.textField.numLines - lineIndex - 1);
					var maxScrollVForLine = minScrollVForLine + (this.textField.numLines - this.textField.maxScrollV);
					if (maxScrollVForLine > this.textField.maxScrollV) {
						maxScrollVForLine = this.textField.maxScrollV;
					}

					var targetScrollV = this.textField.scrollV;
					if ((minScrollVForLine - targetScrollV) > 0) {
						targetScrollV = minScrollVForLine;
					} else if ((targetScrollV - maxScrollVForLine) > 0) {
						targetScrollV = maxScrollVForLine;
					}

					if (targetScrollV != this.textField.scrollV) {
						container.scrollY = (targetScrollV - 1) * (this._savedLineMetrics.height + this._savedLineMetrics.leading);
					}
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
		if (this._ignoreTextFieldScroll || this._smoothScrolling) {
			return;
		}
		var container = cast(this.parent, BaseScrollContainer);
		if (container.maxScrollY > 0.0 && this.textField.maxScrollV > 1) {
			container.scrollY = (this.textField.scrollV - 1) * (this._savedLineMetrics.height + this._savedLineMetrics.leading);
		}
	}

	private function textFieldViewPort_focusInHandler(event:FocusEvent):Void {
		if (Reflect.compare(event.target, this) == 0) {
			this.stage.focus = this.textField;
		}
	}
}
