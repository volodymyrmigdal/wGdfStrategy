(function _GdfConverter_s_() {

'use strict';

/**
 * Collection of strategies to convert complex data structures from one GDF ( generic data format ) to another GDF. You may use the module to serialize complex data structure to string or deserialize string back to the original data structure. Generic data format ( GDF ) is a format of data structure designed with taking into account none unique feature of data so that it is applicable to any kind of data.
  @module Tools/base/GdfConverter
*/

/**
 * @file GdfConverter.s.
 */

if( typeof module !== 'undefined' )
{

  let _ = require( '../../Tools.s' );

  _.include( 'wCopyable' );
  _.include( 'wRoutineFundamentals' );

}

let _global = _global_;
let _ = _global_.wTools;
let Parent = null;
let Self = function wGenericDataFormatConverter( o )
{
  return _.instanceConstructor( Self, this, arguments );
}

Self.shortName = 'Gdf';

// --
// routine
// --

function finit()
{
  let encoder = this;
  encoder.unform();
  return _.Copyable.prototype.finit.apply( encoder, arguments );
}

//

function init( o )
{
  let encoder = this;

  _.assert( arguments.length === 1 );

  _.instanceInit( encoder );
  Object.preventExtensions( encoder );

  if( o )
  encoder.copy( o );

  encoder.form();

  return encoder;
}

//

function unform()
{
  let encoder = this;

  // debugger; xxx

  _.arrayRemoveOnceStrictly( encoder.Elements, encoder );

  encoder.in.forEach( ( e, k ) =>
  {
    _.arrayRemoveOnceStrictly( encoder.InMap[ e ], encoder );
  });
  debugger;

  encoder.out.forEach( ( e, k ) =>
  {
    debugger;
    _.arrayRemoveOnceStrictly( encoder.OutMap[ e ], encoder );
  });

  encoder.ext.forEach( ( e, k ) =>
  {
    debugger;
    _.arrayRemoveOnceStrictly( encoder.ExtMap[ e ], encoder );
  });

  encoder.inOut.forEach( ( e, k ) =>
  {
    _.arrayRemoveOnceStrictly( encoder.InOutMap[ e ], encoder );
  });

}

//

function form()
{
  let encoder = this;

  _.assert( encoder.inOut === null );

  encoder.in = _.arrayAs( encoder.in );
  encoder.out = _.arrayAs( encoder.out );
  encoder.ext = _.arrayAs( encoder.ext );

  if( encoder.name === null )
  encoder.name = ( encoder.ext[ 0 ] ? encoder.ext[ 0 ] + '-' : '' ) + encoder.in[ 0 ] + '->' + encoder.out[ 0 ];

  /* - */

  _.arrayAppendOnceStrictly( encoder.Elements, encoder );

  encoder.in.forEach( ( e, k ) =>
  {
    encoder.InMap[ e ] = _.arrayAppend( encoder.InMap[ e ] || null, encoder );
  });

  encoder.out.forEach( ( e, k ) =>
  {
    encoder.OutMap[ e ] = _.arrayAppend( encoder.OutMap[ e ] || null, encoder );
  });

  encoder.ext.forEach( ( e, k ) =>
  {
    encoder.ExtMap[ e ] = _.arrayAppend( encoder.ExtMap[ e ] || null, encoder );
  });

  let inOut = _.eachSample([ encoder.in, encoder.out ]);
  encoder.inOut = [];
  inOut.forEach( ( inOut ) =>
  {
    let key = inOut.join( '-' );
    encoder.inOut.push( key );
    encoder.InOutMap[ key ] = _.arrayAppend( encoder.InOutMap[ key ] || null, encoder );
  });

  /* - */

  _.assert( _.strIs( encoder.name ) );
  _.assert( _.strsAreAll( encoder.in ) );
  _.assert( _.strsAreAll( encoder.out ) );
  _.assert( _.strsAreAll( encoder.ext ) );

  _.assert( encoder.in.length >= 1 );
  _.assert( encoder.out.length >= 1 );
  _.assert( encoder.ext.length >= 0 );

  _.assert( _.routineIs( encoder.encode ) );

}

//

function encode_pre( routine, args )
{
  let encoder = this;
  let o = args[ 0 ];

  _.assert( arguments.length === 2 );
  _.routineOptions( routine, o );

  return o;
}

//

function encode_body( o )
{
  let encoder = this;

  o = _.assertRoutineOptions( encode_body, arguments );

  /* */

  let op = Object.create( null );

  op.envMap = o.envMap || Object.create( null );

  op.in = Object.create( null );
  op.in.data = o.data;
  op.in.format = o.format || encoder.in;
  if( _.arrayIs( op.in.format ) )
  op.in.format = op.in.format.length === 1 ? op.in.format[ 0 ] : undefined;

  op.out = Object.create( null );
  op.out.data = undefined;
  op.out.format = undefined;

  /* */

  try
  {

    _.assert( _.objectIs( op.envMap ) )
    _.assert( _.strIs( op.in.format ), 'Not clear which input format is' );
    _.assert( _.arrayHas( encoder.in, op.in.format ), () => 'Unknown format ' + op.in.format );

    // debugger;
    encoder.onEncode( op );
    // debugger;

    op.out.format = op.out.format || encoder.out;
    if( _.arrayIs( op.out.format ) )
    op.out.format = op.out.format.length === 1 ? op.out.format[ 0 ] : undefined;

    _.assert( _.strIs( op.out.format ), 'Output should have format' );
    _.assert( _.arrayHas( encoder.out, op.out.format ), () => 'Strange output format ' + o.out.format );

  }
  catch( err )
  {
    debugger;
    op.out.format = undefined;
    throw _.err( 'Error format ' + _.toStr( op.in.format ) + ' by encoder ' + encoder.name + '\n', err );
  }

  /* */

  return op.out;
}

encode_body.defaults =
{
  data : null,
  format : null,
  envMap : null,
}

let encode = _.routineFromPreAndBody( encode_pre, encode_body );

//

/**
 * Searches for converters.
 * Finds converters that match the specified selector.
 * Converter is selected if all fields of selector are equal with appropriate properties of the converter.
 *
 * @param {Object} selector a map with one or several rules that should be met by the converter
 *
 * Possible selector properties are :
 * @param {String} [selector.in] Input format of the converter
 * @param {String} [selector.out] Output format of the converter
 * @param {String} [selector.ext] File extension of the converter
 * @param {Boolean|Number} [selector.default] Selects default converter for provided in,out and ext
 *
 * @example
 * //returns converters that accept string as input
 * let converters = _.Gdf.Select({ in : 'string' });
 * console.log( converters )
 *
 * @example
 * //returns converters that accept string and return structure( object )
 * let converters = _.Gdf.Select({ in : 'string', out : 'structure' });
 * console.log( converters )
 *
 * * @example
 * //returns default json converter that encodes structure to string
 * let converters = _.Gdf.Select({ in : 'structure', out : 'string', ext : 'json', default : 1 });
 * console.log( converters[ 0 ] )
 *
 * @returns {Array} Returns array with selected converters or empty array if nothing found.
 * @throws {Error} If more than one argument is provided
 * @throws {Error} If selector is not an Object
 * @throws {Error} If selector has unknown field
 * @method Select
 * @memberof Tools/base/GdfConverter
 * @static
 */

function Select( selector )
{
  _.assert( arguments.length === 1 );

  let result = _.filter( this.Elements, select );

  if( result.length > 1 )
  if( selector.default !== undefined )
  {
    result = result.filter( ( e ) => selector.default == e.default );
  }

  result = result.map( ( e ) => _.mapExtend( null, selector, { encoder : e } ) );
  result = this.Current( result );

  return result;

  /* */

  function select( converter )
  {
    for( let s in selector )
    {
      let sfield = selector[ s ];
      let cfield = converter[ s ];
      if( s === 'default' )
      continue;
      if( _.arrayIs( cfield ) )
      {
        _.assert( _.strIs( sfield ) );
        if( !_.arrayHas( cfield, sfield ) )
        return undefined;
      }
      else _.assert( 0, 'Unknown selector field ' + s );
      // else
      // {
      //   _.assert( _.boolLike( sfield ) );
      //   if( cfield !== null )
      //   if( cfield != sfield )
      //   return undefined;
      // }
    }
    return converter;
  }

}

// --
// relations
// --

let Elements = [];
let InMap = Object.create( null );
let OutMap = Object.create( null );
let ExtMap = Object.create( null );
let InOutMap = Object.create( null );
let Supported = 
{
  'bson' : 
  {
    primitive : 2,
    regexp : 2,
    buffer : 0,
    complex : 1
  },
  'yaml' : 
  {
    primitive : 2,
    regexp : 2,
    buffer : 1,
    complex : 2
  },
  'cbor' : 
  {
    primitive : 2,
    regexp : 1,
    buffer : 1,
    complex : 1
  },
  'js' : 
  {
    primitive : 3,
    regexp : 2,
    buffer : 3,
    complex : 2
  },
  'cson' : 
  {
    primitive : 1,
    regexp : 2,
    buffer : 2,
    complex : 1
  },
  'json.fine' : 
  {
    primitive : 1,
    regexp : 0,
    buffer : 0,
    complex : 1
  },
  'json.min' : 
  {
    primitive : 1,
    regexp : 0,
    buffer : 0,
    complex : 1
  }
}

let Composes =
{

  name : null,
  shortName : null,

  ext : null,
  in : null,
  out : null,
  inOut : null,

  onEncode : null,
  default : 0,
  forConfig : 1,

}

let Aggregates =
{
}

let Restricts =
{
}

let Statics =
{

  Select,

  Elements,
  InMap,
  OutMap,
  ExtMap,
  InOutMap,

  Supported

}

// --
// declare
// --

let Proto =
{

  finit,
  init,
  unform,
  form,
  encode,

  // relations

  Composes,
  Aggregates,
  Restricts,
  Statics,

}

//

_.classDeclare
({
  cls : Self,
  parent : Parent,
  extend : Proto,
});

_.Copyable.mixin( Self );

// --
// export
// --

_[ Self.shortName ] = Self;

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

if( typeof module !== 'undefined' )
{
  require( './GdfCurrent.s' );
  require( './GdfFormats.s' );
  require( './OldEncoders.s' );
}

})();