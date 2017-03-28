defmodule EmployeeCalendar.EmployeeTest do
  use ExUnit.Case
  doctest EmployeeCalendar.Employee

  setup_all do
    {:ok, start} = Timex.parse("06/15/2017", "%m/%d/%Y", :strftime)
    {:ok, ending} = Timex.parse("06/20/2017", "%m/%d/%Y", :strftime)
    {:ok, from} = Timex.parse("07/15/2018", "%m/%d/%Y", :strftime)
    {:ok, to} = Timex.parse("07/20/2018", "%m/%d/%Y", :strftime)
    {:ok, start: start, ending: ending, from: from, to: to}
  end

  setup do
    test_employee = %EmployeeCalendar.Employee{username: "ckeyes", calendar: []}
    {:ok, test_employee: test_employee}
  end
  
  test "Setting up an employee struct should set the fields to default return the employee\'s calendar list" do
    x = %EmployeeCalendar.Employee{}
    assert x.calendar == []
    assert x.username == nil
  end

  test "Calling add_time_off should add a value to the calendar list and return the new list", %{test_employee: test_employee, start: start, ending: ending} do
    test_employee = EmployeeCalendar.Employee.add_time_off(test_employee, {"06/15/2017", "06/20/2017", :wfh})
    assert Enum.member?(test_employee.calendar, %{from: start, to: ending, reason: :wfh})
  end

  test "get_time_off_for day should return a list of time off days where the given day is in the date range", %{ start: start, ending: ending} do
    test_employee = %EmployeeCalendar.Employee{username: "ckeyes", calendar: [%{from: start, to: ending, reason: :wfh}]}
    assert EmployeeCalendar.Employee.get_time_off_for_day(test_employee, "06/18/2017") == {true, "ckeyes", :wfh}
  end

  test "get_time_off_for day should return only keep the correct date range", %{from: from, to: to, start: start, ending: ending} do
    test_employee = %EmployeeCalendar.Employee{username: "ckeyes", calendar: [%{from: start, to: ending, reason: :wfh},%{from: from, to: to, reason: :wfh}]}
    assert EmployeeCalendar.Employee.get_time_off_for_day(test_employee, "06/18/2017") == {true, "ckeyes", :wfh}
  end

  test "get_time_off_for_day should exclude date ranges that the given day does not fall within", %{start: start, ending: ending} do
    test_employee = %EmployeeCalendar.Employee{username: "ckeyes", calendar: [%{from: start, to: ending, reason: :wfh}]}
    assert EmployeeCalendar.Employee.get_time_off_for_day(test_employee, "06/25/2017") == {false, "ckeyes", nil}
  end

  test "Invalid date range should return an error tuple", %{test_employee: test_employee} do
    assert {:error, :invalid_date_range} = EmployeeCalendar.Employee.add_time_off(test_employee, {"06/20/2017", "06/17/2017", :wfh})
  end

  test "Clean calendar should return a new employee with all dates where the given date is after the \'to\' date removed", %{from: from, to: to, start: start, ending: ending} do
    test_employee = %EmployeeCalendar.Employee{username: "ckeyes", calendar: [%{from: start, to: ending, reason: :wfh}, %{from: from, to: to, reason: :wfh}]}
    test_employee = EmployeeCalendar.Employee.clean_calendar(test_employee, "06/25/2017")
    assert %EmployeeCalendar.Employee{username: "ckeyes", calendar: [%{from: from, to: to, reason: :wfh}]} == test_employee
  end

  test "Date range should be inclusive", %{test_employee: test_employee} do
    test_employee = EmployeeCalendar.Employee.add_time_off(test_employee, {"06/20/2017", "06/20/2017", :wfh})
    assert EmployeeCalendar.Employee.get_time_off_for_day(test_employee, "06/20/2017") == {true, "ckeyes", :wfh}
  end

  test "Should be able to remove any time off by specific date", %{test_employee: test_employee, from: from, to: to} do
    test_employee = test_employee
    |> EmployeeCalendar.Employee.add_time_off({"07/15/2018", "07/20/2018", :wfh})
    |> EmployeeCalendar.Employee.add_time_off({"07/20/2017", "07/23/2017", :wfh})
    |> EmployeeCalendar.Employee.remove_time_off("07/21/2017")
    
    assert %EmployeeCalendar.Employee{username: "ckeyes", calendar: [%{from: from, to: to, reason: :wfh}]} == test_employee
  end
end

