/*
	Feathers UI
	Copyright 2024 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.dragDrop;

import openfl.events.IEventDispatcher;

/**
	A display object that can accept data dropped by the drag and drop manager.
	Must be a subclass of `openfl.display.InteractiveObject`.

	@see `feathers.dragDrop.DragDropManager`

	@since 1.0.0
**/
interface IDropTarget extends IEventDispatcher {}
