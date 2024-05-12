module yyd.y;

private import std.meta : AliasSeq;
private import std.array : replace;

// Functional combinators

mixin template _void() {}

template identity(alias T) 
{
    alias identity = T;
}

template __identity(alias T) {
    enum __identity = identity!T;
}

auto ref identity(T)(inout ref T t) 
{
    return identity!t;
}

/** 
 * Identity
 * Params:
 *   identity = 
 */
mixin template _identity(alias T) 
{
    alias _ = identity!T;
    
    private import yyd.mashup : __identifier;
    enum toString = "identity!" ~ __identifier!T;
}

/*mixin template _identity(alias T,U...) 
{
    alias _ = T!U;
}*/

template __constant(alias T=identity) 
{
    enum __constant = T;
}

mixin template _constant(alias T=identity) 
{
    enum _ = __constant!T;
    private import yyd.mashup : __identifier;
    enum toString = "__constant!" ~ __identifier!T;
}

/*mixin template _isConstant(alias T=identity) {
    alias _ = __traits(compiles,"__constant!"~__traits(identifier,T));
}*/

template isConstant(alias T=identity) {
        enum isConstant = is(typeof(T)) && __traits(compiles,"enum x = " ~ __identifier!T);
}


template __identifier (alias T) 
{
    enum __identifier = __traits(identifier,T);
}

mixin template _identifier (alias T) 
{
    enum _ = __identifier!T;
    enum toString = "__identifier!("~__traits(identifier,T)~")";
}

unittest {
    import yyd.mashup : __toString;
    import yyd.mashup : _mixinD;
    enum x = "X";
    mixin _identifier!x _;
    static assert(_._ == "x");
    static assert(__toString!_ == "__identifier!(x)");
    enum y = mixin(__toString!_);
    static assert(y == "x");
    
    mixin _mixinD!(__toString!_) z;
    static assert(z._ == "x");
}


/**
 * Decombinators (beta reduction).
 * These restore the intended value where _ has been used as a replacement for eponymosity.
 */

/*mixin template __y()
{
    static if(is(typeof(_))) {
        alias _ = _;
    } else {
    }
}*/
/*
template _y(alias T, V ...)
{
    static if(is(typeof(T._))) {
        static if(
                is(typeof(T._.length))
        ) { // check if it's AliasSeq
            alias _y = T._;
        } else static if(
                __traits(isTemplate,T._)
        ) {
            //mixin T!() _;
            //alias _y = _y!(_);
            //alias _y = _y!(T._!(V),V);
            //static if (V.length == len) {
                alias _y = _y!(T._!(V));
            //} else {
            //    alias _y = _y!(T._!(V[0..len]),V[len..$]);
            //}
        } else {
            alias _y = _y!(T._,V);
        }
    } else {
        alias _y = T;
    }
}
*/

// check for eponymous template. The symbol would have a member with the same name as it's identifier.
template _v(alias T) {
    static if (__traits(compiles,mixin("T." ~ __identifier!T))) {
        alias _v = mixin("T." ~ __identifier!T);
    } else {
        alias _v = _y!T;
    }
}

template _y(alias T)
{
    static if (__traits(compiles,T._)) {
        alias _y = T._;
    } else {
        alias _y = T;
    }
}
//alias _ = _y;

/**
 * Decombinator - reduce and instatiate T as template with given parameters V.
 */
template _yy(alias T,V...) 
{
    static if(__traits(compiles,T._!(V))) {
        alias _yy = _y!(T._!(V));
    } else {
        alias _yy = _y!(T!(V));
    }
}
//alias __ = _yy;

/**
 * Same as _yy but instiate as mixin.
 */
mixin template _yyy(alias T,V...) 
{
    import std.array : replace;
    
    static if(__traits(compiles,T._!(V))) {
        mixin T._!(V);
        enum toString = q{
            mixin T._!(V);
        }.replace("T",_identifier!T).replace("V",_identifier!V);
    } else {
        mixin T!(V);
        enum toString = q{
            mixin T!(V);
        }.replace("T",_identifier!T).replace("V",_identifier!V);
    }
    
    /*enum toString = q{
        static if(__traits(compiles,T._!(V))) {
            mixin T._!(V);
        } else {
            mixin T!(V);
        }        
    }.replace("T",_identifier!T).replace("V",_identifier!V);*/
    
}
//alias ___ = _yyy;



/*mixin template _yy_(alias T)
{
    static if(is(typeof(T._))) {
        alias _ ( V ... ) = () {
            mixin T._!V;
        };
    } else {
        alias _ (V ... ) = () {
            mixin T!V;
        };
    }
}*/

/**
 * Create an alias to the instantiation of template T with parameters U
 */
mixin template _apply(alias T=identity,U...) 
{
    template _ () 
    {
        alias _ = T!U;
    }
    enum toString = q{
        template _ () 
        {
            alias _ = } ~ __identifier!T ~ "!" ~ __identifier!U ~ q{;
        }        
    };
}

