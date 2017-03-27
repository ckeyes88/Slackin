defmodule EmployeeCalendar.Employee do
  @moduledoc
  defstruct username: nil, calendar: []
  use Timex

  def new(username) do
    %EmployeeCalendar.Employee{username: username}
  end

  def add_time_off(%EmployeeCalendar.Employee{username: u, calendar: cal}, {date_from, date_to, reason}) do
    from = parse_date(date_from)
    to = parse_date(date_to)
    cond do
      Timex.before?(from, to) || Timex.equal?(from, to)-> 
        %EmployeeCalendar.Employee{username: u, calendar: [%{from: from, to: to, reason: reason}] ++ cal}
      true -> {:error, :invalid_date_range}
    end
  end

  def get_time_off_for_day(%EmployeeCalendar.Employee{username: u, calendar: cal}, day) do
    parsed = parse_date(day)
    day_off = cal
              |> Enum.filter(&tween_dates(parsed, &1.from, &1.to))
    
    case day_off do
      [] -> {false, u, nil}
      _ -> {true, u, Enum.at(day_off, 0).reason}
    end
    
  end

  def clean_calendar(%EmployeeCalendar.Employee{username: u, calendar: cal}, day) do
    parsed = parse_date(day)
    clean_cal = cal
                |> Enum.filter(&(before_inclusive?(parsed, &1.to)))
    %EmployeeCalendar.Employee{username: u, calendar: clean_cal}
  end

  def remove_time_off(%EmployeeCalendar.Employee{username: u, calendar: cal}, day) do
    parsed = parse_date(day)
    new_cal = cal
    |> Enum.filter(&(!tween_dates(parsed, &1.from, &1.to)))

    %EmployeeCalendar.Employee{username: u, calendar: new_cal}
  end

  defp tween_dates(day, start, stop) do
    before_inclusive?(day, stop) && after_inclusive?(day, start)
  end
  
  def before_inclusive?(day_one, day_two) do
    (Timex.before?(day_one, day_two) || Timex.equal?(day_one, day_two))
  end

  defp after_inclusive?(day_one, day_two) do
    (Timex.after?(day_one, day_two) || Timex.equal?(day_one, day_two))
  end

  defp parse_date(date_time_str) do
    case Timex.parse(date_time_str, "%m/%d/%Y", :strftime) do
      {:ok, nd} -> nd
      {:error, _} -> :error
    end
  end

  def formatDate(date_time) do
    Timex.format(date_time, "%m/%d/%Y")
  end
end
