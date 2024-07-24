/*
	Feathers UI
	Copyright 2024 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.layout;

import feathers.core.IValidating;
import feathers.events.FeathersEvent;
import openfl.display.DisplayObject;
import openfl.errors.IllegalOperationError;
import openfl.events.Event;
import openfl.events.EventDispatcher;

/**
	Positions and sizes items by anchoring their edges (or center points) to
	to their parent container or to other items in the same container.

	@event openfl.events.Event.CHANGE Dispatched when a property of the layout
	changes, which triggers the container to invalidate.

	@see [Tutorial: How to use AnchorLayout with layout containers](https://feathersui.com/learn/haxe-openfl/anchor-layout/)
	@see `feathers.layout.AnchorLayoutData`

	@since 1.0.0
**/
@:event(openfl.events.Event.CHANGE)
class AnchorLayout extends EventDispatcher implements ILayout {
	/**
		Creates a new `AnchorLayout` object.

		@since 1.0.0
	**/
	public function new() {
		super();
	}

	/**
		@see `feathers.layout.ILayout.layout()`
	**/
	public function layout(items:Array<DisplayObject>, measurements:Measurements, ?result:LayoutBoundsResult):LayoutBoundsResult {
		for (item in items) {
			var layoutObject:ILayoutObject = null;
			if ((item is ILayoutObject)) {
				layoutObject = cast item;
				if (!layoutObject.includeInLayout) {
					continue;
				}
				var layoutData:AnchorLayoutData = null;
				if (layoutObject != null && (layoutObject.layoutData is AnchorLayoutData)) {
					layoutData = cast layoutObject.layoutData;
				}
				if (layoutData != null) {
					// optimization: if width and height are known, set them before
					// validation because measurement could be expensive
					if (measurements.width != null) {
						var leftAnchor = layoutData.left;
						var rightAnchor = layoutData.right;
						if (leftAnchor != null && rightAnchor != null && leftAnchor.relativeTo == null && rightAnchor.relativeTo == null) {
							item.width = measurements.width - leftAnchor.value - rightAnchor.value;
						}
					}
					if (measurements.height != null) {
						var topAnchor = layoutData.top;
						var bottomAnchor = layoutData.bottom;
						if (topAnchor != null && bottomAnchor != null && topAnchor.relativeTo == null && bottomAnchor.relativeTo == null) {
							item.height = measurements.height - topAnchor.value - bottomAnchor.value;
						}
					}
				}
			}
			if ((item is IValidating)) {
				(cast item : IValidating).validateNow();
			}
		}

		var maxX = 0.0;
		var maxY = 0.0;
		var doneItems:Array<DisplayObject> = [];
		while (doneItems.length < items.length) {
			var oldDoneCount = doneItems.length;
			for (item in items) {
				if (doneItems.indexOf(item) != -1) {
					continue;
				}
				var layoutObject:ILayoutObject = null;
				if ((item is ILayoutObject)) {
					layoutObject = cast item;
					if (!layoutObject.includeInLayout) {
						doneItems.push(item);
						continue;
					}
				}
				var layoutData:AnchorLayoutData = null;
				if (layoutObject != null && (layoutObject.layoutData is AnchorLayoutData)) {
					layoutData = cast layoutObject.layoutData;
				}

				if ((item is IValidating)) {
					(cast item : IValidating).validateNow();
				}

				if (layoutData == null) {
					var itemMaxX = item.x + item.width;
					if (maxX < itemMaxX) {
						maxX = itemMaxX;
					}
					var itemMaxY = item.y + item.height;
					if (maxY < itemMaxY) {
						maxY = itemMaxY;
					}
				} else // has AnchorLayoutData
				{
					if (layoutData.top != null) {
						var top = layoutData.top;
						var value = top.value;
						var relativeTo = top.relativeTo;
						if (relativeTo != null && doneItems.indexOf(relativeTo) == -1) {
							if (item.parent != relativeTo.parent) {
								throw new IllegalOperationError("relativeTo must have the same parent");
							}
							continue;
						}
						item.y = value;
						if (relativeTo != null) {
							item.y += relativeTo.y + relativeTo.height;
						}
					}
					if (layoutData.left != null) {
						var left = layoutData.left;
						var value = left.value;
						var relativeTo = left.relativeTo;
						if (relativeTo != null && doneItems.indexOf(relativeTo) == -1) {
							if (item.parent != relativeTo.parent) {
								throw new IllegalOperationError("relativeTo must have the same parent");
							}
							continue;
						}
						item.x = value;
						if (relativeTo != null) {
							item.x += relativeTo.x + relativeTo.width;
						}
					}
					if (layoutData.verticalCenter == null) {
						var itemMaxY = item.y + item.height;
						if (layoutData.bottom != null) {
							var bottom = layoutData.bottom;
							var value = bottom.value;
							if (layoutData.top != null) {
								itemMaxY += value;
							} else {
								itemMaxY = item.height + value;
							}
						}
						if (maxY < itemMaxY) {
							maxY = itemMaxY;
						}
					} else {
						var itemMaxY = item.height;
						if (maxY < itemMaxY) {
							maxY = itemMaxY;
						}
					}
					if (layoutData.horizontalCenter == null) {
						var itemMaxX = item.x + item.width;
						if (layoutData.right != null) {
							var right = layoutData.right;
							var value = right.value;
							if (layoutData.left != null) {
								itemMaxX += value;
							} else {
								itemMaxX = item.width + value;
							}
						}
						if (maxX < itemMaxX) {
							maxX = itemMaxX;
						}
					} else {
						var itemMaxX = item.width;
						if (maxX < itemMaxX) {
							maxX = itemMaxX;
						}
					}
				}
				doneItems.push(item);
			}
			if (oldDoneCount == doneItems.length) {
				// if no additional items were processed,
				// it's probably a circular reference
				throw new IllegalOperationError("relativeTo circular reference detected");
			}
		}
		var viewPortWidth = 0.0;
		var viewPortHeight = 0.0;
		var loopCount = 0;
		var needsAnotherPass = true;
		while (needsAnotherPass) {
			needsAnotherPass = false;
			if (measurements.width != null) {
				viewPortWidth = measurements.width;
			} else {
				viewPortWidth = maxX;
				if (measurements.minWidth != null && viewPortWidth < measurements.minWidth) {
					viewPortWidth = measurements.minWidth;
				} else if (measurements.maxWidth != null && viewPortWidth > measurements.maxWidth) {
					viewPortWidth = measurements.maxWidth;
				}
			}
			if (measurements.height != null) {
				viewPortHeight = measurements.height;
			} else {
				viewPortHeight = maxY;
				if (measurements.minHeight != null && viewPortHeight < measurements.minHeight) {
					viewPortHeight = measurements.minHeight;
				} else if (measurements.maxHeight != null && viewPortHeight > measurements.maxHeight) {
					viewPortHeight = measurements.maxHeight;
				}
			}
			#if (hl && haxe_ver < 4.3)
			doneItems.splice(0, doneItems.length);
			#else
			doneItems.resize(0);
			#end
			while (doneItems.length < items.length) {
				var oldDoneCount = doneItems.length;
				for (item in items) {
					if (doneItems.indexOf(item) != -1) {
						// already done
						continue;
					}
					var layoutObject:ILayoutObject = null;
					if ((item is ILayoutObject)) {
						layoutObject = cast item;
						if (!layoutObject.includeInLayout) {
							doneItems.push(item);
							continue;
						}
					}
					var layoutData:AnchorLayoutData = null;
					if (layoutObject != null && (layoutObject.layoutData is AnchorLayoutData)) {
						layoutData = cast layoutObject.layoutData;
					}
					if (layoutData == null) {
						doneItems.push(item);
						continue;
					}
					if (layoutData.top != null) {
						var top = layoutData.top;
						var relativeTo = top.relativeTo;
						if (relativeTo != null && doneItems.indexOf(relativeTo) == -1) {
							if (item.parent != relativeTo.parent) {
								throw new IllegalOperationError("relativeTo must have the same parent");
							}
							continue;
						}
						var y = top.value;
						if (relativeTo != null) {
							y += relativeTo.y + relativeTo.height;
						}
						item.y = y;
					}
					if (layoutData.left != null) {
						var left = layoutData.left;
						var relativeTo = left.relativeTo;
						if (relativeTo != null && doneItems.indexOf(relativeTo) == -1) {
							if (item.parent != relativeTo.parent) {
								throw new IllegalOperationError("relativeTo must have the same parent");
							}
							continue;
						}
						var x = left.value;
						if (relativeTo != null) {
							x += relativeTo.x + relativeTo.width;
						}
						item.x = x;
					}
					if (layoutData.bottom != null) {
						var bottom = layoutData.bottom;
						var relativeTo = bottom.relativeTo;
						if (relativeTo != null && doneItems.indexOf(relativeTo) == -1) {
							if (item.parent != relativeTo.parent) {
								throw new IllegalOperationError("relativeTo must have the same parent");
							}
							continue;
						}
						var bottomPixels = bottom.value;
						var bottomEdge = viewPortHeight;
						if (relativeTo != null) {
							bottomEdge = relativeTo.y;
						}
						if (layoutData.top == null) {
							item.y = bottomEdge - bottomPixels - item.height;
						} else {
							var itemHeight = bottomEdge - bottomPixels - item.y;
							if (itemHeight < 0.0) {
								itemHeight = 0.0;
							}
							if (item.height != itemHeight) {
								// to ensure that the item can continue to auto-size
								// itself, don't set the explicit size unless needed
								item.height = itemHeight;
								if (measurements.width == null && (item is IValidating)) {
									(cast item : IValidating).validateNow();
									// for some components, setting one dimension
									// may cause the other dimension to change.
									// for example, resizing the width of word
									// wrapped text can affect its height.
									// this may affect the view port dimensions
									// which means that we need to start over!
									var maxItemX = item.x + item.width;
									if (maxX < maxItemX) {
										maxX = maxItemX;
										needsAnotherPass = true;
										break;
									}
								}
							}
						}
					} else if (layoutData.verticalCenter != null) {
						item.y = layoutData.verticalCenter + (viewPortHeight - item.height) / 2.0;
					}
					if (layoutData.right != null) {
						var right = layoutData.right;
						var relativeTo = right.relativeTo;
						if (relativeTo != null && doneItems.indexOf(relativeTo) == -1) {
							if (item.parent != relativeTo.parent) {
								throw new IllegalOperationError("relativeTo must have the same parent");
							}
							continue;
						}
						var rightPixels = right.value;
						var rightEdge = viewPortWidth;
						if (relativeTo != null) {
							rightEdge = relativeTo.x;
						}
						if (layoutData.left == null) {
							item.x = rightEdge - rightPixels - item.width;
						} else {
							var itemWidth = rightEdge - rightPixels - item.x;
							if (itemWidth < 0.0) {
								itemWidth = 0.0;
							}
							if (item.width != itemWidth) {
								// to ensure that the item can continue to auto-size
								// itself, don't set the explicit size unless needed
								item.width = itemWidth;
								if (measurements.height == null && (item is IValidating)) {
									(cast item : IValidating).validateNow();
									// for some components, setting one dimension
									// may cause the other dimension to change.
									// for example, resizing the width of word
									// wrapped text can affect its height.
									// this may affect the view port dimensions
									// which means that we need to start over!
									var maxItemY = item.y + item.height;
									if (maxY < maxItemY) {
										maxY = maxItemY;
										needsAnotherPass = true;
										break;
									}
								}
							}
						}
					} else if (layoutData.horizontalCenter != null) {
						item.x = layoutData.horizontalCenter + (viewPortWidth - item.width) / 2.0;
					}
					doneItems.push(item);
				}
				if (!needsAnotherPass && oldDoneCount == doneItems.length) {
					// if no additional items were processed,
					// it's probably a circular reference
					throw new IllegalOperationError("relativeTo circular reference detected");
				}
			}
			if (needsAnotherPass) {
				loopCount++;
				if (loopCount > items.length) {
					throw new IllegalOperationError('AnchorLayout is stuck in an infinite loop.');
				}
			}
		}
		if (result == null) {
			result = new LayoutBoundsResult();
		}
		result.contentX = 0.0;
		result.contentY = 0.0;
		result.contentWidth = viewPortWidth;
		result.contentHeight = viewPortHeight;
		result.viewPortWidth = viewPortWidth;
		result.viewPortHeight = viewPortHeight;
		return result;
	}
}

