( function _Cbor_test_s_()
{
'use strict';

if( typeof module !== 'undefined' )
{
  let _ = require( '../../../../dwtools/Tools.s' );
  require( '../gdf/entry/Gdf.s' );
  _.include( 'wTesting' );
}

var _global = _global_;
let _ = _global_.wTools;

_.assert( _testerGlobal_.wTools !== _global_.wTools );

// --
// test
// --

function cbor( test )
{
  var self = this;

  let SamplesPrimitive =
  {
    null : null,
    number : 13,
    string : 'something',
  }

  let SamplesSimple =
  {
    map : { a : '1', dir : { b : 2 }, c : [ 1, 2, 3 ] },
    array : [ { a : '1', dir : { b : 2 }, c : [ 1, 2, 3 ] } ],
  }

  let SamplesComplicated =
  {
    regexp : /.regexp/g,
    infinity : -Infinity,
    nan : NaN,
    date : new Date(),
  }

  /* */

  test.case = 'select';

  var serialize = _.gdf.select({ in : 'structure', out : 'buffer.node', ext : 'cbor' });
  test.identical( serialize.length, 1 );
  serialize = serialize[ 0 ];

  var deserialize = _.gdf.select({ in : 'buffer.node', out : 'structure', ext : 'cbor' });
  test.identical( deserialize.length, 1 );
  deserialize = deserialize[ 0 ];

  /* */

  test.open( 'simple' );
  for( let s in SamplesSimple )
  {
    test.case = s;
    let src = SamplesSimple[ s ];

    if( !_.mapIs( src ) )
    src = { [ s ] : src };

    let serialized = serialize.encode({ data : src });
    test.identical( serialized.format, 'buffer.node' );
    test.is( _.bufferNodeIs( serialized.data ) );

    let deserialized = deserialize.encode({ data : serialized.data });
    test.identical( deserialized.data, src );
    test.identical( deserialized.format, 'structure' );
  }
  test.close( 'simple' );

  test.case = 'all simple together';
  var serialized = serialize.encode({ data : SamplesSimple });
  test.identical( serialized.format, 'buffer.node' );
  test.is( _.bufferNodeIs( serialized.data ) );

  var deserialized = deserialize.encode({ data : serialized.data });
  test.identical( deserialized.data, SamplesSimple );
  test.identical( deserialized.format, 'structure' );

  /* */

  test.open( 'primitive' );
  for( let s in SamplesPrimitive )
  {
    test.case = s;
    let src = SamplesPrimitive[ s ];

    if( !_.mapIs( src ) )
    src = { [ s ] : src };

    let serialized = serialize.encode({ data : src });
    test.identical( serialized.format, 'buffer.node' );

    let deserialized = deserialize.encode({ data : serialized.data });
    test.identical( deserialized.data, src );
    test.identical( deserialized.format, 'structure' );
  }
  test.close( 'primitive' );

  test.case = 'all primitive together';
  var serialized = serialize.encode({ data : SamplesPrimitive });
  test.identical( serialized.format, 'buffer.node' );
  test.is( _.bufferNodeIs( serialized.data ) );

  var deserialized = deserialize.encode({ data : serialized.data });
  test.identical( deserialized.data, SamplesPrimitive );
  test.identical( deserialized.format, 'structure' );

  /* */

  test.open( 'complicated' );
  for( let s in SamplesComplicated )
  {
    test.case = s;
    let src = SamplesComplicated[ s ];

    if( !_.mapIs( src ) )
    src = { [ s ] : src };

    let serialized = serialize.encode({ data : src });
    test.identical( serialized.format, 'buffer.node' );

    let deserialized = deserialize.encode({ data : serialized.data });
    let identical = _.entityIdentical( deserialized.data, src );
    if( _.regexpIs( src[ s ] ) )
    test.is( !identical );
    else
    test.is( identical );
    test.identical( deserialized.format, 'structure' );
  }
  test.close( 'complicated' );

  test.case = 'all complicated together';
  var serialized = serialize.encode({ data : SamplesComplicated });
  test.identical( serialized.format, 'buffer.node' );
  test.is( _.bufferNodeIs( serialized.data ) );

  var deserialized = deserialize.encode({ data : serialized.data });
  test.notIdentical( deserialized.data, SamplesComplicated );
  test.identical( deserialized.format, 'structure' );

  /* */

}

// --
// declare
// --

var Self =
{

  name : 'Tools.cbor.gdf',
  silencing : 1,

  context :
  {
  },

  tests :
  {
    cbor
  },

};

Self = wTestSuite( Self );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
