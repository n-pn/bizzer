defmodule Bizzer.RandUtil do
  @doc "Random fixed size string"
  def string(size \\ 10) do
    :crypto.strong_rand_bytes(size)
    |> Base.encode32(case: :lower)
    |> binary_part(0, size)
  end

  @doc "Random fixed size number"
  def number(digits \\ 6) do
    for _ <- 1..digits do
      (:rand.uniform(10) - 1) |> Integer.to_string()
    end
    |> Enum.join()
  end
end
