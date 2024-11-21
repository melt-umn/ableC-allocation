#include <arena.h>

int foo() {
  with_arena ar {
    int *x = allocate(sizeof(int));
    *x = 42;
    return *x;  // Memory leak
  }
}

int main() {
  foo();
}