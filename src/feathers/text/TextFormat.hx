/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.text;

import feathers.events.FeathersEvent;
import feathers.utils.TextFormatUtil;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.text.TextFormatAlign;

/**
	A special replacement for `openfl.text.TextFormat` that dispatches
	`Event.CHANGE` when any of its properties changes, and supports creating a
	clone with the same properties.

	@event openfl.events.Event.CHANGE Dispatched when any property of the
	`TextFormat` changes.

	@since 1.0.0
**/
@:event(openfl.events.Event.CHANGE)
class TextFormat extends EventDispatcher {
	/**
		Creates a new `TextFormat` object with the given arguments.

		@since 1.0.0
	**/
	public function new(font:String = null, size:Null<Int> = null, color:Null<Int> = null, bold:Null<Bool> = null, italic:Null<Bool> = null,
			underline:Null<Bool> = null, url:String = null, target:String = null, align:TextFormatAlign = null, leftMargin:Null<Int> = null,
			rightMargin:Null<Int> = null, indent:Null<Int> = null, leading:Null<Int> = null) {
		super();
		this._textFormat = new openfl.text.TextFormat(font, size, color, bold, italic, underline, url, target, align, leftMargin, rightMargin, indent, leading);
	}

	private var _textFormat:openfl.text.TextFormat;

	/**
		@see [`openfl.text.TextFormat.font`](https://api.openfl.org/openfl/text/TextFormat.html#font)
	**/
	@:bindable("change")
	public var font(get, set):String;

	private function get_font():String {
		return this._textFormat.font;
	}

	private function set_font(value:String):String {
		if (this._textFormat.font == value) {
			return this._textFormat.font;
		}
		// create a copy so that it won't pass equality checks
		this._textFormat = TextFormatUtil.clone(this._textFormat);
		this._textFormat.font = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._textFormat.font;
	}

	/**
		@see [`openfl.text.TextFormat.size`](https://api.openfl.org/openfl/text/TextFormat.html#size)
	**/
	@:bindable("change")
	public var size(get, set):Null<Int>;

	private function get_size():Null<Int> {
		return this._textFormat.size;
	}

	private function set_size(value:Null<Int>):Int {
		if (this._textFormat.size == value) {
			return this._textFormat.size;
		}
		// create a copy so that it won't pass equality checks
		this._textFormat = TextFormatUtil.clone(this._textFormat);
		this._textFormat.size = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._textFormat.size;
	}

	/**
		@see [`openfl.text.TextFormat.color`](https://api.openfl.org/openfl/text/TextFormat.html#color)
	**/
	@:bindable("change")
	@:inspectable(format = "Color")
	public var color(get, set):Null<Int>;

	private function get_color():Null<Int> {
		return this._textFormat.color;
	}

	private function set_color(value:Null<Int>):Int {
		if (this._textFormat.color == value) {
			return this._textFormat.color;
		}
		// create a copy so that it won't pass equality checks
		this._textFormat = TextFormatUtil.clone(this._textFormat);
		this._textFormat.color = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._textFormat.color;
	}

	/**
		@see [`openfl.text.TextFormat.bold`](https://api.openfl.org/openfl/text/TextFormat.html#bold)
	**/
	@:bindable("change")
	public var bold(get, set):Null<Bool>;

	private function get_bold():Null<Bool> {
		return this._textFormat.bold;
	}

	private function set_bold(value:Null<Bool>):Null<Bool> {
		if (this._textFormat.bold == value) {
			return this._textFormat.bold;
		}
		// create a copy so that it won't pass equality checks
		this._textFormat = TextFormatUtil.clone(this._textFormat);
		this._textFormat.bold = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._textFormat.bold;
	}

	/**
		@see [`openfl.text.TextFormat.italic`](https://api.openfl.org/openfl/text/TextFormat.html#italic)
	**/
	@:bindable("change")
	public var italic(get, set):Null<Bool>;

	private function get_italic():Null<Bool> {
		return this._textFormat.italic;
	}

