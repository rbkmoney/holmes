-module(dummy_woody_event_handler).

-behaviour(woody_event_handler).

-export([handle_event/4]).

%%

-spec handle_event(woody_event_handler:event(), woody:rpc_id(), woody_event_handler:event_meta(), _) ->
    _.

handle_event(EventType, RpcID, #{status := error, class := Class, reason := Reason, stack := Stack}, _) ->
    io:format("[client][~p] ~s with ~s:~p at ~s~n", [maps:to_list(RpcID), EventType, Class, Reason, genlib_format:format_stacktrace(Stack, [newlines])]);
handle_event(_EventType, _RpcID, _EventMeta, _) ->
    ok.
