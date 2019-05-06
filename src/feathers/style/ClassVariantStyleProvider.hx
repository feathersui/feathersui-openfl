/*
	Feathers
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.style;

import feathers.events.FeathersEvent;
import feathers.core.IUIControl;
import haxe.rtti.Meta;
import openfl.events.Event;
import openfl.events.EventDispatcher;

class ClassVariantStyleProvider extends EventDispatcher implements IStyleProvider {
	private var styleTargets:Map<StyleTarget, Dynamic->Void>;

	public function setStyleFunction<T>(type:Class<T>, variant:String, callback:T->Void):Void {
		if (styleTargets == null) {
			styleTargets = [];
		}
		styleTargets.set(StyleTarget.ClassAndVariant(Type.getClassName(type), variant), callback);
		FeathersEvent.dispatch(this, Event.CHANGE);
	}

	public function applyStyles(target:IStyleObject):Void {
		if (this.styleTargets == null) {
			return;
		}
		if (!Std.is(target, IUIControl)) {
			return;
		}

		var uiControl = cast(target, IUIControl);
		var styleContext = uiControl.styleContext;
		var variant = uiControl.variant;

		var styleContextName = Type.getClassName(styleContext);
		var styleTarget = StyleTarget.ClassAndVariant(styleContextName, variant);
		var callback = this.styleTargets.get(styleTarget);
		if (callback == null) {
			return;
		}
		callback(target);
	}
}

private enum StyleTarget {
	ClassAndVariant(type:String, variant:String);
}