/**
 * Create an alias template that instantiates template T inside a lambda with the argument forwarded.
 */
mixin template _call(alias T=identity) 
{
    alias _ (U...) = (U u) => T!u;
}

/**
 * Create a template _ to form a "partial" version of a mixin template T with the first part of the 
 * supplied argument list, and the remainder as parameters to the created template.
 */
mixin template _partialm(alias T=_identity,U...) 
{
    template _ (V...) 
    {
        mixin T!(U,V) _;
    }
}

/**
 * Create a template _ to form a "partial" version of template T with the last part of the 
 * supplied argument list, and the preceding parts as parameters to the created template.
 */
mixin template _rpartialm(alias T=_identity,U ...) 
{
    template _ (V ...) 
    {
        mixin T!(V,U) _;
    }
}

/**
 * Same as _partial but creates a mixin template.
 */
mixin template _mpartial(alias T=identity, U ...) 
{
    mixin template _ (V ...) 
    {
        alias _ = T!(U,V);
    }
}

/**
 * Create an alias template that is a partial version of template T with the first 
 * part of the argument list supplied as parameter U... and the remainder as 
 * parameters to the created template _ .
 */
mixin template _partial(alias T=identity, U ...) 
{
    template _ (V ...) 
    {
        alias _ = T!(U,V);
    }
}

mixin template _rpartial(alias T=_identity,U...) 
{
    template _ (V ...) 
    {
        alias _ = T!(V,U);
    }
}

/*
mixin template _partialf(alias T,U...) 
{
    alias _(V...) = (V v) => T(U,v);
}

mixin template _rpartialf(alias T,U...) {
    alias _(V ...) = (V v) => T(v.U);
}
*/

mixin template _partialf(alias T=identity,U...) 
{
    auto _ (V ...) (V v) 
    {
       return T(U,v);
    }
    //alias _ (V ...) = (V v) => T(U,v);
}

mixin template _rpartialf(alias T=identity,U...) 
{
    auto _ (V ...) (V v) 
    {
        return T(v,U);
    }
    //alias _ (V ...) = (V v) => T(v,U);
}

mixin template _partialmf(alias T=identity,U...) 
{
    auto _ (V ...) (V v) 
    {
       mixin T!(U,v) _;
       return _y!_;
    }
    //alias _ (V ...) = (V v) => T(U,v);
}

mixin template _rpartialmf(alias T=identity,U...) 
{
    auto _ (V ...) (V v) 
    {
        mixin T!(v,U) _;
        return _y!_;
    }
    //alias _ (V ...) = (V v) => T(v,U);
}


unittest {
    auto t1(string A,string B,string C)() {
        return A ~ B ~ C;
    }

    mixin _partial!(t1,"First ","second ") p;
    enum result = p._!"third";

    static assert (result == "First second third");
}

unittest {
    auto t1(string A,string B,string C)() {
        return A ~ B ~ C;
    }

    mixin _rpartial!(t1,"First ","second") p;
    enum result = _yy!(p,"third ");

    static assert (result == "third First second");
}

unittest {
    template t1(string A,string B,string C) {
        enum t1 = A ~ B ~ C;
    }

    mixin _partial!(t1,"First ") p;
    //mixin _partial!(_y!(p,"second ")) q;
    mixin _partial!(_v!p,"second ") q;
    //enum result = q._!("third");
    enum result = _yy!(q,"third");

    static assert (result == "First second third");
}

unittest {
    template t1(string A,string B,string C) {
        enum t1 = A ~ B ~ C;
    }

    mixin _partial!(t1,"First ") p;
    mixin _partial!(_y!p,"second ") _p;
    mixin _apply!(_y!_p,"third") _q;
    enum result = _yy!(_q);

    static assert (result == "First second third");
}

unittest {
    auto t1(string A,string B,string C) {
        return A ~ B ~ C;
    }

    mixin _partialf!(t1,"First ") p;
    //mixin _partialf!(p._,"second ") _p;
    mixin _partialf!(_y!p,"second ") _p;
    //enum result = _p._("third");
    enum result = _y!(_p)("third");

    static assert (result == "First second third");
}

/*template bind(alias T=identity) {
    template bind(U) 
    if(is(U == struct))
    {
        
    }
}*/

/**
 * Embed a template into a lambda.
 */
template toFnc(alias op,V ...) 
{
	alias toFnc(T...) = (V v)=>op!T(v);
}

/**
 * Mxin template decombinator into lambda.
 */
mixin template y__(alias op) 
{
	alias _ = () {
		mixin op!(T) _;
        return y!(_);
	};
}

/*template y_ (alias T) {
    alias y_() = ()=>T!();
}*/

mixin template _toFnc(alias op)
{
	alias _ = toFnc!op;
}

mixin template _toFnc_m(alias op, V ...)
{
    mixin toFnc_m!(op,V) _;
	//alias _ = toFnc_m!(op,V);
}


