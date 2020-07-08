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
class TreeViewItemRenderer extends ItemRenderer implements ITreeViewItemRenderer implements IDataRenderer implements IOpenCloseToggle {
	/**
		The variant used to style the `ToggleButton` child component in a theme.

		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)
	**/
	public static final CHILD_VARIANT_DISCLOSURE_BUTTON = "treeViewItemRenderer_disclosureButton";

	/**
		Creates a new `TreeViewItemRenderer` object.

		@since 1.0.0
	**/
	public function new() {
		initializeTreeViewItemRendererTheme();
		super();
		this.mouseChildren = true;
	}

	private var _data:Dynamic;

	/**
		@since 1.0.0
	**/
	@:flash.property
	public var data(get, set):Dynamic;

	private function get_data():Dynamic {
		return this._data;
	}

	private function set_data(value:Dynamic):Dynamic {
		if (this._data == value) {
			return this._data;
		}
		this._data = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this._data;
	}

	private var _location:Array<Int>;

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
		this.setInvalid(InvalidationFlag.DATA);
		return this._location;
	}

	private var _branch:Bool = false;

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
		this.setInvalid(InvalidationFlag.DATA);
		return this._branch;
	}

	private var _opened:Bool = false;

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
		this.setInvalid(InvalidationFlag.DATA);
		if (this._opened) {
			FeathersEvent.dispatch(this, Event.OPEN);
		} else {
			FeathersEvent.dispatch(this, Event.CLOSE);
		}
		return this._opened;
	}

	private var _ignoreOpenCloseChange = false;

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
		@:bypassAccessor this.paddingLeft = paddingLeft + indent + this.disclosureButton.width + disclosureGap;
		super.layoutContent();
		@:bypassAccessor this.paddingLeft = paddingLeft;
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
