module yyd.arith;

private import yyd.y : _y;

// Arithmatic expression evaluator templates

template add(alias A, alias B) 
{
	enum add = A + B;
}

template sub(alias A, alias B) 
{
	enum sub = A - B;
}

template mul(alias A, alias B) 
{
	enum mul = A * B;
}

template div(alias A, alias B) 
{
	enum div = A / B;
}


template booleanOr(alias A, alias B) 
{
	enum booleanOr = A | B;
}

template booleanAnd(alias A, alias B) 
{
	enum booleanAnd = A & B;
}

template logicalOr(alias A, alias B) 
{
	enum logicalOr = A || B;
}

template logicalAnd(alias A, alias B) 
{
	enum logicalAnd = A && B;
}

template concat(alias A, alias B) 
{
	enum concat = A ~ B;
}

template equal(alias A, alias B) 
{
	enum equal = A == B;
}

template notEqual(alias A, alias B) 
{
	enum equal = A != B;
}

template condExpr(alias cond, alias _if, alias _else) 
{
    enum condExpr = cond ? _if : _else;
}

template sum(T...) 
if(T.length == 0) 
{}

template sum(T...) 
if(T.length == 1) 
{
	enum sum = T[0];
}

template sum(T...) 
if (T.length > 1) 
{
	enum sum = add!(T[0],sum!(T[1..$]));
}

unittest {
    static assert(sum!(1,1,1) == 3);
}

template concantenate(T...) if(T.length == 0) 
{}

template concantenate(T...) if(T.length == 1) 
{    
	enum concantenate = T[0];
}

template concantenate(T...) if(T.length > 1) 
{    
	enum concantenate = concat!(T[0],concantenate!(T[1..$]));
}

unittest {
    static assert(concantenate!("a","a","a") == "aaa");
}


mixin template _add(alias A, alias B) 
{
	alias _ = add!(A,B);
}

mixin template _sub(alias A, alias B) 
{
	alias _ = sub!(A,B);
}

mixin template _mul(alias A, alias B) 
{
	alias _ = mul!(A,B);
}

mixin template _div(alias A, alias B) 
{
	alias _ = div!(A,B);
}

mixin template _concat(alias A, alias B) 
{
	alias _ = concat!(A,B);
}

mixin template _sum(T...) 
{
	alias _ = sum!(T);
}

mixin template _concantenate(T...) 
{
	alias _ = concantenate!(T);
}


unittest {
    mixin _sum!(1,1,1) t;
    static assert (_y!t == 3);
}

unittest {
    mixin _concantenate!("a","b","c") t;
    static assert (_y!t == "abc");
}

//alias add(A,B) = (const A a, const B b) => a + b;
//alias sub(A,B) = (const A a, const B b) => a - b;
//alias mul(A,B) = (A a, B b) => a * b;
//alias div(A,B) = (const A a, const B b) => a / b;

alias add_(alias A,alias B) = () => A() + B();
alias sub_(alias A,alias B) = () => A() - B();
alias mul_(alias A,alias B) = () => A() * B();
alias div_(alias A,alias B) = () => A() / B();


alias booleanOr_(alias A, alias B) = () => A() | B();
alias booleanAnd_(alias A, alias B) = () => A() & B();
alias logicalOr_(alias A, alias B) = () => A() || B();
alias logicalAnd_(alias A, alias B) = () => A() && B();

alias concat_(alias A, alias B) = () => A() ~ B();

alias equal_(alias A, alias B) = () => A() == B();
alias notEqual_(alias A, alias B) = () => A() != B();

alias condExpr_(alias Cond, alias _If, alias _Else) = () => Cond() ? _If() : _Else();



//alias add(A,B) = (const A function() a,const B function() b) => add!(a,b);

//alias sub(A,B) = (const A function() a,const B function() b) => sub!(a,b);

//alias mul(A,B) = (const A function() a,const B function() b) => mul!(a,b);

//alias div(A,B) = (const A function() a,const B function() b) => div!(a,b);

template addTo(alias T) 
{
	alias addTo(V) = () => T += V;
}

template addToX(alias T) 
{
	alias addToX(V) = (V v) => T += v;
}

mixin template _addTo(alias T,alias V) 
{
	alias _ = addTo!(T,V);
}

