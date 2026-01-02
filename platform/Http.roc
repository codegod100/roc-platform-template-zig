Http := [].{
    get! : Str => {
        requestUrl : Str,
        responseBody : List(U8),
        statusCode : U16,
    }
    get_batch! : List(Str) => List({
        requestUrl : Str,
        responseBody : List(U8),
        statusCode : U16,
    })
}
