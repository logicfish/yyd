# yYd - Mixin template combinators for D

Sequential combinators for templates.

The library allows us to bind to compiler constructs as identifiers
using templates and mixin templates.

This code was created to address the issue that we can't bind the
templates in phobos to, for example, a static foreach block without
reference to unnecessary nested or exposed code blocks.
A prime example of this is mixin templates which have the special
feature of having both an inherited scope for context and a nested
scope for definitions - highly desirable, but little support in the
templates libraries.

The only external import is `std.typecons : AliasSeq` from phobos.
This is probably redundant.

These issues aren't ususally a problem for most apps, however when
writing compilers or other apps that generate code, we end up with
huge amounts of unnecessary code in the generated output and potenitially
deep nesting.  So yYd attempts to make this output more readable, and
in the future will also try to create more meaningful error messages.


One of the differences between mixin templates and ordinary templates is
that we can't alias the name of the template to another symbol.
To access any kind of output from a mixin template then we are forced
to introduce a symbol into the local scope. So the mixin templates in
this library use the underscore symbol to represent the namespace of 
each instance of a mixin template. Some of the algorithms that take 
a parameter of a symbol representing a mixin template will expect
that the passed in template will create a local underscore symbol in
order to access the result. In future there will be a method to detect
this and perform indirection where necessary.


```
identity!T :== alias _ = T

evaluate!T :== enum _ = T

partial!(T, U...) :== (V...) => T!(U,V) 

rpartial!(T, U...) :== (V...) => T!(V,U) 

etc...
```

Many of the mixin templates start with a single underscore _ .
This indicates that this mixin template defines a single identifier
in scope comprising an underscore which represents an alias binding
to the combinator. 

```
    mixin _identity!"Some string" s;
    static assert (s._ == "Some string");
```


The underscore may be an alias, and might be a template or a mixin template.

So we can pass an identifier to a mixin template as an argument to
a combinator template. The template then instantiates the mixin as 
defined by its semantics of the combinator.

So for example to iterate an AliasSeq

```
mixin template mixinTemplate(T) { ... }
eachApply!(mixinTemplate,AliasSeq...);
```

"mixinTemplate" will be applied for each member of the sequence.

Some of the templates define the result as a template that can be access
`_!(...)`
This might be changed in future to a different symbol for returned templates,
and another one for returned mixin templates.
This makes sense because we might want a compiler to generate a mixin template
for the output, rather than a string that we mixin. Then we can decide the 
scope of the compiled code and include it at top level or inside a class or
function body.

Some of the conditional templates only bind
the underscore alias if the condition is met, otherwise 
`is(typeof(_!()))`
or
`is(typeof(_))`

will evaluate to false.

