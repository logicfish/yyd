# yYd - Mixin template combinators for D

Sequential combinators for templates.

The library allows us to bind to compiler constructs as identifiers
using templates and mixin templates.


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



Some of the conditional templates only bind
the underscore alias if the condition is met, otherwise 
`is(_!())`
will evaluate to false.


