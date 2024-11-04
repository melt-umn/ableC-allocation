#include <stdio.h>

typedef int arena_t;

void check_array(int *arr, int n, int start, int err) {
  for (int i = 0; i < n; i++) {
    printf("%d ", arr[i]);
    if (arr[i] != i + start) {
      printf("Did not match expected!\n");
      exit(err);
    }
  }
  printf("\n");
}

int main() {
  int vals[] = {1, 2, 3, 4};

  printf("Using stack:\n");
  allocate_using stack;
  int *a1 = allocate(sizeof(vals));
  memcpy(a1, vals, sizeof(vals));
  check_array(a1, 4, 1, 1);
  a1 = reallocate(a1, sizeof(vals) + sizeof(int));
  a1[4] = 5;
  check_array(a1, 5, 1, 2);

  printf("Using heap:\n");
  allocate_using heap;
  int *a2 = allocate(sizeof(vals));
  memcpy(a2, vals, sizeof(vals));
  check_array(a2, 4, 1, 3);
  a2 = reallocate(a2, sizeof(vals) + sizeof(int));
  a2[4] = 5;
  check_array(a2, 5, 1, 4);
  deallocate(a2);

  printf("Using gc:\n");
  allocate_using gc;
  int *a3 = allocate(sizeof(vals));
  memcpy(a3, vals, sizeof(vals));
  check_array(a3, 4, 1, 5);
  a3 = reallocate(a3, sizeof(vals) + sizeof(int));
  a3[4] = 5;
  check_array(a3, 5, 1, 6);

  printf("Using arena:\n");
  arena_t ar = arena_create_sized(3);

  allocate_using arena ar;
  int *a4 = allocate(sizeof(vals)), *a5 = allocate(sizeof(int));
  memcpy(a4, vals, sizeof(vals));
  *a5 = 5;
  check_array(a4, 4, 1, 7);
  check_array(a5, 1, 5, 8);

  a5 = reallocate(a5, sizeof(int) * 2);
  a5[1] = 6;
  check_array(a5, 2, 5, 9);

  a4 = reallocate(a4, sizeof(vals) + sizeof(int));
  a4[4] = 5;
  check_array(a4, 5, 1, 10);

  arena_destroy(ar);

  printf("Using with_arena:\n");
  with_arena ar2 {
    int *a5 = allocate(sizeof(vals)), *a6 = allocate(sizeof(int));
    memcpy(a5, vals, sizeof(vals));
    *a6 = 5;
    check_array(a5, 4, 1, 11);
    check_array(a6, 1, 5, 12);

    a6 = reallocate(a6, sizeof(int) * 2);
    a6[1] = 6;
    check_array(a6, 2, 5, 13);

    a5 = reallocate(a5, sizeof(vals) + sizeof(int));
    a5[4] = 5;
    check_array(a5, 5, 1, 14);
  }

  return 0;
}
