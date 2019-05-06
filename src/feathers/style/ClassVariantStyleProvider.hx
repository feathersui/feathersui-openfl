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
		var typeName = Type.getClassName(type);
		var styleTarget = variant == null ? StyleTarget.Class(typeName) : StyleTarget.ClassAndVariant(typeName, variant);
		if (callback == null) {
			styleTargets.remove(styleTarget);
		} else {
			styleTargets.set(styleTarget, callback);
		}
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
		var styleTarget = variant == null ? StyleTarget.Class(styleContextName) : StyleTarget.ClassAndVariant(styleContextName, variant);
		var callback = this.styleTargets.get(styleTarget);
		if (callback == null && variant != null) {
			// try again without the variant
			styleTarget = StyleTarget.Class(styleContextName);
			callback = this.styleTargets.get(styleTarget);
		}
		if (callback == null) {
			if (uiControl.defaultStyleProvider != null) {
				// fall back to the default, if available
				uiControl.defaultStyleProvider.applyStyles(target);
			}
			return;
		}
		callback(target);
	}
}

private enum StyleTarget {
	Class(type:String);
	ClassAndVariant(type:String, variant:String);
}
