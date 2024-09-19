#include <stdio.h>
#include <stdlib.h>
#include <arena.h>
#include <alloca.h>

int main() {
  // No allocator defined
  int *x = allocate(sizeof(int));

  with_arena a {
    // No deallocator for arena
    deallocate(x);
  }
}
