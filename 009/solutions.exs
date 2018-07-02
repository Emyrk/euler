# Euclid's formula
# https://en.wikipedia.org/wiki/Pythagorean_triple#Generating_a_triple
# a = m^2 - n^2
# b = 2mn
# c = m^2 + n^2
# m > n > 0
# The result of a+b+c can be off by some k, -> k(a + b + c)


defmodule Euclid do
    def generate_triple(m, n) when m <= n or n <= 0 do
        raise("Incorrect arugments. m > n > 0")
    end

    def generate_triple(m, n) do
        a = :math.pow(m, 2) - :math.pow(n, 2)
        b = 2 *m * n
        c = :math.pow(m, 2) + :math.pow(n, 2)
        {trunc(a), trunc(b), trunc(c)}
    end
end


# This part is not programmed, but using the formula above:
# n = (500/m) - m <- Plug m, n into Euclid.generte_triple
# Now solve for n where n < m
# m = 20, n = 5
# {a, b, c} = {375, 200, 425}