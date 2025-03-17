/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.layout;

import feathers.events.FeathersEvent;
import feathers.layout.AnchorLayout.AbstractAnchor;
import feathers.layout.AnchorLayout.Anchor;
import openfl.events.Event;
import openfl.events.EventDispatcher;

/**
	Sets anchors on children of containers that use `AnchorLayout`.

	@event openfl.events.Event.CHANGE Dispatched when a property of the layout
	data changes, which triggers the container to invalidate.

	@see `feathers.layout.AnchorLayout`
	@see `feathers.layout.ILayoutObject.layoutData`

	@since 1.0.0
**/
@:event(openfl.events.Event.CHANGE)
class AnchorLayoutData extends EventDispatcher implements ILayoutData {
	/**
		Creates `AnchorLayoutData` that centers the object both horizontally and
		vertically, with the ability to optionally specify offsets in either
		direction.

		In the following example, one of the container's children is centered
		both horizontally and vertically within the container's bounds:

		```haxe
		var container = new LayoutGroup();
		container.layout = new AnchorLayout();

		var child = new Label();
		child.layoutData = AnchorLayoutData.center();
		container.addChild(child);
		```

		@see `AnchorLayoutData.horizontalCenter`
		@see `AnchorLayoutData.verticalCenter`

		@since 1.0.0
	**/
	public static function center(x:Null<Float> = 0.0, y:Null<Float> = 0.0):AnchorLayoutData {
		return new AnchorLayoutData(null, null, null, null, x, y);
	}

	/**
		Creates `AnchorLayoutData` that fills the parent container, with the
		ability to optionally specify a padding value to pass to `top`, `right`,
		`bottom`, and `left`.

		In the following example, one of the container's children fills the
		container's bounds:

		```haxe
		var container = new LayoutGroup();
		container.layout = new AnchorLayout();

		var child = new Label();
		child.layoutData = AnchorLayoutData.fill();
		container.addChild(child);
		```

		@see `AnchorLayoutData.top`
		@see `AnchorLayoutData.right`
		@see `AnchorLayoutData.bottom`
		@see `AnchorLayoutData.left`

		@since 1.0.0
	**/
	public static function fill(padding:Float = 0.0):AnchorLayoutData {
		return new AnchorLayoutData(padding, padding, padding, padding);
	}

	/**
		Creates `AnchorLayoutData` that fills the width of the parent container,
		with the ability to optionally specify a padding value to pass to
		`left` and `right`.

		In the following example, one of the container's children fills the
		container's width:

		```haxe
		var container = new LayoutGroup();
		container.layout = new AnchorLayout();

		var child = new Label();
		child.layoutData = AnchorLayoutData.fillHorizontal();
		container.addChild(child);
		```

		@see `AnchorLayoutData.left`
		@see `AnchorLayoutData.right`

		@since 1.0.0
	**/
	public static function fillHorizontal(padding:Float = 0.0):AnchorLayoutData {
		return new AnchorLayoutData(null, padding, null, padding);
	}

	/**
		Creates `AnchorLayoutData` that fills the height of the parent
		container, with the ability to optionally specify a padding value to
		pass to `top` and `bottom`.

		In the following example, one of the container's children fills the
		container's height:

		```haxe
		var container = new LayoutGroup();
		container.layout = new AnchorLayout();

		var child = new Label();
		child.layoutData = AnchorLayoutData.fillHorizontal();
		container.addChild(child);
		```

		@see `AnchorLayoutData.top`
		@see `AnchorLayoutData.bottom`

		@since 1.0.0
	**/
	public static function fillVertical(padding:Float = 0.0):AnchorLayoutData {
		return new AnchorLayoutData(padding, null, padding, null);
	}

	/**
		Creates `AnchorLayoutData` that aligns the child to the top-left corner
		of the parent container, with the ability to optionally specify padding
		values to pass to `top` and `left`.

		In the following example, one of the container's children is aligned to
		the container's top-left corner:

		```haxe
		var container = new LayoutGroup();
		container.layout = new AnchorLayout();

		var child = new Label();
		child.layoutData = AnchorLayoutData.topLeft();
		container.addChild(child);
		```

		@see `AnchorLayoutData.top`
		@see `AnchorLayoutData.left`

		@since 1.0.0
	**/
	public static function topLeft(top:Float = 0.0, left:Float = 0.0) {
		return new AnchorLayoutData(top, null, null, left);
	}

