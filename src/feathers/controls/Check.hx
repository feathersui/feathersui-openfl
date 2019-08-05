/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.style.IStyleObject;

/**
	@since 1.0.0
**/
class Check extends ToggleButton {
	public function new() {
		super();
	}

	override private function get_styleContext():Class<IStyleObject> {
		return Check;
	}
}
