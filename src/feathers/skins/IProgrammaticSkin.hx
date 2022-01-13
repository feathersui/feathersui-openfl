/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.skins;

import feathers.core.IMeasureObject;
import feathers.core.IUIControl;

/**
	Interface for Feathers UI skins that are drawn programmatically.

	@since 1.0.0
**/
interface IProgrammaticSkin extends IMeasureObject {
	/**
		The UI component that is displaying this skin.

		@since 1.0.0
	**/
	public var uiContext(get, set):IUIControl;
}
