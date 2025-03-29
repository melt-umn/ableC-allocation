#ifndef _ARENA_H_
#define _ARENA_H_

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stddef.h>

#define ARENA_INITIAL_CAPACITY 64

typedef struct arena *arena_t;
struct arena {
  size_t capacity;
  size_t used;
  arena_t next;
  max_align_t data[];
};

static inline arena_t arena_create_sized(size_t capacity) {
  arena_t arena = malloc(sizeof(struct arena) + capacity);
  arena->capacity = capacity;
  arena->used = 0;
  arena->next = NULL;
  return arena;
}

static inline arena_t arena_create() {
  return arena_create_sized(ARENA_INITIAL_CAPACITY);
}

static inline void arena_destroy(arena_t arena) {
  if (arena->next) {
    arena_destroy(arena->next);
  }
  free(arena);
}

// Callback wrapper for use with pthread_cleanup_push
static void arena_destroy_cb(void *arena) {
  arena_destroy((arena_t)arena);
}

static inline void *arena_malloc(arena_t arena, size_t size) {
  const size_t alignment = _Alignof(max_align_t);
  size_t used_padded = (arena->used + alignment - 1) & ~(alignment - 1);

  if (used_padded + size < arena->capacity) {
    // The object fits in the current segment
    void *result = (unsigned char*)arena->data + used_padded;
    arena->used = used_padded + size;
    return result;
  }

  // Allocate in the next segment
  if (arena->next == NULL) {
    arena->next = arena_create_sized((arena->capacity + size) * 2);
  }
  return arena_malloc(arena->next, size);
}

static inline void *arena_realloc(arena_t arena, void *ptr, size_t size) {
  if (ptr == NULL) {
    return arena_malloc(arena, size);
  } else if ((unsigned char*)ptr < (unsigned char*)arena->data || (unsigned char*)ptr >= (unsigned char*)arena->data + arena->capacity) {
    // The pointer is not in the current block of memory
    if (arena->next == NULL) {
      fprintf(stderr, "arena_realloc'ed pointer %p not in arena %p\n", ptr, (void*)arena);
      abort();
    }
    return arena_realloc(arena->next, ptr, size);
  } else if (arena->used + size < arena->capacity && ptr == (unsigned char*)arena->data + arena->used) {
    // If the pointer is the last allocated memory, we can just extend it.
    arena->used = (unsigned char*)arena->data - (unsigned char*)ptr + size;
    return ptr;
  } else {
    // Else, allocate a new segment and copy the memory.
    // We don't know how long the originally-allocated segment to copy was,
    // but it can't have been longer than the used portion of the current segment
    // following the pointer.
    size_t max_orig_size = arena->used + (unsigned char*)arena->data - (unsigned char*)ptr;
    void *result = arena_malloc(arena, size);
    memcpy(result, ptr, max_orig_size < size? max_orig_size : size);
    return result;
  }
}

static size_t arena_total_capacity(arena_t ar) {
  return ar->capacity + (ar->next? arena_total_capacity(ar->next) : 0);
}

#endif
