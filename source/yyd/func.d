module yyd.func;

import std.meta : AliasSeq;

public import yyd.y;


// Algorithmic mixin templates

mixin template conditional(alias cond, alias _if, alias _else) {
    static if(cond) {
        alias conditional = _if;
    } else {
        alias conditional = _else;
    }
}

mixin template eachApply(alias T,alias F) {
    static foreach(t;T) {
        mixin F!(t);
    }
}

mixin template eachPairApply(alias T,alias F) {
    static foreach(k,v;T) {
        mixin F!(k,v);
    }
}

mixin template eachIndexApply(alias T,alias F) {
    static foreach(i;0..T.length) {
        mixin F!(i,T[i]);
    }
}
mixin template _mapApply(alias F,T...) if (T.length == 0) {
}
mixin template _mapApply(alias F,T...) if (T.length == 1) {
    mixin F!(T[0]) _first;
    alias _ = _first._;
}
mixin template _mapApply(alias F,T...) if (T.length > 1) {
    mixin F!(T[0]) _first;
    mixin _mapApply!(F,T[1..$]) _next;
    //alias f = _first._;
    //alias n = _next._;
    //alias _ = AliasSeq!(f,n);
    alias _ = AliasSeq!(_first._,_next._);
}

unittest {
    mixin _mapApply!(_identity,"Test","Test2") m;
    static assert(m._ == AliasSeq!("Test","Test2"));
}

/*
unittest {
    import yyd.arith;
    mixin _mapApply!(_concat,"Test","Test2") m;
    static assert(m._ == AliasSeq!("TestTest2"));
}
*/

unittest {
    import yyd.arith;
    mixin _partialm!(_add,1) _a;
    static assert((_a._!2)._ == 3);
    alias _b = _a._;
    static assert((_b!1)._ == 2);
    //mixin _mpartial!(add,1) _a;
    //mixin _a._!() _b;
    //mixin _mapApply!(_a._,1,2,3) m;
    //mixin _mapApply!(_b,1,2,3) m;
    //static assert(m._ == AliasSeq!(2,3,4));
}

unittest {
    import yyd.arith;
    //mixin _partialm!(_add,1) _a;
    //static assert((_a._!2)._ == 3);
    //static assert((_b!1)._ == 2);
    mixin _mpartial!(add,1) _a;
    //alias _b = _a._;
    mixin _a._!(2) _b;
    static assert(_b._ == 3);
    //mixin _mapApply!(_a._,1,2,3) m;
    //mixin _mapApply!(_b,1,2,3) m;
    //static assert(m._ == AliasSeq!(2,3,4));
}

unittest {
    import yyd.arith;
    mixin template addOne(alias T) {
        alias _ = add!(1,T);
    }
    mixin _mapApply!(addOne,1,2,3) m;
    static assert(m._ == AliasSeq!(2,3,4));
}

