/*
	Copyright (c) 2014 Blake Embrey (hello@blakeembrey.com)

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in
	all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
	THE SOFTWARE.
 */

package feathers.utils;

@:dox(hide)
@:noCompletion
typedef Key = {
	name:String,
	prefix:String,
	delimiter:String,
	optional:Bool,
	repeat:Bool,
	partial:Bool,
	asterisk:Bool,
	pattern:String
}

private enum Token {
	Static(token:String);
	Capture(key:Key);
}

@:dox(hide)
@:noCompletion
typedef Options = {
	?strict:Bool,
	?end:Bool,
	?sensitive:Bool
}

@:dox(hide)
@:noCompletion
class Path2EReg {
	private static function parse(str:String):Array<Token> {
		var matcher = new EReg([
			'(\\\\.)',
			'([\\/.])?(?:(?:\\:(\\w+)(?:\\(((?:\\\\.|[^\\\\()])+)\\))?|\\(((?:\\\\.|[^\\\\()])+)\\))([+*?])?|(\\*))'
		].join('|'), 'g');
		var tokens:Array<Token> = [];
		var key = 0;
		var index = 0;
		var path = '';

		function matched(index)
			return try matcher.matched(index) catch (e:Dynamic) null;

		matcher.map(str, function(matcher) {
			var m = matched(0),
				escaped = matched(1),
				offset = matcher.matchedPos().pos;

			path += str.substring(index, offset);
			index = offset + m.length;

			if (escaped != null) {
				path += escaped.charAt(1);
				return '';
			}

			var next = str.charAt(index),
				prefix = matched(2),
				name = matched(3),
				capture = matched(4),
				group = matched(5),
				modifier = matched(6),
				asterisk = matched(7),
				delimiter = prefix == null ? '/' : prefix;

			if (path != '') {
				tokens.push(Static(path));
				path = '';
			}

			tokens.push(Capture({
				name: name == null ? '${key++}' : name,
				prefix: prefix == null ? '' : prefix,
				delimiter: delimiter,
				optional: modifier == '?' || modifier == '*',
				repeat: modifier == '+' || modifier == '*',
				partial: prefix != null && next != '' && next != prefix,
				asterisk: asterisk != null,
				pattern: escapeGroup(switch [capture, group, asterisk] {
					case [null, null, null]: '[^' + delimiter + ']+?';
					case [null, null, x]: '.*';
					case [null, x, _]: x;
					case [x, _, _]: x;
				})
			}));

			return '';
		});

		if (index < str.length)
			path += str.substr(index);

		if (path != '')
			tokens.push(Static(path));

		return tokens;
	}

	private static function tokensToEReg(tokens:Array<Token>, ?options:Options) {
		options = defaults(options);

		var strict = options.strict;
		var end = options.end;
		var route:String = '';
		var lastToken = tokens[tokens.length - 1];
		var endsWithSlash = switch (lastToken) {
			case Static(token): token.charAt(token.length - 1) == '/';
			default: false;
		}

		for (token in tokens)
			switch token {
				case Static(token):
					route += escapeString(token);
				case Capture(token):
					var prefix = escapeString(token.prefix);
					var capture = '(?:' + token.pattern + ')';

					if (token.repeat) {
						capture += '(?:' + prefix + capture + ')*';
					}

					if (token.optional) {
						if (!token.partial) {
							capture = '(?:' + prefix + '(' + capture + '))?';
						} else {
							capture = prefix + '(' + capture + ')?';
						}
					} else {
						capture = prefix + '(' + capture + ')';
					}

					route += capture;
			}

		if (!strict) {
			route = (endsWithSlash ? route.substr(0, route.length - 2) : route) + '(?:\\/(?=$))?';
		}

		if (end) {
			route += '$';
		} else {
			route += strict && endsWithSlash ? '' : '(?=\\/|$)';
		}

		return new EReg('^' + route, flags(options));
	}

	private static function defaults(?options:Options):Options {
		options = options == null ? {} : options;
		return {
			strict: options.strict == null ? false : options.strict,
			end: options.end == null ? true : options.end,
			sensitive: options.sensitive == null ? false : options.sensitive
		};
	}

	private static function escapeGroup(group:String) {
		var chars = '=!:$/()'.split('');
		for (char in chars) {
			group = StringTools.replace(group, char, '\\$char');
		}
		return group;
	}

	private static function escapeString(str:String) {
		var chars = "\\.+*?=^!:${}()[]|/".split('');
		for (char in chars) {
			str = StringTools.replace(str, char, '\\$char');
		}
		return str;
	}

	private static function flags(options:Options) {
		return options.sensitive ? '' : 'i';
	}

	private static function encodeAsterisk(str:String):String {
		return ~/[?#]/g.map(str, function(matcher) {
			var c = matcher.matched(0);
			return '%' + StringTools.hex(c.charCodeAt(0)).toUpperCase();
		});
	}

	public static function toEReg(path:String, ?options:Options) {
		var tokens = parse(path);
		var keys = [];
		for (token in tokens) {
			switch token {
				case Capture(key):
					keys.push(key);
				default:
					continue;
			}
		}
		return {
			ereg: tokensToEReg(tokens, options),
			keys: keys
		};
	}
}
