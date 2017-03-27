defmodule EmployeeCalendar.EmployeeServerTest do
  use ExUnit.Case, async: true
  alias EmployeeCalendar.{EmployeeServer, Employee}
  doctest EmployeeCalendar

  setup do
    employee = %Employee{username: "ckeyes", calendar: []}
    {:ok, username} = EmployeeCalendar.EmployeeSupervisor.find_or_create_process "ckeyes"
    {:ok, username: username, employee: employee}
  end

  test "Employee server should create a new employee with initial state", %{username: username, employee: employee} do

    assert EmployeeServer.get_employee(username) == employee
  end

  test "Employee server should be able to add days off to an employee\'s calendar", %{username: username, employee: employee} do
    assert :ok = EmployeeServer.add_time_off(username, "05/05/2016", "05/05/2016", "work from home")
  end

  test "Employee server should respond with the employee name and reason for being off", %{username: username} do
    EmployeeServer.add_time_off(username, "05/05/2016","05/07/2016", "work from home")

    assert EmployeeServer.get_time_off_for_day(username, "05/05/2016") == {true, "ckeyes", "work from home"}
  end

  test "Employee Server should remove dates from its employee", %{username: pid} do
    EmployeeServer.add_time_off(pid, "05/05/2016","05/07/2016", "work from home")
    EmployeeServer.remove_time_off(pid, "05/07/2016")

    assert {false, "ckeyes"} = EmployeeServer.get_time_off_for_day(pid, "05/06/2016")
  end

  test "Employee server should be able to clean old dates from the calendar", %{username: pid} do
    EmployeeServer.add_time_off(pid, "05/05/2016","05/07/2016", "work from home")
    EmployeeServer.add_time_off(pid, "05/05/2017","05/07/2017", "work from home")
    EmployeeServer.add_time_off(pid, "05/05/2018","05/07/2018", "work from home")
    EmployeeServer.clean_calendar(pid, "06/01/2017")
    assert {true, "ckeyes", "work from home"} = EmployeeServer.get_time_off_for_day(pid, "05/07/2018")
    assert {false, "ckeyes"} = EmployeeServer.get_time_off_for_day(pid, "05/06/2017")
    assert {false, "ckeyes"} = EmployeeServer.get_time_off_for_day(pid, "05/06/2016")
  end
end
