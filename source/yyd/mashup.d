module yyd.mashup;

public import yyd.y;

template __msg (string T) 
{
    pragma(msg, T);
    enum __msg = T;
}

mixin template _msg (string T) 
{
    alias _ = __msg!(T);
    enum toString = "__msg!(\""~ T ~ "\")";
}

mixin template _compilesD(string T)  {
    enum toString = "__traits(compiles,"~T~")";
    enum _ = mixin(toString);
}

/*template __compilesD(string T) {
    enum __compilesD = mixin("__traits(compiles,"~T~")");    
}*/

unittest {
    int x;
    mixin _compilesD!(q{x=10}) _;
    static assert(_._);
    static assert(_y!_);
    static assert(__toString!_ == "__traits(compiles,x=10)");
}

unittest {
    mixin _compilesD!(q{x=10});
    static assert(!_);
    static assert(toString == "__traits(compiles,x=10)");
}

unittest {
    int x;
    mixin _compilesD!(q{x=10});
    static assert(_);
    static assert(toString == "__traits(compiles,x=10)");
}

unittest {
    mixin _compilesD!(q{x=10});
    static assert(!_);
    static assert(toString == "__traits(compiles,x=10)");
}



unittest {
    mixin _compilesD!(q{blah,blah}) _;
    
    static assert(_._ is false);
    static assert(_y!_ is false);

    mixin _msg!(__toString!_);

    static assert(__toString!_ == "__traits(compiles,blah,blah)");
    static assert(mixin(_.toString) is false);
}

unittest {
    mixin _msg!("Unit test") _;

    static assert(_.toString == "__msg!(\"Unit test\")");
    static assert(__toString!_ == "__msg!(\"Unit test\")");
    enum x = mixin(_.toString);
    
    mixin _toString!_ s;
    static assert(__toString!s == "__toString!(\"__msg!(\"Unit test\")\")");
    
}

template __toString(alias T) 
if(is(typeof(T.toString)))
{
    alias __toString = T.toString;
}

template __toString(alias T) 
if(
	!is(typeof(T.toString))
	/*&& (
		is(typeof(T) == bool)
	)*/
)
{
    alias __toString = T;
}


mixin template _toString(alias T) {
    enum _ = __toString!T;
    enum toString = "__toString!(\"" ~ _ ~ "\")";
}

template __mixinD(string T) {
    enum __mixinD = mixin(T);
} 

mixin template _mixinD (string T) 
{
    enum _ = mixin(T);
    enum toString = "mixin(" ~ T ~ ")";
}

mixin template _mixin_t (alias T = _identity, U ...) 
{
    mixin T!U;
}

unittest {
	template X() {
		struct _X {
			auto ten() { 
				return 10;
			}                
		}
	}
    alias f = {
        mixin _mixin_t!X;
        return _X();
    };
    assert(f().ten == 10);
}

mixin template _mixin_mt (alias T = _identity) 
{
    mixin template _(U...) {
        mixin T!U;
    }
}

unittest {
	
	// A mixin that generates a struct called GeneratedStruct.
	mixin template generateStruct() {
		struct GeneratedStruct {
			auto ten() { 
				return 10;
			}                
		}
	}

	// Creates a new mixin template that pulls in generateStruct for the 
	// body.
	// Need to create an alias to the mixin before use.
	mixin _mixin_mt!generateStruct;	
    alias generate = _;
	
	// Function that includes the mixin and returns an instance of the
	// struct defined within.
    alias f = {
        mixin generate;
        return GeneratedStruct();
    };

	// GeneratedStruct isn't visible to the program.
	static assert(!is(typeof(GeneratedStruct)));
	
	// Create an instant of GeneratedStruct.
    static assert(f().ten == 10);
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
    
    enum toString = q{
		template _ () 
		if(} ~ Cond ~ q{) 
		{
			alias _ = } ~ Fnc ~ q{;
		}
		
		template _ (U...) 
		if(} ~ Cond ~ q{) 
		{
			alias _ = } ~ Fnc ~ q{!U;
		}
		
	};
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
    static assert(is(typeof(g._) == void));

}

mixin template _import(string name,alias T=_identity,V...) {
    mixin("import " ~ name ~ ";");
    //enum toString = "import " ~ name ~ ";";
    mixin T!V _;
}

/*
mixin template _import(string name,tokens...) {
    import std.array : join;
    enum _tokens = tokens.join(",");
    mixin("import " ~ name ~ ":" ~ _tokens ~ ";");
    enum toString = "import " ~ name ~ " : " ~ _tokens ~ ";";
}*/

template __importFile(string name) {
    enum __importFile=import(name);
}

mixin template _importFile(string name) {
    enum _ = __importFile!(name);
    enum toString = "importFile! (" ~ name ~ ")";
}

mixin template _main(alias _body=_identity) {
    auto main(string[] args) {
        mixin _body;
    }
}


