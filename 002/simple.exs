fib = &(cond do
         &1 < trunc(4.0e6)-> if rem(&2, 2) == 0, do: &2 + &3.(&2, &1 + &2, &3), else: &3.(&2, &1 + &2, &3)
        true -> 0 
    end)
IO.puts fib.(1, 2, fib)