package feathers.style;

import openfl.events.EventDispatcher;

class CallbackStyleProvider extends EventDispatcher implements IStyleProvider {
	public function new(callback:Dynamic->Void) {
		super();
		this.callback = callback;
	}

	public var callback(default, null):IStyleObject->Void;

	public function applyStyles(target:IStyleObject):Void {
		this.callback(target);
	}
}
