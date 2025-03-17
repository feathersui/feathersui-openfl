/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.layout;

import feathers.events.FeathersEvent;
import openfl.events.Event;
import openfl.events.EventDispatcher;

/**
	Provides optional percentage sizing for children of containers that use
	`HorizontalLayout`.

	@event openfl.events.Event.CHANGE Dispatched when a property of the layout
	data changes, which triggers the container to invalidate.

	@see `feathers.layout.HorizontalLayout`
	@see `feathers.layout.ILayoutObject.layoutData`

	@since 1.0.0
**/
@:event(openfl.events.Event.CHANGE)
class HorizontalLayoutData extends EventDispatcher implements ILayoutData {
	/**
		Creates `HorizontalLayoutData` that fills the parent container, with the
		`percentWidth` and `percentHeight` both set to `100.0`.

		In the following example, one of the container's children fills the
		container's bounds:

		```haxe
		var container = new LayoutGroup();
		container.layout = new HorizontalLayout();

		var child = new Label();
		child.layoutData = HorizontalLayoutData.fill();
		container.addChild(child);
		```

		@see `HorizontalLayoutData.percentWidth`
		@see `HorizontalLayoutData.percentHeight`

		@since 1.0.0
	**/
	public static function fill():HorizontalLayoutData {
		return new HorizontalLayoutData(100.0, 100.0);
	}

	/**
		Creates `HorizontalLayoutData` that fills the width of the parent
		container, with the ability to optionally specify a percentage value to
		pass to `percentWidth`.

		In the following example, one of the container's children fills the
		container's width:

		```haxe
		var container = new LayoutGroup();
		container.layout = new HorizontalLayout();

		var child = new Label();
		child.layoutData = HorizontalLayoutData.fillHorizontal();
		container.addChild(child);
		```

		@see `HorizontalLayoutData.percentWidth`

		@since 1.0.0
	**/
	public static function fillHorizontal(percentWidth:Float = 100.0):HorizontalLayoutData {
		return new HorizontalLayoutData(percentWidth, null);
	}

	/**
		Creates `HorizontalLayoutData` that fills the height of the parent
		container, with the ability to optionally specify a percentage value to
		pass to `percentHeight`.

		In the following example, one of the container's children fills the
		container's height:

		```haxe
		var container = new LayoutGroup();
		container.layout = new HorizontalLayout();

		var child = new Label();
		child.layoutData = HorizontalLayoutData.fillHorizontal();
		container.addChild(child);
		```

		@see `HorizontalLayoutData.percentHeight`

		@since 1.0.0
	**/
	public static function fillVertical(percentHeight:Float = 100.0):HorizontalLayoutData {
		return new HorizontalLayoutData(null, percentHeight);
	}

	/**
		Creates a new `HorizontalLayoutData` object from the given arguments.

		@since 1.0.0
	**/
	public function new(?percentWidth:Float, ?percentHeight:Float) {
		super();
		this.percentWidth = percentWidth;
		this.percentHeight = percentHeight;
	}

	private var _percentWidth:Null<Float> = null;

	/**
		The width of the layout object, as a percentage of the parent
		container's width.

		A percentage may be specified in the range from `0.0` to `100.0`. If the
		value is set to `null`, this property is ignored and the standard width
		in pixels will be used.

		The parent container will calculate the sum of all of its children with
		explicit pixel widths, and then the remaining space will be distributed
		to children with percent widths. Additionally, if the total sum
		of `percentWidth` values exceeds `100.0`, all `percentWidth` values will
		be normalized to the range from `0.0` to `100.0`.

		In the following example, the width of a container's child is set to
		50% of the container's width:

		```haxe
		var container = new LayoutGroup();
		container.layout = new HorizontalLayout();

		var percentages = new HorizontalLayoutData();
		percentages.percentWidth = 50.0;

		var child = new Label();
		child.layoutData = percentages;
		container.addChild(child);
		```

		@default null

		@since 1.0.0
	**/
	@:bindable("change")
	public var percentWidth(get, set):Null<Float>;

	private function get_percentWidth():Null<Float> {
		return this._percentWidth;
	}

	private function set_percentWidth(value:Null<Float>):Null<Float> {
		if (this._percentWidth == value) {
			return this._percentWidth;
		}
		this._percentWidth = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._percentWidth;
	}

	private var _percentHeight:Null<Float> = null;

	/**
		The height of the layout object, as a percentage of the parent
		container's height.

		A percentage may be specified in the range from `0.0` to `100.0`. If the
		value is set to `null`, this property is ignored.

		Tip: If all children of the same container will have the `percentHeight`
		value set to `100.0`, it's better for performance to set
		`HorizontalLayout.verticalAlign` to `VerticalAlign.JUSTIFY` instead.

		In the following example, the height of a container's child is set to
		50% of the container's height:

		```haxe
		var container = new LayoutGroup();
		container.layout = new HorizontalLayout();

		var percentages = new HorizontalLayoutData();
		percentages.percentHeight = 50.0;

		var child = new Label();
		child.layoutData = percentages;
		container.addChild(child);
		```

		@default null

		@since 1.0.0
	**/
	@:bindable("change")
	public var percentHeight(get, set):Null<Float>;

	private function get_percentHeight():Null<Float> {
		return this._percentHeight;
	}

	private function set_percentHeight(value:Null<Float>):Null<Float> {
		if (this._percentHeight == value) {
			return this._percentHeight;
		}
		this._percentHeight = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._percentHeight;
	}

	private var _marginLeft:Null<Float> = null;

	/**
		Extra space, measured in pixels, that is inserted before this item in
		the layout.

		This item's `marginLeft` value will be added to the layout's `gap`
		value and the previous item's `marginRight` value to create the total
		space between items. If this is the first item in the layout, nothing
		will be added to this item's `marginLeft` value.

		Negative values are allowed for the margins.

		@default null

		@see `HorizontalLayoutData.marginRight`
		@see `HorizontalLayout.gap`

		@since 1.1.0
	**/
	@:bindable("change")
	public var marginLeft(get, set):Null<Float>;

	private function get_marginLeft():Null<Float> {
		return this._marginLeft;
	}

	private function set_marginLeft(value:Null<Float>):Null<Float> {
		if (this._marginLeft == value) {
			return this._marginLeft;
		}
		this._marginLeft = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._marginLeft;
	}

	private var _marginRight:Null<Float> = null;

	/**
		Extra space, measured in pixels, that is inserted after this item in
		the layout.

		This item's `marginRight` value will be added to the layout's `gap`
		value and the next item's `marginLeft` value to create the total space
		between items. If this is the last item in the layout, nothing will be
		added too the `marginRight` value.

		Negative values are allowed for the margins.

		@default null

		@see `HorizontalLayoutData.marginLeft`
		@see `HorizontalLayout.gap`

		@since 1.1.0
	**/
	@:bindable("change")
	public var marginRight(get, set):Null<Float>;

	private function get_marginRight():Null<Float> {
		return this._marginRight;
	}

	private function set_marginRight(value:Null<Float>):Null<Float> {
		if (this._marginRight == value) {
			return this._marginRight;
		}
		this._marginRight = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._marginRight;
	}
}
