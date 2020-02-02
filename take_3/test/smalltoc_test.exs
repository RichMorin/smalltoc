defmodule SmalltocTest do
  use ExUnit.Case

  test "adds TOC for a simple case" do

    test_inp  = """
    <html>
      <head>
      </head>
      <body>
        <h1> <a href="/">Pete&apos;s Alley</a></h1></a><br/>
        <toc />
        <h2>About Pete's Alley</h2></a>
        <h3>Motivation</h3>
        <h3>Approach</h3>
        <h3>Implementation</h3>
      </body>
    """

    test_out  = [
      "<html>\n",
      "  <head>\n",
      "  </head>\n",
      "  <body>\n",
      "    <a name='f_0'><h1> <a href=\"/\">Pete&apos;s Alley</a></h1>",
           "</a></a><br/>\n",
      "    <b>Contents:</b>\n<span class=\"hs-hide1 hs-ih hs-none\">(<a\n",
      "  href=\"#\">hide</a>)</span>\n<span ",
         "class=\"hs-show1 hs-is hs-none\">(<a\n",
      "  href=\"#\">show</a>)</span>\n\n",
      "<div class=\"hs-body1 hs-ih toc\">\n",
      "<ul>\n",
      "  <li><a href='#f_0'>Pete's Alley</a></li>\n",
      "<ul>\n",
      "    <li><a href='#f_1'>About Pete's Alley</a></li>\n",
      "<ul>\n",
      "      <li><a href='#f_2'>Motivation</a></li>\n",
      "      <li><a href='#f_3'>Approach</a></li>\n",
      "      <li><a href='#f_4'>Implementation</a></li>\n",
             "</ul></ul></ul>\n",
      "</div>\n\n",
      "    <a name='f_1'><h2>About Pete's Alley</h2></a></a>\n",
      "    <a name='f_2'><h3>Motivation</h3></a>\n",
      "    <a name='f_3'><h3>Approach</h3></a>\n",
      "    <a name='f_4'><h3>Implementation</h3></a>\n",
      "  </body>\n" ]
    |> Enum.join("")

    assert Smalltoc.add(test_inp) == test_out
  end
end
