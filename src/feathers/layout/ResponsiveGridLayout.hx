/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.layout;

import feathers.core.IMeasureObject;
import feathers.core.IValidating;
import feathers.events.FeathersEvent;
import openfl.display.DisplayObject;
import openfl.errors.ArgumentError;
import openfl.errors.IllegalOperationError;
import openfl.events.Event;
import openfl.events.EventDispatcher;

/**
	Positions items in a grid, with a specific number of columns (defaults to
	twelve columns). Items may span multiple columns and may be displayed with
	offsets in between. When a row is "full", meaning that all twelve columns
	have been filled, items are laid out starting on the next row automatically.

	@event openfl.events.Event.CHANGE Dispatched when a property of the layout
	changes, which triggers the container to invalidate.

	@see [Tutorial: How to use ResponsiveGridLayout with layout containers](https://feathersui.com/learn/haxe-openfl/responsive-grid-layout/)
	@see `feathers.layout.ResponsiveGridLayoutData`

	@since 1.0.0
**/
@:event(openfl.events.Event.CHANGE)
@:access(feathers.layout.ResponsiveGridLayoutData)
class ResponsiveGridLayout extends EventDispatcher implements ILayout {
	/**
		Creates a new `ResponsiveGridLayout` object from the given arguments.

		@since 1.0.0
	**/
	public function new(columnCount:Int = 12, sm:Float = 576.0, md:Float = 768.0, lg:Float = 992.0, xl:Float = 1200.0, xxl:Float = 1400.0) {
		super();
		this._columnCount = columnCount;
		this._sm = sm;
		this._md = md;
		this._lg = lg;
		this._xl = xl;
		this._xxl = xxl;
	}

	private var _columnCount:Int;

	/**
		The number of columns in the grid.

		In the following example, the number of columns in the layout is set to 6:

		```haxe
		layout.columnCount = 6;
		```

		@since 1.0.0
	**/
	@:bindable("change")
	public var columnCount(get, set):Int;

	private function get_columnCount():Int {
		return this._columnCount;
	}

	private function set_columnCount(value:Int):Int {
		if (this._columnCount == value) {
			return this._columnCount;
		}
		this._columnCount = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._columnCount;
	}

	private var _sm:Float = 576.0;

	/**
		The minimum size of the _sm_ breakpoint, measured in pixels.

		In the following example, the layout's _sm_ breakpoint is set to 1000 pixels:

		```haxe
		layout.lg = 1000.0;
		```

		@since 1.0.0
	**/
	@:bindable("change")
	public var sm(get, set):Float;

	private function get_sm():Float {
		return this._sm;
	}

	private function set_sm(value:Float):Float {
		if (this._sm == value) {
			return this._sm;
		}
		this._sm = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._sm;
	}

	private var _md:Float = 768.0;

	/**
		The minimum size of the _md_ breakpoint, measured in pixels. Must be
		greater than or equal to the size of the _sm_ breakpoint.

		In the following example, the layout's _md_ breakpoint is set to 1000 pixels:

		```haxe
		layout.lg = 1000.0;
		```

		@since 1.0.0
	**/
	@:bindable("change")
	public var md(get, set):Float;

	private function get_md():Float {
		return this._md;
	}

	private function set_md(value:Float):Float {
		if (this._md == value) {
			return this._md;
		}
		this._md = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._md;
	}

	private var _lg:Float = 992.0;

	/**
		The minimum size of the _lg_ breakpoint, measured in pixels. Must be
		greater than or equal to the size of the _md_ breakpoint.

		In the following example, the layout's _lg_ breakpoint is set to 1000 pixels:

		```haxe
		layout.lg = 1000.0;
		```

		@since 1.0.0
	**/
	@:bindable("change")
	public var lg(get, set):Float;

	private function get_lg():Float {
		return this._lg;
	}

	private function set_lg(value:Float):Float {
		if (this._lg == value) {
			return this._lg;
		}
		this._lg = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._lg;
	}

	private var _xl:Float = 1200.0;

	/**
		The minimum size of the _xl_ breakpoint, measured in pixels. Must be
		greater than or equal to the size of the _lg_ breakpoint.

		In the following example, the layout's _xl_ breakpoint is set to 1000 pixels:

		```haxe
		layout.xl = 1000.0;
		```

		@since 1.0.0
	**/
	@:bindable("change")
	public var xl(get, set):Float;

	private function get_xl():Float {
		return this._xl;
	}

	private function set_xl(value:Float):Float {
		if (this._xl == value) {
			return this._xl;
		}
		this._xl = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._xl;
	}

	private var _xxl:Float = 1400.0;

