/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.layout;

import feathers.controls.GridViewColumn;
import feathers.data.IFlatCollection;
import feathers.core.IMeasureObject;
import openfl.events.Event;
import openfl.display.DisplayObject;
import openfl.events.EventDispatcher;
import feathers.core.IValidating;

/**
	Positions cell or header renderers in a `GridView` component.

	@see `feathers.controls.GridView`

	@since 1.0.0
**/
class GridViewRowLayout extends EventDispatcher implements ILayout {
	/**
		Creates a new `GridViewRowLayout` object.

		@since 1.0.0
	**/
	public function new() {
		super();
	}

	/**
		The collection of columns displayed by the `GridView`.
	**/
	public var columns(default, set):IFlatCollection<GridViewColumn>;

	private function set_columns(value:IFlatCollection<GridViewColumn>):IFlatCollection<GridViewColumn> {
		if (this.columns == value) {
			return this.columns;
		}
		this.columns = value;
		this.dispatchEvent(new Event(Event.CHANGE));
		return this.columns;
	}

	/**
		@see `feathers.layout.ILayout.layout`
	**/
	public function layout(items:Array<DisplayObject>, measurements:Measurements, ?result:LayoutBoundsResult):LayoutBoundsResult {
		this.applyColumnWidths(items, measurements.width, measurements.minWidth, measurements.maxWidth);

		var contentWidth = 0.0;
		var contentHeight = 0.0;
		for (item in items) {
			if (Std.is(item, IValidating)) {
				cast(item, IValidating).validateNow();
			}
			if (contentHeight < item.height) {
				contentHeight = item.height;
			}
			item.x = contentWidth;
			contentWidth += item.width;
		}

		var viewPortWidth = contentWidth;
		if (measurements.width != null) {
			viewPortWidth = measurements.width;
		} else {
			if (measurements.minWidth != null && viewPortWidth < measurements.minWidth) {
				viewPortWidth = measurements.minWidth;
			} else if (measurements.maxWidth != null && viewPortWidth > measurements.maxWidth) {
				viewPortWidth = measurements.maxWidth;
			}
		}
		var viewPortHeight = contentHeight;
		if (measurements.height != null) {
			viewPortHeight = measurements.height;
		} else {
			if (measurements.minHeight != null && viewPortHeight < measurements.minHeight) {
				viewPortHeight = measurements.minHeight;
			} else if (measurements.maxHeight != null && viewPortHeight > measurements.maxHeight) {
				viewPortHeight = measurements.maxHeight;
			}
		}

		this.applyViewPortHeight(items, viewPortHeight);

		if (contentWidth < viewPortWidth) {
			contentWidth = viewPortWidth;
		}
		if (contentHeight < viewPortHeight) {
			contentHeight = viewPortHeight;
		}

		if (result == null) {
			result = new LayoutBoundsResult();
		}
		result.contentWidth = contentWidth;
		result.contentHeight = contentHeight;
		result.viewPortWidth = viewPortWidth;
		result.viewPortHeight = viewPortHeight;
		return result;
	}

	private inline function validateItems(items:Array<DisplayObject>) {
		for (i in 0...this.columns.length) {
			var column = this.columns.get(i);
			var item = items[i];
			var columnWidth = column.width;
			if (columnWidth != null) {
				item.width = columnWidth;
			}
			if (Std.is(item, IValidating)) {
				cast(item, IValidating).validateNow();
			}
		}
	}

	private inline function applyViewPortHeight(items:Array<DisplayObject>, viewPortHeight:Float):Void {
		for (item in items) {
			item.height = viewPortHeight;
		}
	}

	private function applyColumnWidths(items:Array<DisplayObject>, explicitWidth:Null<Float>, explicitMinWidth:Null<Float>,
			explicitMaxWidth:Null<Float>):Void {
		var pendingIndices:Array<Int> = [];
		var totalMeasuredWidth = 0.0;
		var totalMinWidth = 0.0;
		var totalPercentWidth = 0.0;
		for (i in 0...this.columns.length) {
			var column = this.columns.get(i);
			var columnWidth = column.width;
			var item = items[i];
			if (columnWidth != null) {
				item.width = columnWidth;
				if (Std.is(item, IValidating)) {
					// changing the width of the item may cause its height
					// to change, so we need to validate. the height is
					// needed for measurement.
					cast(item, IValidating).validateNow();
				}
			} else {
				var percentWidth = 100.0;
				var columnMinWidth = column.minWidth;
				if (columnMinWidth != null) {
					totalMinWidth += columnMinWidth;
				}
				totalPercentWidth += percentWidth;
				pendingIndices.push(i);
				continue;
			}
			totalMeasuredWidth += item.width;
		}
		var remainingWidth = 0.0;
		if (explicitWidth != null) {
			remainingWidth = explicitWidth;
		} else {
			remainingWidth = totalMeasuredWidth + totalMinWidth;
			if (explicitMinWidth != null && remainingWidth < explicitMinWidth) {
				remainingWidth = explicitMinWidth;
			} else if (explicitMaxWidth != null && remainingWidth > explicitMaxWidth) {
				remainingWidth = explicitMaxWidth;
			}
		}
		remainingWidth -= totalMeasuredWidth;
		if (remainingWidth < 0.0) {
			remainingWidth = 0.0;
		}
		var needsAnotherPass = true;
		while (needsAnotherPass) {
			needsAnotherPass = false;
			var percentToPixels = remainingWidth / totalPercentWidth;
			for (index in pendingIndices) {
				var item = items[index];
				var column = this.columns.get(index);
				var percentWidth = 100.0;
				var itemWidth = percentToPixels * percentWidth;
				var columnMinWidth = column.minWidth;
				if (columnMinWidth != null && columnMinWidth > remainingWidth) {
					// we try to respect the item's minimum width, but if
					// it's larger than the remaining space, we need to
					// force it to fit
					columnMinWidth = remainingWidth;
				}
				if (itemWidth < columnMinWidth) {
					itemWidth = columnMinWidth;
					remainingWidth -= itemWidth;
					totalPercentWidth -= percentWidth;
					pendingIndices.remove(index);
					needsAnotherPass = true;
				}
				item.width = itemWidth;
				if (Std.is(item, IValidating)) {
					// changing the width of the item may cause its height
					// to change, so we need to validate. the height is
					// needed for measurement.
					cast(item, IValidating).validateNow();
				}
			}
		}
	}
}