	/**
		Creates `AnchorLayoutData` that aligns the child to the top-center edge
		of the parent container, with the ability to optionally specify padding
		values to pass to `top` and `horizontalCenter`.

		In the following example, one of the container's children is aligned to
		the container's top-center edge:

		```haxe
		var container = new LayoutGroup();
		container.layout = new AnchorLayout();

		var child = new Label();
		child.layoutData = AnchorLayoutData.topCenter();
		container.addChild(child);
		```

		@see `AnchorLayoutData.top`
		@see `AnchorLayoutData.horizontalCenter`

		@since 1.0.0
	**/
	public static function topCenter(top:Float = 0.0, horizontalCenter:Float = 0.0) {
		return new AnchorLayoutData(top, null, null, null, horizontalCenter);
	}

	/**
		Creates `AnchorLayoutData` that aligns the child to the top-right corner
		of the parent container, with the ability to optionally specify padding
		values to pass to `top` and `right`.

		In the following example, one of the container's children is aligned to
		the container's top-right corner:

		```haxe
		var container = new LayoutGroup();
		container.layout = new AnchorLayout();

		var child = new Label();
		child.layoutData = AnchorLayoutData.topRight();
		container.addChild(child);
		```

		@see `AnchorLayoutData.top`
		@see `AnchorLayoutData.right`

		@since 1.0.0
	**/
	public static function topRight(top:Float = 0.0, right:Float = 0.0) {
		return new AnchorLayoutData(top, right);
	}

	/**
		Creates `AnchorLayoutData` that aligns the child to the middle-edge
		corner of the parent container, with the ability to optionally specify
		padding values to pass to `verticalCenter` and `left`.

		In the following example, one of the container's children is aligned to
		the container's middle-left edge:

		```haxe
		var container = new LayoutGroup();
		container.layout = new AnchorLayout();

		var child = new Label();
		child.layoutData = AnchorLayoutData.middleLeft();
		container.addChild(child);
		```

		@see `AnchorLayoutData.verticalCenter`
		@see `AnchorLayoutData.left`

		@since 1.0.0
	**/
	public static function middleLeft(verticalCenter:Float = 0.0, left:Float = 0.0) {
		return new AnchorLayoutData(null, null, null, left, null, verticalCenter);
	}

	/**
		Creates `AnchorLayoutData` that aligns the child to the middle-right
		edge of the parent container, with the ability to optionally specify
		padding values to pass to `verticalCenter` and `right`.

		In the following example, one of the container's children is aligned to
		the container's middle-right edge:

		```haxe
		var container = new LayoutGroup();
		container.layout = new AnchorLayout();

		var child = new Label();
		child.layoutData = AnchorLayoutData.middleRight();
		container.addChild(child);
		```

		@see `AnchorLayoutData.verticalCenter`
		@see `AnchorLayoutData.right`

		@since 1.0.0
	**/
	public static function middleRight(verticalCenter:Float = 0.0, right:Float = 0.0) {
		return new AnchorLayoutData(null, right, null, null, null, verticalCenter);
	}

	/**
		Creates `AnchorLayoutData` that aligns the child to the bottom-left
		corner of the parent container, with the ability to optionally specify
		padding values to pass to `bottom` and `left`.

		In the following example, one of the container's children is aligned to
		the container's bottom-left corner:

		```haxe
		var container = new LayoutGroup();
		container.layout = new AnchorLayout();

		var child = new Label();
		child.layoutData = AnchorLayoutData.bottomLeft();
		container.addChild(child);
		```

		@see `AnchorLayoutData.bottom`
		@see `AnchorLayoutData.left`

		@since 1.0.0
	**/
	public static function bottomLeft(bottom:Float = 0.0, left:Float = 0.0) {
		return new AnchorLayoutData(null, null, bottom, left);
	}

	/**
		Creates `AnchorLayoutData` that aligns the child to the bottom-center
		edge of the parent container, with the ability to optionally specify
		padding values to pass to `bottom` and `horizontalCenter`.

		In the following example, one of the container's children is aligned to
		the container's bottom-center edge:

		```haxe
		var container = new LayoutGroup();
		container.layout = new AnchorLayout();

		var child = new Label();
		child.layoutData = AnchorLayoutData.bottomCenter();
		container.addChild(child);
		```

		@see `AnchorLayoutData.bottom`
		@see `AnchorLayoutData.horizontalCenter`

		@since 1.0.0
	**/
	public static function bottomCenter(bottom:Float = 0.0, horizontalCenter:Float = 0.0) {
		return new AnchorLayoutData(null, null, bottom, null, horizontalCenter);
	}

