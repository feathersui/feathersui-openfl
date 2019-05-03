package feathers.themes;

import openfl.events.Event;
import feathers.events.FeathersEvent;
import feathers.core.FeathersControl;

class Theme {
	private static var styleProvider:IStyleProvider;

	public static function getStyleProvider(target:FeathersControl):IStyleProvider {
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