	private function set_italic(value:Null<Bool>):Null<Bool> {
		if (this._textFormat.italic == value) {
			return this._textFormat.italic;
		}
		// create a copy so that it won't pass equality checks
		this._textFormat = TextFormatUtil.clone(this._textFormat);
		this._textFormat.italic = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._textFormat.italic;
	}

	/**
		@see [`openfl.text.TextFormat.underline`](https://api.openfl.org/openfl/text/TextFormat.html#underline)
	**/
	@:bindable("change")
	public var underline(get, set):Null<Bool>;

	private function get_underline():Null<Bool> {
		return this._textFormat.underline;
	}

	private function set_underline(value:Null<Bool>):Null<Bool> {
		if (this._textFormat.underline == value) {
			return this._textFormat.underline;
		}
		// create a copy so that it won't pass equality checks
		this._textFormat = TextFormatUtil.clone(this._textFormat);
		this._textFormat.underline = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._textFormat.underline;
	}

	#if (openfl >= "9.5.0" && !flash)
	/**
		@see [`openfl.text.TextFormat.strikethrough`](https://api.openfl.org/openfl/text/TextFormat.html#strikethrough)
	**/
	@:bindable("change")
	public var strikethrough(get, set):Null<Bool>;

	private function get_strikethrough():Null<Bool> {
		return this._textFormat.strikethrough;
	}

	private function set_strikethrough(value:Null<Bool>):Null<Bool> {
		if (this._textFormat.strikethrough == value) {
			return this._textFormat.strikethrough;
		}
		// create a copy so that it won't pass equality checks
		this._textFormat = TextFormatUtil.clone(this._textFormat);
		this._textFormat.strikethrough = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._textFormat.strikethrough;
	}
	#end

	/**
		@see [`openfl.text.TextFormat.url`](https://api.openfl.org/openfl/text/TextFormat.html#url)
	**/
	@:bindable("change")
	public var url(get, set):String;

	private function get_url():String {
		return this._textFormat.url;
	}

	private function set_url(value:String):String {
		if (this._textFormat.url == value) {
			return this._textFormat.url;
		}
		// create a copy so that it won't pass equality checks
		this._textFormat = TextFormatUtil.clone(this._textFormat);
		this._textFormat.url = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._textFormat.url;
	}

	/**
		@see [`openfl.text.TextFormat.target`](https://api.openfl.org/openfl/text/TextFormat.html#target)
	**/
	@:bindable("change")
	public var target(get, set):String;

	private function get_target():String {
		return this._textFormat.target;
	}

	private function set_target(value:String):String {
		if (this._textFormat.target == value) {
			return this._textFormat.target;
		}
		// create a copy so that it won't pass equality checks
		this._textFormat = TextFormatUtil.clone(this._textFormat);
		this._textFormat.target = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._textFormat.target;
	}

	/**
		@see [`openfl.text.TextFormat.align`](https://api.openfl.org/openfl/text/TextFormat.html#align)
	**/
	@:bindable("change")
	public var align(get, set):TextFormatAlign;

	private function get_align():TextFormatAlign {
		return this._textFormat.align;
	}

	private function set_align(value:TextFormatAlign):TextFormatAlign {
		if (this._textFormat.align == value) {
			return this._textFormat.align;
		}
		// create a copy so that it won't pass equality checks
		this._textFormat = TextFormatUtil.clone(this._textFormat);
		this._textFormat.align = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._textFormat.align;
	}

	/**
		@see [`openfl.text.TextFormat.leftMargin`](https://api.openfl.org/openfl/text/TextFormat.html#leftMargin)
	**/
	@:bindable("change")
	public var leftMargin(get, set):Null<Int>;

	private function get_leftMargin():Null<Int> {
		return this._textFormat.leftMargin;
	}

	private function set_leftMargin(value:Null<Int>):Int {
		if (this._textFormat.leftMargin == value) {
			return this._textFormat.leftMargin;
		}
		// create a copy so that it won't pass equality checks
		this._textFormat = TextFormatUtil.clone(this._textFormat);
		this._textFormat.leftMargin = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._textFormat.leftMargin;
	}

