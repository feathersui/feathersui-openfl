/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.layout;

import feathers.events.FeathersEvent;
import feathers.layout.ResponsiveGridLayout.Breakpoint;
import openfl.errors.ArgumentError;
import openfl.events.Event;
import openfl.events.EventDispatcher;

/**
	Sets the optional span and offset for an item in a `ResponsiveGridLayout`.

	@event openfl.events.Event.CHANGE Dispatched when a property of the layout
	data changes, which triggers the container to invalidate.

	@see `feathers.layout.ResponsiveGridLayout`

	@since 1.0.0
**/
@:event(openfl.events.Event.CHANGE)
class ResponsiveGridLayoutData extends EventDispatcher implements ILayoutData {
	/**
		Creates a new `ResponsiveGridLayoutData` object from the given arguments.

		@since 1.0.0
	**/
	public function new(span:Int = 1, offset:Int = 0, smSpan:Int = -1, smOffset:Int = -1, mdSpan:Int = -1, mdOffset:Int = -1, lgSpan:Int = -1,
			lgOffset:Int = -1, xlSpan:Int = -1, xlOffset:Int = -1) {
		super();

		this.span = span;
		this.offset = offset;
		this.smSpan = smSpan;
		this.smOffset = smOffset;
		this.mdSpan = mdSpan;
		this.mdOffset = mdOffset;
		this.lgSpan = lgSpan;
		this.lgOffset = lgOffset;
		this.xlSpan = xlSpan;
		this.xlOffset = xlOffset;
	}

	private var _span:Int = 1;

	/**
		The number of columns that this item spans.

		@since 1.0.0
	**/
	@:bindable("change")
	public var span(get, set):Int;

	private function get_span():Int {
		return this._span;
	}

	private function set_span(value:Int):Int {
		if (value <= 0) {
			throw new ArgumentError("span must be greater than 0");
		}
		if (this._span == value) {
			return this._span;
		}
		this._span = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._span;
	}

	private var _offset:Int = 0;

	/**
		The number of empty columns to display before the start of this item.

		@since 1.0.0
	**/
	@:bindable("change")
	public var offset(get, set):Int;

	private function get_offset():Int {
		return this._offset;
	}

	private function set_offset(value:Int):Int {
		if (this._offset == value) {
			return this._offset;
		}
		this._offset = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._offset;
	}

	private var _display:Bool = true;

	/**
		Indicates if the item should be displayed by the layout or not.

		@since 1.0.0
	**/
	@:bindable("change")
	public var display(get, set):Bool;

	private function get_display():Bool {
		return this._display;
	}

	private function set_display(value:Bool):Bool {
		if (this._display == value) {
			return this._display;
		}
		this._display = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._display;
	}

	private var _smSpan:Int = -1;

	/**
		The number of columns that this item spans when the layout is using the
		_sm_ breakpoint. Set to `-1` to fall back to the default `span`.

		@see `feathers.layout.ResponsiveGridLayout.sm`

		@since 1.0.0
	**/
	@:bindable("change")
	public var smSpan(get, set):Int;

	private function get_smSpan():Int {
		return this._smSpan;
	}

	private function set_smSpan(value:Int):Int {
		if (this._smSpan == value) {
			return this._smSpan;
		}
		this._smSpan = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._smSpan;
	}

	private var _smOffset:Int = -1;

	/**
		The number of empty columns to display before the start of this item
		when the layout is using the _sm_ breakpoint. Set to `-1` to fall back
		to the default `offset`.

		@see `feathers.layout.ResponsiveGridLayout.sm`

		@since 1.0.0
	**/
	@:bindable("change")
	public var smOffset(get, set):Int;

	private function get_smOffset():Int {
		return this._smOffset;
	}

	private function set_smOffset(value:Int):Int {
		if (this._smOffset == value) {
			return this._smOffset;
		}
		this._smOffset = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._smOffset;
	}

	private var _smDisplay:Null<Bool> = null;

	/**
		Indicates if the item should be displayed by the layout or not when the
		layout is using the _sm_ breakpoint. Set to `null` to fall back to the
		default `display`.

		@see `feathers.layout.ResponsiveGridLayout.sm`

		@since 1.0.0
	**/
	@:bindable("change")
	public var smDisplay(get, set):Null<Bool>;

	private function get_smDisplay():Null<Bool> {
		return this._smDisplay;
	}

	private function set_smDisplay(value:Null<Bool>):Null<Bool> {
		if (this._smDisplay == value) {
			return this._smDisplay;
		}
		this._smDisplay = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._smDisplay;
	}

	private var _mdSpan:Int = -1;

	/**
		The number of columns that this item spans when the layout is using the
		_md_ breakpoint. Set to `-1` to fall back to `smSpan`.

		@see `feathers.layout.ResponsiveGridLayout.md`

		@since 1.0.0
	**/
	@:bindable("change")
	public var mdSpan(get, set):Int;

	private function get_mdSpan():Int {
		return this._mdSpan;
	}

