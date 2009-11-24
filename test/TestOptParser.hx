package test;

import opt.Parser;

class TestOptParser extends haxe.unit.TestCase {
	
	function test() {
		
		// test simple argument reading
		
		var terminal = new opt.Parser( "TestOptParser.n" );
		terminal.addOption( ["f"], store( "filename", TString ) );
		
		terminal.parse( ["-f","myfile"] );
		assertEquals( "myfile", terminal.opt.filename );
		
		terminal.parse( ["--f","myfile"] );
		assertEquals( "myfile", terminal.opt.filename );

		terminal.parse( ["-f=myfile"] );
		assertEquals( "myfile", terminal.opt.filename );
		
		terminal.parse( ["--f=myfile"] );
		assertEquals( "myfile", terminal.opt.filename );
		
		terminal.parse( ["-f = myfile"] );
		assertEquals( "myfile", terminal.opt.filename );
		
		terminal.parse( ["-f	=	myfile"] );
		assertEquals( "myfile", terminal.opt.filename );
		
		terminal.parse( ["-fmyfile"] );
		assertEquals( "myfile", terminal.opt.filename );
		
		terminal.parse( ["--fmyfile"] );
		assertEquals( "myfile", terminal.opt.filename );
		
		terminal.parseString( "-fmyfile" );
		assertEquals( "myfile", terminal.opt.filename );
		
		terminal.parseString( "-f myfile" );
		assertEquals( "myfile", terminal.opt.filename );
		
		terminal.parseString( " -f myfile " );
		assertEquals( "myfile", terminal.opt.filename );
		
		
		// test string reading
		
		terminal = new opt.Parser( "TestOptParser.n" );
		terminal.addOption( ["s"], store( "another", TInt ) );
		
		terminal.parseString( "-s 23" );
		assertEquals( 23, terminal.opt.another );

		terminal.parseString( "-s 23.4" );
		assertEquals( 23, terminal.opt.another );
		
		terminal.parseString( "-s 23.9" );
		assertEquals( 23, terminal.opt.another );
		
		terminal.parseString( "-s 24" );
		assertFalse( terminal.opt.another==23 );
		

		// test unregistered options
		
		terminal = new opt.Parser( "TestOptParser.n" );
		
		terminal.parseString( "-f outfile --quiet" );
		assertEquals( true, terminal.opt.f );
		assertEquals( true, terminal.opt.quiet );
		assertEquals( "outfile", terminal.opt.outfile );
		
		terminal.parseString( "--quiet --file outfile" );
		assertEquals( true, terminal.opt.file );
		assertEquals( true, terminal.opt.quiet );
		assertEquals( "outfile", terminal.opt.outfile );
		
		terminal.parseString( "--quiet -foutfile" );
		assertEquals( null, terminal.opt.file );
		assertEquals( true, terminal.opt.quiet );
		assertEquals( null, terminal.opt.outfile );
		assertEquals( true, terminal.opt.foutfile );
		
		terminal.addOption( ["f"], store( "filename", TString ) );
		terminal.parseString( "--quiet -foutfile" );
		assertEquals( true, terminal.opt.quiet );
		assertEquals( "outfile", terminal.opt.filename );
		assertEquals( null, terminal.opt.outfile );
		
		terminal.parseString( "-f outfile --quiet" );
		assertEquals( "outfile", terminal.opt.filename );
		assertEquals( true, terminal.opt.quiet );
		assertEquals( null, terminal.opt.outfile );
		
		
		// test callback
		
		var cl = new opt.Parser( "TestOptParser.n" );
		cl.addOption( ["s"], call( myCallback ) );
		cl.parse( ["-s"] );
		//..................
		
		
		// test direct access
		
		var cl = opt.Parser.get( "-f -o -q", "foq" ).opt;
		assertEquals( true, cl.f );
		assertEquals( true, cl.o );
		assertEquals( true, cl.q );
		assertEquals( 3, Reflect.fields( cl ).length );
		
		var cl = opt.Parser.get( "  --f   ", "foq" ).opt;
		assertEquals( true, cl.f );
		assertEquals( 1, Reflect.fields( cl ).length );
		
		var cl = opt.Parser.get( "  --test   ", "foq test" ).opt;
		assertEquals( true, cl.test );
		assertEquals( 1, Reflect.fields( cl ).length );
		
		
		// test help
		
		/*
		terminal = new opt.Parser( "TestOptParser.n" );
		terminal.addSwitch( ["f","ff","fff"], store( "filename", TString ), "TEST info" );
		terminal.addSwitch( ["s"], store( "filename", TString ) );
		terminal.exe = "neko";
		terminal.description = "This is a testunit for opt.Parser.";
		terminal.help();
		*/
	}
	
	function myCallback() {
		trace("MYCALLBACK");
	}

	static function main() {
		var r = new haxe.unit.TestRunner();
		r.add( new TestOptParser() );
		r.run();
	}
	
}
