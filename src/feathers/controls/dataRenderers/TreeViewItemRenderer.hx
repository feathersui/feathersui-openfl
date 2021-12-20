/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.dataRenderers;

/**
	A branch and leaf renderer for `TreeView`.

	@event openfl.events.Event.OPEN Dispatched when a branch item renderer
	opens. Does not get dispatched for leaf item renderers.

	@event openfl.events.Event.CLOSE Dispatched when a branch item renderer
	closes. Does not get dispatched for leaf item renderers.

	@see `feathers.controls.TreeView`

	@since 1.0.0
**/
@:event(openfl.events.Event.OPEN)
@:event(openfl.events.Event.CLOSE)
@:deprecated('TreeViewItemRenderer is deprecated. Use HierarchicalItemRenderer instead.')
class TreeViewItemRenderer extends HierarchicalItemRenderer implements ITreeViewItemRenderer {
	/**
		Creates a new `TreeViewItemRenderer` object.

		@since 1.0.0
	**/
	public function new() {
		super();
	}

	private var _location:Array<Int>;

	/**
		@see `feathers.controls.dataRenderers.ITreeViewItemRenderer.location`
	**/
	@:flash.property
	public var location(get, set):Array<Int>;

	private function get_location():Array<Int> {
		return this._location;
	}

	private function set_location(value:Array<Int>):Array<Int> {
		if (this._location == value) {
			return this._location;
		}
		this._location = value;
		this.setInvalid(DATA);
		return this._location;
	}

	private var _treeViewOwner:TreeView;

	/**
		@see `feathers.controls.dataRenderers.ITreeViewItemRenderer.treeViewOwner`
	**/
	@:flash.property
	public var treeViewOwner(get, set):TreeView;

	private function get_treeViewOwner():TreeView {
		return this._treeViewOwner;
	}

	private function set_treeViewOwner(value:TreeView):TreeView {
		if (this._treeViewOwner == value) {
			return this._treeViewOwner;
		}
		this._treeViewOwner = value;
		this.setInvalid(DATA);
		return this._treeViewOwner;
	}
}
