-module(montecarlo).
-export([main/2]).

monte_carlo(0, Hits) -> Hits;
monte_carlo(N, Hits) ->
  X = random:uniform(),
  Y = random:uniform(),
  R = X * X + Y * Y,
  if R =< 1 -> monte_carlo(N - 1, Hits + 1);
     true -> monte_carlo(N - 1, Hits)
  end.

coordinator(0, Hits, Samples, Nodes) ->
  Total = monte_carlo(Samples, Hits),
  Pi =  4 * Total /(Samples * (Nodes + 1)),
  io:format("~p~n", [Pi]);
coordinator(N, Hits, Samples, Nodes) ->
  receive
    Nodehits ->
      coordinator(N - 1, Hits + Nodehits, Samples, Nodes)
  end.

participant(Coordinator, Samples) ->
  Nodehits = monte_carlo(Samples, 0),
  Coordinator ! Nodehits.

main(Nodes, Samples) ->
  Pid = self(),
  _ = [spawn(fun() -> participant(Pid, Samples) end) || _ <- lists:seq(1, Nodes)],
  coordinator(Nodes, 0, Samples, Nodes).
