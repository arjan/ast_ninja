Nonterminals
expression.

Terminals
value operator.

Rootsymbol expression.

expression -> expression operator expression : {unwrap('$2'), ['$1', '$3']}.
expression -> value : unwrap('$1').

Erlang code.

unwrap({_,V}) -> V.
