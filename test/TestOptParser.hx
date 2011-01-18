package;

import Getopt;

class TestOptParser extends haxe.unit.TestCase {
	
	function test() {
		
		var go = new Getopt();
		
		go.parse( ["clean"] );
		assertEquals( true, go.opt.clean );
		assertEquals( 1, Reflect.fields( go.opt ).length );
		
		
		go.addSwitch( ["f","file"], store( "filename", TString ) );
		
		go.parse( ["-f","myfile"] );
		assertEquals( "myfile", go.opt.filename );
		assertEquals( 1, Reflect.fields( go.opt ).length );
		
		go.parse( ["--f","myfile"] );
		assertEquals( "myfile", go.opt.filename );
		assertEquals( 1, Reflect.fields( go.opt ).length );
		
		go.parse( ["---y","myfile"] );
		assertEquals( 2, Reflect.fields( go.opt ).length );
		
		go.parse( ["---y","-f","myfile"] );
		assertEquals( 2, Reflect.fields( go.opt ).length );
	
		go.parse( ["-a","myfile"] );
		assertEquals( 2, Reflect.fields( go.opt ).length );
		
		go.parse( ["-f=myfile"] );
		assertEquals( "myfile", go.opt.filename );
		assertEquals( 1, Reflect.fields( go.opt ).length );
		
		go.parse( ["-a=myfile"] );
		assertEquals( 0, Reflect.fields( go.opt ).length );
		
		go.parse( ["-f = myfile"] );
		assertEquals( "myfile", go.opt.filename );
		assertEquals( 1, Reflect.fields( go.opt ).length );
		
		go.parse( ["--f		=		myfile"] );
		assertEquals( "myfile", go.opt.filename );
		
		go.parse( ["---f=myfile"] );
		assertEquals( 1, Reflect.fields( go.opt ).length );


		//TODO allow this:: -fmyfile
		//cl.parse( ["-fmyfile"] );
		//assertEquals( "myfile", cl.opt.filename );
		//assertEquals( 1, Reflect.fields( cl.opt ).length );
	//	go.parse( ["-fmyfile"] );
	//	trace(go);
	//	assertEquals( 1, Reflect.fields( go.opt ).length );
		
		
		// test string parsing
		
		go = new Getopt();
		go.addSwitch( ["s"], store( "another", TInt ) );
		
		go.parseString( "-s 23" );
		assertEquals( 23, go.opt.another );
		assertEquals( 1, Reflect.fields( go.opt ).length );
		
		go.parseString( "-s=23" );
		assertEquals( 23, go.opt.another );
		
		go.parseString( "--s = 23" );
		assertEquals( 23, go.opt.another );
		
		go.parseString( "-s 23.4" );
		assertEquals( 23, go.opt.another );
		
		go.parseString( "  -s 	23.9" );
		assertEquals( 23, go.opt.another );
		
		go.parseString( "-s 24" );
		assertFalse( go.opt.another==23 );
		
		//TODO
		// test direct access
		
		/*
		var opts = Getopt.opts( "-f -o -q", "foq" );
		assertEquals( 3, Reflect.fields( opts ).length );
		assertEquals( true, opts.f );
		assertEquals( true, opts.o );
		assertEquals( true, opts.q );
		
		var go = Getopt.opts( "-f name -o -q", "foq" );
		trace(go);
		assertEquals( 3, Reflect.fields( opts ).length );
		assertEquals( true, opts.f );
		assertEquals( true, opts.o );
		assertEquals( true, opts.q );
		*/
	}

	static function main() {
		var r = new haxe.unit.TestRunner();
		r.add( new TestOptParser() );
		r.run();
	}
}