	/**
		The minimum size of the _xxl_ breakpoint, measured in pixels. Must be
		greater than or equal to the size of the _xl_ breakpoint.

		In the following example, the layout's _xxl_ breakpoint is set to 1000 pixels:

		```haxe
		layout.xxl = 1000.0;
		```

		@since 1.0.0
	**/
	@:bindable("change")
	public var xxl(get, set):Float;

	private function get_xxl():Float {
		return this._xxl;
	}

	private function set_xxl(value:Float):Float {
		if (this._xxl == value) {
			return this._xxl;
		}
		this._xxl = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._xxl;
	}

	private var _rowGap:Float = 0.0;

	/**
		The gap, in pixels, between each row.

		In the following example, the layout's row gap is set to 20 pixels:

		```haxe
		layout.rowGap = 20.0;
		```

		@since 1.0.0
	**/
	@:bindable("change")
	public var rowGap(get, set):Float;

	private function get_rowGap():Float {
		return this._rowGap;
	}

	private function set_rowGap(value:Float):Float {
		if (this._rowGap == value) {
			return this._rowGap;
		}
		this._rowGap = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._rowGap;
	}

	private var _columnGap:Float = 0.0;

	/**
		The gap, in pixels, between each column.

		In the following example, the layout's column gap is set to 20 pixels:

		```haxe
		layout.columnGap = 20.0;
		```

		@since 1.0.0
	**/
	@:bindable("change")
	public var columnGap(get, set):Float;

	private function get_columnGap():Float {
		return this._columnGap;
	}

	private function set_columnGap(value:Float):Float {
		if (this._columnGap == value) {
			return this._columnGap;
		}
		this._columnGap = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._columnGap;
	}

	private var _paddingTop:Float = 0.0;

	/**
		The space, in pixels, between the parent container's top edge and its
		content.

		In the following example, the layout's top padding is set to 20 pixels:

		```haxe
		layout.paddingTop = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:bindable("change")
	public var paddingTop(get, set):Float;

	private function get_paddingTop():Float {
		return this._paddingTop;
	}

	private function set_paddingTop(value:Float):Float {
		if (this._paddingTop == value) {
			return this._paddingTop;
		}
		this._paddingTop = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._paddingTop;
	}

	private var _paddingRight:Float = 0.0;

	/**
		The space, in pixels, between the parent container's right edge and its
		content.

		In the following example, the layout's right padding is set to 20 pixels:

		```haxe
		layout.paddingRight = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:bindable("change")
	public var paddingRight(get, set):Float;

	private function get_paddingRight():Float {
		return this._paddingRight;
	}

	private function set_paddingRight(value:Float):Float {
		if (this._paddingRight == value) {
			return this._paddingRight;
		}
		this._paddingRight = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._paddingRight;
	}

	private var _paddingBottom:Float = 0.0;

	/**
		The space, in pixels, between the parent container's bottom edge and its
		content.

		In the following example, the layout's bottom padding is set to 20 pixels:

		```haxe
		layout.paddingBottom = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:bindable("change")
	public var paddingBottom(get, set):Float;

	private function get_paddingBottom():Float {
		return this._paddingBottom;
	}

	private function set_paddingBottom(value:Float):Float {
		if (this._paddingBottom == value) {
			return this._paddingBottom;
		}
		this._paddingBottom = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._paddingBottom;
	}

	private var _paddingLeft:Float = 0.0;

	/**
		The space, in pixels, between the parent container's left edge and its
		content.

		In the following example, the layout's left padding is set to 20 pixels:

		```haxe
		layout.paddingLeft = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:bindable("change")
	public var paddingLeft(get, set):Float;

	private function get_paddingLeft():Float {
		return this._paddingLeft;
	}

	private function set_paddingLeft(value:Float):Float {
		if (this._paddingLeft == value) {
			return this._paddingLeft;
		}
		this._paddingLeft = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._paddingLeft;
	}

	private var _rowVerticalAlign:VerticalAlign = TOP;

	/**
		How items in a row are positioned vertically (along the y-axis) within
		that row.

		The following example aligns each row's content to the bottom:

		```haxe
		layout.rowVerticalAlign = BOTTOM;
		```

		@default feathers.layout.VerticalAlign.TOP

		@see `feathers.layout.VerticalAlign.TOP`
		@see `feathers.layout.VerticalAlign.MIDDLE`
		@see `feathers.layout.VerticalAlign.BOTTOM`
		@see `feathers.layout.VerticalAlign.JUSTIFY`
		@see `ResponsiveGridLayout.justifyResetEnabled`

		@since 1.0.0
	**/
	@:bindable("change")
	public var rowVerticalAlign(get, set):VerticalAlign;

	private function get_rowVerticalAlign():VerticalAlign {
		return this._rowVerticalAlign;
	}

