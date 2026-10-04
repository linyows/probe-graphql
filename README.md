# probe-graphql

A [Probe](https://github.com/linyows/probe) action that sends a GraphQL query over HTTP.

Probe downloads it the first time a workflow uses it. It needs a Probe that supports external actions (v1.17.0 or later).

```yaml
name: Countries API
jobs:
- name: countries
  steps:
  - name: Look up Japan
    uses: github.com/linyows/probe-graphql@<commit SHA>
    with:
      url: https://countries.trevorblades.com/graphql
      query: |
        query Country($code: ID!) {
          country(code: $code) { name capital currency }
        }
      variables:
        code: JP
    test: res.code == 200 && len(res.errors) == 0 && res.data.country.capital == "Tokyo"
```

Probe only takes a full 40-character commit SHA. The notes of each [release](https://github.com/linyows/probe-graphql/releases) start with the `uses` line to copy.

## Parameters

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `url` | String | Yes | - | GraphQL endpoint, `http` or `https` |
| `query` | String | Yes | - | The query or mutation document |
| `variables` | Object | No | - | Values for the variables the document declares |
| `operation_name` | String | No | - | The operation to run when the document has more than one |
| `headers` | Object | No | - | Request headers, such as `Authorization`. They override the defaults below |
| `timeout` | Duration | No | `30s` | Time limit for the request, as `10s` or a number of seconds. `0` removes it |

The request is a `POST` with a JSON body, sent with `Content-Type: application/json`, `Accept: application/graphql-response+json, application/json` and `User-Agent: probe-graphql/<version>`.

## Result

| Field | Type | Description |
|---|---|---|
| `res.code` | Integer | HTTP status code |
| `res.status` | String | HTTP status line, such as `"200 OK"` |
| `res.headers` | Object | Response headers, keyed by canonical name |
| `res.data` | Any | The `data` of the response, or `null` |
| `res.errors` | Array | The `errors` of the response; empty when there are none |
| `res.body` | Any | The whole response body, parsed when it is JSON, otherwise the raw string |
| `res.rawbody` | String | The unparsed body, present when the body is JSON |
| `req` | Object | The `url`, `query`, `variables`, `operation_name` and `headers` that were sent |
| `rt` | Duration | Round-trip time |
| `status` | Integer | `0` when the status code is 2xx, the body is JSON and `errors` is empty; `1` otherwise |

Any response the server sends is a result, so a test can assert on a GraphQL error or a 500. Only a request that gets no response, such as a refused connection or a timeout, fails the step as an error.

## Releasing

Pushing a `v*` tag builds the executables with GoReleaser and publishes them on the release. The workflow then commits an `action.yml` with their URLs and SHA-256 digests to `main`, and adds the commit to the release notes. That commit is the one to pin: Probe reads `action.yml` at the pinned commit and refuses an executable whose digest differs.

## License

MIT