	private function set_mdSpan(value:Int):Int {
		if (this._mdSpan == value) {
			return this._mdSpan;
		}
		this._mdSpan = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._mdSpan;
	}

	private var _mdOffset:Int = -1;

	/**
		The number of empty columns to display before the start of this item
		when the layout is using the _md_ breakpoint. Set to `-1` to fall back
		to `smOffset`.

		@see `feathers.layout.ResponsiveGridLayout.md`

		@since 1.0.0
	**/
	@:bindable("change")
	public var mdOffset(get, set):Int;

	private function get_mdOffset():Int {
		return this._mdOffset;
	}

	private function set_mdOffset(value:Int):Int {
		if (this._mdOffset == value) {
			return this._mdOffset;
		}
		this._mdOffset = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._mdOffset;
	}

	private var _mdDisplay:Null<Bool> = null;

	/**
		Indicates if the item should be displayed by the layout or not when the
		layout is using the _md_ breakpoint. Set to `null` to fall back to the
		`smDisplay`.

		@see `feathers.layout.ResponsiveGridLayout.md`

		@since 1.0.0
	**/
	@:bindable("change")
	public var mdDisplay(get, set):Null<Bool>;

	private function get_mdDisplay():Null<Bool> {
		return this._mdDisplay;
	}

	private function set_mdDisplay(value:Null<Bool>):Null<Bool> {
		if (this._mdDisplay == value) {
			return this._mdDisplay;
		}
		this._mdDisplay = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._mdDisplay;
	}

	private var _lgSpan:Int = -1;

	/**
		The number of columns that this item spans when the layout is using the
		_lg_ breakpoint. Set to `-1` to fall back to `mdSpan`.

		@see `feathers.layout.ResponsiveGridLayout.lg`

		@since 1.0.0
	**/
	@:bindable("change")
	public var lgSpan(get, set):Int;

	private function get_lgSpan():Int {
		return this._lgSpan;
	}

	private function set_lgSpan(value:Int):Int {
		if (this._lgSpan == value) {
			return this._lgSpan;
		}
		this._lgSpan = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._lgSpan;
	}

	private var _lgOffset:Int = -1;

	/**
		The number of empty columns to display before the start of this item
		when the layout is using the _lg_ breakpoint. Set to `-1` to fall back
		to `mdOffset`.

		@see `feathers.layout.ResponsiveGridLayout.lg`

		@since 1.0.0
	**/
	@:bindable("change")
	public var lgOffset(get, set):Int;

	private function get_lgOffset():Int {
		return this._lgOffset;
	}

	private function set_lgOffset(value:Int):Int {
		if (this._lgOffset == value) {
			return this._lgOffset;
		}
		this._lgOffset = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._lgOffset;
	}

	private var _lgDisplay:Null<Bool> = null;

	/**
		Indicates if the item should be displayed by the layout or not when the
		layout is using the _lg_ breakpoint. Set to `null` to fall back to the
		`mdDisplay`.

		@see `feathers.layout.ResponsiveGridLayout.lg`

		@since 1.0.0
	**/
	@:bindable("change")
	public var lgDisplay(get, set):Null<Bool>;

	private function get_lgDisplay():Null<Bool> {
		return this._lgDisplay;
	}

	private function set_lgDisplay(value:Null<Bool>):Null<Bool> {
		if (this._lgDisplay == value) {
			return this._lgDisplay;
		}
		this._lgDisplay = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._lgDisplay;
	}

	private var _xlSpan:Int = -1;

	/**
		The number of columns that this item spans when the layout is using the
		_xl_ breakpoint. Set to `-1` to fall back to `lgSpan`.

		@see `feathers.layout.ResponsiveGridLayout.xl`

		@since 1.0.0
	**/
	@:bindable("change")
	public var xlSpan(get, set):Int;

	private function get_xlSpan():Int {
		return this._xlSpan;
	}

	private function set_xlSpan(value:Int):Int {
		if (this._xlSpan == value) {
			return this._xlSpan;
		}
		this._xlSpan = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._xlSpan;
	}

	private var _xlOffset:Int = -1;

	/**
		The number of empty columns to display before the start of this item
		when the layout is using the _xl_ breakpoint. Set to `-1` to fall back
		to `lgOffset`.

		@see `feathers.layout.ResponsiveGridLayout.xl`

		@since 1.0.0
	**/
	@:bindable("change")
	public var xlOffset(get, set):Int;

	private function get_xlOffset():Int {
		return this._xlOffset;
	}

	private function set_xlOffset(value:Int):Int {
		if (this._xlOffset == value) {
			return this._xlOffset;
		}
		this._xlOffset = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._xlOffset;
	}

	private var _xlDisplay:Null<Bool> = null;

	/**
		Indicates if the item should be displayed by the layout or not when the
		layout is using the _xl_ breakpoint. Set to `null` to fall back to the
		`lgDisplay`.

		@see `feathers.layout.ResponsiveGridLayout.xl`

		@since 1.0.0
	**/
	@:bindable("change")
	public var xlDisplay(get, set):Null<Bool>;

