/*
	Feathers
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.style;

import openfl.events.Event;
import feathers.events.FeathersEvent;

class Theme {
	private static var styleProvider:IStyleProvider;

	public static function getStyleProvider(target:IStyleObject):IStyleProvider {
		if (styleProvider == null) {
			styleProvider = new ClassVariantStyleProvider();
		}
		return styleProvider;
	}

	public static function setStyleProvider(value:IStyleProvider):Void {
		var oldStyleProvider = styleProvider;
		styleProvider = value;
		if (oldStyleProvider != null) {
			FeathersEvent.dispatch(oldStyleProvider, Event.CHANGE);
		}
	}
}
