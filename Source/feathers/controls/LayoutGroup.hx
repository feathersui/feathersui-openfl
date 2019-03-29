/*
	Feathers
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.core.FeathersControl;

/**
	A generic container that supports layouts and automatically sizes itself
	based on its content.

	The following example creates a layout group with a horizontal layout and
	adds two buttons to it:

	```hx
	var group:LayoutGroup = new LayoutGroup();
	var layout:HorizontalLayout = new HorizontalLayout();
	layout.gap = 20;
	layout.padding = 20;
	group.layout = layout;
	this.addChild( group );

	var yesButton:Button = new Button();
	yesButton.label = "Yes";
	group.addChild( yesButton );

	var noButton:Button = new Button();
	noButton.label = "No";
	group.addChild( noButton );</listing>
	```

	@see [How to use the Feathers `LayoutGroup` component](../../../help/layout-group.html)
	@see `feathers.controls.ScrollContainer` is a layout container that supports scrolling

	@since 1.0.0
**/
class LayoutGroup extends FeathersControl {
	public function new() {
		super();
	}
}
