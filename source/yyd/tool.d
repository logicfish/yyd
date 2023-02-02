module yyd.tool;

public import yyd.y;
public import yyd.func;

// Compilation primitives and mixin combinators

template __msg (alias T) 
{
    pragma(msg,T);
}

mixin template _msg (alias T) 
{
    pragma(msg,T);
}

mixin template _compilesD(string T) 
{
    enum _ = mixin("__traits(compiles,"~T~")");
}

unittest {
    mixin _compilesD!(q{blah,blah});
    static assert(_ is false);
}

unittest {
    int x;
    mixin _compilesD!(q{x=10});
    static assert(_);
}

mixin template __mixinD (string T) 
{
    alias _ = mixin(T);
}

mixin template _mixin_t (alias T, U ...) 
{
    mixin T!U;
}

template mixin_t (alias T = _identity, U ...) 
{
    mixin T!U mixin_t;
}

mixin template mixin_all(T ...)
if(T.length == 0)
{}

mixin template mixin_all(T ...)
if(T.length == 1)
{
    mixin (T[0]);
}

mixin template mixin_all(T ...)
if(T.length > 1)
{
    mixin (T[0]);
    mixin mixin_all!(T[1..$]);
}

mixin template assertion (alias T) 
{
    static assert (T);
    enum _ = true;
}

unittest {
    mixin assertion!true;
    //mixin assertion!false;
    static assert(is(typeof(_)));
    static assert(_);
}

mixin template _contract (alias Cond, alias Fnc = identity) 
{
    template _ () 
    if(Cond) 
    {
        alias _ = Fnc;
    }
    
    template _ (U...) 
    if(Cond) 
    {
        alias _ = Fnc!U;
    }
}

mixin template _ncontract (alias Cond, alias Fnc = identity) 
{
    mixin _contract!(!Cond,Fnc);
}

unittest {
    mixin _contract!(true,"Test");
    static assert(_!() == "Test");
}

unittest {
    mixin _ncontract!(false,"Test");
    static assert(_!() == "Test");
}

mixin template _contractm (alias Cond,alias Fnc=identity) 
{
    mixin template _ (U...) 
    if(Cond) 
    {
        alias _ = Fnc!U;
    }
}

mixin template _mcontractm(alias Cond,alias Fnc=_identity) {
    mixin template _ (U...) 
    if(Cond) 
    {
        mixin Fnc!U;
    }
}

template contract(alias Cond,alias Fnc=identity) 
if (Cond) 
{
    alias contract = Fnc;
}

mixin template _ncontractm(alias Cond,alias Fnc=identity) 
{
    mixin template _ (U...) 
    if(!Cond) 
    {
        alias _ = Fnc!U;
    }
}

template ncontract(alias Cond,alias Fnc=identity) 
if (!Cond) 
{
    alias ncontract = Fnc;
}

unittest {
    static assert(!is(typeof(contract!(false,"Test"))));
    static assert(is(typeof(contract!(true,"Test")) == string));
    static assert(contract!(true,"Test")=="Test");
}

unittest {
    mixin _contractm!(true,identity) m;
    //static assert(is(typeof(m._!(true))));
    mixin m._!("Test") n;
    static assert(n._ == "Test");
}

unittest {
    mixin _contractm!(false,identity) m;
    //static assert(!is(typeof(m._!(true))));
    //mixin m._!("Test") n;
    //mixin m._!() n;
    //assert(n._ == "Test");
}

unittest {
    mixin _contract!(false,"Test");
    static assert(!is(typeof(_!())));
//    static assert(is(typeof(_) == void));
}

unittest {
    mixin _contract!(true,"Test");
    static assert(_!() == "Test");
}

unittest {
    mixin _contract!(true,identity);
    static assert(_!("Test") == "Test");
}

unittest {
    alias c = mixin_t!(_contract,true,identity);
    //static assert(is(typeof(c._)));
    mixin c._!("Test") d;
    static assert(d._ == "Test");

    mixin _mixin_t!(_contract,true,identity) e;
    mixin e._!("Test") f;
    static assert(f._ == "Test");

    mixin _mixin_t!(_contract,false,identity) g;
    //static assert(!is(typeof(g._)));

}

mixin template _version (
        alias Fnc = _identity,
        alias N = _identity,
        V ...
) {
    version (V) {
        mixin Fnc;
    } else {
        mixin N;
    }
}

template version_ (
        alias Fnc = identity,
        alias N = identity,
        V ...
) {
    version (V) {
        alias version_ = Fnc;
    } else {
        alias version_ = N;       
    }
}
