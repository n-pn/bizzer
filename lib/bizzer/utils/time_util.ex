defmodule Bizzer.TimeUtil do
  @hour 60 * 60
  @day @hour * 24
  @week @day * 7
  @month @day * 30

  def this_hour do
    now = NaiveDateTime.utc_now()
    NaiveDateTime.add(now, -@hour)
  end

  def this_day do
    now = NaiveDateTime.utc_now()
    NaiveDateTime.add(now, -@day)
  end

  def this_week do
    now = NaiveDateTime.utc_now()
    NaiveDateTime.add(now, -@week)
  end

  def this_month do
    now = NaiveDateTime.utc_now()
    NaiveDateTime.add(now, -@month)
  end

  @doc "Compare two time periods"
  def time_diff(time1, type \\ :past, time2 \\ NaiveDateTime.utc_now())

  def time_diff(time1, :past, time2) do
    NaiveDateTime.diff(time2, time1)
  end

  def time_diff(time1, :future, time2) do
    NaiveDateTime.diff(time1, time2)
  end

  def parse_int(str, default \\ 0)
  def parse_int(nil, _), do: -1

  def parse_int(str, default) do
    case Integer.parse(str) do
      :error -> default
      {int, _} -> int
    end
  end

  @minute 60
  @hour @minute * 60
  @day @hour * 24

  def relative(time) do
    diff = time_diff(time)

    cond do
      diff < @minute -> "#{diff} giây trước"
      diff < @hour -> "#{div(diff, @minute)} phút trước"
      diff < @day -> "#{div(diff, @hour)} giờ trước"
      true -> "#{div(diff, @day)} ngày trước"
    end
  end

  @timezone 7 * 60 * 60

  def get_date(time) do
    time
    |> NaiveDateTime.add(@timezone, :second)
    |> NaiveDateTime.to_date()
    |> Date.to_string()
  end

  @epoch ~N[1970-01-01 00:00:00]
  def from_unix(time, unit \\ :millisecond) do
    NaiveDateTime.add(@epoch, time, unit)
  end

  def pretty_print(time) do
    time = NaiveDateTime.add(time, @timezone, :second)
    "ngày #{time.day}/#{time.month}/#{time.year}, lúc #{time.hour}:#{time.minute}"
  end
end
