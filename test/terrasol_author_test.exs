defmodule TerrasolAuthorTest do
  use ExUnit.Case
  doctest Terrasol.Author

  test "valid from spec" do
    assert Terrasol.Author.parse("@suzy.bo5sotcncvkr7p4c3lnexxpb4hjqi5tcxcov5b4irbnnz2teoifua") ==
             {"suzy",
              47_156_363_425_378_973_145_356_108_481_427_676_913_709_812_305_928_140_414_295_363_664_859_552_638_071}

    assert Terrasol.Author.parse("@js80.bnkivt7pdzydgjagu4ooltwmhyoolgidv6iqrnlh5dc7duiuywbfq") ==
             {"js80",
              34_235_478_715_415_188_160_911_838_470_992_347_459_983_493_941_183_478_312_615_283_457_026_055_311_722}
  end
end
