module yyd.arith;

// Arithmatic expression evaluator templates

template add(alias A, alias B) {
	enum add = A + B;
}

template sub(alias A, alias B) {
	enum sub = A - B;
}

template mul(alias A, alias B) {
	enum mul = A * B;
}

template div(alias A, alias B) {
	enum div = A / B;
}

template booleanOr(alias A, alias B) {
	enum booleanOr = A || B;
}

template booleanAnd(alias A, alias B) {
	enum booleanAnd = A && B;
}

template logicalOr(alias A, alias B) {
	enum logicalOr = A | B;
}

template logicalAnd(alias A, alias B) {
	enum logicalAnd = A & B;
}

template concat(alias A, alias B) {
	enum concat = A ~ B;
}

template equal(alias A, alias B) {
	enum equal = A == B;
}

template notEqual(alias A, alias B) {
	enum equal = A != B;
}

template condExpr(alias cond, alias _if, alias _else) {
    enum condExpr = cond ? _if : _else;
}

template sum(T...) if(T.length == 0) {
}

template sum(T...) if(T.length == 1) {
	enum sum = T[0];
}

template sum(T...) if (T.length > 1) {
	enum sum = add!(T[0],sum!(T[1..$]));
}

unittest {
    static assert(sum!(1,1,1) == 3);
}

template concantenate(T...) if(T.length == 0) {    
}

template concantenate(T...) if(T.length == 1) {    
	enum concantenate = T[0];
}

template concantenate(T...) if(T.length > 1) {    
	enum concantenate = concat!(T[0],concantenate!(T[1..$]));
}

unittest {
    static assert(concantenate!("a","a","a") == "aaa");
}


mixin template _add(alias A, alias B) {
	alias _ = add!(A,B);
}

mixin template _sub(alias A, alias B) {
	alias _ = sub!(A,B);
}

mixin template _mul(alias A, alias B) {
	alias _ = mul!(A,B);
}

mixin template _div(alias A, alias B) {
	alias _ = div!(A,B);
}

mixin template _sum(T...) {
	alias _ = sum!(T);
}

mixin template _concat(alias A, alias B) {
	alias _ = concat!(A,B);
}


unittest {
    mixin _sum!(1,1,1) t;
    static assert (t._ == 3);
}
