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
  attachNote extensionGenerated("ableC-allocation");
  forwards to ableC_Expr { alloca($Expr{@size}) };
}

production malloc implements Alloc
top::Expr ::= @size::Expr
{
  attachNote extensionGenerated("ableC-allocation");
  forwards to ableC_Expr { malloc($Expr{@size}) };
}

production gcMalloc implements Alloc
top::Expr ::= @size::Expr
{
  attachNote extensionGenerated("ableC-allocation");
  forwards to ableC_Expr { GC_malloc($Expr{@size}) };
}

production arenaMalloc implements Alloc
top::Expr ::= @size::Expr arena::Name
{
  attachNote extensionGenerated("ableC-allocation");
  forwards to ableC_Expr { arena_malloc($Name{@arena}, $Expr{@size}) };
}

production unspecifiedAlloc implements Alloc
top::Expr ::= @size::Expr
{
  attachNote extensionGenerated("ableC-allocation");
  forwards to errorExpr([errFromOrigin(top, "An allocator to use must be specfied (e.g. `allocate_using heap;`)")]);
}

dispatch Realloc = Expr ::= @p::Expr @size::Expr;

production stackRealloc implements Realloc
top::Expr ::= @ptr::Expr @size::Expr
{
  top.pp = pp"stack_realloc(${ptr}, ${size})";
  attachNote extensionGenerated("ableC-allocation");
  nondecorated local ptrName::Name = freshName("ptr");
  nondecorated local sizeName::Name = freshName("size");
  nondecorated local resName::Name = freshName("res");
  forward fwrd = ableC_Expr {
    proto_typedef size_t;
    ({void *$Name{ptrName} = $Expr{@ptr};
      size_t $Name{sizeName} = $Expr{@size};
      void *$Name{resName} = alloca($Name{sizeName});
      // We don't know the previous size of ptr, but this is safe because ptr was
      // previously allocated on the stack before this buffer.
      if ($Name{ptrName}) memcpy($Name{resName}, $Name{ptrName}, $Name{sizeName});
      $Name{resName};})
  };
  forwards to
    if null(lookupValue("memcpy", top.env))
    then errorExpr([errFromOrigin(top, "Reallocation on stack requires include of <stdlib.h>")])
    else @fwrd;
}

production realloc implements Realloc
top::Expr ::= @ptr::Expr @size::Expr
{
  attachNote extensionGenerated("ableC-allocation");
  forwards to ableC_Expr { realloc($Expr{@ptr}, $Expr{@size}) };
}

production gcRealloc implements Realloc
top::Expr ::= @ptr::Expr @size::Expr
{
  attachNote extensionGenerated("ableC-allocation");
  forwards to ableC_Expr { GC_realloc($Expr{@ptr}, $Expr{@size}) };
}

production arenaRealloc implements Realloc
top::Expr ::= @ptr::Expr @size::Expr arena::Name
{
  attachNote extensionGenerated("ableC-allocation");
  forwards to ableC_Expr { arena_realloc($Name{@arena}, $Expr{@ptr}, $Expr{@size}) };
}

production unspecifiedRealloc implements Realloc
top::Expr ::= @ptr::Expr @size::Expr
{
  attachNote extensionGenerated("ableC-allocation");
  forwards to errorExpr([errFromOrigin(top, s"An allocator to use must be specfied (e.g. `allocate_using heap;`)")]);
}

production unsupportedRealloc implements Realloc
top::Expr ::= @ptr::Expr @size::Expr name::String
{
  attachNote extensionGenerated("ableC-allocation");
  forwards to errorExpr([errFromOrigin(top, s"${name} does not support reallocation`)")]);
}

dispatch Dealloc = Expr ::= @ptr::Expr;

production free implements Dealloc
top::Expr ::= @ptr::Expr
{
  attachNote extensionGenerated("ableC-allocation");
  forwards to ableC_Expr { free($Expr{@ptr}) };
}

production unspecifiedDealloc implements Dealloc
top::Expr ::= @ptr::Expr
{
  attachNote extensionGenerated("ableC-allocation");
  forwards to errorExpr([errFromOrigin(top, s"An allocator to use must be specfied (e.g. `allocate_using heap;`)")]);
}

production unsupportedDealloc implements Dealloc
top::Expr ::= @ptr::Expr name::String
{
  attachNote extensionGenerated("ableC-allocation");
  forwards to errorExpr([errFromOrigin(top, s"${name} does not support deallocation")]);
}
