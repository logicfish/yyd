module yyd.tool;

public import yyd.y;
public import yyd.alg;

// Compilation primitives and mixin combinators

template __msg ( T ... ) 
{
    pragma(msg, T);
}

/* mixin template _msg ( T ... ) 
{
    pragma(msg,T);
} */

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

mixin template _mixin_t (alias T = _identity, U ...) 
{
    mixin T!U;
}

mixin template _mixin_mt (alias T = _identity) 
{
    mixin template _(U...) {
        mixin T!U;
    }
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
    alias _front = T[0];
    mixin _front;
}

mixin template mixin_all(T ...)
if(T.length > 1)
{
    alias _front = T[0];
    mixin _front;
    mixin mixin_all!(T[1..$]);
}

mixin template aliasOf(string label,alias T=identity)
{
    mixin("alias " ~ label ~ " = T;");
}

unittest {
    enum a = 0;
    mixin aliasOf!("b",a);
    static assert(is(typeof(b) == typeof(a)));
    static assert(b is a);
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
        string V,
        alias Fnc = identity,
        alias N = identity
) {
    mixin(q{
        version ( } ~ V ~ q{ ) {
            alias version_ = Fnc;
        } else {
            alias version_ = N;       
        }
    });
}

unittest {
    alias r = version_!("unittest",true,false);
    static assert (r);
}

mixin template tryCatch(alias _try, _catchType, alias _catchBody, alias _finally)
{
    alias _f = () {        
        try {
            mixin _try!();
        } catch (_catchType e) {
            mixin _catchBody!(e);
        } finally {
            mixin _finally!();
        }
    };
    alias _ = _f();
}

mixin template _public(alias T=_indentity) 
{
    public {
        mixin T!();
    }
}

mixin template _protected(alias T=_indentity) 
{
    protected {
        mixin T!();
    }
}

mixin template _private(alias T=_indentity) 
{
    private {
        mixin T!();
    }
}

mixin template _package(alias T=_indentity) 
{
    package {
        mixin T!();
    }
}

mixin template _interface(alias T=_indentity) 
{
    interface _ {
        mixin T!();
    }
}

mixin template _interface(alias T=_indentity,interfaces ...) 
{
    interface _ : interfaces {
        mixin T!();
    }
}

mixin template _struct(alias T=_indentity) 
{
    struct _ {
        mixin T!();
    }
}

mixin template _class(alias T=_indentity) 
{
    class _ {
        mixin T!();
    }
}

mixin template _class(alias T=_indentity,superClass) 
{
    class _ : superClass {
        mixin T!();
    }
}

mixin template _class(alias T=_indentity,superClass,interfaces ...) 
{
    class _ : superClass, interfaces {
        mixin T!();
    }
}

mixin template _aliasThis(alias T=identity)
{
    alias T this;
}

mixin template _fnc(alias T=_identity,U ...)
{
    alias _ = (U u) {
        mixin T!();
    };
}

mixin template template_(alias T=_identity,U ...)
{
    alias _ = T!(U);
}


mixin template _template(alias T=_identity,U ...)
{
    template _ (U) {
        mixin T!();
    }
}

mixin template _mtemplate(alias T=_identity,U ...)
{
    mixin template _ (U) {
        mixin T!();
    }
}

mixin template _exitScope(alias T=_identity,alias V=_identity)
{
    alias _ = () {
        scope(exit) {
            mixin V!();
        }
        mixin T!();
    };
}
