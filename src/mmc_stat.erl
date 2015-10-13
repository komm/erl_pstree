-module(mmc_stat).
-export([all/0]).

all()->
  
   Message_queue_len = lists:reverse(lists:sort([ begin 
                                   {message_queue_len, V} = erlang:process_info(P, message_queue_len), {V, P} 
                              end || P <- processes()
                            ])),

   Dictionary_len = lists:reverse(lists:sort([ begin 
                                   {dictionary, V} = erlang:process_info(P, dictionary), {length(V), P} 
                              end || P <- processes()
                            ])),
   Total_heap_size = lists:reverse(lists:sort([ begin 
                                   {total_heap_size, V} = erlang:process_info(P, total_heap_size), {V, P} 
                              end || P <- processes()
                            ])),
   Heap_size = lists:reverse(lists:sort([ begin 
                                   {heap_size, V} = erlang:process_info(P, heap_size), {V, P} 
                              end || P <- processes()
                            ])),
   Stack_size = lists:reverse(lists:sort([ begin 
                                   {stack_size, V} = erlang:process_info(P, stack_size), {V, P} 
                              end || P <- processes()
                            ])),
   Reductions = lists:reverse(lists:sort([ begin 
                                   {reductions, V} = erlang:process_info(P, reductions), {V, P} 
                              end || P <- processes()
                            ])),


   io:format("message queue length: ~w~n~n"
             "dictionary length: ~w~n~n"
             "MEMORY:~n"
             "total heap size: ~w~n details: ~w~n~n"
             "heap size: ~w~n details: ~w~n~n"
             "stack size: ~w~n details: ~w~n~n"
             "reductions: ~w~n~n"
             , [Message_queue_len, Dictionary_len, 
                lists:sum([ V || {V,_} <- Total_heap_size ]), Total_heap_size, 
                lists:sum([ V || {V,_} <-Heap_size ]),  Heap_size, 
                lists:sum([ V || {V,_} <-Stack_size]),  Stack_size, 
                Reductions]
    )
.
% {reductions,595},