	/**
		@see [`openfl.text.TextFormat.rightMargin`](https://api.openfl.org/openfl/text/TextFormat.html#rightMargin)
	**/
	@:bindable("change")
	public var rightMargin(get, set):Null<Int>;

	private function get_rightMargin():Null<Int> {
		return this._textFormat.rightMargin;
	}

	private function set_rightMargin(value:Null<Int>):Int {
		if (this._textFormat.rightMargin == value) {
			return this._textFormat.rightMargin;
		}
		// create a copy so that it won't pass equality checks
		this._textFormat = TextFormatUtil.clone(this._textFormat);
		this._textFormat.rightMargin = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._textFormat.rightMargin;
	}

	/**
		@see [`openfl.text.TextFormat.indent`](https://api.openfl.org/openfl/text/TextFormat.html#indent)
	**/
	@:bindable("change")
	public var indent(get, set):Null<Int>;

	private function get_indent():Null<Int> {
		return this._textFormat.indent;
	}

	private function set_indent(value:Null<Int>):Int {
		if (this._textFormat.indent == value) {
			return this._textFormat.indent;
		}
		// create a copy so that it won't pass equality checks
		this._textFormat = TextFormatUtil.clone(this._textFormat);
		this._textFormat.indent = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._textFormat.indent;
	}

	/**
		@see [`openfl.text.TextFormat.leading`](https://api.openfl.org/openfl/text/TextFormat.html#leading)
	**/
	@:bindable("change")
	public var leading(get, set):Null<Int>;

	private function get_leading():Null<Int> {
		return this._textFormat.leading;
	}

	private function set_leading(value:Null<Int>):Int {
		if (this._textFormat.leading == value) {
			return this._textFormat.leading;
		}
		// create a copy so that it won't pass equality checks
		this._textFormat = TextFormatUtil.clone(this._textFormat);
		this._textFormat.leading = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._textFormat.leading;
	}

	/**
		@see [`openfl.text.TextFormat.blockIndent`](https://api.openfl.org/openfl/text/TextFormat.html#blockIndent)
	**/
	@:bindable("change")
	public var blockIndent(get, set):Null<Int>;

	private function get_blockIndent():Null<Int> {
		return this._textFormat.blockIndent;
	}

	private function set_blockIndent(value:Null<Int>):Int {
		if (this._textFormat.blockIndent == value) {
			return this._textFormat.blockIndent;
		}
		// create a copy so that it won't pass equality checks
		this._textFormat = TextFormatUtil.clone(this._textFormat);
		this._textFormat.blockIndent = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._textFormat.blockIndent;
	}

	/**
		@see [`openfl.text.TextFormat.bullet`](https://api.openfl.org/openfl/text/TextFormat.html#bullet)
	**/
	@:bindable("change")
	public var bullet(get, set):Null<Bool>;

	private function get_bullet():Null<Bool> {
		return this._textFormat.bullet;
	}

	private function set_bullet(value:Null<Bool>):Null<Bool> {
		if (this._textFormat.bullet == value) {
			return this._textFormat.bullet;
		}
		// create a copy so that it won't pass equality checks
		this._textFormat = TextFormatUtil.clone(this._textFormat);
		this._textFormat.bullet = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._textFormat.bullet;
	}

	/**
		@see [`openfl.text.TextFormat.kerning`](https://api.openfl.org/openfl/text/TextFormat.html#kerning)
	**/
	@:bindable("change")
	public var kerning(get, set):Null<Bool>;

	private function get_kerning():Null<Bool> {
		return this._textFormat.kerning;
	}

	private function set_kerning(value:Null<Bool>):Null<Bool> {
		if (this._textFormat.kerning == value) {
			return this._textFormat.kerning;
		}
		// create a copy so that it won't pass equality checks
		this._textFormat = TextFormatUtil.clone(this._textFormat);
		this._textFormat.kerning = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._textFormat.kerning;
	}

