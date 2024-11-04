#include <stdio.h>
#include <stdlib.h>
#include <gc.h>
#include <alloca.h>
#include <arena.h>

void print_array(int *arr, int n) {
  for (int i = 0; i < n; i++) {
    printf("%d ", arr[i]);
  }
  printf("\n");
}

int main() {
  int vals[] = {1, 2, 3, 4};

  printf("Using stack:\n");
  allocate_using stack;
  int *a1 = allocate(sizeof(vals));
  memcpy(a1, vals, sizeof(vals));
  print_array(a1, 4);

  printf("Using heap:\n");
  allocate_using heap;
  int *a2 = allocate(sizeof(vals));
  memcpy(a2, vals, sizeof(vals));
  print_array(a2, 4);
  a2 = reallocate(a2, sizeof(vals) + sizeof(int));
  a2[4] = 5;
  print_array(a2, 5);
  deallocate(a2);

  printf("Using gc:\n");
  allocate_using gc;
  int *a3 = allocate(sizeof(vals));
  memcpy(a3, vals, sizeof(vals));
  print_array(a3, 4);
  a3 = reallocate(a3, sizeof(vals) + sizeof(int));
  a3[4] = 5;
  print_array(a3, 5);

  printf("Using arena:\n");
  arena_t ar = arena_create_sized(3);

  allocate_using arena ar;
  int *a4 = allocate(sizeof(vals)), *a5 = allocate(sizeof(int));
  memcpy(a4, vals, sizeof(vals));
  *a5 = 5;
  print_array(a4, 4);
  print_array(a5, 1);

  a5 = reallocate(a5, sizeof(int) * 2);
  a5[1] = 6;
  print_array(a5, 2);

  a4 = reallocate(a4, sizeof(vals) + sizeof(int));
  a4[4] = 5;
  print_array(a4, 5);

  arena_destroy(ar);

  printf("Using with_arena:\n");
  with_arena ar2 {
    int *a5 = allocate(sizeof(vals)), *a6 = allocate(sizeof(int));
    memcpy(a5, vals, sizeof(vals));
    *a6 = 5;
    print_array(a5, 4);
    print_array(a6, 1);

    a6 = reallocate(a6, sizeof(int) * 2);
    a6[1] = 6;
    print_array(a6, 2);

    a5 = reallocate(a5, sizeof(vals) + sizeof(int));
    a5[4] = 5;
    print_array(a5, 5);
  }

  return 0;
}
