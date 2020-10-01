/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.core.IUIControl;

@:event(feathers.events.TriggerEvent.TRIGGER)

/**
	A UI component that dispatches `TriggerEvent.TRIGGER`. Some components may
	prefer to listen for `TriggerEvent.TRIGGER` instead of `MouseEvent.CLICK` or
	`TouchEvent.TOUCH_TAP`.

	@since 1.0.0
**/
interface ITriggerView extends IUIControl {}