	/**
		Creates `AnchorLayoutData` that aligns the child to the bottom-right
		corner of the parent container, with the ability to optionally specify
		padding values to pass to `bottom` and `right`.

		In the following example, one of the container's children is aligned to
		the container's bottom-right corner:

		```haxe
		var container = new LayoutGroup();
		container.layout = new AnchorLayout();

		var child = new Label();
		child.layoutData = AnchorLayoutData.bottomRight();
		container.addChild(child);
		```

		@see `AnchorLayoutData.bottom`
		@see `AnchorLayoutData.right`

		@since 1.0.0
	**/
	public static function bottomRight(bottom:Float = 0.0, right:Float = 0.0) {
		return new AnchorLayoutData(null, right, bottom);
	}

	/**
		Creates a new `AnchorLayoutData` object from the given arguments.

		@since 1.0.0
	**/
	public function new(?top:AbstractAnchor, ?right:AbstractAnchor, ?bottom:AbstractAnchor, ?left:AbstractAnchor, ?horizontalCenter:Null<Float>,
			?verticalCenter:Null<Float>) {
		super();
		this.top = top;
		this.right = right;
		this.bottom = bottom;
		this.left = left;
		this.horizontalCenter = horizontalCenter;
		this.verticalCenter = verticalCenter;
	}

	private var _top:AbstractAnchor = null;

	/**
		The position, measured in pixels, of the object's top edge relative to
		the top anchor, or, if there is no top anchor, then the position is
		relative to to the top edge of the parent container. If this value is
		`null`, the object's top edge will not be anchored.

		In the following example, one of the container's children is anchored 10
		pixels from the top edge of the container:

		```haxe
		var container = new LayoutGroup();
		container.layout = new AnchorLayout();

		var anchors = new AnchorLayoutData();
		anchors.top = 10.0;

		var child = new Label();
		child.layoutData = anchors;
		container.addChild(child);
		```

		@since 1.0.0
	**/
	@:bindable("change")
	public var top(get, set):AbstractAnchor;

	private function get_top():AbstractAnchor {
		return this._top;
	}

	private function set_top(value:AbstractAnchor):AbstractAnchor {
		if (this._top == value) {
			return this._top;
		}
		if (this._top != null) {
			var top:Anchor = this._top;
			top.removeEventListener(Event.CHANGE, anchorLayoutData_anchor_changeHandler);
		}
		this._top = value;
		if (this._top != null) {
			var top:Anchor = this._top;
			top.addEventListener(Event.CHANGE, anchorLayoutData_anchor_changeHandler, false, 0, true);
		}
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._top;
	}

	private var _right:AbstractAnchor = null;

	/**
		The position, measured in pixels, of the object's right edge relative to
		the right anchor, or, if there is no right anchor, then the position is
		relative to the right edge of the parent container. If this value is
		`null`, the object's right edge will not be anchored.

		In the following example, one of the container's children is anchored 10
		pixels from the right edge of the container:

		```haxe
		var container = new LayoutGroup();
		container.layout = new AnchorLayout();

		var anchors = new AnchorLayoutData();
		anchors.right = 10.0;

		var child = new Label();
		child.layoutData = anchors;
		container.addChild(child);
		```

		@since 1.0.0
	**/
	@:bindable("change")
	public var right(get, set):AbstractAnchor;

	private function get_right():AbstractAnchor {
		return this._right;
	}

	private function set_right(value:AbstractAnchor):AbstractAnchor {
		if (this._right == value) {
			return this._right;
		}
		if (this._right != null) {
			var anchor:Anchor = this._right;
			anchor.removeEventListener(Event.CHANGE, anchorLayoutData_anchor_changeHandler);
		}
		this._right = value;
		if (this._right != null) {
			var anchor:Anchor = this._right;
			anchor.addEventListener(Event.CHANGE, anchorLayoutData_anchor_changeHandler, false, 0, true);
		}
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._right;
	}

	private var _bottom:AbstractAnchor = null;

	/**
		The position, measured in pixels, of the object's bottom edge relative
		to the bottom anchor, or, if there is no bottom anchor, then the
		position is relative to the bottom edge of the parent container. If this
		value is `null`, the object's bottom edge will not be anchored.

		In the following example, one of the container's children is anchored 10
		pixels from the bottom edge of the container:

		```haxe
		var container = new LayoutGroup();
		container.layout = new AnchorLayout();

		var anchors = new AnchorLayoutData();
		anchors.bottom = 10.0;

		var child = new Label();
		child.layoutData = anchors;
		container.addChild(child);
		```

		@since 1.0.0
	**/
	@:bindable("change")
	public var bottom(get, set):AbstractAnchor;

