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
class VerticalLayoutData extends EventDispatcher implements ILayoutData {
	public function new(?percentWidth:Float, ?percentHeight:Float) {
		super();
		this.percentWidth = percentWidth;
		this.percentHeight = percentHeight;
	}

	/**
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
