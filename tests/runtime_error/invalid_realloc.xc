#include <arena.h>

int main() {
  int foo;

  with_arena ar {
    reallocate(&foo, 42);
  }
}