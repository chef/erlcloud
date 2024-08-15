%% -*- mode: erlang;erlang-indent-level: 4;indent-tabs-mode: nil -*-
-module(erlcloud_s3_presigned_url_tests).
-include_lib("eunit/include/eunit.hrl").
-include("erlcloud.hrl").
-include("erlcloud_aws.hrl").


% to run:
% AWS_DEFAULT_REGION=us-east-1 ./rebar3 eunit --module=erlcloud_s3_presigned_url_tests

% escape question marks with two backslashes (\\?)
% .* matches 0 or more characters
% .+ matches 1 or more characters
-define(URL_REGEX, "^https://bucket\.s3\.us-east-1\.amazonaws\.com:441/key\\?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=access-key-id%2F.+%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=.+&X-Amz-Expires=0&X-Amz-SignedHeaders=abc%3Bhost%3Bxyz&X-Amz-Signature=.+$").
-define(URL,       "https://bucket.s3.us-east-1.amazonaws.com:441/key?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=access-key-id%2F20201005%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20201005T122030Z&X-Amz-Expires=0&X-Amz-SignedHeaders=X-User%3Bhost&X-Amz-Signature=8b2f2eb3ff9c23924dae7fe95caf08805d8285a792f4e0dadeaa8f830cbceb5e").

config() ->
    erlcloud_s3:new("access-key-id", "secret-access-key", "host.com", 441).
make_presigned_v4_url_test() ->
    Config = (config())#aws_config{s3_host="s3.us-east-1.amazonaws.com"},
    Urls = [erlcloud_s3:make_presigned_v4_url(0, "bucket", Method, "key", [], [{"abc","123"}, {"xyz","456"}], Config) || Method <- [head, get, post, put]],
    [{match, [{0, 318}]} = re:run(Url, ?URL_REGEX, [report_errors]) || Url <- Urls].

gen_static_url_test() ->
    Config = (config())#aws_config{s3_host="s3.us-east-1.amazonaws.com"},
    ?URL = erlcloud_s3:make_presigned_v4_url(0, "bucket", put, "key", [], [{"X-User", "12333333"}], "20201005T122030Z", Config).
