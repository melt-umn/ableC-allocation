grammar edu:umn:cs:melt:exts:ableC:allocation:abstractsyntax;

imports silver:core hiding fail;
imports silver:langutil;
imports silver:langutil:pp;
imports silver:rewrite;

imports edu:umn:cs:melt:ableC:abstractsyntax:host;
imports edu:umn:cs:melt:ableC:abstractsyntax:construction;
imports edu:umn:cs:melt:ableC:abstractsyntax:env;

dispatch Alloc = Expr ::= @size::Expr;

production alloca implements Alloc
top::Expr ::= @size::Expr
{
  forwards to ableC_Expr { alloca($Expr{@size}) };
}

production malloc implements Alloc
top::Expr ::= @size::Expr
{
  forwards to ableC_Expr { malloc($Expr{@size}) };
}

production gcMalloc implements Alloc
top::Expr ::= @size::Expr
{
  forwards to ableC_Expr { GC_malloc($Expr{@size}) };
}

production arenaMalloc implements Alloc
top::Expr ::= @size::Expr arena::Name
{
  forwards to ableC_Expr { arena_malloc($Name{@arena}, $Expr{@size}) };
}

production unspecifiedAlloc implements Alloc
top::Expr ::= @size::Expr
{
  forwards to errorExpr([errFromOrigin(top, s"An allocator to use must be specfied (e.g. `allocate_using heap;`)")]);
}

dispatch Realloc = Expr ::= @p::Expr @size::Expr;

production realloc implements Realloc
top::Expr ::= @ptr::Expr @size::Expr
{
  forwards to ableC_Expr { realloc($Expr{@ptr}, $Expr{@size}) };
}

production gcRealloc implements Realloc
top::Expr ::= @ptr::Expr @size::Expr
{
  forwards to ableC_Expr { GC_realloc($Expr{@ptr}, $Expr{@size}) };
}

production arenaRealloc implements Realloc
top::Expr ::= @ptr::Expr @size::Expr arena::Name
{
  forwards to ableC_Expr { arena_realloc($Name{@arena}, $Expr{@ptr}, $Expr{@size}) };
}

production unspecifiedRealloc implements Realloc
top::Expr ::= @ptr::Expr @size::Expr
{
  forwards to errorExpr([errFromOrigin(top, s"An allocator to use must be specfied (e.g. `allocate_using heap;`)")]);
}

production unsupportedRealloc implements Realloc
top::Expr ::= @ptr::Expr @size::Expr name::String
{
  forwards to errorExpr([errFromOrigin(top, s"${name} does not support reallocation`)")]);
}

dispatch Dealloc = Expr ::= @ptr::Expr;

production free implements Dealloc
top::Expr ::= @ptr::Expr
{
  forwards to ableC_Expr { free($Expr{@ptr}) };
}

production unspecifiedDealloc implements Dealloc
top::Expr ::= @ptr::Expr
{
  forwards to errorExpr([errFromOrigin(top, s"An allocator to use must be specfied (e.g. `allocate_using heap;`)")]);
}

production unsupportedDealloc implements Dealloc
top::Expr ::= @ptr::Expr name::String
{
  forwards to errorExpr([errFromOrigin(top, s"${name} does not support deallocation")]);
}
