#ifndef _ARENA_H_
#define _ARENA_H_

#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#define ARENA_INITIAL_CAPACITY 64

typedef struct arena *arena_t;
struct arena {
  size_t capacity;
  size_t used;
  arena_t next;
  unsigned char data[];
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

static inline void *arena_malloc(arena_t arena, size_t size) {
  if (arena->used + size < arena->capacity) {
    // The object fits in the current segment
    void *result = arena->data + arena->used;
    arena->used += size;
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
  } else if (ptr < (void*)arena->data || ptr >= (void*)arena->data + arena->capacity) {
    // The pointer is not in the current block of memory
    if (arena->next == NULL) {
      fprintf(stderr, "arena_realloc'ed pointer %p not in arena %p\n", (void*)ptr, (void*)arena);
      abort();
    }
    return arena_realloc(arena->next, ptr, size);
  } else if (arena->used + size < arena->capacity && ptr == arena->data + arena->used) {
    // If the pointer is the last allocated memory, we can just extend it.
    arena->used = (void*)arena->data - ptr + size;
    return ptr;
  } else {
    // Else, allocate a new segment and copy the memory.
    void *result = arena_malloc(arena, size);
    // We don't know how long the originally-allocated segment to copy was,
    // but it can't have been longer than the used portion of the current segment.
    memcpy(result, ptr, arena->used < size? arena->used : size);
    return result;
  }
}

static inline void arena_free(arena_t arena) {
  if (arena->next) {
    arena_free(arena->next);
  }
  free(arena);
}

#endif
