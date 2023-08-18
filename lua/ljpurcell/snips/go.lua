local ls = require("luasnip")

ls.snippets = {
    go = {
        ls.parser.parse_snippet("e!", "hello there")
    }
}
