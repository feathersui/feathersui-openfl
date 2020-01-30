/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.layout;

import openfl.events.Event;
import feathers.events.FeathersEvent;
import openfl.events.EventDispatcher;

/**
	Provides optional percentage sizing for children of containers that use
	`VerticalLayout`.

	@see `feathers.layout.VerticalLayout`
	@see `feathers.layout.ILayoutObject.layoutData`

	@since 1.0.0
**/
class VerticalLayoutData extends EventDispatcher implements ILayoutData {
	/**
		Creates a new `VerticalLayoutData` object from the given arguments.

		@since 1.0.0
	**/
	public function new(?percentWidth:Float, ?percentHeight:Float) {
		super();
		this.percentWidth = percentWidth;
		this.percentHeight = percentHeight;
	}

	/**
		The width of the layout object, as a percentage of the parent
		container's width.

		A percentage may be specified in the range from `0.0` to `100.0`. If the
		value is set to `null`, this property is ignored.

		In the following example, the width of a container's child is set to
		50% of the container's width:

		```hx
		var container = new LayoutGroup();
		container.layout = new VerticalLayout();

		var percentages = new VerticalLayoutData();
		percentages.percentWidth = 50.0;

		var child = new Label();
		child.layoutData = percentages;
		container.addChild(child);
		```

		@default null

		@since 1.0.0
	**/
	public var percentWidth(default, set):Null<Float> = null;

	private function set_percentWidth(value:Null<Float>):Null<Float> {
		if (this.percentWidth == value) {
			return this.percentWidth;
		}
		this.percentWidth = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this.percentWidth;
	}

	/**
		The height of the layout object, as a percentage of the parent
		container's height. The parent container will calculate the sum of all
		of its children with explicit pixel heights, and then the remaining
		space will be distributed to children with percent heights.

		A percentage may be specified in the range from `0.0` to `100.0`. If the
		value is set to `null`, this property is ignored.

		In the following example, the height of a container's child is set to
		50% of the container's height:

		```hx
		var container = new LayoutGroup();
		container.layout = new VerticalLayout();

		var percentages = new VerticalLayoutData();
		percentages.percentHeight = 50.0;

		var child = new Label();
		child.layoutData = percentages;
		container.addChild(child);
		```

		@default null

		@since 1.0.0
	**/
	public var percentHeight(default, set):Null<Float> = null;

	private function set_percentHeight(value:Null<Float>):Null<Float> {
		if (this.percentHeight == value) {
			return this.percentHeight;
		}
		this.percentHeight = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this.percentHeight;
	}
}
