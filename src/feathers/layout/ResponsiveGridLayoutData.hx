/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.layout;

import feathers.layout.ResponsiveGridLayout.Breakpoint;
import openfl.errors.ArgumentError;
import openfl.events.Event;
import feathers.events.FeathersEvent;
import openfl.events.EventDispatcher;

/**
	Sets the optional span and offset for an item in a `ResponsiveGridLayout`.

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
	@:flash.property
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
	@:flash.property
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

	private var _smSpan:Int = -1;

	/**
		The number of columns that this item spans when the layout is using the
		_sm_ breakpoint. Set to `-1` to fall back to the default `span`.

		@see `feathers.layout.ResponsiveGridLayout.sm`

		@since 1.0.0
	**/
	@:flash.property
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
	@:flash.property
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

	private var _mdSpan:Int = -1;

	/**
		The number of columns that this item spans when the layout is using the
		_md_ breakpoint. Set to `-1` to fall back to `smSpan`.

		@see `feathers.layout.ResponsiveGridLayout.md`

		@since 1.0.0
	**/
	@:flash.property
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
	@:flash.property
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

	private var _lgSpan:Int = -1;

	/**
		The number of columns that this item spans when the layout is using the
		_lg_ breakpoint. Set to `-1` to fall back to `mdSpan`.

		@see `feathers.layout.ResponsiveGridLayout.lg`

		@since 1.0.0
	**/
	@:flash.property
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
	@:flash.property
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

	private var _xlSpan:Int = -1;

	/**
		The number of columns that this item spans when the layout is using the
		_xl_ breakpoint. Set to `-1` to fall back to `lgSpan`.

		@see `feathers.layout.ResponsiveGridLayout.xl`

		@since 1.0.0
	**/
	@:flash.property
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
	@:flash.property
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

	private function getSpan(breakpoint:Breakpoint):Int {
		return switch (breakpoint) {
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
}
