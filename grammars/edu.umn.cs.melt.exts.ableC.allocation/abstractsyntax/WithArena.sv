grammar edu:umn:cs:melt:exts:ableC:allocation:abstractsyntax;

production withArena
top::Stmt ::= a::Name body::Stmt
{
  attachNote extensionGenerated("ableC-allocation");
  top.pp = ppConcat([ pp"with_arena", space(), a.pp, line(), braces(nestlines(2, body.pp)) ]);
  top.functionDefs := body.functionDefs;
  top.labelDefs := body.labelDefs;

  local localErrors::[Message] =
   (if null(lookupValue("arena_malloc", top.env))
    then [errFromOrigin(top, "Use of with_arena requires include of <arena.h>")]
    else []) ++
    case lookupMisc("this_func", top.env) of
    | currentFunctionItem(n, _) :: _ ->
        if n.name == "main" then [] else body.returnWarnings
    | _ -> body.returnWarnings
    end ++
    body.errors;
  
  forward fwrd = ableC_Stmt {
    proto_typedef arena_t;
    {
      arena_t $Name{@a} = arena_create();
      $Decl{arenaAllocDecl(^a)}
      $Stmt{@body}
      arena_destroy($Name{^a});
    }
  };

  forwards to if null(localErrors) then @fwrd else warnStmt(localErrors);
}

monoid attribute returnWarnings::[Message] occurs on
  Stmt, Decls, Decl, Declarators, Declarator, Expr, MaybeExpr, Exprs, ExprOrTypeName;
propagate returnWarnings on
  Stmt, Decls, Decl, Declarators, Declarator, Expr, MaybeExpr, Exprs, ExprOrTypeName;

aspect returnWarnings on top::Stmt using <- of
| returnStmt(_) -> [wrnFromOrigin(top, "Return statement in with_arena block causes arena to not be freed; this is probably a memory leak")]
end;
