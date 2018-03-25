using HTTP

# export respond, mux

# Utils

pre(f) = (app, req) -> app(f(req))
post(f) = (app, req) -> f(app(req))

### Working with requests
# Rather than converting the requests into a different Dict-based format we will make it easier to work with the HTTP.Request type

# Easy way to get request content
body(req::HTTP.Request) = HTTP.IOExtras.bytes(req.body)

# Easy way to access headers
# TODO: These may be duplicated here: https://github.com/JuliaWeb/HTTP.jl/blob/master/src/Messages.jl#L361-L364
hasheader(req::HTTP.Request, header::AbstractString) =
    count(h -> h.first == header) > 0
getheaders(req::HTTP.Request, header::AbstractString) =
    filter(h -> h.first == header)
firstheader(req::HTTP.Request, header::AbstractString) =
    hasheader(req, header) ? filter(req, header)[1] : nothing

# Easy ways to deal with URIs
path(req::HTTP.Request) = HTTP.URI(req.target).path
query(req::HTTP.Request) = HTTP.URI(req.target).query

# params!(req) = get!(req, :params, d())

### Working with responses
# Not currently adding any -- there are good construction methods for them in HTTP


# Response(d::Associative) = HTTP.Response(
#     get(d, :status, 200),
#     convert(HTTP.Headers, get(d, :headers, HTTP.Headers())),
#            get(d, :body, ""))
#
# Response(o) = Response(stringmime(MIME"text/html"(), o))
#
# response(d) = d
# response(s::AbstractString) = d(:body=>s)
#
# toresponse(app, req) = Response(response(app(req)))
#
# respond(res) = req -> response(res)

# reskey(k, v) = post(res -> merge!(res, d(k=>v)))
#
# status(s) = reskey(:status, s)

# Error handling

mux_css = """
  body { font-family: sans-serif; padding:50px; }
  .box { background: #fcfcff; padding:20px; border: 1px solid #ddd; border-radius:5px; }
  pre { line-height:1.5 }
  a { text-decoration:none; color:#225; }
  a:hover { color:#336; }
  u { cursor: pointer }
  """

error_phrases = ["Looks like someone needs to pay their developers more."
                 "Someone order a thousand more monkeys! And a million more typewriters!"
                 "Maybe it's time for some sleep?"
                 "Don't bother debugging this one – it's almost definitely a quantum thingy."
                 "It probably won't happen again though, right?"
                 "F5! F5! F5!"
                 "F5! F5! FFS!"
                 "On the bright side, nothing has exploded. Yet."
                 "If this error has frustrated you, try clicking <u>here</u>."]

function basiccatch(app, req)
  try
    app(req)
  catch e
    io = IOBuffer()
    println(io, "<style>", mux_css, "</style>")
    println(io, "<h1>Internal Error</h1>")
    println(io, "<p>$(error_phrases[rand(1:length(error_phrases))])</p>")
    println(io, "<pre class=\"box\">")
    showerror(io, e, catch_backtrace())
    println(io, "</pre>")
    return HTTP.Response(500, String(take!(io)))
  end
end

function nothingtosee(app, req)
    res =  HTTP.Response(200, "{message: \"Nothing to see here\"}")
    push!(res.headers, Pair("Content-Type", "application/json"))
    return res
end
