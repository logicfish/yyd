module yyd.tool;

public import yyd.y;
public import yyd.func;

// Compilation primitives and mixin combinators

template __msg(alias T) {
    pragma(msg,T);
}

mixin template __mixinD(alias T) {
    alias _ = mixin(T);
}

mixin template _mixin_t(alias T,U...) {
    mixin T!U;
}

template mixin_t(alias T,U...) {
    mixin T!U mixin_t;
}

mixin template _isD(string txt) {
    enum _ = __traits(compiles,txt);
}

unittest {
    enum txt = "__blah()";
    //static assert(!__traits(compiles,txt));
    mixin _isD!txt;
    //static assert(!_);
}

mixin template assertion(alias T) {
    static assert (T);
}

unittest {
    mixin assertion!true;
    //assertion!false;
}

mixin template _contract(alias Cond,alias Fnc) {
    template _() if(Cond) {
        alias _ = Fnc;
    }
    template _(U...) if(Cond) {
        alias _ = Fnc!U;
    }
}

unittest {
    mixin _contract!(true,"Test");
    static assert(_!() == "Test");
}

mixin template _contractm(alias Cond,alias Fnc) {
    mixin template _(U...) if(Cond) {
        alias _ = Fnc!U;
    }
}

unittest {
    mixin _contractm!(true,identity) m;
    mixin m._!("Test") n;
    static assert(n._ == "Test");
}

template contract(alias Cond,alias Fnc) if (Cond) {
    alias contract = Fnc;
}

unittest {
    static assert(contract!(true,"Test")=="Test");
}

unittest {
    mixin _contract!(false,"Test");
    static assert(!is(typeof(_!())));
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
    mixin c._!("Test") d;
    static assert(d._ == "Test");

    mixin _mixin_t!(_contract,true,identity) e;
    mixin e._!("Test") f;
    static assert(f._ == "Test");

    mixin _mixin_t!(_contract,false,identity) g;
    static assert(!is(g._));

}

