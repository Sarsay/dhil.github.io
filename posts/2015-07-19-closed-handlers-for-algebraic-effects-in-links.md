---
title: (Closed) Handlers for Algebraic Effects in Links
tags: MSc project, functional programming
---
This Thursday I gave a short presentation about the progress of my MSc-project: *Handlers for Algebraic Effects in Links*. A handful of classmates and supervisors were present. My classmates presented their respective projects too. However we only had 10 minutes each to cover subject introduction, demonstration and report on current progress. I figured I would elaborate the demonstration of my presentation here.

I am working on implementing first-class effect handlers in the [web-oriented functional programming Links](http://groups.inf.ed.ac.uk/links/). I will show how to apply simple transformations to computations, program simple exception handling, manipulate choice computations, and how to simulate stateful computations using closed handlers in Links.
<!--more-->

## Programming with closed handlers
At the time of writing I got a working implementation of closed handlers (modulo whatever bugs I have not discovered yet).
Currently, I am working on implementing support for open handlers in Links.
We can think of a closed handler as imposing an upper bound on the kind of effectful computations that it handles. Conversely, an open handler handles whatever effects it can and leaves the remainding part of the computation abstract for other handlers to interpret.

Let us dive right into programming with closed handlers with some examples. Our first example is the (rather boring) identity handler:
```links
fun identity(m) {
  handle(m) {
    case Return(x) -> x
  }
}
```
In Links handlers are abstracted over by functions. The handler's name is `identity` and it takes one parameter `m` which is the computation it handles. The handle construct is essentially a collection of case-statements. In this particular handler we only have one case, namely, the `Return`-case.
`Return` is a special effect that is invoked upon completion of the computation `m`. It is reminisicent of the monadic function *return* in Haskell.

The type for `identity` is \\( \(\(\) \\to a) \\to a \\), i.e. it is a function which takes a computation (thunk) as input parameter, and outputs a value of type `a`. Let us try to handle some computations with `identity`:
```links
fun fortytwo() { 42 }
links> identity(fortytwo);
42 : Int

fun empty() { }
links> identity(empty);
() : ()

fun hello() {
    print("Hello World")
}
links> identity(hello);
Type error: The function identity ...
```
As expected nothing interesting really happens. The computation `fortytwo` just returns 42 and `empty` returns unit. However, we get a type error when we try to handle `hello`. This is because printing to standard out is an *side effect* and `identity` does not handle this side effect. Actually, in my current implementation no handler can handle the print side effect as it is a built-in effect and my handlers only handles user-defined effects.
Note that `fortytwo` and `empty` are both pure computations.

We could transform the output instead of returning it plainly. Let us wrap it inside a singleton list:
```links
fun listify(m) {
    handle(m) {
       case Return(x) -> [x]
    }
}
```
The inferred type for `listify` is \\(\(\(\) \\to a \) \\to \[a\] \\). Running a few examples, we see that every output gets wrapped inside a singleton list:
```links
links> listify(fortytwo);
[42] : [Int]

links> listify(empty);
[()] : [()]

links> listify(fun() { [1,2,3,4] });
[[1,2,3,4]] : [[Int]]
```
So far, we have only transformed the results of computations. Next let us make things more interesting by using effects.

### Exception handling: The Maybe handler
Possibly the very first application of handlers I thought of was exception handlers. Let us create a handler that returns `Nothing` when a computation fails and `Just` the result when it succeeds. Haskell programmers will recognise this as the *Maybe* monad. We will use the operation `Fail` to indicate error:
```links
fun maybe(m) {
    handle(m) {
       case Fail(p,k) -> Nothing
       case Return(x) -> Just(x)
    }
}
```
The first case handles the user-defined operation `Fail`. The case exposes two parameters `p` and `k`. The first parameter `p` is a user-defined argument, while `k` is a continuation from when the operation was discharged. The `maybe` handler gets typed as
\\[ \( \(\) \\xrightarrow{\\{Fail: \( \\_ \) \\to \( \\_ \) \\}} a\) \\to \[|Just:a|Nothing| \\_ |\] \\]
Here underscore (_) hides the names of unused type variables. The output type might look rather obscure, but it is just Links "pretty-printing" a polymorphic variant type. Notice that the computation signature has an nonempty effect signature now. The signature is interpreted as "`maybe` handles a computation that *might* perform the `Fail` operation".

At the time of writing operations are discharged by using the `do` primitive which does not really "feel" functionally. It is really a construct from the intermediate representation in the compiler which has leaked into the front-end such that there is a one-to-one mapping. For now it is convenient, but I might change in the future. In my implementation I take advantage of Links' structural typing system, so we need not declare operations before using them. Syntactically an user-defined operation begins with a capital letter, e.g. `Fail` is an operation name. Let us try some examples with `maybe`:
```links
links> maybe(fortytwo);
Just(42) : [|Just:Int|Nothing|_|]

fun failure() {
    do Fail()
}
links> maybe(failure);
Nothing() : [|Just:a|Nothing|_|]
```
The abstract computation `failure` gets typed as \\( \(\) \\xrightarrow{\\{Fail:\( \( \) \) \\to a \\; | \\rho \\}} a \\).
We see that its type closely resembles the type of the input parameter to `maybe`. However, there are a few subtle differences:

* The `failure` computation's effect row is open as signified by the presence of \\( \\rho \\) in the signature.
* The type of the argument to `Fail` is unit \\(()\\).

Firstly, \\( \\rho \\) is a [polymorphic row variable](http://gallium.inria.fr/~remy/ftp/taoop1.pdf). Row polymorphism will be crucial for open handlers. Actually, row polymorphism is principal in my project, so it's a bit strange to gloss over it. Anyways, we will possibly return to it in a later post.

Secondly, the type system ensures that the application `maybe(failure)` is well-typed by unifying the types of `failure` and the input parameter `m` to `maybe`. So, the type variables get instantiated with concrete types.

Upon failure `maybe` discards the remainder of computation as the following example shows:
```links
fun helpMe() {
    var x = "I got a bad feeling about this..."
    do Fail();
    var x = "Thanks!";
    x
}
links> maybe(helpMe);
Nothing() : [|Just:a|Nothing|_|]
```
Actually, we could invoke the continuation `k` to recover the computation e.g.
```links
fun recover(m) {
    handle(m) {
        case Fail(p,k) -> k(())
    	case Return(x) -> Just(x)
    }
}

links> recover(helpMe);
Just("Thanks!") : [|Just:String|_|]
```
The handler `recover` ignores the failure and resumes execution of the computation. Albeit, it is seldomly a sound idea to ignore an exception, but this example hints that handlers assign semantics to computations. The operations are entirely abstract, it is the handlers that instantiate operations with a concrete implementation. The key insight is that we can think of computations as trees where the nodes are operations and leaves are concrete results. In other words, an abstract computation is a syntactical structure.

### Handling Choice
In this section we will look at a slightly more interesting example of how we may use handlers to change the semantics of a computation. Consider the following computation:
```links
fun choice() {
    var x =
    	if (do Choose()) {
	   40
        } else {
	   10
	}
    var y =
        if (do Choose()) {
	   0
        } else {
	   2
	}
    x + y	
}
```
The abstract computation `choice` discharges the operation `Choose` twice: first time to select whether `x` should be assigned 40 or 10, and the second time to select whether `y` should be assigned 0 or 2. Finally, the values of `x` and `y` are added. The operation `Choose` gets typed as \\( \(\) \\to \\texttt{Bool} \\), and the type of `choice` is
\\[ \(\) \\xrightarrow{\\{ Choose: \( \( \) \) \\to \\texttt{Bool} \\; | \\rho \\}} \\texttt{Int} \\]

We can define two handlers, `chooseTrue` and `chooseFalse`, which always choose true and false respectively:
```links
fun chooseTrue(m) {
    handle(m) {
       case Choose(p,k) -> k(true)
       case Return(x)   -> x
    }
}

fun chooseFalse(m) {
    handle(m) {
       case Choose(p,k) -> k(false)
       case Return(x)   -> x
    }
}
```
They both get typed as \\( \( \(\) \\xrightarrow{\\{ Choose: \( \\_ \) \\to \\texttt{Bool} \\}} \\texttt{Int} \) \\to \\texttt{Int} \\).
Let us run the handlers on `choice`:
```links
links> chooseTrue(choice);
40 : Int

links> chooseFalse(choice);
12 : Int
```
Unsurprisingly, `chooseTrue` corresponds to take the first branch in each of the conditional expression. Analogously, `chooseFalse` takes the second branch in both conditional expressions. Notice that we only invoke the continuation `k` once; there is nothing keeping us from invoking it twice, three, four, five, or whatever times you would like. By invoking it twice we can easily define a handler that enumerates all possible choices:
```links
fun chooseAll(m) {
    handle(m) {
       case Choose(p,k) -> k(true) ++ k(false)
       case Return(x)   -> [x]
    }
}

links> chooseAll(choice);
[40, 42, 10, 12] : [Int]
```
When handling `Choose` the handler `chooseAll` invokes the continuation twice. The first invocation picks the true branch and the second picks the false branch. For the particular abstract computation `choice` the handler invokes the continuation `k` six times to visit all branches of the computation.

I think this example is a nice first practical example of how handlers assign semantics to computations. Furthermore, we could add randomness to choose branches at random. However, in order to do this modularily we need open handlers, so I will leave that example for later.

### Simulating stateful computations
Let us conclude this tour by looking at how we can simulate stateful computations using closed handlers. We will need two operations:

1. `Get` with type \\( \(\) \\to s \\) to retrieve the state.
2. `Put` with type \\( s \\to \( \) \\) to modify the state.

Consider the following stateful computation where our state \\( s \\) is an integer:
```links
fun comp() {
    var s = do Get();
    do Put(s + 1);
    var s = do Get();
    do Put(s + s);
    do Get()
}
```
The stateful computation `comp` first retrieve the initial state and then increments it by one. Afterwards, it retrieves and doubles the state, and then returns the final state. The type of `comp` is
\\[ \( \) \\xrightarrow{\\{ Get:\(\(\)\) \\to \\texttt{Int}, Put:\(\\texttt{Int}\) \\to \(\) \\; | \\rho \\}} \\texttt{Int} \\]

The interesting part is how we implement state. Because Links is a functional programming language our principal abstraction is a function type. Thus, we will abstract over state by encapsulating it inside a function:
```links
fun state(m) {
    handle(m) {
       case Get(p,k)  -> fun(s) {
                           k(s)(s)
                         }
       case Put(p,k)  -> fun(s) {
                           k(())(p)
                         }
       case Return(x) -> fun(s) {
                           x
                         }
    }
}
```
The `state` handler has type
\\[ \(\(\) \\xrightarrow{\\{ Get:\( \\_ \) \\to \\texttt{a}, Put:\(a\) \\to \(\)\\}} b \) \\to \(a\) \\to b \\]
Thus, we can tell from the signature that `state(comp)` returns a function of type \\( \(\\texttt{Int}\) \\to \\texttt{Int} \\) which is a function that given an initial state will return the final state.

At first glance the cases may seem unclear how the state is maintained, but I invite the reader to do an abstract simulation of `state(comp)` (on paper) -- it is an interesting little exercise.

This state handler is partially lazy as when it first handles either `Get` or `Put` it immediate returns a function and when that function is invoked the remainder of the stateful computation is executed.

We define a convenient helper function to run stateful computations:
```links
fun runState(s0, c) {
    var f = state(c);
    f(s0)
}
```
The parameter `s0` is the initial state and `c` is the computation we want to execute.
Let us try to execute `comp` with different initial states:
```links
links> runState(0, comp);
2 : Int

links> runState(1, comp);
4 : Int

links> runState(2, comp);
6 : Int

links> runState(3, comp);
8 : Int

links> runState(333, comp);
668 : Int
```
The stateful computation `comp` may not itself be the most interesting computation, but it shows that we can simulate state using functions.

## Conclusion
We seen examples of programming with closed handlers in Links (as they look now). Moreover, we have seen how different handlers can interpret the same computations differently.