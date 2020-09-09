/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.dataRenderers;

import feathers.events.FeathersEvent;
import openfl.events.Event;
import feathers.core.InvalidationFlag;
import feathers.core.IOpenCloseToggle;
import feathers.themes.steel.components.SteelTreeViewItemRendererStyles;

/**
	A branch and leaf renderer for `TreeView`.

	@see `feathers.controls.TreeView`

	@since 1.0.0
**/
@:styleContext
class TreeViewItemRenderer extends ItemRenderer implements ITreeViewItemRenderer implements IOpenCloseToggle {
	/**
		The variant used to style the `ToggleButton` child component in a theme.

		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_DISCLOSURE_BUTTON = "treeViewItemRenderer_disclosureButton";

	/**
		Creates a new `TreeViewItemRenderer` object.

		@since 1.0.0
	**/
	public function new() {
		initializeTreeViewItemRendererTheme();
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

	private var _branch:Bool = false;

	/**
		@see `feathers.controls.dataRenderers.ITreeViewItemRenderer.branch`
	**/
	@:flash.property
	public var branch(get, set):Bool;

	private function get_branch():Bool {
		return this._branch;
	}

	private function set_branch(value:Bool):Bool {
		if (this._branch == value) {
			return this._branch;
		}
		this._branch = value;
		this.setInvalid(DATA);
		return this._branch;
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

	private var _opened:Bool = false;

	/**
		@see `feathers.core.IOpenCloseToggle.opened`
	**/
	@:flash.property
	public var opened(get, set):Bool;

	private function get_opened():Bool {
		return this._opened;
	}

	private function set_opened(value:Bool):Bool {
		if (this._opened == value) {
			return this._opened;
		}
		this._opened = value;
		this.setInvalid(DATA);
		if (this._opened) {
			FeathersEvent.dispatch(this, Event.OPEN);
		} else {
			FeathersEvent.dispatch(this, Event.CLOSE);
		}
		return this._opened;
	}

	private var _ignoreOpenCloseChange = false;

	/**
		The space, measured in pixels, added to the left side of the item
		renderer at each level of the hierarchy.

		@since 1.0.0
	**/
	@:style
	public var indentation:Float = 0.0;

	private var disclosureButton:ToggleButton;

	override private function initialize():Void {
		super.initialize();
		if (this.disclosureButton == null) {
			this.disclosureButton = new ToggleButton();
			this.disclosureButton.variant = CHILD_VARIANT_DISCLOSURE_BUTTON;
			this.addChild(this.disclosureButton);
		}
		this.disclosureButton.addEventListener(Event.CHANGE, treeViewItemRenderer_disclosureButton_changeHandler);
	}

	override private function update():Void {
		this.disclosureButton.visible = this._branch;
		var oldIgnoreOpenCloseChange = this._ignoreOpenCloseChange;
		this._ignoreOpenCloseChange = true;
		this.disclosureButton.selected = this._opened;
		this._ignoreOpenCloseChange = oldIgnoreOpenCloseChange;
		super.update();
	}

	override private function layoutContent():Void {
		this.disclosureButton.validateNow();
		var paddingLeft = this.paddingLeft;
		var disclosureGap = this.gap;
		var depth = 0;
		if (this._location != null) {
			depth = this._location.length - 1;
		}
		var indent = this.indentation * depth;
		this.runWithoutInvalidation(() -> {
			this.paddingLeft = paddingLeft + indent + this.disclosureButton.width + disclosureGap;
		});
		super.layoutContent();
		this.runWithoutInvalidation(() -> {
			this.paddingLeft = paddingLeft;
		});
		this.disclosureButton.x = this.paddingLeft + indent;
		this.disclosureButton.y = this.paddingTop + (this.actualHeight - this.paddingTop - this.paddingBottom - this.disclosureButton.height) / 2.0;
	}

	private function initializeTreeViewItemRendererTheme():Void {
		SteelTreeViewItemRendererStyles.initialize();
	}

	private function treeViewItemRenderer_disclosureButton_changeHandler(event:Event):Void {
		if (this._ignoreOpenCloseChange) {
			return;
		}
		// use the setter
		this.opened = this.disclosureButton.selected;
	}
}
