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
	Positions items from left to right in a single row.

	@see [Tutorial: How to use VerticalLayout with layout containers](https://feathersui.com/learn/haxe-openfl/vertical-layout/)

	@since 1.0.0
**/
class VerticalLayout extends EventDispatcher implements ILayout {
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
		var maxWidth = 0.0;
		var yPosition = this.paddingTop;
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
			if (maxWidth < item.width) {
				maxWidth = item.width;
			}
			item.y = yPosition;
			yPosition += item.height + this.gap;
		}
		yPosition += this.paddingBottom;
		if (items.length > 0) {
			yPosition -= this.gap;
		}
		var xPosition = maxWidth + this.paddingLeft + this.paddingRight;

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

		this.applyHorizontalAlign(items, viewPortWidth);
		this.applyVerticalAlign(items, yPosition, viewPortHeight);

		if (result == null) {
			result = new LayoutBoundsResult();
		}
		result.contentWidth = xPosition;
		result.contentHeight = yPosition;
		result.viewPortWidth = viewPortWidth;
		result.viewPortHeight = viewPortHeight;
		return result;
	}

	private inline function applyHorizontalAlign(items:Array<DisplayObject>, viewPortWidth:Float):Void {
		for (item in items) {
			var layoutObject:ILayoutObject = null;
			if (Std.is(item, ILayoutObject)) {
				layoutObject = cast(item, ILayoutObject);
				if (!layoutObject.includeInLayout) {
					continue;
				}
			}
			switch (this.horizontalAlign) {
				case HorizontalAlign.RIGHT:
					item.x = this.paddingLeft + (viewPortWidth - this.paddingLeft - this.paddingRight) - item.width;
				case HorizontalAlign.CENTER:
					item.x = this.paddingLeft + (viewPortWidth - this.paddingLeft - this.paddingRight - item.width) / 2.0;
				case HorizontalAlign.JUSTIFY:
					item.x = this.paddingLeft;
					item.width = viewPortWidth - this.paddingLeft - this.paddingRight;
				default:
					item.x = this.paddingLeft;
			}
		}
	}

	private inline function applyVerticalAlign(items:Array<DisplayObject>, contentHeight:Float, viewPortHeight:Float):Void {
		if (this.verticalAlign != VerticalAlign.BOTTOM && this.verticalAlign != VerticalAlign.MIDDLE) {
			return;
		}
		var maxAlignmentHeight = viewPortHeight - this.paddingTop - this.paddingBottom;
		if (contentHeight >= maxAlignmentHeight) {
			return;
		}
		var verticalOffset = 0.0;
		if (this.verticalAlign == VerticalAlign.BOTTOM) {
			verticalOffset = maxAlignmentHeight - contentHeight;
		} else if (this.verticalAlign == VerticalAlign.MIDDLE) {
			verticalOffset = (maxAlignmentHeight - contentHeight) / 2.0;
		}
		for (item in items) {
			var layoutObject:ILayoutObject = null;
			if (Std.is(item, ILayoutObject)) {
				layoutObject = cast(item, ILayoutObject);
				if (!layoutObject.includeInLayout) {
					continue;
				}
			}
			item.y += verticalOffset;
		}
	}
}
