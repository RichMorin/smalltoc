# smalltoc.ex

defmodule Smalltoc do
#
# Public Functions
#
#   add/1         add a Table of Contents to the (HTML) output page
#
# Private Functions
#
#   edit_body/2   edit the body of the output page
#   get_level/1   generate a level from a header
#   get_name/1    generate a name from an index value
#   get_toc/1     generate TOC HTML from the match_list
#
# Written by Rich Morin, CFCL, 2020.

  # Public Functions

  @spec add(st) :: st
    when st: String.t

  def add(html) do
    edit_body(html)
  end

  # Private Functions

  @spec edit_body(st) :: st
    when st: String.t

  defp edit_body(body_inp) do
  #
  # Check the body of the output page for a "<toc />" element.
  # If this is present, edit the body:
  #
  # - Wrap header elements in "<a name=...> elements.
  # - Replace the "<toc />" element with a table of contents. 
  #
  #!K - Parsing (etc) HTML with regexen is brittle.

    #!K - This will break if Unicode is present!
    body_tmp  = IO.iodata_to_binary(body_inp)

    patt_toc  = "<toc />"

    if String.contains?(body_tmp, patt_toc) do
      patt_hdr    = ~r{<[Hh][1-6].+?[Hh][1-6]>}

      match_list  = patt_hdr
      |> Regex.scan(body_tmp)     # [ [ "<h1>Foo</h1>" ], ... ]
      |> Enum.map(&hd/1)          # [ "<h1>Foo</h1>", ... ]
      |> Enum.with_index()        # [ { "<h1>Foo</h1>", 0 }, ... ]

      match_map   = match_list
      |> Enum.into(%{})           # %{ "<h1>Foo</h1>" => 0, ... }

      replace_fn  = fn header ->
        hdr_ndx   = match_map[header]

        "<a name='#{ get_name(hdr_ndx) }'>#{ header }</a>"
      end

      body_tmp
      |> String.replace(patt_hdr, replace_fn)
      |> String.replace(patt_toc, get_toc(match_list))
    else
      body_inp
    end
  end

  # Private Functions

  defp get_level(header) do
  #
  # Generate a level from a header.

    header                    # "<h3>Foo</h3>"
    |> String.slice(2..2)     # "3"
    |> String.to_integer()    # 3
  end

  defp get_name(ndx), do: "f_#{ ndx }"
  #
  # Generate a name from an index value.

  defp get_toc(match_list) do
  #
  # Generate TOC HTML from the match_list.

    map_fn  = fn match_tuple ->
      {header, hdr_ndx, level_prev} = match_tuple
      level_this        = get_level(header)

      {:ok, tree}   = Floki.parse_fragment(header)
      hdr_text  = tree  # [{"h1", [], [" ", {"a", [{"href", "/"}], ["Foo"]}]}]
      |> Floki.text()   # " Foo"
      |> String.trim()  # "Foo"

      href        = "'##{ get_name(hdr_ndx) }'"
      item        = String.duplicate("  ",  level_this) <>
                    "<li><a href=#{ href }>#{ hdr_text }</a></li>"
      level_diff  = level_this - level_prev

      cond do
        level_this == 0 ->    # Close out all ul levels.
          adjust  = String.duplicate("</ul>", -level_diff)
          [ adjust ]

        level_diff > 0 ->     # Increase the ul level.
          adjust  = String.duplicate("<ul>",   level_diff)
          [ adjust, item ]

        level_diff < 0 ->     # Decrease the ul level.
          adjust  = String.duplicate("</ul>", -level_diff)
          [ adjust, item ]

        true -> item
      end
    end

    m_r_fn  = fn tup_inp, level_prev ->
      {header, _hdr_ndx}  = tup_inp

      tup_out   = tup_inp               # { "<h3>Foo</h3>", 2}
      |> Tuple.append(level_prev)       # { "<h3>Foo</h3>", 2, 2}

      level_this  = get_level(header)

      {tup_out, level_this}             # { { "<h3>Foo</h3>", 2, 2}, 3}
    end

    dummy_item  = {"<h0></h0>", 99}

    {toc_tmp1, _acc}  = match_list      # [ ..., {"<h4>...</h4>", 20} ]
    |> List.insert_at(-1, dummy_item)   # append {"<h0></h0>", 99}
    |> Enum.map_reduce(0, m_r_fn)       # { [ ..., {"<h0></h0>", 99, 4} ], 0}

    toc_tmp2   = toc_tmp1               # [ ..., {"<h0></h0>", 99, 4} ]
    |> Enum.map(map_fn)                 # [ ..., [ "</ul></ul></ul></ul>" ] ]
    |> List.flatten()                   # [ ..., "</ul></ul></ul></ul>" ]
    |> Enum.join("\n")                  # "...\n</ul></ul></ul></ul>"
    
    """
    <b>Contents:</b>
    <span class="hs-hide1 hs-ih hs-none">(<a
      href="#">hide</a>)</span>
    <span class="hs-show1 hs-is hs-none">(<a
      href="#">show</a>)</span>

    <div class="hs-body1 hs-ih toc">
    #{ toc_tmp2 }
    </div>
    """
  end
    
end
