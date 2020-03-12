/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.layout;

import feathers.events.FeathersEvent;
import feathers.layout.AnchorLayout.AbstractAnchor;
import openfl.events.Event;
import openfl.events.EventDispatcher;

/**
	Sets anchors on children of containers that use `AnchorLayout`.

	@see `feathers.layout.AnchorLayout`
	@see `feathers.layout.ILayoutObject.layoutData`

	@since 1.0.0
**/
class AnchorLayoutData extends EventDispatcher implements ILayoutData {
	/**
		Creates `AnchorLayoutData` that centers the object both horizontally and
		vertically, with the ability to optionally specify offsets in either
		direction.

		In the following example, one of the container's children is centered
		both horizontally and vertically within the container's bounds:

		```hx
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

		```hx
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
		Creates `AnchorLayoutData` that aligns the child to the top-left corner
		of the parent container, with the ability to optionally specify padding
		values to pass to `top` and `left`.

		In the following example, one of the container's children is aligned to
		the container's top-left corner:

		```hx
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

		```hx
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

		```hx
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

		```hx
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

		```hx
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

		```hx
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

		```hx
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

		```hx
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

	/**
		The position, measured in pixels, of the object's top edge relative to
		the top anchor, or, if there is no top anchor, then the position is
		relative to to the top edge of the parent container. If this value is
		`null`, the object's top edge will not be anchored.

		In the following example, one of the container's children is anchored 10
		pixels from the top edge of the container:

		```hx
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
	public var top(default, set):AbstractAnchor = null;

	private function set_top(value:AbstractAnchor):AbstractAnchor {
		if (this.top == value) {
			return this.top;
		}
		this.top = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this.top;
	}

	/**
		The position, measured in pixels, of the object's right edge relative to
		the right anchor, or, if there is no right anchor, then the position is
		relative to the right edge of the parent container. If this value is
		`null`, the object's right edge will not be anchored.

		In the following example, one of the container's children is anchored 10
		pixels from the right edge of the container:

		```hx
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
	public var right(default, set):AbstractAnchor = null;

	private function set_right(value:AbstractAnchor):AbstractAnchor {
		if (this.right == value) {
			return this.right;
		}
		this.right = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this.right;
	}

	/**
		The position, measured in pixels, of the object's bottom edge relative
		to the bottom anchor, or, if there is no bottom anchor, then the
		position is relative to the bottom edge of the parent container. If this
		value is `null`, the object's bottom edge will not be anchored.

		In the following example, one of the container's children is anchored 10
		pixels from the bottom edge of the container:

		```hx
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
	public var bottom(default, set):AbstractAnchor = null;

	private function set_bottom(value:AbstractAnchor):AbstractAnchor {
		if (this.bottom == value) {
			return this.bottom;
		}
		this.bottom = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this.bottom;
	}

	/**
		The position, measured in pixels, of the object's left edge relative to
		the left anchor, or, if there is no left anchor, then the position is
		relative to the left edge of the parent container. If this value is
		`null`, the object's left edge will not be anchored.

		In the following example, one of the container's children is anchored 10
		pixels from the left edge of the container:

		```hx
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
	public var left(default, set):AbstractAnchor = null;

	private function set_left(value:AbstractAnchor):AbstractAnchor {
		if (this.left == value) {
			return this.left;
		}
		this.left = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this.left;
	}

	/**
		The position, measured in pixels, of the object's horizontal center
		relative to the horizontal center anchor, or, if there is no horizontal
		center anchor, then the position is relative to the horizontal center of
		the parent container. If this value is `null`, the object's horizontal
		center will not be anchored.

		In the following example, one of the container's children is centered
		horizontally within the container's bounds:

		```hx
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
		The position, measured in pixels, of the object's vertical center
		relative to the vertical center anchor, or, if there is no vertical
		center anchor, then the position is relative to the vertical center of
		the parent container. If this value is `null`, the object's vertical
		center will not be anchored.

		In the following example, one of the container's children is centered
		vertically within the container's bounds:

		```hx
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
