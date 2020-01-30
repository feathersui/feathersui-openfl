/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.style;

/**
	An object that supports styling and may have variants.

	@since 1.0.0
**/
interface IVariantStyleObject extends IStyleObject {
	/**
		The class used as the context for styling the UI component. In other
		words, a subclass of a component may have different styles than its
		superclass, or it may inherit styles from its superclass.

		@since 1.0.0
	**/
	public var styleContext(get, never):Class<IStyleObject>;

	/**
		May be used to provide multiple different variations of the same UI
		component, each with a different appearance.

		The following example sets the variant of a `Label` component:

		```hx
		var label = new Label();
		label.variant = Label.VARIANT_HEADING;
		```

		@since 1.0.0
	**/
	public var variant(default, set):String;
}
