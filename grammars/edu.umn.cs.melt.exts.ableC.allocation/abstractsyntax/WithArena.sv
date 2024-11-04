grammar edu:umn:cs:melt:exts:ableC:allocation:abstractsyntax;

production withArena
top::Stmt ::= a::Name body::Stmt
{
  attachNote extensionGenerated("ableC-allocation");
  top.pp = ppConcat([ pp"with_arena", space(), a.pp, line(), braces(nestlines(2, body.pp)) ]);
  top.functionDefs := [];
  top.labelDefs := [];
  
  forward fwrd = ableC_Stmt {
    proto_typedef arena_t;
    {
      arena_t $Name{@a} = arena_create();
      $Decl{arenaAllocDecl(^a)}
      $Stmt{@body}
      arena_destroy($Name{^a});
    }
  };

  forwards to
    if null(lookupValue("arena_malloc", top.env))
    then warnStmt([errFromOrigin(top, "Use of with_arena requires include of <arena.h>")])
    else @fwrd;
}
