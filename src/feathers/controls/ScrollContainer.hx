/*
	Feathers
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.utils.Scroller;
import openfl.events.Event;
import openfl.geom.Rectangle;

/**
	A generic container that supports layout, scrolling, and a background skin.
	For a lighter weight container without scrolling, see `LayoutGroup`.

	The following example creates a scroll container with a horizontal layout
	and adds two buttons to it:

	```hx
	var container:ScrollContainer = new ScrollContainer();
	var layout:HorizontalLayout = new HorizontalLayout();
	layout.gap = 20;
	layout.padding = 20;
	container.layout = layout;
	this.addChild( container );

	var yesButton:Button = new Button();
	yesButton.label = "Yes";
	container.addChild( yesButton );

	var noButton:Button = new Button();
	noButton.label = "No";
	container.addChild( noButton );
	```

	@see [How to use the Feathers ScrollContainer component](../../../help/scroll-container.html)
	@see `feathers.controls.LayoutGroup`

	@since 1.0.0
**/
class ScrollContainer extends LayoutGroup {
	public function new() {
		super();
	}

	private var scroller:Scroller;

	override private function initialize():Void {
		if (this.scroller == null) {
			this.scroller = new Scroller();
		}
		this.scroller.target = this;
		this.scroller.addEventListener(Event.SCROLL, scrollContainer_scroller_scrollHandler);
	}

	override private function handleLayoutResult():Void {
		super.handleLayoutResult();
		scroller.setDimensions(this._layoutResult.viewPortWidth, this._layoutResult.viewPortHeight, this._layoutResult.contentWidth, this._layoutResult
			.contentHeight);
		this.refreshScrollRect();
	}

	private var _currentScrollRect:Rectangle;
	private var _scrollRect1:Rectangle = new Rectangle();
	private var _scrollRect2:Rectangle = new Rectangle();

	private function refreshScrollRect():Void {
		// instead of creating a new Rectangle every time, we're going to swap
		// between two of them to avoid excessive garbage collection
		var scrollRect = this._scrollRect1;
		if (this._currentScrollRect == scrollRect) {
			scrollRect = this._scrollRect2;
		}
		this._currentScrollRect = scrollRect;
		scrollRect.setTo(scroller.scrollX, scroller.scrollY, this.actualWidth, this.actualHeight);
		this.scrollRect = scrollRect;
	}

	private function scrollContainer_scroller_scrollHandler(event:Event):Void {
		this.refreshScrollRect();
	}
}
