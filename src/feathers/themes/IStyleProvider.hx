package feathers.themes;

import feathers.core.FeathersControl;
import openfl.events.IEventDispatcher;

interface IStyleProvider extends IEventDispatcher {
	public function applyStyles(target:FeathersControl):Void;
}
