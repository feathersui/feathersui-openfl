/*
	Feathers
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.style.IStyleObject;
import feathers.layout.Direction;

/**

	A horizontal slider where you may select a value within a range by dragging
	a thumb along the x-axis of a track.

	The following example sets the slider's range and listens for when the value
	changes:

	```hx
	var slider:HSlider = new HSlider();
	slider.minimum = 0;
	slider.maximum = 100;
	slider.step = 1;
	slider.value = 12;
	slider.addEventListener( Event.CHANGE, slider_changeHandler );
	this.addChild( slider );</listing>
	```

	@see `feathers.controls.VSlider`
	@see [How to use the Feathers `HSlider` and `VSlider` components](../../../help/slider.html)

	@since 1.0.0
**/
class HSlider extends BaseSlider {
	public function new() {
		super(Direction.HORIZONTAL);
	}

	override private function get_styleType():Class<IStyleObject> {
		return HSlider;
	}
}
