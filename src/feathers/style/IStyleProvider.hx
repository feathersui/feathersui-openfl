/*
	Feathers
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.style;

import openfl.events.IEventDispatcher;

interface IStyleProvider extends IEventDispatcher {
	public function applyStyles<T>(target:IStyleObject, contextType:Class<IStyleObject>):Void;
}
