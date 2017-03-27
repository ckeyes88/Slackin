defmodule EmployeeCalendar.EmployeeSupervisor do
  use Supervisor
  @employee_registry_name :employee_registry
  
  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

   def find_or_create_process(username) do
    if employee_process_exists?(username) do
      {:ok, username}
    else
      username |> create_employee_process
    end
  end

  def employee_process_exists?(employee) do
    case Registry.lookup(@employee_registry_name, employee) do
      [] -> false
      _ -> true
    end
  end

  def create_employee_process(username) do
    case Supervisor.start_child(__MODULE__, [username]) do
      {:ok, _pid} -> {:ok, username}
      {:error, {:already_started, _pid}} -> {:error, :process_already_exists}
      other -> {:error, other}
    end
  end

  def employees do
    Supervisor.which_children(__MODULE__)
    |> Enum.map(fn {_, employee_pid, _, _} ->
      Registry.keys(@employee_registry_name, employee_pid)
      |> List.first
    end)
    |> Enum.sort
  end

  def init(_) do
    children = [
      worker(EmployeeCalendar.EmployeeServer, [])
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end