	private function get_bottom():AbstractAnchor {
		return this._bottom;
	}

	private function set_bottom(value:AbstractAnchor):AbstractAnchor {
		if (this._bottom == value) {
			return this._bottom;
		}
		if (this._bottom != null) {
			var anchor:Anchor = this._bottom;
			anchor.removeEventListener(Event.CHANGE, anchorLayoutData_anchor_changeHandler);
		}
		this._bottom = value;
		if (this._bottom != null) {
			var anchor:Anchor = this._bottom;
			anchor.addEventListener(Event.CHANGE, anchorLayoutData_anchor_changeHandler, false, 0, true);
		}
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._bottom;
	}

	private var _left:AbstractAnchor = null;

	/**
		The position, measured in pixels, of the object's left edge relative to
		the left anchor, or, if there is no left anchor, then the position is
		relative to the left edge of the parent container. If this value is
		`null`, the object's left edge will not be anchored.

		In the following example, one of the container's children is anchored 10
		pixels from the left edge of the container:

		```haxe
		var container = new LayoutGroup();
		container.layout = new AnchorLayout();

		var anchors = new AnchorLayoutData();
		anchors.left = 10.0;

		var child = new Label();
		child.layoutData = anchors;
		container.addChild(child);
		```

		@since 1.0.0
	**/
	@:bindable("change")
	public var left(get, set):AbstractAnchor;

	private function get_left():AbstractAnchor {
		return this._left;
	}

	private function set_left(value:AbstractAnchor):AbstractAnchor {
		if (this._left == value) {
			return this._left;
		}
		if (this._left != null) {
			var anchor:Anchor = this._left;
			anchor.removeEventListener(Event.CHANGE, anchorLayoutData_anchor_changeHandler);
		}
		this._left = value;
		if (this._left != null) {
			var anchor:Anchor = this._left;
			anchor.addEventListener(Event.CHANGE, anchorLayoutData_anchor_changeHandler, false, 0, true);
		}
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._left;
	}

	private var _horizontalCenter:Null<Float> = null;

	/**
		The position, measured in pixels, of the object's horizontal center
		relative to the horizontal center anchor, or, if there is no horizontal
		center anchor, then the position is relative to the horizontal center of
		the parent container. If this value is `null`, the object's horizontal
		center will not be anchored.

		In the following example, one of the container's children is centered
		horizontally within the container's bounds:

		```haxe
		var container = new LayoutGroup();
		container.layout = new AnchorLayout();

		var anchors = new AnchorLayoutData();
		anchors.horizontalCenter = 0.0;

		var child = new Label();
		child.layoutData = anchors;
		container.addChild(child);
		```

		@since 1.0.0
	**/
	@:bindable("change")
	public var horizontalCenter(get, set):Null<Float>;

	private function get_horizontalCenter():Null<Float> {
		return this._horizontalCenter;
	}

	private function set_horizontalCenter(value:Null<Float>):Null<Float> {
		if (this._horizontalCenter == value) {
			return this._horizontalCenter;
		}
		this._horizontalCenter = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._horizontalCenter;
	}

	private var _verticalCenter:Null<Float> = null;

	/**
		The position, measured in pixels, of the object's vertical center
		relative to the vertical center anchor, or, if there is no vertical
		center anchor, then the position is relative to the vertical center of
		the parent container. If this value is `null`, the object's vertical
		center will not be anchored.

		In the following example, one of the container's children is centered
		vertically within the container's bounds:

		```haxe
		var container = new LayoutGroup();
		container.layout = new AnchorLayout();

		var anchors = new AnchorLayoutData();
		anchors.verticalCenter = 0.0;

		var child = new Label();
		child.layoutData = anchors;
		container.addChild(child);
		```

		@since 1.0.0
	**/
	@:bindable("change")
	public var verticalCenter(get, set):Null<Float>;

	private function get_verticalCenter():Null<Float> {
		return this._verticalCenter;
	}

	private function set_verticalCenter(value:Null<Float>):Null<Float> {
		if (this._verticalCenter == value) {
			return this._verticalCenter;
		}
		this._verticalCenter = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._verticalCenter;
	}

	private function anchorLayoutData_anchor_changeHandler(event:Event):Void {
		FeathersEvent.dispatch(this, Event.CHANGE);
	}
}
