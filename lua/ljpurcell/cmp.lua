cmp.setup({
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    experimental = {
        ghost_text = true
    },
    sources = cmp.config.sources({
        { name = 'nvim_lsp', max_item_count = 6 },
        { name = 'luasnip' },
        { name = 'path' },
        { name = 'nvim_lua' },
        { name = 'buffer',   max_item_count = 3, keyword_length = 5 },
    })
})

lsp.setup_nvim_cmp({
    mapping = cmp_mappings,
})