	/**
		@see [`openfl.text.TextFormat.letterSpacing`](https://api.openfl.org/openfl/text/TextFormat.html#letterSpacing)
	**/
	@:bindable("change")
	public var letterSpacing(get, set):Null<Float>;

	private function get_letterSpacing():Null<Float> {
		return this._textFormat.letterSpacing;
	}

	private function set_letterSpacing(value:Null<Float>):Null<Float> {
		if (this._textFormat.letterSpacing == value) {
			return this._textFormat.letterSpacing;
		}
		// create a copy so that it won't pass equality checks
		this._textFormat = TextFormatUtil.clone(this._textFormat);
		this._textFormat.letterSpacing = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._textFormat.letterSpacing;
	}

	/**
		@see [`openfl.text.TextFormat.tabStops`](https://api.openfl.org/openfl/text/TextFormat.html#tabStops)
	**/
	@:bindable("change")
	public var tabStops(get, set):Array<Int>;

	private function get_tabStops():Array<Int> {
		return this._textFormat.tabStops;
	}

	private function set_tabStops(value:Array<Int>):Array<Int> {
		if (this._textFormat.tabStops == value) {
			return this._textFormat.tabStops;
		}
		this._textFormat = TextFormatUtil.clone(this._textFormat);
		this._textFormat.tabStops = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._textFormat.tabStops;
	}

	/**
		Creates a copy of the `feathers.text.TextFormat` object.

		@since 1.0.0
	**/
	public function clone():TextFormat {
		var clone = new TextFormat(this.font, this.size, this.color, this.bold, this.italic, this.underline, this.url, this.target, this.align,
			this.leftMargin, this.rightMargin, this.indent, this.leading);
		clone._textFormat.blockIndent = this.blockIndent;
		clone._textFormat.bullet = this.bullet;
		clone._textFormat.kerning = this.kerning;
		clone._textFormat.letterSpacing = this.letterSpacing;
		#if (openfl >= "9.5.0" && !flash)
		clone._textFormat.strikethrough = this.strikethrough;
		#end
		clone._textFormat.tabStops = this.tabStops;
		return clone;
	}

	/**
		Returns an `openfl.text.TextFormat` object.

		@since 1.0.0
	**/
	public function toSimpleTextFormat():openfl.text.TextFormat {
		return this._textFormat;
	}
}

/**
	Converts a `openfl.text.TextFormat` value to a `feathers.text.TextFormat`
	used by many Feathers UI components.

	@see `feathers.text.TextFormat`

	@since 1.0.0
**/
@:forward(font, size, color, bold, italic, underline, url, target, align, leftMargin, rightMargin, indent, leading, blockIndent, bullet, kerning,
	letterSpacing, tabStops, clone #if (openfl >= "9.5.0" && !flash), strikethrough #end)
abstract AbstractTextFormat(TextFormat) from TextFormat to TextFormat {
	/**
		Converts an `openfl.text.TextFormat` value to a
		`feathers.text.TextFormat` value.

		@since 1.0.0
	**/
	@:from
	public static function fromSimpleTextFormat(textFormat:openfl.text.TextFormat):AbstractTextFormat {
		if (textFormat == null) {
			return null;
		}
		var clone = new TextFormat(textFormat.font, textFormat.size, textFormat.color, textFormat.bold, textFormat.italic, textFormat.underline,
			textFormat.url, textFormat.target, textFormat.align, textFormat.leftMargin, textFormat.rightMargin, textFormat.indent, textFormat.leading);
		clone.blockIndent = textFormat.blockIndent;
		clone.bullet = textFormat.bullet;
		clone.kerning = textFormat.kerning;
		clone.letterSpacing = textFormat.letterSpacing;
		#if (openfl >= "9.5.0" && !flash)
		clone.strikethrough = textFormat.strikethrough;
		#end
		clone.tabStops = textFormat.tabStops;
		return clone;
	}

	/**
		Converts a `feathers.text.TextFormat` value to an
		`openfl.text.TextFormat` value.
	**/
	@:to
	public function toSimpleTextFormat():openfl.text.TextFormat {
		return this.toSimpleTextFormat();
	}
}
