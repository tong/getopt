
#if php
import php.Lib;
import php.Sys;
#elseif neko
import neko.Lib;
import neko.Sys;
#elseif cpp
import cpp.Lib;
import cpp.Sys;
#elseif nodejs
import js.Lib;
import js.Sys;
#end

enum ArgumentType {
	TInt;
	TFloat;
	TString;
	//TPath;
	//TURL;
	TBool;
	//ROptional( t : ArgumentType );
	//RList( types : Iterable<ArgumentType> );
}

enum Action {
	store( dest : String, ?type : ArgumentType );
	//stores( dest : Array<String>, types : Array<ArgumentType> );
	//cb( f : Void->Void );
}

private typedef Switch = {
	var names : Array<String>;
	var action : Action;
	//var mask : Iterable<ArgumentType>;
	var required : Bool;
}

private class Options implements Dynamic {
	public function new() {}
}

/**
	
*/
class Getopt {
	
	static var regexp_switch =  ~/^--?([a-zA-Z0-9][a-zA-Z0-9_-]*)(\s*=\s*([a-zA-Z0-9_-]+))?$/;
	
	public var opt(default,null) : Options;
	
	//var options : Array<String>;
	var switches : Array<Switch>;
	var args : Array<String>;
	var i : Int;
	
	public function new() {
		opt = new Options();
		switches = new Array();
	}
	
	/**
	*/
	public function addSwitch( names : Iterable<String>, action : Action,
							   required : Bool = false ) {
		var _names = new Array<String>();
		for( n in names ) {
			//TODO check
			_names.push( n );
		}
		switches.push( { names : _names, action : action, required : required } );
	}
	
	/**
	*/
	public function parseString( t : String ) : Bool {
		if( t == null || t == "" )
			return false;
		t = StringTools.trim( t );
		t = ~/(\s+)/.replace( t, " " );
		var args = t.split( " " );
		for( i in 0...args.length ) {
			if( args[i] == "=" ) args.splice( i, 1 ); //?
		}
		return parse( args );
	}
	
	/**
	*/
	public function parse( args : Array<String> ) : Bool {
		this.args = args;
		opt = new Options();
		i = 0;
		return parseArgument();
	}
	
	public function toString() : String {
		var t = "\nopts:\n";
		for( o in Reflect.fields( opt ) )
			t += "  "+o+"\n";
		t += "switches:\n";
		for( s in switches )
			t += "  "+s.names.join(",")+": "+s.action+", "+s.required+"\n";
		return t;
	}
	
	function parseArgument() : Bool {
		var arg = args[i];
		if( arg == null || arg == "" ) return false;
		arg = StringTools.trim( arg );
		var r = regexp_switch; //r1:cmd, r2:(=), r3:param
		if( r.match( arg ) ) {
			var hasEqualsSign = r.matched( 2 ) != null;
			if( hasEqualsSign ) {
				args[i] = r.matched( 1 );
				args.insert( i+1, r.matched( 3 ) );
				if( i > 0 ) {
					i--;
					arg = args[i];
				}
			}
			var sw = r.matched( 1 );
			for( s in switches ) {
				for( n in s.names ) {
					var solved = false;
					if( n == sw ) { // match
						resolveSwitch( sw, s.action );
						i++;
						solved = true;
					}
					if( solved )
						break;
				}
				if( hasEqualsSign )
					i++;
				else
					addUnhandledValue( sw );
			}
		} else {
			addUnhandledValue( arg, arg );
		}
		return ( ++i < args.length ) ? parseArgument() : true;
	}
	
	function resolveSwitch( s : String, a : Action ) {
		switch( a ) {
		case store(d,t) :
			if( t == null ) {
				Reflect.setField( opt, d, s );
				return;
			}
			var v : String = null;
			if( t != TBool ) {
				//TODO throw errors ?
				if( i == args.length-1 )
					throw "Missing ("+t+") value for switch: "+s;
				v = args[i+1];
				v = ~/'(.+)'/g.replace( v, "$1" ); // unquote
			}
			switch( t ) {
			case TInt :
				Reflect.setField( opt, d, Std.parseInt( v ) );
			case TFloat :
				Reflect.setField( opt, d, Std.parseFloat( v ) );
			case TString :
				Reflect.setField( opt, d, v );
			case TBool :
				Reflect.setField( opt, d, true );
			}
		}
	}
	
	function addUnhandledValue( arg : String, value : Dynamic = true ) {
		if( hasSwitch( arg ) )
			return;
		Reflect.setField( opt, arg, true );
		//Reflect.setField( opt, arg, value );
	}
	
	function hasSwitch( t : String ) : Bool {
		for( s in switches ) { for( n in s.names ) { if( n == t ) return true; } }
		return false;
	}
	
	/*
	public static function opts( t : String, matrix : String ) : Dynamic {
		matrix = StringTools.trim( matrix );
		matrix = ~/(\s+)/.replace( matrix, " " );
		var sw = matrix.split( " " );
		var p = new Getopt();
		for( m in sw )
			p.addSwitch( [m], store(m) );
		p.parseString( t );
		return p.opt;
	}
	*/
	
}
