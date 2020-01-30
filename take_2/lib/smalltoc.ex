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
#   get_name/1    generate a name from a list
#   update_acc/3  update the accumulator, based on the current header info
#   wrap_hdr/2    wrap a header node with a "<a name=...>" node
#   wrap_hdrs/1   wrap all header nodes with "<a name=...>" nodes
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
  # First, parse the body of the output page.
  # Then, if a "<toc />" element is present, edit the body:
  #
  # - Wrap header elements in "<a name=...> elements.
  # - Replace the "<toc />" element with a table of contents. 

    # Parse the input HTML.

    {:ok, tree_inp}   = Floki.parse_document(body_inp)
    tocs      = Floki.find(tree_inp, "toc")

    body_out  = if Enum.empty?(tocs) do
      body_inp
    else
      # Wrap the headers and accumulate info.

      {tree_out1, _acc_out1} = wrap_hdrs(tree_inp)

      Floki.raw_html(tree_out1)    # Convert tree back into HTML.
    end

    body_out
  end

  @spec get_name([integer]) :: st
    when st: String.t

  defp get_name(ndx_list) do
  #
  # Generate a fragment name from an index list.

    tmp   = ndx_list          # [5, 4, 3, 2, 1]
    |> Enum.reverse()         # [1, 2, 3, 4, 5]
    |> Enum.join("x")         # "1x2x3x4x5"

    "x#{ tmp }"               # "x1x2x3x4x5"
  end

  @spec update_acc(any, number, htag) :: any
    when htag: Floki.html_tag

  defp update_acc(acc_inp, this_level, this_node) do
  #
  # Update the accumulator, based on the current header info.
  # If the header level jumps (e.g., from h2 to h5), fake up entries.

    this_text    = [ this_node ]
    |> Floki.text()
    |> String.trim()

    prev_tuple  = Enum.at(acc_inp, 0) || { 0, [], "" }
    { prev_level, prev_list, _prev_text } = prev_tuple
    level_diff  = this_level - prev_level
    acc_tmp     = acc_inp

    unfold_fn = fn          # Fake up entries for level jumps.
      ^prev_level -> nil    # Done if back to previous level.

      tmp_level ->          # Missing level; fake up an entry.
        foo_cnt   = tmp_level - prev_level
        foo_list  = List.duplicate(1, foo_cnt) ++ prev_list

        t = { tmp_level, foo_list, "" }
        { t, tmp_level - 1 }
    end

    { acc_tmp, this_list }  = cond do
      level_diff > 0 ->                           # higher level

        { acc_tmp, tmp_list } = case level_diff do
          1 ->                                    # single step
            { acc_tmp, prev_list }

          _ ->                                    # missing step(s)
            add_list  = this_level - 1
            |> Stream.unfold(unfold_fn)
            |> Enum.to_list()

            acc_tmp     = add_list ++ acc_tmp
            { acc_tmp, prev_list }
        end

        tmp_list = [ 1 | tmp_list ]               # [2,1] -> [1,2,1]
        { acc_tmp, tmp_list }

      level_diff < 0 ->                           # lower level
        tmp_list    = Enum.drop(prev_list, -level_diff)
        this_index  = hd(tmp_list) + 1
        tmp_list = [ this_index | tl(tmp_list) ]  # [2,1] -> [3,1]
        { acc_tmp, tmp_list }

      true  ->                                    # same level
        this_index  = hd(prev_list) + 1
        tmp_list = [ this_index | tl(prev_list) ]
        { acc_tmp, tmp_list }
    end

    this_list  = cond do
      Enum.empty?(acc_tmp) -> [ 1 ]       # First entry; fake up a list.

      level_diff <= 0 -> this_list        # Same or lower level; stet.

      true ->                             # Higher level; augment list
        {_, foo_list, _} = hd(acc_tmp)    # [ {1, [1, 1], "..."}, ...]
        [ 1 | foo_list ]                  # [1, 1, 1]
    end

    item_out  = { this_level, this_list, this_text }
    [ item_out | acc_tmp ]
  end

  @spec wrap_hdr(list, htag) :: htag
    when htag: Floki.html_tag

  defp wrap_hdr(acc_tmp, hdr_node) do
  #
  # Get the previous entry from the accumulator.
  # Extract the previous `ndx_list` value.
  # Generate the current name, based on this value.
  # Wrap the header node with a "<a name=...>" node.

    { _hdr_level, ndx_list, _hdr_text } = hd(acc_tmp)
    curr_name   = get_name(ndx_list)
    { "a", [ {"name", curr_name} ], hdr_node }
#   |> IO.inspect #!T
  end

  @spec wrap_hdrs(ht) :: {ht, list}
    when ht: Floki.html_tree

  defp wrap_hdrs(tree_inp) do
  #
  # Wrap each header node with a "<a name=...>" node.
  # Accumulate a list of descriptive tuples.

    tau_fn1 = fn level, hdr_node, acc_inp ->
    # Update the accumulator, then wrap the header node.

      acc_out   = update_acc(acc_inp, level, hdr_node)
      node_out  = wrap_hdr(acc_out, hdr_node)
      { node_out, acc_out }
    end

    tau_fn2 = fn
    # If this is a header node, use tau_fn1 to process it.
    # Note: Floki lowercases HTML tags such as "H1".

      hdr_node = {"h1", _, _}, acc -> tau_fn1.(1, hdr_node, acc)
      hdr_node = {"h2", _, _}, acc -> tau_fn1.(2, hdr_node, acc)
      hdr_node = {"h3", _, _}, acc -> tau_fn1.(3, hdr_node, acc)
      hdr_node = {"h4", _, _}, acc -> tau_fn1.(4, hdr_node, acc)
      hdr_node = {"h5", _, _}, acc -> tau_fn1.(5, hdr_node, acc)
      hdr_node = {"h6", _, _}, acc -> tau_fn1.(6, hdr_node, acc)

      # Otherwise, leave the node (and accumulator) alone.

      node, acc        -> {node, acc}
    end

    {tree_out, acc_out}  = tree_inp
    |> Floki.traverse_and_update([], tau_fn2)

    {tree_out, acc_out}
  end

end