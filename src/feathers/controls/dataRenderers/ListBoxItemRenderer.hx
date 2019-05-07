/*
	Feathers
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.dataRenderers;

import feathers.core.InvalidationFlag;
import feathers.style.IStyleObject;

class ListBoxItemRenderer extends Button implements IListBoxItemRenderer {
	override private function get_styleContext():Class<IStyleObject> {
		return ListBoxItemRenderer;
	}

	public var data(default, set):Dynamic;

	private function set_data(value:Dynamic):Dynamic {
		if (this.data == value) {
			return this.data;
		}
		this.data = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this.data;
	}

	public var index(default, set):Int;

	private function set_index(value:Int):Int {
		if (this.index == value) {
			return this.index;
		}
		this.index = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this.index;
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);

		if (dataInvalid) {
			if (this.data == null) {
				this.text = null;
			} else {
				this.text = this.data.text;
			}
		}

		super.update();
	}
}
