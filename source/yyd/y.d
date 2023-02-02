module yyd.y;

import std.meta : AliasSeq;

// Functional combinators

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

template identity(alias T,U...) 
{
   alias identity = T!U;
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

mixin template _apply(alias T=identity,U...) 
{
    template _ () 
    {
        alias _ = T!U;
    }
}

mixin template _call(alias T=identity) 
{
    alias _ (U...) = (U u) => T!u;
}

mixin template _partialm(alias T=_identity,U...) 
{
    template _ (V...) 
    {
        mixin T!(U,V) _;
    }
}

mixin template _rpartialm(alias T=_identity,U ...) 
{
    template _ (V ...) 
    {
        mixin T!(V,U) _;
    }
}

mixin template _mpartial(alias T=identity, U ...) 
{
    mixin template _ (V ...) 
    {
        alias _ = T!(U,V);
    }
}

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
   auto _ (V...) (V v) {
       return T(U,v);
   }
}

mixin template _rpartialf(alias T=identity,U...) 
{
    auto _(V...)(V v) {
        return T(v,U);
    }
}

unittest {
    auto t1(string A,string B,string C)() {
        return A ~ B ~ C;
    }

    mixin _partial!(t1,"First ","second ") p;
    enum result = p._!("third");

    static assert (result == "First second third");
}

unittest {
    auto t1(string A,string B,string C)() {
        return A ~ B ~ C;
    }

    mixin _rpartial!(t1,"First ","second") p;
    enum result = p._!("third ");

    static assert (result == "third First second");
}

unittest {
    template t1(string A,string B,string C) {
        enum t1 = A ~ B ~ C;
    }

    mixin _partial!(t1,"First ") p;
    mixin _partial!(p._,"second ") _p;
    enum result = _p._!("third");

    static assert (result == "First second third");
}

unittest {
    template t1(string A,string B,string C) {
        enum t1 = A ~ B ~ C;
    }

    mixin _partial!(t1,"First ") p;
    mixin _partial!(p._,"second ") _p;
    mixin _apply!(_p._,"third") _q;
    enum result = _q._!();

    static assert (result == "First second third");
}

unittest {
    auto t1(string A,string B,string C) {
        return A ~ B ~ C;
    }

    mixin _partialf!(t1,"First ") p;
    mixin _partialf!(p._,"second ") _p;
    enum result = _p._("third");

    static assert (result == "First second third");
}
