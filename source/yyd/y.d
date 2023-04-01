module yyd.y;

private import std.meta : AliasSeq;

// Functional combinators

/** 
 * Identity
 * Params:
 *   identity = 
 */
mixin template _identity(alias T) 
{
    alias _ = T;
}

mixin template _identity(alias T,U...) 
{
    alias _ = T!U;
}

template identity(alias T) 
{
    alias identity = T;
}

auto ref identity(T)(inout ref T t) 
{
    return t;
}

mixin template _evaluate(alias T=identity) 
{
    enum _ = T;
}

template evaluate(alias T=identity) 
{
    enum evaluate = T;
}


/**
 * Decombinators.
 * These restore the original value where _ has been used as a replacement for eponymosity.
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

template _y(alias T)
{
    static if(is(typeof(T._))) {
        alias _y = T._;
    } else {
        // TODO check for eponymous template. The symbol would have a member with the same name as it's identifier.
        alias _y = T;
    }
}

/**
 * Decombinator and instatiate T as template with given parameters V.
 */
template _yy(alias T,V...) 
{
    static if(is(typeof(T._))) {
        alias _yy = _y!(T._!(V));
    } else {
        alias _yy = _y!(T!(V));
    }
}
/**
 * Same as _yy but instiate as mixin.
 */
mixin template _yyy(alias T,V...) 
{
    static if(is(typeof(T._))) {
        mixin T._!(V);
    } else {
        mixin T!(V);
    }
}

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
}

/**
 * Create an alias template that instantiates template T with a passed in argument.
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
    //enum result = _y!(p,"third");
    enum result = p._!"third";

    static assert (result == "First second third");
}

unittest {
    auto t1(string A,string B,string C)() {
        return A ~ B ~ C;
    }

    mixin _rpartial!(t1,"First ","second") p;
    //enum result = _y!(p,"third ");
    enum result = _yy!(p,"third ");

    static assert (result == "third First second");
}

unittest {
    template t1(string A,string B,string C) {
        enum t1 = A ~ B ~ C;
    }

    mixin _partial!(t1,"First ") p;
    //mixin _partial!(_y!(p,"second ")) q;
    mixin _partial!(p._,"second ") q;
    //enum result = q._!("third");
    enum result = _yy!(q,"third");

    static assert (result == "First second third");
}

unittest {
    template t1(string A,string B,string C) {
        enum t1 = A ~ B ~ C;
    }

    mixin _partial!(t1,"First ") p;
    mixin _partial!(p._,"second ") _p;
    mixin _apply!(_p._,"third") _q;
    //enum result = _q._!();
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
    enum result = _yy!(_p,"third");

    static assert (result == "First second third");
}

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

template y_ (alias T) {
    alias y_() = ()=>T!v;
}

mixin template _toFnc(alias op)
{
	alias _ = toFnc!op;
}

mixin template _toFnc_m(alias op, V ...)
{
    mixin toFnc_m!(op,V) _;
	//alias _ = toFnc_m!(op,V);
}


