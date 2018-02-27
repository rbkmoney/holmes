-module(party_migration_escript).

-export([main/1]).

-include_lib("dmsl/include/dmsl_domain_thrift.hrl").
-include_lib("dmsl/include/dmsl_payment_processing_thrift.hrl").

-define(USER, <<"party_migration_escript">>).

-spec main([_Args]) ->
    no_return().
main(Args) ->

    {ok, _} = application:ensure_all_started(migration),

    OptSpecList = opt_spec_list(),

    case Args of
        [] ->
            getopt:usage(OptSpecList, "party migration escript");
        _ ->
            {ok, ParsedArgs0} = getopt:parse(OptSpecList, Args),
            ParsedArgs = element(1, ParsedArgs0),

            OptNames = [hg_url, party_id, payment_institution_id, payout_schedule_id],
            [
                HellgateUrl,
                PartyID,
                PaymentInstitutionID,
                PayoutScheduleID
            ] = [proplists:get_value(OptName, ParsedArgs) || OptName <- OptNames],

            ok = error_logger:tty(false),
            State = #{
                hg_url => HellgateUrl,
                party_id => PartyID,
                user_info => make_user_info(),
                woody_context => make_context(),
                payment_institution_ref => #domain_PaymentInstitutionRef{id = PaymentInstitutionID},
                payout_schedule_ref => #domain_PayoutScheduleRef{id = PayoutScheduleID}
            },
            migrate(State)
    end.

migrate(State) ->
    #domain_Party{
        shops = Shops,
        contracts = Contracts
    } = get_party(State),
    _ = genlib_map:foreach(
        fun(_ShopID, Shop) ->
            case check_shop(Shop, Contracts, maps:get(payment_institution_ref, State)) of
                true ->
                    migrate_shop(Shop, State);
                false ->
                    ok
            end
        end,
        Shops
    ),
    ok.

migrate_shop(#domain_Shop{id = ShopID}, State) ->
    #payproc_Claim{
        id = ClaimID,
        revision = Revision
    } = create_claim(ShopID, State),
    ok = accept_claim(ClaimID, Revision, State),
    % check shop after claim acceptence
    case check_payout_schedule(get_shop(ShopID, State)) of
        false ->
            ok;
        true ->
            exit_w_error({ShopID, "Claim accepted, but shop doesn't have payout schedule"})
    end.


check_shop(Shop, Contracts, PaymentInstitutionRef) ->
    check_payout_schedule(Shop) andalso check_payment_institution(Shop, Contracts, PaymentInstitutionRef).

check_payout_schedule(#domain_Shop{payout_schedule = undefined}) ->
    true;
check_payout_schedule(#domain_Shop{payout_schedule = _Any}) ->
    false.

check_payment_institution(#domain_Shop{contract_id = ContractID}, Contracts, PaymentInstitutionRef) ->
    Contract = genlib_map:get(ContractID, Contracts),
    Contract#domain_Contract.payment_institution =:= PaymentInstitutionRef.

make_user_info() ->
    #payproc_UserInfo{id = ?USER, type = {service_user, #payproc_ServiceUser{}}}.

make_context() ->
    Ctx = woody_context:new(),
    woody_user_identity:put(#{id => ?USER, realm => <<"service">>}, Ctx).


get_party(State) ->
    handle_result(party_call('Get', [], State)).

create_claim(ShopID, State) ->
    Changeset = [
        {shop_modification, #payproc_ShopModificationUnit{
            id = ShopID,
            modification = {payout_schedule_modification, #payproc_ScheduleModification{
                schedule = maps:get(payout_schedule_ref, State)
            }}
        }}
    ],
    handle_result(party_call('CreateClaim', [Changeset], State)).

accept_claim(ClaimID, Revision, State) ->
    handle_result(party_call('AcceptClaim', [ClaimID, Revision], State)).

get_shop(ShopID, State) ->
    handle_result(party_call('GetShop', [ShopID], State)).

party_call(Function, Args, State) ->
    #{
        hg_url := RootUrl,
        party_id := PartyID,
        user_info := UserInfo,
        woody_context := Context
    } = State,
    Path = "/v1/processing/partymgmt",
    Service = {dmsl_payment_processing_thrift, 'PartyManagement'},
    Url = iolist_to_binary([RootUrl, Path]),
    Request = {Service, Function, [UserInfo, PartyID | Args]},
    try
        woody_client:call(
            Request,
            #{
                url           => Url,
                event_handler => scoper_woody_event_handler
            },
            Context
        )
    catch
        error:Error ->
            {error, {Error, erlang:get_stacktrace()}}
    end.

handle_result({ok, Result}) ->
    Result;
handle_result({exception, Error}) ->
    exit_w_error(Error);
handle_result({error, Error}) ->
    exit_w_error(Error).

exit_w_error(Error) ->
    ok = io:format("ERROR: ~p~n", [Error]),
    halt(1).

opt_spec_list() ->
    [
        {hg_url, undefined, undefined, string, "Hellgate url"},
        {party_id, undefined, "party-id", string , "Party ID"},
        {payment_institution_id, undefined, "payment-institution-id", integer, "Live payment institution ID"},
        {payout_schedule_id, undefined, "payout-schedule-id", integer, "Payout schedule ID"}
    ].
