%% -*- mode: erlang;erlang-indent-level: 4;indent-tabs-mode: nil -*-
-module(erlcloud_s3_presigned_url_tests).
-include_lib("eunit/include/eunit.hrl").
%-include("erlcloud.hrl").
%-include("erlcloud_aws.hrl").

% to run:
% ./rebar3 eunit --module=erlcloud_s3_presigned_url_tests

% escape question marks with two backslashes (\\?)
% .* matches 0 or more characters
% .+ matches 1 or more characters
-define(URL_REGEX, "^https://bucket\.host\.com:441/key\\?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=access-key-id%2F.+%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=.+&X-Amz-Expires=0&X-Amz-SignedHeaders=abc%3Bhost%3Bxyz&X-Amz-Signature=.+$").

config() ->
    erlcloud_s3:new("access-key-id", "secret-access-key", "host.com", 441).

make_presigned_v4_url_test() ->
    Config = config(),
    Urls = [erlcloud_s3:make_presigned_v4_url(0, "bucket", Method, "key", [], [{"abc","123"}, {"xyz","456"}], Config) || Method <- [head, get, post, put]],
    [{match, [{0,300}]} = re:run(Url, ?URL_REGEX) || Url <- Urls].