	private function set_rowVerticalAlign(value:VerticalAlign):VerticalAlign {
		if (this._rowVerticalAlign == value) {
			return this._rowVerticalAlign;
		}
		this._rowVerticalAlign = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._rowVerticalAlign;
	}

	private var _justifyResetEnabled:Bool = false;

	/**
		Indicates if the height of items should be reset if the
		`rowVerticalAlign` property is set to `VerticalAlign.JUSTIFY`.

		@see `HorizontalLayout.rowVerticalAlign`

		@since 1.0.0
	**/
	@:bindable("change")
	public var justifyResetEnabled(get, set):Bool;

	private function get_justifyResetEnabled():Bool {
		return this._justifyResetEnabled;
	}

	private function set_justifyResetEnabled(value:Bool):Bool {
		if (this._justifyResetEnabled == value) {
			return this._justifyResetEnabled;
		}
		this._justifyResetEnabled = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._justifyResetEnabled;
	}

	/**
		Sets all four padding properties to the same value.

		@see `ResponsiveGridLayout.paddingTop`
		@see `ResponsiveGridLayout.paddingRight`
		@see `ResponsiveGridLayout.paddingBottom`
		@see `ResponsiveGridLayout.paddingLeft`

		@since 1.0.0
	**/
	public function setPadding(value:Float):Void {
		this.paddingTop = value;
		this.paddingRight = value;
		this.paddingBottom = value;
		this.paddingLeft = value;
	}

	/**
		Sets both column and row gap properties to the same value.

		@see `ResponsiveGridLayout.columnGap`
		@see `ResponsiveGridLayout.rowGap`

		@since 1.0.0
	**/
	public function setGap(value:Float):Void {
		this.columnGap = value;
		this.rowGap = value;
	}

	private var _rowItems:Array<DisplayObject> = [];

	/**
		@see `feathers.layout.ILayout.layout()`
	**/
	public function layout(items:Array<DisplayObject>, measurements:Measurements, ?result:LayoutBoundsResult):LayoutBoundsResult {
		if (this._xxl < this._xl) {
			throw new IllegalOperationError("xxl must be greater than xl");
		}
		if (this._xl < this._lg) {
			throw new IllegalOperationError("xl must be greater than lg");
		}
		if (this._lg < this._md) {
			throw new IllegalOperationError("lg must be greater than md");
		}
		if (this._md < this._sm) {
			throw new IllegalOperationError("md must be greater than sm");
		}

		var viewPortWidth = (measurements.width != null) ? measurements.width : this._md;
		var contentHeight = this.layoutItems(items, viewPortWidth);
		var viewPortHeight = contentHeight;
		if (measurements.height != null) {
			viewPortHeight = measurements.height;
		}

		if (result == null) {
			result = new LayoutBoundsResult();
		}
		result.contentX = 0.0;
		result.contentY = 0.0;
		result.contentWidth = viewPortWidth;
		result.contentHeight = contentHeight;
		result.viewPortWidth = viewPortWidth;
		result.viewPortHeight = viewPortHeight;
		return result;
	}

	private function layoutItems(items:Array<DisplayObject>, viewPortWidth:Float):Float {
		var breakpoint = this.getBreakpoint(viewPortWidth);
		var availableWidth = viewPortWidth - this._paddingLeft - this._paddingRight;
		var columnWidth = ((availableWidth + this._columnGap) / this._columnCount) - this._columnGap;
		var totalOffset = 0;
		var yPosition = this._paddingTop;
		var maxRowHeight = 0.0;
		#if (hl && haxe_ver < 4.3)
		this._rowItems.splice(0, this._rowItems.length);
		#else
		this._rowItems.resize(0);
		#end
		for (item in items) {
			if ((item is ILayoutObject)) {
				var layoutItem:ILayoutObject = cast item;
				if (!layoutItem.includeInLayout) {
					continue;
				}
			}
			var display = this.getDisplay(item, breakpoint);
			item.visible = display;
			if (!display) {
				continue;
			}
			var span = this.getSpan(item, breakpoint);
			var offset = this.getOffset(item, span, breakpoint);
			if (totalOffset + offset + span > this._columnCount) {
				this.alignRow(yPosition, maxRowHeight);
				#if (hl && haxe_ver < 4.3)
				this._rowItems.splice(0, this._rowItems.length);
				#else
				this._rowItems.resize(0);
				#end
				totalOffset = 0;
				yPosition += maxRowHeight + this._rowGap;
				maxRowHeight = 0.0;
			}
			totalOffset += offset;
			this.positionItem(item, span, totalOffset, columnWidth, yPosition);
			totalOffset += span;
			maxRowHeight = Math.max(maxRowHeight, item.height);
			this._rowItems.push(item);
		}
		this.alignRow(yPosition, maxRowHeight);
		// we don't want to keep a reference to any of the items, so clear
		// this cache
		#if (hl && haxe_ver < 4.3)
		this._rowItems.splice(0, this._rowItems.length);
		#else
		this._rowItems.resize(0);
		#end
		if (maxRowHeight == 0.0) {
			yPosition -= this._rowGap;
		}
		return yPosition + maxRowHeight + this._paddingBottom;
	}