/**
	Specifies how to position an object added to a container using
	`AnchorLayout`.

	@see `feathers.layout.AnchorLayout`
	@see `feathers.layout.AnchorLayoutData`

	@since 1.0.0
**/
class Anchor extends EventDispatcher {
	/**
		Creates a new `Anchor` object with the given arguments.

		@since 1.0.0
	**/
	public function new(value:Float = 0.0, ?relativeTo:DisplayObject) {
		super();
		this._value = value;
		this._relativeTo = relativeTo;
	}

	private var _value:Float;

	/**
		The number of pixels away from the edge of the parent container (or
		from the `relativeTo` display object) to position the target.

		@since 1.0.0
	**/
	@:bindable("change")
	public var value(get, set):Float;

	private function get_value():Float {
		return this._value;
	}

	private function set_value(newValue:Float):Float {
		if (this._value == newValue) {
			return this._value;
		}
		this._value = newValue;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._value;
	}

	private var _relativeTo:Null<DisplayObject>;

	/**
		The target may be optionally positioned relative to another display
		object, instead of the edges of the parent container.

		@since 1.0.0
	**/
	@:bindable("change")
	public var relativeTo(get, set):Null<DisplayObject>;

	private function get_relativeTo():Null<DisplayObject> {
		return this._relativeTo;
	}

	private function set_relativeTo(value:Null<DisplayObject>):Null<DisplayObject> {
		if (this._relativeTo == value) {
			return this._relativeTo;
		}
		this._relativeTo = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._relativeTo;
	}
}

/**
	Converts a `Float` or `DisplayObject` value to an `Anchor` used by
	`AnchorLayoutData`.

	@see `feathers.layout.AnchorLayoutData`

	@since 1.0.0
**/
@:forward(value, relativeTo)
abstract AbstractAnchor(Anchor) from Anchor to Anchor {
	/**
		Converts a `Float` value, measured in pixels, to an `Anchor`.

		@since 1.0.0
	**/
	@:from
	public static function fromPixels(pixels:Float):AbstractAnchor {
		return new Anchor(pixels);
	}

	/**
		Converts a `DisplayObject` to an `Anchor`.

		@since 1.0.0
	**/
	@:from
	public static function fromDisplayObject(relativeTo:DisplayObject):AbstractAnchor {
		return new Anchor(0.0, relativeTo);
	}
}
