# doxygen-mermaid 🧜‍♀️

This is an example of how to include [Mermaid](https://mermaid-js.github.io/mermaid) graphs in [doxygen](https://www.doxygen.nl/index.html) documentation.

**https://github.com/tttapa/doxygen-mermaid**

---

## Demo: C++ coroutine example

```cpp
task<> foo() {
    co_return;
}

task<> bar() {
    task<> f = foo();
    co_await f;
}
```

@mermaid{task}

@see https://tttapa.github.io/mp-coro/Doxygen/classmp__coro_1_1task.html
