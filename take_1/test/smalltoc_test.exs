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
    "<html>",
      "<head></head>",
      "<body>",
        "<a name=\"x1\"><h1><a href=\"/\">Pete&apos;s Alley</a></h1></a><br/>",
        "<div>",
          "<b>Contents:</b>",
          "<ul style=\"list-style-type:none\">",
            "<li>1 <a href=\"#x1x1x1\">Motivation</a></li>",
            "<li>2 <a href=\"#x1x1x2\">Approach</a></li>",
            "<li>3 <a href=\"#x1x1x3\">Implementation</a></li>",
          "</ul>",
        "</div>",
        "<a name=\"x1x1\"><h2>About Pete&apos;s Alley</h2></a>",
        "<a name=\"x1x1x1\"><h3>Motivation</h3></a>",
        "<a name=\"x1x1x2\"><h3>Approach</h3></a>",
        "<a name=\"x1x1x3\"><h3>Implementation</h3></a>",
      "</body>",
    "</html>" ]
    |> Enum.join("")

    assert Smalltoc.add(test_inp) == test_out
  end
end
