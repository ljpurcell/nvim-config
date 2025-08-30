; Match jsFunc and keyFunc at any nesting level, with better error handling
(pair
  key: (string
    (string_content) @_key)
  value: (string
    (string_content) @injection.content)
  (#match? @_key "^(js|key)Func$")
  (#set! injection.language "javascript")
  (#set! injection.include-children))

; Also match valueDeserializer for JavaScript content
(pair
  key: (string
    (string_content) @_key)
  value: (string
    (string_content) @injection.content)
  (#eq? @_key "valueDeserializer")
  (#set! injection.language "javascript")
  (#set! injection.include-children))