	private function alignRow(positionY:Float, maxItemHeight:Float):Void {
		for (item in this._rowItems) {
			// handle all other vertical alignment values. the y position
			// of all items is set here.
			switch (this._rowVerticalAlign) {
				case JUSTIFY:
					item.y = positionY;
					if (item.height != maxItemHeight) {
						item.height = maxItemHeight;
					}
				case BOTTOM:
					item.y = positionY + maxItemHeight - item.height;
				case MIDDLE:
					item.y = positionY + ((maxItemHeight - item.height) / 2.0);
				case TOP:
					item.y = positionY;
				default:
					throw new ArgumentError("Unknown row vertical align: " + this._rowVerticalAlign);
			}
		}
	}

	private inline function positionItem(item:DisplayObject, span:Int, offset:Int, columnWidth:Float, yPosition:Float):Void {
		item.x = this._paddingLeft + ((offset != 0) ? ((columnWidth + this._columnGap) * offset) : 0.0);
		item.y = yPosition;
		item.width = (span != 0) ? ((columnWidth + this._columnGap) * span) - this._columnGap : columnWidth;
		if (this._rowVerticalAlign == JUSTIFY && this._justifyResetEnabled && (item is IMeasureObject)) {
			(cast item : IMeasureObject).resetHeight();
		}
		if ((item is IValidating)) {
			(cast item : IValidating).validateNow();
		}
	}

	private function getBreakpoint(viewPortWidth:Float):Breakpoint {
		if (viewPortWidth >= this._xxl) {
			return XXL;
		}
		if (viewPortWidth >= this._xl) {
			return XL;
		}
		if (viewPortWidth >= this._lg) {
			return LG;
		}
		if (viewPortWidth >= this._md) {
			return MD;
		}
		if (viewPortWidth >= this._sm) {
			return SM;
		}
		return XS;
	}

	private inline function getSpan(item:DisplayObject, breakpoint:Breakpoint):Int {
		if (!(item is ILayoutObject)) {
			return 1;
		}
		var layoutItem:ILayoutObject = cast item;
		if (!layoutItem.includeInLayout) {
			return 0;
		}

		var layoutData = Std.downcast(layoutItem.layoutData, ResponsiveGridLayoutData);
		if (layoutData == null) {
			return 1;
		}
		var span = layoutData.getSpan(breakpoint);
		if (span > this._columnCount) {
			return this._columnCount;
		}
		return span;
	}

	private inline function getOffset(item:DisplayObject, span:Int, breakpoint:Breakpoint):Int {
		if (!(item is ILayoutObject)) {
			return 0;
		}
		var layoutItem:ILayoutObject = cast item;
		if (!layoutItem.includeInLayout) {
			return 0;
		}
		var layoutData = Std.downcast(layoutItem.layoutData, ResponsiveGridLayoutData);
		if (layoutData == null) {
			return 0;
		}
		var offset = layoutData.getOffset(breakpoint);
		var maxOffset = this._columnCount - span;
		if (offset > maxOffset) {
			return maxOffset;
		}
		return offset;
	}

	private inline function getDisplay(item:DisplayObject, breakpoint:Breakpoint):Bool {
		if (!(item is ILayoutObject)) {
			return true;
		}
		var layoutItem:ILayoutObject = cast item;
		var layoutData = Std.downcast(layoutItem.layoutData, ResponsiveGridLayoutData);
		if (layoutData == null) {
			return true;
		}
		return layoutData.getDisplay(breakpoint);
	}
}

/**
	Breakpoints used by `ResponsiveGridLayout`.

	@since 1.0.0
**/
enum Breakpoint {
	/**
		Extra small breakpoint. Default: < 576 pixels.

		@since 1.0.0
	**/
	XS;

	/**
		Small breakpoint. Default: >= 576 pixels.

		@since 1.0.0
	**/
	SM;

	/**
		Medium breakpoint. Default: >= 768 pixels.

		@since 1.0.0
	**/
	MD;

	/**
		Large breakpoint. Default: >= 992 pixels.

		@since 1.0.0
	**/
	LG;

	/**
		Extra large breakpoint. Default: >= 1200 pixels.

		@since 1.0.0
	**/
	XL;

	/**
		Extra extra large breakpoint. Default: >= 1400 pixels.

		@since 1.0.0
	**/
	XXL;
}
