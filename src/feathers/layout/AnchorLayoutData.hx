/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.layout;

import openfl.events.Event;
import feathers.events.FeathersEvent;
import openfl.events.EventDispatcher;

/**
	@since 1.0.0
**/
class AnchorLayoutData extends EventDispatcher implements ILayoutData {
	/**
		Creates `AnchorLayoutData` that centers the object both horizontally and
		vertically.

		@see `horizontalCenter`
		@see `verticalCenter`

		@since 1.0.0
	**/
	public static function center(x:Null<Float> = 0, y:Null<Float> = 0):AnchorLayoutData {
		return new AnchorLayoutData(null, null, null, null, x, y);
	}

	/**
		Creates `AnchorLayoutData` that fills the parent container.

		@since 1.0.0
	**/
	public static function fill():AnchorLayoutData {
		return new AnchorLayoutData(0, 0, 0, 0);
	}

	public function new(?top:Null<Float>, ?right:Null<Float>, ?bottom:Null<Float>, ?left:Null<Float>, ?horizontalCenter:Null<Float>,
			?verticalCenter:Null<Float>) {
		super();
		this.top = top;
		this.right = right;
		this.bottom = bottom;
		this.left = left;
		this.horizontalCenter = horizontalCenter;
		this.verticalCenter = verticalCenter;
	}

	/**
		The position, in pixels, of the object's top edge relative to the top
		anchor, or, if there is no top anchor, then the position is relative to
		to the top edge of the parent container. If this value is `null`, the
		object's top edge will not be anchored.

		@since 1.0.0
	**/
	public var top(default, set):Null<Float> = null;

	private function set_top(value:Null<Float>):Null<Float> {
		if (this.top == value) {
			return this.top;
		}
		this.top = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this.top;
	}

	/**
		The position, in pixels, of the object's right edge relative to the
		right anchor, or, if there is no right anchor, then the position is
		relative to the right edge of the parent container. If this value is
		`null`, the object's right edge will not be anchored.

		@since 1.0.0
	**/
	public var right(default, set):Null<Float> = null;

	private function set_right(value:Null<Float>):Null<Float> {
		if (this.right == value) {
			return this.right;
		}
		this.right = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this.right;
	}

	/**
		The position, in pixels, of the object's bottom edge relative to the
		bottom anchor, or, if there is no bottom anchor, then the position is
		relative to the bottom edge of the parent container. If this value is
		`null`, the object's bottom edge will not be anchored.

		@since 1.0.0
	**/
	public var bottom(default, set):Null<Float> = null;

	private function set_bottom(value:Null<Float>):Null<Float> {
		if (this.bottom == value) {
			return this.bottom;
		}
		this.bottom = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this.bottom;
	}

	public var left(default, set):Null<Float> = null;

	/**
		The position, in pixels, of the object's left edge relative to the left
		anchor, or, if there is no left anchor, then the position is relative to
		the left edge of the parent container. If this value is `null`, the
		object's left edge will not be anchored.

		@since 1.0.0
	**/
	private function set_left(value:Null<Float>):Null<Float> {
		if (this.left == value) {
			return this.left;
		}
		this.left = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this.left;
	}

	/**
		The position, in pixels, of the object's horizontal center relative to
		the horizontal center anchor, or, if there is no horizontal center
		anchor, then the position is relative to the horizontal center of the
		parent container. If this value is `null`, the object's horizontal
		center will not be anchored.

		@since 1.0.0
	**/
	public var horizontalCenter(default, set):Null<Float> = null;

	private function set_horizontalCenter(value:Null<Float>):Null<Float> {
		if (this.horizontalCenter == value) {
			return this.horizontalCenter;
		}
		this.horizontalCenter = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this.horizontalCenter;
	}

	/**
		The position, in pixels, of the object's vertical center relative to
		the vertical center anchor, or, if there is no vertical center
		anchor, then the position is relative to the vertical center of the
		parent container. If this value is `null`, the object's vertical
		center will not be anchored.

		@since 1.0.0
	**/
	public var verticalCenter(default, set):Null<Float> = null;

	private function set_verticalCenter(value:Null<Float>):Null<Float> {
		if (this.verticalCenter == value) {
			return this.verticalCenter;
		}
		this.verticalCenter = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this.verticalCenter;
	}
}
