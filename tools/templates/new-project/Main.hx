import ::baseClassQualifiedName::;
import feathers.controls.Label;

class ::projectName:: extends ::baseClassName:: {
	public function new() {
		super();

		var label = new Label();
		label.text = "Hello World";
		addChild(label);
	}
}