grammar edu:umn:cs:melt:exts:ableC:allocation:concretesyntax;

marking terminal Allocate_t 'allocate' lexer classes {Keyword, Global};
marking terminal Reallocate_t 'reallocate' lexer classes {Keyword, Global};
marking terminal Deallocate_t 'deallocate' lexer classes {Keyword, Global};

concrete productions top::PrimaryExpr_c
| 'allocate' '(' size::AssignExpr_c ')'
  { abstract allocExpr; }
| 'reallocate' '(' ptr::AssignExpr_c ',' size::AssignExpr_c ')'
  { abstract reallocExpr; }
| 'deallocate' '(' ptr::AssignExpr_c ')'
  { abstract deallocExpr; }
