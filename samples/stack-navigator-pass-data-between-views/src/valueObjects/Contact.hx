package valueObjects;

class Contact {
	public function new(?name:String, ?email:String) {
		this.name = name;
		this.email = email;
	}

	public var name:String;
	public var email:String;
}
