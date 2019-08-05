/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.layout;

import openfl.events.Event;
import openfl.display.DisplayObject;
import openfl.events.EventDispatcher;
import feathers.core.IValidating;

/**
	Positions items from top to bottom in a single column.

	@see [Tutorial: How to use HorizontalLayout with layout containers](https://feathersui.com/learn/haxe-openfl/horizontal-layout/)

	@since 1.0.0
**/
class HorizontalLayout extends EventDispatcher implements ILayout {
	public function new() {
		super();
	}

	/**
		@since 1.0.0
	**/
	public var paddingTop(default, set):Float = 0.0;

	private function set_paddingTop(value:Float):Float {
		if (this.paddingTop == value) {
			return this.paddingTop;
		}
		this.paddingTop = value;
		this.dispatchEvent(new Event(Event.CHANGE));
		return this.paddingTop;
	}

	/**
		@since 1.0.0
	**/
	public var paddingRight(default, set):Float = 0.0;

	private function set_paddingRight(value:Float):Float {
		if (this.paddingRight == value) {
			return this.paddingRight;
		}
		this.paddingRight = value;
		this.dispatchEvent(new Event(Event.CHANGE));
		return this.paddingRight;
	}

	/**
		@since 1.0.0
	**/
	public var paddingBottom(default, set):Float = 0.0;

	private function set_paddingBottom(value:Float):Float {
		if (this.paddingBottom == value) {
			return this.paddingBottom;
		}
		this.paddingBottom = value;
		this.dispatchEvent(new Event(Event.CHANGE));
		return this.paddingBottom;
	}

	/**
		@since 1.0.0
	**/
	public var paddingLeft(default, set):Float = 0.0;

	private function set_paddingLeft(value:Float):Float {
		if (this.paddingLeft == value) {
			return this.paddingLeft;
		}
		this.paddingLeft = value;
		this.dispatchEvent(new Event(Event.CHANGE));
		return this.paddingLeft;
	}

	/**
		@since 1.0.0
	**/
	public var gap(default, set):Float = 0.0;

	private function set_gap(value:Float):Float {
		if (this.gap == value) {
			return this.gap;
		}
		this.gap = value;
		this.dispatchEvent(new Event(Event.CHANGE));
		return this.gap;
	}

	/**
		@since 1.0.0
	**/
	public var horizontalAlign(default, set):HorizontalAlign = HorizontalAlign.LEFT;

	private function set_horizontalAlign(value:HorizontalAlign):HorizontalAlign {
		if (this.horizontalAlign == value) {
			return this.horizontalAlign;
		}
		this.horizontalAlign = value;
		this.dispatchEvent(new Event(Event.CHANGE));
		return this.horizontalAlign;
	}

	/**
		@since 1.0.0
	**/
	public var verticalAlign(default, set):VerticalAlign = VerticalAlign.TOP;

	private function set_verticalAlign(value:VerticalAlign):VerticalAlign {
		if (this.verticalAlign == value) {
			return this.verticalAlign;
		}
		this.verticalAlign = value;
		this.dispatchEvent(new Event(Event.CHANGE));
		return this.verticalAlign;
	}

	public function layout(items:Array<DisplayObject>, measurements:Measurements, ?result:LayoutBoundsResult):LayoutBoundsResult {
		var maxHeight = 0.0;
		var xPosition = this.paddingLeft;
		for (item in items) {
			var layoutObject:ILayoutObject = null;
			if (Std.is(item, ILayoutObject)) {
				layoutObject = cast(item, ILayoutObject);
				if (!layoutObject.includeInLayout) {
					continue;
				}
			}
			if (Std.is(item, IValidating)) {
				cast(item, IValidating).validateNow();
			}
			if (maxHeight < item.height) {
				maxHeight = item.height;
			}
			item.x = xPosition;
			xPosition += item.width + this.gap;
		}
		xPosition += this.paddingRight;
		if (items.length > 0) {
			xPosition -= this.gap;
		}
		var yPosition = maxHeight + this.paddingTop + this.paddingBottom;

		var viewPortWidth = xPosition;
		if (measurements.width != null) {
			viewPortWidth = measurements.width;
		} else {
			if (measurements.minWidth != null && viewPortWidth < measurements.minWidth) {
				viewPortWidth = measurements.minWidth;
			} else if (measurements.maxWidth != null && viewPortWidth > measurements.maxWidth) {
				viewPortWidth = measurements.maxWidth;
			}
		}
		var viewPortHeight = yPosition;
		if (measurements.height != null) {
			viewPortHeight = measurements.height;
		} else {
			if (measurements.minHeight != null && viewPortHeight < measurements.minHeight) {
				viewPortHeight = measurements.minHeight;
			} else if (measurements.maxHeight != null && viewPortHeight > measurements.maxHeight) {
				viewPortHeight = measurements.maxHeight;
			}
		}

		this.applyVerticalAlign(items, viewPortHeight);
		this.applyHorizontalAlign(items, xPosition, viewPortWidth);

		if (result == null) {
			result = new LayoutBoundsResult();
		}
		result.contentWidth = xPosition;
		result.contentHeight = yPosition;
		result.viewPortWidth = viewPortWidth;
		result.viewPortHeight = viewPortHeight;
		return result;
	}

	private inline function applyVerticalAlign(items:Array<DisplayObject>, viewPortHeight:Float):Void {
		for (item in items) {
			var layoutObject:ILayoutObject = null;
			if (Std.is(item, ILayoutObject)) {
				layoutObject = cast(item, ILayoutObject);
				if (!layoutObject.includeInLayout) {
					continue;
				}
			}
			switch (this.verticalAlign) {
				case VerticalAlign.BOTTOM:
					item.y = this.paddingTop + (viewPortHeight - this.paddingTop - this.paddingBottom) - item.height;
				case VerticalAlign.MIDDLE:
					item.y = this.paddingTop + (viewPortHeight - this.paddingTop - this.paddingBottom - item.height) / 2.0;
				case VerticalAlign.JUSTIFY:
					item.y = this.paddingTop;
					item.height = viewPortHeight - this.paddingTop - this.paddingBottom;
				default:
					item.y = this.paddingTop;
			}
		}
	}

	private inline function applyHorizontalAlign(items:Array<DisplayObject>, contentWidth:Float, viewPortWidth:Float):Void {
		if (this.horizontalAlign != HorizontalAlign.RIGHT && this.horizontalAlign != HorizontalAlign.CENTER) {
			return;
		}
		var maxAlignmentWidth = viewPortWidth - this.paddingLeft - this.paddingRight;
		if (contentWidth >= maxAlignmentWidth) {
			return;
		}
		var horizontalOffset = 0.0;
		if (this.horizontalAlign == HorizontalAlign.RIGHT) {
			horizontalOffset = maxAlignmentWidth - contentWidth;
		} else if (this.horizontalAlign == HorizontalAlign.CENTER) {
			horizontalOffset = (maxAlignmentWidth - contentWidth) / 2.0;
		}
		for (item in items) {
			var layoutObject:ILayoutObject = null;
			if (Std.is(item, ILayoutObject)) {
				layoutObject = cast(item, ILayoutObject);
				if (!layoutObject.includeInLayout) {
					continue;
				}
			}
			item.x += horizontalOffset;
		}
	}
}
