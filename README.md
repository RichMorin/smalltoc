# SmallTOC Mix projects

The code in these Mix projects was extracted from a much larger system,
in order to have smaller and more cohesive versions for experimentation.
In the original system, the code adds a table of contents (TOC)
to the HTML output page from a Phoenix-based server.
It does this task successfully, but causes an error for `mix dialyzer`
(see `dial_out` for details).

## Infrastructure

This code uses several functions from the
[Floki](https://hexdocs.pm/floki/Floki.html) library:

- `find/2`                - search the input tree for a `toc` element
- `parse_document/1`      - generate a parse tree from the input HTML
- `parse_fragment/1`      - generate a parse tree from the TOC HTML
- `raw_html/1`            - regenerate HTML from the parse tree
- `text/1`                - extract text from header elements
- `traverse_and_update/2` - replace the `toc` element with the TOC
- `traverse_and_update/3` - add the TOC to the page

It also uses some of Floki's type definitions, in its `@spec` entries:

- `Floki.html_tag`
- `Floki.html_tree`

*Note:*
Floki's `traverse_and_update/3` function is very new
and its `@spec` entry has a small error.
So, for the moment,
I'm using a [modified copy](https://github.com/RichMorin/floki) of the library.

## Mix Projects

This Git repo contains two Mix projects.
Each of these passes `mix test`, but fails `mix dialyzer`.
(See `dial_out_t1` and `dial_out_t2` for details.)
The projects differ as discussed below.

### `take_1`

The `smalltoc.ex` file was copied from `router.toc.ex` in the larger system.
The Phoenix-related code was then removed
and a test file (`smalltoc_test.exs`) was created.
This version of `Smalltoc.add/1`:

- wraps each HTML header in a `<a name=...` element
- replaces the `<toc />` element with a TOC list

### `take_2`

The `smalltoc.ex` file was edited
to remove the TOC generation and replacement code;
the test file was modified accordingly.
