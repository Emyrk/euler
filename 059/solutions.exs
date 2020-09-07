# Going to Golang
use Bitwise

defmodule XORCipher do
    def xor(str, key) do
        key_stream = to_charlist(key) |> Stream.cycle


        to_charlist(str)
        |> Enum.map(fn v->
            bxor(v, )
        end)
        |> to_string
    end
end


XORCipher.xor("test", "") |> XORCipher.xor ""


defmodule Test do

    def test_all() do

    end

    def test_xor(v, key) do
        if XORCipher.xor(XORCipher.xor(v, key), key) != v, do: IO.puts "Error!"
    end

end
