defmodule EmployeeCalendar.EmployeeServer do
  use GenServer
  alias EmployeeCalendar.Employee
  
  def start_link(employee_id) do
    GenServer.start_link(__MODULE__, %Employee{username: employee_id, calendar: []}, name: via_tuple(employee_id))
  end

  def get_employee(username) do
    GenServer.call(via_tuple(username), :get)
  end

  def get_time_off_for_day(username, day) do
    GenServer.call(via_tuple(username), {:get_time_off, day})
  end

  def add_time_off(username, date_to, date_from, reason) do
    GenServer.cast(via_tuple(username), {:add, date_to, date_from, reason})
  end

  def remove_time_off(username, date) do
    GenServer.cast(via_tuple(username), {:remove, date})
  end

  def clean_calendar(username, date) do
    GenServer.cast(via_tuple(username), {:clean, date})
  end
  ###### CALLBACKS ########
  def init(employee) do
    {:ok, employee}
  end

  def handle_call(:get, _from, employee) do
    {:reply, employee, employee}
  end

  def handle_call({:get_time_off, day}, _from, employee) do
    {:reply, Employee.get_time_off_for_day(employee, day), employee}
  end

  def handle_cast({:add, date_to, date_from, reason}, employee) do
    new_employee = Employee.add_time_off(employee, {date_to, date_from, reason})
    {:noreply, new_employee}
  end

  def handle_cast({:remove, date}, employee) do
    {:noreply, Employee.remove_time_off(employee, date)}
  end
  
  def handle_cast({:clean, date}, employee) do
    {:noreply, Employee.clean_calendar(employee, date)}
  end

  defp via_tuple(username) do
    {:via, Registry, {:employee_registry, username}} 
  end
end