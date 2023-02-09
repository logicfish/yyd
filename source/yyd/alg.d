module yyd.alg;

import std.meta : AliasSeq;

public import yyd.y;


// Algorithmic mixin templates

template conditional(alias cond, alias _if, alias _else) 
{
    static if(cond) {
        alias conditional = _if;
    } else {
        alias conditional = _else;
    }
}

mixin template _conditional(alias cond, alias _if, alias _else) 
{
    static if(cond) {
        mixin _if!();
    } else {
        mixin _else!();
    }
}

mixin template _conditionalm(alias cond, alias _if, alias _else) 
{
    mixin cond!() c;
    static if(_y!c) {
        mixin _if!();
    } else {
        mixin _else!();
    }
}

mixin template eachApply(alias T,alias F) 
{
    static foreach(t;T) {
        mixin F!(t);
    }
}

mixin template eachPairApply(alias T,alias F) 
{
    static foreach(k,v;T) {
        mixin F!(k,v);
    }
}

mixin template eachIndexApply(alias T,alias F) 
{
    static foreach(i;0..T.length) {
        mixin F!(i,T[i]);
    }
}

mixin template _mapApply(alias F,T...) 
if (T.length == 0) 
{}

mixin template _mapApply(alias F,T...) 
if (T.length == 1) 
{
    mixin F!(T[0]) _first;
    alias _ = _y!_first;
}

mixin template _mapApply(alias F,T...) 
if (T.length > 1) 
{
    mixin F!(T[0]) _first;
    mixin _mapApply!(F,T[1..$]) _next;
    alias _ = AliasSeq!(_y!_first,_y!_next);
}

unittest {
    mixin _mapApply!(_identity,"Test","Test2") m;
    static assert(_y!m == AliasSeq!("Test","Test2"));
}

unittest {
    import yyd.arith;

    mixin _partialm!(_add,1) _a;

    static assert( ( _a._!2 )._ == 3);
    static assert( _yy!( _a, 2 ) == 3 );
    
    //alias _b = _a._;
    alias _b = _y!_a; // wont work yet it tries to instance the template without its args
    static assert( _y!( _b!1 ) == 2);
    static assert ( _yy!( _b, 1 ) == 2 );

}

unittest {
    import yyd.arith;

    mixin _mpartial!(add,1) _a;
    mixin _a._!(2) _b;
    static assert(_y!_b == 3);

}

unittest {
    import yyd.arith;
    mixin template addOne(alias T) {
        alias _ = add!(1,T);
    }
    mixin _mapApply!(addOne,1,2,3) m;
    static assert(_y!m == AliasSeq!(2,3,4));
}

