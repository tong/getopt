package opt;

#if php
import php.Sys;
import php.Lib;
#elseif neko
import neko.Sys;
import neko.Lib;
#elseif cpp
import cpp.Sys;
import cpp.Lib;
#end

/**
	Type of actions.
*/
enum Action {
	storeTrue( dest : String );
	storeFalse( dest : String );
	store( dest : String, ?type : ArgumentType );
	call( f : Void->Void );
}

/**
	Argument datatypes.
*/
enum ArgumentType {
	TInt;
	TFloat;
	TString;
	TBool;
}

private typedef TAction = {
	var switches : Array<String>;
	var type : Action;
	var help : String;
	//var meta
}

private class Options implements Dynamic {
	//public var unkown : Array
	public function new() {
	}
}

/**
	Getopt style cli parser.
*/
class Parser {
	
	public var program : String;
	public var opt(default,null) : Options;
	public var actions : List<TAction>;
	public var exe : String;
	public var description : String;
	
	var args : Array<String>;
	var i : Int;
	
	public function new( program : String ) {
		this.program = program;
		opt = new Options();
		actions = new List();
	}
	
	/**
	*/
	public function help() {
		var b = new StringBuf();
		b.add( "\n\nUsage = " );
		if( exe != null ) {
			b.add( exe );
			b.add( " " );
		}
		if( program != null )
			b.add( program );
		if( actions.length > 0 ) {
			b.add( " [Options]\n" );
			b.add( "\nOptions:\n\n" );
			b.add( "\t-h,--h\n\t\tShow this help message and exit\n" );
			for( a in actions ) {
				b.add( "\n\t" );
				for( i in 0...a.switches.length ) {
					b.add( a.switches[i] );
					if( i != a.switches.length-1 )
						b.add( ", " );
				}
				b.add( "\n" );
				//if( a.switches.length > 1 )
					//b.add( "\n" );
				b.add( "\t\t" );
				if( a.help != null ) {
					b.add( a.help );
				} else {
					b.add( "undocumented." );
				}
				b.add( "\n" );
			}
		}
		b.add( "\n" );
		if( description != null ) {
			b.add( description );
			b.add( "\n" );
		}
		b.add( "\n" );
		Lib.print( b.toString() );
		Sys.exit( 0 );
	}
	
	/**
	*/
	public function addOption( switches : Array<String>, action : Action, ?help : String ) : Bool {
		for( ns in switches ) {
			if( hasSwitch( ns) )
				return false;
		}
		actions.push( { switches : switches, type : action, help : help } );
		return true;
	}
	
	/**
	*/
	public function clear() {
		actions = new List();
		opt = new Options();
		i = 0;
	}
	
	/**
	*/
	public function parseString( t : String ) {
		t = StringTools.trim( t );
		t = ~/(\s+)/.replace( t, " " );
		parse( t.split( " " ) );
	}
	
	/**
	*/
	public function parse( args : Array<String> ) {
		this.args = args;
		opt = new Options();
		i = 0;
		parseArgument();
	}
	
	function parseArgument() {
		var arg = args[i];	
		switch( arg ) {
		case null :
			return;
		default :
			// check fot switches
			var reg = ~/--?([a-zA-Z0-9_-]+)(\s*=\s*([a-zA-Z0-9_-]+))?/;
			// check if '='
			if( reg.match( arg ) ) {
				if( reg.matched( 2 ) != null ) {
					args[i] = reg.matched( 1 );
					args.insert( i+1, reg.matched( 3 ) );
					if( i > 0 ) {
						i--;
						arg = args[i];
					}
				}
				var sw = reg.matched( 1 );
				for( a in actions ) {
					for( s in a.switches ) {
						var sw1 = sw.substr( 0, s.length );
						var sw2 = sw.substr( s.length );
						if( s == sw1 ) { // switch match
							if( sw2 != "" ) {
								args[i] = sw1;
								args.insert( i+1, sw2 );
							}
							resolveSwitch( sw, a.type );
							i++;
							continue;
						}
					}
				}
				//trace("UNHANDLED SWITCH VALUE "+sw);
				addUnregisteredValue( sw );
			} else {
				//trace(" UNHANDLED VALUE "+arg);
				addUnregisteredValue( arg, arg );
			}
		}
		if( i < args.length-1 ) {
			i++;
			parseArgument();
		}
	}
	
	function addUnregisteredValue( arg : String, value : Dynamic = true ) {
		if( hasSwitch( arg ) ) return;
		Reflect.setField( opt, arg, value );
	}
	
	function hasSwitch( t : String ) : Bool {
		for( a in actions ) {
			for( s in a.switches ) {
				if( s == t )
					return true;
			}
		}
		return false;
	}
	
	function resolveSwitch( s : String, a : Action ) {
		switch( a ) {
		case storeTrue(d) :
			Reflect.setField( opt, d, true );
			return;
		case storeFalse(d) :
			Reflect.setField( opt, d, false );
			return;
		case store(d,t) :
			if( t == null ) {
				trace("NUUUUUUUUUUUUUUUULLLLLLLLLL TYPE " );
				Reflect.setField( opt, d, s );
				return;
			}
			var v : String = null;
			if( t != TBool ) {
				//TODO throw errors ?
				if( i == args.length-1 )
					throw "Missing ("+t+") value for switch: "+s ;
				if( StringTools.startsWith( args[i+1], "-" ) )
					throw "Missing argument value for: "+s;
				v = args[i+1];
				//TODO
				v = ~/'(.+)'/g.replace( v, "$1" ); //unquote
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
		case call(cb) :
			cb();
		}
		
	}
	
	public static function get( t : String, matrix : String ) : Parser {
		matrix = StringTools.trim( matrix );
		matrix = ~/(\s+)/.replace( matrix, " " );
		var sw = matrix.split( " " );
		var p = new Parser( null );
		for( m in sw ) {
			p.addOption( [m], storeTrue(m) );
		}
		p.parseString( t );
		return p;
	}
	
	/*
	public static function getArgs( matrix : String ) : Dynamic {
		var args = neko.Sys.args();
		return null;
	}
	*/
	
}
