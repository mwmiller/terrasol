defmodule TerrasolAuthorTest do
  use ExUnit.Case
  doctest Terrasol.Author

  test "valid from spec" do
    assert Terrasol.Author.parse("@suzy.bo5sotcncvkr7p4c3lnexxpb4hjqi5tcxcov5b4irbnnz2teoifua") ==
             %Terrasol.Author{
               privatekey: nil,
               publickey:
                 <<119, 100, 233, 137, 162, 170, 163, 247, 240, 91, 91, 73, 123, 188, 60, 58, 96,
                   142, 204, 87, 19, 171, 208, 241, 17, 11, 91, 157, 76, 142, 65, 104>>,
               shortname: "suzy",
               string: "@suzy.bo5sotcncvkr7p4c3lnexxpb4hjqi5tcxcov5b4irbnnz2teoifua"
             }

    assert Terrasol.Author.parse("@js80.bnkivt7pdzydgjagu4ooltwmhyoolgidv6iqrnlh5dc7duiuywbfq") ==
             %Terrasol.Author{
               privatekey: nil,
               publickey:
                 <<106, 145, 89, 253, 227, 206, 6, 100, 128, 212, 227, 156, 185, 217, 135, 195,
                   156, 179, 32, 117, 242, 33, 22, 172, 253, 24, 190, 58, 34, 152, 176, 75>>,
               shortname: "js80",
               string: "@js80.bnkivt7pdzydgjagu4ooltwmhyoolgidv6iqrnlh5dc7duiuywbfq"
             }
  end

  test "key roundtrip from spec" do
    assert "b4p3qioleiepi5a6iaalf6pm3qhgapkftxnxcszjwa352qr6gempa"
           |> Terrasol.bdecode()
           |> Ed25519.derive_public_key()
           |> Terrasol.bencode() == "bnkivt7pdzydgjagu4ooltwmhyoolgidv6iqrnlh5dc7duiuywbfq"

    assert "becvcwa5dp6kbmjvjs26pe76xxbgjn3yw4cqzl42jqjujob7mk4xq"
           |> Terrasol.bdecode()
           |> Ed25519.derive_public_key()
           |> Terrasol.bencode() == "bo5sotcncvkr7p4c3lnexxpb4hjqi5tcxcov5b4irbnnz2teoifua"
  end

  test "valid vectors from reference test suite" do
    assert Terrasol.Author.parse("@suzy.bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx") ==
             %Terrasol.Author{
               privatekey: nil,
               publickey:
                 "\xBD\xEF{\xDE\xF7\xBD\xEF{\xDE\xF7\xBD\xEF{\xDE\xF7\xBD\xEF{\xDE\xF7\xBD\xEF{\xDE\xF7\xBD\xEF{\xDE\xF7\xBD\xEF",
               shortname: "suzy",
               string: "@suzy.bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
             }

    assert Terrasol.Author.parse("@s999.bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx") ==
             %Terrasol.Author{
               privatekey: nil,
               publickey:
                 "\xBD\xEF{\xDE\xF7\xBD\xEF{\xDE\xF7\xBD\xEF{\xDE\xF7\xBD\xEF{\xDE\xF7\xBD\xEF{\xDE\xF7\xBD\xEF{\xDE\xF7\xBD\xEF",
               shortname: "s999",
               string: "@s999.bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
             }
  end

  test "invalid vector from reference test suite" do
    assert :error = Terrasol.Author.parse("")
    assert :error = Terrasol.Author.parse("@")
    assert :error = Terrasol.Author.parse(".")
    assert :error = Terrasol.Author.parse("@.")
    assert :error = Terrasol.Author.parse("@suzy.")
    assert :error = Terrasol.Author.parse("@suzy")
    assert :error = Terrasol.Author.parse("suzy")

    assert :error =
             Terrasol.Author.parse("@.bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")

    assert :error =
             Terrasol.Author.parse("@bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")

    assert :error =
             Terrasol.Author.parse("@suzy@bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")

    assert :error =
             Terrasol.Author.parse("suzy.bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")

    assert :error =
             Terrasol.Author.parse("@suzy.bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")

    assert :error =
             Terrasol.Author.parse("@suzy.bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")

    assert :error =
             Terrasol.Author.parse("@suzybxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")

    assert :error =
             Terrasol.Author.parse("@suzy.bxxxxxxxxxxxxxxxxxxxxx.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")

    assert :error =
             Terrasol.Author.parse(" @suzy.bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")

    assert :error =
             Terrasol.Author.parse("@suzy.bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx ")

    assert :error =
             Terrasol.Author.parse("@SUZY.bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")

    assert :error =
             Terrasol.Author.parse("@suzy.bxxxxxXXXxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx ")

    assert :error =
             Terrasol.Author.parse("@suzy.7xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")

    assert :error =
             Terrasol.Author.parse("@1uzy.bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")

    assert :error =
             Terrasol.Author.parse("@@uzy.bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")

    assert :error = Terrasol.Author.parse("123")
    assert :error = Terrasol.Author.parse(nil)

    assert :error =
             Terrasol.Author.parse("@suzy.b01xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")
  end
end
