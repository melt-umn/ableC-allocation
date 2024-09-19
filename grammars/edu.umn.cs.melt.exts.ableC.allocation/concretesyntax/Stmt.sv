grammar edu:umn:cs:melt:exts:ableC:allocation:concretesyntax;

marking terminal WithArena_t 'with_arena' lexer classes {Keyword, Global};

concrete productions top::Stmt_c
| 'with_arena' a::Identifier_c '{' '}'
  { top.ast = withArena(a.ast, ast:nullStmt()); }
| 'with_arena' a::Identifier_c '{' body::BlockItemList_c '}'
  { top.ast = withArena(a.ast, ast:foldStmt(body.ast)); }