	private function get_xlDisplay():Null<Bool> {
		return this._xlDisplay;
	}

	private function set_xlDisplay(value:Null<Bool>):Null<Bool> {
		if (this._xlDisplay == value) {
			return this._xlDisplay;
		}
		this._xlDisplay = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._xlDisplay;
	}

	private var _xxlSpan:Int = -1;

	/**
		The number of columns that this item spans when the layout is using the
		_xxl_ breakpoint. Set to `-1` to fall back to `xlSpan`.

		@see `feathers.layout.ResponsiveGridLayout.xxl`

		@since 1.0.0
	**/
	@:bindable("change")
	public var xxlSpan(get, set):Int;

	private function get_xxlSpan():Int {
		return this._xxlSpan;
	}

	private function set_xxlSpan(value:Int):Int {
		if (this._xxlSpan == value) {
			return this._xxlSpan;
		}
		this._xxlSpan = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._xxlSpan;
	}

	private var _xxlOffset:Int = -1;

	/**
		The number of empty columns to display before the start of this item
		when the layout is using the _xxl_ breakpoint. Set to `-1` to fall back
		to `xlOffset`.

		@see `feathers.layout.ResponsiveGridLayout.xxl`

		@since 1.0.0
	**/
	@:bindable("change")
	public var xxlOffset(get, set):Int;

	private function get_xxlOffset():Int {
		return this._xxlOffset;
	}

	private function set_xxlOffset(value:Int):Int {
		if (this._xxlOffset == value) {
			return this._xxlOffset;
		}
		this._xxlOffset = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._xxlOffset;
	}

	private var _xxlDisplay:Null<Bool> = null;

	/**
		Indicates if the item should be displayed by the layout or not when the
		layout is using the _xxl_ breakpoint. Set to `null` to fall back to the
		`xlDisplay`.

		@see `feathers.layout.ResponsiveGridLayout.xxl`

		@since 1.0.0
	**/
	@:bindable("change")
	public var xxlDisplay(get, set):Null<Bool>;

	private function get_xxlDisplay():Null<Bool> {
		return this._xxlDisplay;
	}

	private function set_xxlDisplay(value:Null<Bool>):Null<Bool> {
		if (this._xxlDisplay == value) {
			return this._xxlDisplay;
		}
		this._xxlDisplay = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._xxlDisplay;
	}

	private function getSpan(breakpoint:Breakpoint):Int {
		return switch (breakpoint) {
			case XXL:
				if (this._xxlSpan == -1) {
					return this.getSpan(XL);
				}
				return this._xxlSpan;
			case XL:
				if (this._xlSpan == -1) {
					return this.getSpan(LG);
				}
				return this._xlSpan;
			case LG:
				if (this._lgSpan == -1) {
					return this.getSpan(MD);
				}
				return this._lgSpan;
			case MD:
				if (this._mdSpan == -1) {
					return this.getSpan(SM);
				}
				return this._mdSpan;
			case SM:
				if (this._smSpan == -1) {
					return this.getSpan(XS);
				}
				return this._smSpan;
			case XS:
				return this._span;
			default:
				throw new ArgumentError("Unknown ResponseGridLayout breakpoint: " + breakpoint);
		}
	}

	private function getOffset(breakpoint:Breakpoint):Int {
		return switch (breakpoint) {
			case XXL:
				if (this._xxlOffset == -1) {
					return this.getOffset(XL);
				}
				return this._xxlOffset;
			case XL:
				if (this._xlOffset == -1) {
					return this.getOffset(LG);
				}
				return this._xlOffset;
			case LG:
				if (this._lgOffset == -1) {
					return this.getOffset(MD);
				}
				return this._lgOffset;
			case MD:
				if (this._mdOffset == -1) {
					return this.getOffset(SM);
				}
				return this._mdOffset;
			case SM:
				if (this._smOffset == -1) {
					return this.getOffset(XS);
				}
				return this._smOffset;
			case XS:
				return this._offset;
			default:
				throw new ArgumentError("Unknown ResponseGridLayout breakpoint: " + breakpoint);
		}
	}

	private function getDisplay(breakpoint:Breakpoint):Bool {
		return switch (breakpoint) {
			case XXL:
				if (this._xxlDisplay == null) {
					return this.getDisplay(XL);
				}
				return this._xxlDisplay;
			case XL:
				if (this._xlDisplay == null) {
					return this.getDisplay(LG);
				}
				return this._xlDisplay;
			case LG:
				if (this._lgDisplay == null) {
					return this.getDisplay(MD);
				}
				return this._lgDisplay;
			case MD:
				if (this._mdDisplay == null) {
					return this.getDisplay(SM);
				}
				return this._mdDisplay;
			case SM:
				if (this._smDisplay == null) {
					return this.getDisplay(XS);
				}
				return this._smDisplay;
			case XS:
				return this._display;
			default:
				throw new ArgumentError("Unknown ResponseGridLayout breakpoint: " + breakpoint);
		}
	}
}
