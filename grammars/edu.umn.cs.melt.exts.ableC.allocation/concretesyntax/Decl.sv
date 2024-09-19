grammar edu:umn:cs:melt:exts:ableC:allocation:concretesyntax;

marking terminal AllocUsing_t 'allocate_using' lexer classes {Keyword, Global};
terminal Stack_t 'stack' lexer classes {Keyword};
terminal Heap_t 'heap' lexer classes {Keyword};
terminal Gc_t 'gc' lexer classes {Keyword};
terminal Arena_t 'arena' lexer classes {Keyword};

concrete productions top::Declaration_c
| 'allocate_using' a::Allocator_c
  { top.ast = a.ast; }

closed tracked nonterminal Allocator_c with ast<ast:Decl>;

concrete productions top::Allocator_c
| 'stack'
  { abstract stackAllocDecl; }
| 'heap'
  { abstract heapAllocDecl; }
| 'gc'
  { abstract gcAllocDecl; }
| 'arena' a::Identifier_t
  { top.ast = arenaAllocDecl(ast:fromId(a)); }
