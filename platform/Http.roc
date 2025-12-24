Http := [].{
    get! : Str => {
        requestUrl : Str,
        requestHeaders : Dict(Str, Str),
        responseHeaders : Dict(Str, Str),
        responseBody : List(U8),
    }
}