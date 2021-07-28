ExUnit.start()

defmodule ExampleData do
  def spec_map do
    %{
      :author => "@suzy.bjzee56v2hd6mv5r5ar3xqg3x3oyugf7fejpxnvgquxcubov4rntq",
      :content => "Flowers are pretty",
      :contentHash => "bt3u7gxpvbrsztsm4ndq3ffwlrtnwgtrctlq4352onab2oys56vhq",
      :deleteAfter => nil,
      :format => "es.4",
      :path => "/wiki/shared/Flowers",
      :signature =>
        "bjljalsg2mulkut56anrteaejvrrtnjlrwfvswiqsi2psero22qqw7am34z3u3xcw7nx6mha42isfuzae5xda3armky5clrqrewrhgca",
      :timestamp => 1_597_026_338_596_000,
      :workspace => "+gardening.friends"
    }
  end

  def test_author do
    %Terrasol.Author{
      privatekey:
        <<62, 37, 115, 177, 36, 26, 209, 115, 153, 190, 29, 234, 128, 153, 163, 112, 189, 188,
          109, 187, 125, 4, 219, 162, 119, 72, 207, 30, 136, 242, 28, 117>>,
      publickey:
        <<187, 236, 6, 191, 211, 79, 121, 7, 149, 102, 189, 186, 140, 91, 159, 188, 186, 21, 140,
          86, 13, 155, 102, 213, 155, 113, 246, 7, 188, 37, 27, 55>>,
      shortname: "test",
      string: "@test.bxpwanp6tj54qpflgxw5iyw47xs5bldcwbwnwnvm3oh3appbfdm3q"
    }
  end
end
