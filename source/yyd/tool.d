module yyd.tool;

public import yyd.y;
public import yyd.alg;
public import yyd.mashup;

// Compilation primitives and mixin combinators


mixin template assertion (alias T) 
{
    static assert (T);
    enum _ = true;
    enum toString = "static assert (" ~ __toString!T ~ ")";
}

unittest {
    mixin assertion!true;
    //mixin assertion!false;
    //static assert(is(typeof(_)));
    //static assert(_);
    static assert (toString == "static assert (\x01)" );
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

/*mixin template _tryCatch(alias _try, _catchType, alias _catchBody, alias _finally)
{
    try {
        mixin _try!();
    } catch (_catchType e) {
        mixin _catchBody!(e);
    } finally {
        mixin _finally!();
    }
}*/

mixin template _public(alias T=_identity,V...) 
{
    public {
        mixin T!(V);
    }
}

mixin template _protected(alias T=_identity,V...) 
{
    protected {
        mixin T!(V);
    }
}

mixin template _private(alias T=_identity,V...) 
{
    private {
        mixin T!(V);
    }
}

mixin template _package(alias T=_identity,V...) 
{
    package {
        mixin T!(V);
    }
}

mixin template _synchronized(alias T=_identity,V...) 
{
    synchronized {
        mixin T!(V);
    }
}

// Class elements

mixin template _aliasThis(alias T=_identitiy) {
    //import std.array : replace;
    mixin template _aliasThis_(alias T=_identity)
    {
        mixin ("alias T this;".replace("T",__identifier!T));
    }
    mixin _import!("std.array : replace",_aliasThis_,T);
}

mixin template _field(string ident,alias T=identity,alias V=identity) {
    enum toString = (T.stringof ~ " "~ident~" = "~V.stringof~";");
    mixin(toString);
}

mixin template _intField(string ident,alias T=__identity!(0)) {
    mixin _field!(ident,int,T);
}
mixin template _longField(string ident,alias T=__identity!(0)) {
    mixin _field!(ident,long,T);
}
mixin template _stringField(string ident,alias T=__identity!("")) {
    mixin _field!(ident,string,T);
}
mixin template _doubleField(string ident,alias T=__identity!("")) {
    mixin _field!(ident,double,T);
}



mixin template _interface(alias T=_identity,V...) 
{
    interface _ {
        mixin T!(V);
    }
}

mixin template _interface(alias T=_identity,interfaces ...) 
{
    interface _ : interfaces {
        mixin T!();
    }
}

mixin template _struct(alias T=_identity) 
{
    struct _ {
        mixin T!();
    }
}

mixin template _enum(alias T=_identity) 
{
    enum _ = {
        mixin T!();
    };
}

mixin template _class(alias T=_identity) 
{
    class _ {
        mixin T!() _this;
        mixin _aliasThis!_this;
        
        static if(is(typeof(_this.toString))) {
            enum _toString_ = _this.toString;            
        } else {
            enum _toString_ = __identifier!T;            
        }

    }
    static if(is(typeof(_._toString_))) {
        auto toString() {
            import std.array : replace;
            return q{class _ {T}}.replace("T",_._toString_);
        } 
    }
}

mixin template _class(alias T=_indentity,alias superClass) 
if(is(superClass == class) || is(superClass == interface))
{
    class _ : superClass {
        mixin T!() _;
        mixin _aliasThis!_;
        static if(isConstant!(_.toString)) {
            enum _toString_ = _.toString;            
        } else {
            //
        }
    }
    
    static if (typeof(_._toString_)) {
        import std.array : replace;
        enum toString = q{class _ : superClass { T }}
                .replace("T",_._toString_).replace("superClass",__identifier!superClass);        
    }
}

template isInterface(alias T) {
    enum isInterface = is(T == interface);
}

mixin template _class(alias T=_indentity,alias superClass,interfaces ...) 
if(
    is(superClass == class) || is(superClass == interface) 
    && interfaces.length > 1 
    && allSatisfy!(isInterface,interfaces)
) {
    class _ : superClass, interfaces {
        mixin T!() _;
        mixin _aliasThis!_;
        static if(isConstant!(_.toString)) {
            enum _toString_ = _.toString;            
        } else {
            //
        }
    }
    /*static if (__traits(compiles,_._toString_)) {
        import std.array : replace,array;
        import std.string : join;
        import std.meta : aliasSeqOf, staticMap;
        enum toString = q{class _ : superClass, interfaces {T}}
                .replace("T",_._toString_)
                .replace("superClass",__identifier!superClass)
                .replace("interfaces",staticMap!(__identifier,interfaces).array
        );
    }*/
}


unittest {
    mixin template _body() {
        enum i = 10;
        enum toString = q{enum i = 10;};
    }
    mixin _class!(_body) c;
    
    //c._ _c = new c._;
    alias c_ = _y!c;
    c_ _c = new c_;
    
    static assert (_c.i == 10);
    mixin __msg!(c.toString);
    static assert (c.toString == q{class _ {enum i = 10;}});
}

unittest {
    mixin template ten() {
        enum _ = 10;
    }
    mixin template _body() {
        mixin ten!() _i;
        alias i = _y!_i;
        
        mixin ten!() _j;
        alias j = _y!_j;
        
        mixin ten!() _k;
        alias k = _y!_k;
    }
    mixin _class!(_body) c;
    c._ _c;
    static assert (_c.i == 10);
    static assert (_c.j == 10);
    static assert (_c.k == 10);
}


unittest {
    mixin template _body() {
        enum i = 10;
        enum toString = q{enum i = 10;};
    }
    
    class myBaseClass {
        enum j = 10;
    }
    
    interface myInterface0 {
        
    }
    interface myInterface1 {
        
    }
    mixin _class!(_body,myBaseClass,myInterface0,myInterface1) c;
    //alias __c = c._;
    alias __c = _y!c;
    //c._ _c = new c._;
    __c _c = new __c;
    static assert (_c.i == 10);
    static assert (_c.j == 10);
    
    assert (cast(myBaseClass)_c);
    assert (cast(myInterface0)_c);
    assert (cast(myInterface1)_c);

    //mixin __msg!(c.toString);
//    static assert (c.toString == q{class _ {enum i = 10;}});
}



mixin template _constructor(alias T=_identity,V...) {
    this(V v) {
        mixin T!v _;
        static if (__traits(compiles,mixin("_." ~ __identifier!T ~ "()"))) {
            mixin("_." ~ __identifier!T ~ "();");
        } else static if(__traits(compiles,_._)) {
            _._();
        }
    };
}

unittest {
    /*mixin*/ template ten() {
        enum _ = 10;
    }
    
    mixin template __this0(alias int A,alias long B,alias string C) {
        alias __this0 = {
            a = A;
            b = B;
            c = C;
        };
    }

    mixin template __this1(alias int A) {
        alias __this1 = {
            a = A;
        };
    }

    mixin template _body() {
        mixin ten!() i;
        mixin ten!() j;
        mixin ten!() k;
        
        mixin _intField!("a",5);
        mixin _longField!("b",5);
        mixin _stringField!("c","5");
        //mixin _stringField!("d","7");
        mixin _mixin_t!(_stringField,"d","7");
        mixin _longField!("e");
        mixin _intField!("f");
        
        mixin _constructor!(__this0,int,long,string);
        mixin _constructor!(__this1,int);
    }
    
    mixin _class!(_body) c;
    
    c._ _c = new c._(6,7,"8");
    static assert (_c.i._ == 10);
    static assert (_y!(_c.i) == 10);
    static assert (_y!(_c.j) == 10);
    static assert (_y!(_c.k) == 10);

    static assert (is(typeof(_c.a) == int));
    static assert (is(typeof(_c.b) == long));
    static assert (is(typeof(_c.c) == string));
    static assert (is(typeof(_c.d) == string));

    assert (_c.a == 6);
    assert (_c.b == 7);
    assert (_c.c == "8");
    assert (_c.d == "7");

    _c = new c._(7);
    assert (_c.a == 7);

}

unittest {
    /*mixin*/ template ten() {
        enum _ = 10;
    }
    
    /*mixin*/ template __this(alias int A,alias long B,alias string C) {
        alias _ = {
            a = A;
            b = B;
            c = C;
        };
    }

    mixin template _body() {
        mixin ten!() i;
        mixin ten!() j;
        mixin ten!() k;
        
        mixin _intField!("a",5);
        mixin _longField!("b",5);
        mixin _stringField!("c","5");
        mixin _stringField!("d");
        mixin _longField!("e");
        mixin _intField!("f");
        
        mixin _constructor!(__this,int,long,string);
    }
    
    mixin _class!(_body) c;
    
    c._ _c = new c._(6,7,"8");
    static assert (_c.i._ == 10);
    static assert (_y!(_c.i) == 10);
    static assert (_y!(_c.j) == 10);
    static assert (_y!(_c.k) == 10);

    static assert (is(typeof(_c.a) == int));
    static assert (is(typeof(_c.b) == long));
    static assert (is(typeof(_c.c) == string));
    static assert (is(typeof(_c.d) == string));

    assert (_c.a == 6);
    assert (_c.b == 7);
    assert (_c.c == "8");
}

mixin template _fnc(alias T=_identity,U ...)
{
    alias _ = (U u) {
        mixin T!(u);
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

mixin template exitScope(alias T=_identity,alias V=_identity)
{
    alias _ = () {
        scope(exit) {
            V!();
        }
        T!();
    };
}


mixin template aliasOf(string ident,alias T=identity)
{
    mixin("alias " ~ ident ~ " = T;");
}

unittest {
    enum a = 0;
    mixin aliasOf!("b",a);
    static assert(is(typeof(b) == typeof(a)));
    static assert(b is a);
}

mixin template enumOf(string ident,alias T=identity)
{
    mixin("enum " ~ ident ~ " = T;");
    //enum toString = "enum " ~ label ~ " = " ~ __identifier!T ~ ")";
}

unittest {
    enum a = 0;
    mixin enumOf!("b",a);
    static assert(is(typeof(b) == typeof(a)));
    static assert(b is a);
}

mixin template enumOf(string ident,string _body)
{
    mixin("enum "~ident~ " = {" ~ _body ~ "};");
}

mixin template structOf(string ident,string _body) {
    mixin("struct "~ident~ "{" ~ _body ~ "};");
}

mixin template unionOf(string ident,string _body) {
    mixin("union "~ident~ "{" ~ _body ~ "};");
}

mixin template classOf(string ident,string _body) {
    mixin("class "~ident~ "{" ~ _body ~ "};");
}

