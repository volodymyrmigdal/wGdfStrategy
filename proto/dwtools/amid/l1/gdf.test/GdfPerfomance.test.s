( function _GdfPerfomance_test_s_( )
{

'use strict';

if( typeof module !== 'undefined' )
{

  let _ = require( '../../../../dwtools/Tools.s' );
  require( '../gdf/entry/Gdf.s' );
  _.include( 'wTesting' );
  _.include( 'wFiles' );

}

var _global = _global_;
let _ = _global_.wTools;

// --
// context
// --

function onSuiteBegin()
{
  var self = this;
  self.testSuitePath = _.path.dirTempOpen( _.path.join( __dirname, '../..' ), 'wGdf' );

  self.results = Object.create( null );
}

//

function onSuiteEnd()
{
  let self = this;
  let results = self.results;

  _.fileProvider.filesDelete( self.testSuitePath );

  let data = {};

  for( var converter in results )
  {
    let resultsOfConverter = results[ converter ];
    for( var size in resultsOfConverter )
    {
      if( !data[ size ] )
      data[ size ] = [];
      data[ size ].push( resultsOfConverter[ size ] )
    }
  }

  for( let i in data )
  {
    var o =
    {
      data : data[ i ],
      head : [ 'Converter', 'Out size', 'Write time', 'Read time' ],
      colWidth : 15
    }
    var output = _.strTable( o );

    console.log( i, '\n' );
    console.log( output );
  }

}

//

function testApp()
{
  let _ = require( '../../../Tools.s' );
  require( '../../../abase/l8/Converter.s' );

  let commonTypes =
  {
    string : 1,
    number : 1,
    map : 1,
    array : 1,
    boolean : 1,
    null : 1,

    mapComplex : 1,
    arrayComplex : 1
  }

  var o1 = _.mapExtend( { depth : 1, breadth : 1 }, commonTypes );
  var o2 = _.mapExtend( { depth : 20, breadth : 90 }, commonTypes );
  var o3 = _.mapExtend( { depth : 150, breadth : 1100 }, commonTypes );

  _.diagnosticsStructureGenerate( o1 );
  _.diagnosticsStructureGenerate( o2 );
  _.diagnosticsStructureGenerate( o3 );

  let srcs =
  {
    '1Kb' : o1.structure,
    '1Mb' : o2.structure,
    '100Mb' : o3.structure
  };

  let results = {};

  process.on( 'message', ( o ) =>
  {
    run( o );
  })

  /*  */

  function run( o )
  {
    var serialize = _.gdf.select( o.serialize );
    serialize = serialize[ 0 ];

    var deserialize = _.gdf.select( o.deserialize );
    deserialize = deserialize[ 0 ];

    _.assert( serialize );
    _.assert( deserialize );

    console.log( '\n', '-> ', serialize.ext, ' <-', '\n' );

    for( var i in srcs )
    {
      let serialized,
        deserialized;

      let src = srcs[ i ];
      let srcSize = i;
      let result = results[ i ] = [ serialize.ext, '-', '-', '-' ];

      console.log( '\nSrc: ', srcSize );

      try
      {
        let t0 = _.time.now();
        serialized = serialize.encode({ data : src });
        let spent = _.time.spent( t0 );
        let size =  _.strMetricFormatBytes( _.entitySize( serialized.data ) );

        console.log( 'write: ', spent );
        console.log( serialize.ext, 'out size:', size );

        result[ 1 ] = size;
        result[ 2 ] = spent;

        process.send({ converter : serialize.ext, results });

      }
      catch( err )
      {
        _.errLogOnce( err );

        result[ 1 ] = 'Err';
        result[ 2 ] = 'Err';
        result[ 3 ] = 'Err';

        process.send({ converter : serialize.ext, results });

        continue;
      }

      try
      {
        let t0 = _.time.now();
        deserialized = deserialize.encode({ data : serialized.data });
        let spent = _.time.spent( t0 );
        console.log( 'read: ', spent );

        result[ 3 ] = spent;

        process.send({ converter : serialize.ext, results });

      }
      catch( err )
      {
        _.errLogOnce( err );
        result[ 3 ] = 'Err';

        process.send({ converter : serialize.ext, results });
      }

    }

    process.exit();
  }
}

//

let converters =
{
  'bson' :
  {
    serialize : { in : 'structure', out : 'buffer.node', ext : 'bson' },
    deserialize : { in : 'buffer.node', out : 'structure', ext : 'bson' }
  },

  'json.fine' :
  {
    serialize : { in : 'structure', out : 'string', ext : 'json.fine' },
    deserialize : { in : 'string', out : 'structure', ext : 'json', default : 1 }
  },

  'json.min' :
  {
    serialize : { in : 'structure', out : 'string', ext : 'json', default : 1 },
    deserialize : { in : 'string', out : 'structure', ext : 'json', default : 1 }
  },

  'cson' :
  {
    serialize : { in : 'structure', out : 'string', ext : 'cson' },
    deserialize : { in : 'string', out : 'structure', ext : 'cson' }
  },

  'js' :
  {
    serialize : { in : 'structure', out : 'string', ext : 'js' },
    deserialize : { in : 'string', out : 'structure', ext : 'js' }
  },

  'cbor' :
  {
    serialize : { in : 'structure', out : 'buffer.node', ext : 'cbor' },
    deserialize : { in : 'buffer.node', out : 'structure', ext : 'cbor' }
  },

  'yml' :
  {
    serialize : { in : 'structure', out : 'string', ext : 'yml' },
    deserialize : { in : 'string', out : 'structure', ext : 'yml' }
  },

  'msgpack.lite' :
  {
    serialize : { in : 'structure', out : 'buffer.node', ext : 'msgpack.lite' },
    deserialize : { in : 'buffer.node', out : 'structure', ext : 'msgpack.lite' }
  },

  'msgpack.wtp' :
  {
    serialize : { in : 'structure', out : 'buffer.node', ext : 'msgpack.wtp' },
    deserialize : { in : 'buffer.node', out : 'structure', ext : 'msgpack.wtp' }
  }
}

//

function perfomance( test )
{
  let self = this;

  var routinePath = _.path.join( self.testSuitePath, test.name );
  var testAppPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp.js' ) );
  var testAppCode = testApp.toString() + '\ntestApp();';
  _.fileProvider.fileWrite( testAppPath, testAppCode );

  let ready = new _.Consequence().take( null );

  for( var c in self.converters )
    ready.finally( _.routineSeal( self, execute, [ self.converters[ c ] ] ) );


  return ready;

  /*  */

  function execute( converter )
  {
    let o =
    {
      execPath : _.path.nativize( testAppPath ),
      maximumMemory : 1,
      mode : 'spawn',
      ipc : 1,
      timeOut : 5 * 60000,
      stdio : 'pipe',
      outputPiping : 1,
    }

    let con = _.shellNode( o );

    o.process.send( converter );

    o.process.on( 'message', ( data ) =>
    {
      self.results[ data.converter ] = data.results;
    })

    con.finally( ( err, got ) =>
    {
      test.is( !err )
      return null;
    })

    return con;
  }
}

perfomance.experimental = 1;
perfomance.timeOut = _.mapOwnKeys( converters ).length * 6 * 60000;

// --
// declare
// --

var Self =
{

  name : 'Tools/base/EncoderStrategyPerfomance',
  silencing : 1,
  enabled : 0,

  onSuiteBegin,
  onSuiteEnd,

  context :
  {
    testSuitePath : null,
    results : null,
    converters
  },

  tests :
  {
    perfomance
  },

};

Self = wTestSuite( Self );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
