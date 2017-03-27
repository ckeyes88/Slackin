defmodule Slackin.Kin do
  use Slack
  use Timex
  # use EmployeeCalendar

  def handle_connect(slack, state) do
    IO.puts "Connected as #{slack.me.name}"
    {:ok, state}
  end

  def handle_event(message = %{type: "message"}, slack, state) do
    # IO.puts(Regex.run ~r/<@#{slack.me.id}>:?\sWho/, message.text)
    # IO.puts(message.text)
    # IO.inspect(message)
    if(message[:text] != nil) do
      case Regex.run ~r/<@#{slack.me.id}>[^.!?]+\?$/, message.text do
        
        [_head | []] -> 
          results = case msg = find_time_off() do
            "" -> "<@#{message.user}> Looks like we\'re all here today!"
            _ -> msg
          end
          # IO.inspect(results)
          send_message(results, message.channel, slack)
        _ -> 
          case Regex.run(~r/<@#{slack.me.id}>/, message.text) do
            [_head | []] -> 
              parts = String.split(message.text, " ")
              add_time_off(message.user, Enum.at(parts, 1), Enum.at(parts, 2), Enum.at(parts, 3))
              send_message("<@#{message.user}> Time off added", message.channel, slack)
            _ -> :error
          end
      end
    end

    {:ok, state}
  end

  def handle_event(_message, _slack, state), do: {:ok, state}
  def handle_info(_, _, state), do: {:ok, state}
  def handle_close(_, _, state), do: {:ok, state}
  defp find_time_off() do
    {:ok, today} = Timex.format(Timex.today, "%m/%d/%Y", :strftime)

    EmployeeCalendar.EmployeeSupervisor.employees
    |> Enum.map(fn username -> Task.async(fn -> EmployeeCalendar.EmployeeServer.get_time_off_for_day(username, today) end) end)
    |> Enum.map(fn task -> Task.await(task) end)
    |> Enum.filter(fn {out, _, _} -> out end)
    |> Enum.map(fn {_, name, reason} -> "<@#{name}> is out for #{reason}" end)
    |> Enum.reduce( "", fn msg, acc -> acc <> "\n" <> msg end )
  end

  defp add_time_off(username, from, to, reason) do
    case EmployeeCalendar.EmployeeSupervisor.find_or_create_process(username) do
      {:ok, u} -> 
        EmployeeCalendar.EmployeeServer.add_time_off(u, from, to, reason)
      _ -> :error
    end

  end
end