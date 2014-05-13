# encoding: utf-8

require 'test_helper'

class EvaluationTest < ActiveSupport::TestCase

  def setup
    @period_week = Period.new('4.12.2006', '10.12.2006')
    @period_month = Period.new('1.12.2006', '31.12.2006')
    @period_day = Period.new('4.12.2006', '4.12.2006')
  end

  def test_clients
    @evaluation = ClientsEval.new
    assert ! @evaluation.absences?
    assert ! @evaluation.for?(employees(:pascal))
    assert ! @evaluation.class::TOTAL_DETAILS

    divisions = @evaluation.divisions
    assert_equal 2, divisions.size
    assert_equal clients(:puzzle), divisions[0]
    assert_equal clients(:swisstopo), divisions[1]

    assert_sum_times 0, 20, 32, 33, clients(:puzzle)
    assert_sum_times 3, 10, 21, 21, clients(:swisstopo)
  end

  def test_clients_detail_puzzle
    @evaluation = ClientsEval.new
    @evaluation.set_division_id clients(:puzzle).id
    assert_sum_times 0, 20, 32, 33
    assert_count_times 0, 3, 5, 6
  end

  def test_clients_detail_swisstopo
    @evaluation = ClientsEval.new
    @evaluation.set_division_id clients(:swisstopo).id

    assert_sum_times 3, 10, 21, 21
    assert_count_times 1, 2, 3, 3
  end

  def test_employees
    @evaluation = EmployeesEval.new
    assert ! @evaluation.absences?
    assert ! @evaluation.for?(employees(:pascal))
    assert ! @evaluation.class::TOTAL_DETAILS

    divisions = @evaluation.divisions
    assert_equal 3, divisions.size

    assert_sum_times 0, 18, 18, 18, employees(:mark)
    assert_sum_times 0, 9, 30, 30, employees(:lucien)
    assert_sum_times 3, 3, 5, 6, employees(:pascal)
  end

  def test_employee_detail_mark
    @evaluation = EmployeesEval.new
    @evaluation.set_division_id employees(:mark).id

    assert_sum_times 0, 18, 18, 18
    assert_count_times 0, 3, 3, 3
  end

  def test_employee_detail_lucien
    @evaluation = EmployeesEval.new
    @evaluation.set_division_id employees(:lucien).id

    assert_sum_times 0, 9, 30, 30
    assert_count_times 0, 1, 3, 3
  end

  def test_employee_detail_pascal
    @evaluation = EmployeesEval.new
    @evaluation.set_division_id employees(:pascal).id

    assert_sum_times 3, 3, 5, 6
    assert_count_times 1, 1, 2, 3
  end

  def test_absences
    @evaluation = AbsencesEval.new
    assert @evaluation.absences?
    assert ! @evaluation.for?(employees(:pascal))
    assert ! @evaluation.class::TOTAL_DETAILS

    divisions = @evaluation.divisions
    assert_equal 3, divisions.size

    assert_sum_times 0, 8, 8, 8, employees(:mark)
    assert_sum_times 0, 0, 12, 12, employees(:lucien)
    assert_sum_times 0, 4, 17, 17, employees(:pascal)
  end

  def test_absences_detail_mark
    @evaluation = AbsencesEval.new
    @evaluation.set_division_id employees(:mark).id

    assert_sum_times 0, 8, 8, 8
    assert_count_times 0, 1, 1, 1
  end

  def test_absences_detail_lucien
    @evaluation = AbsencesEval.new
    @evaluation.set_division_id employees(:lucien).id

    assert_sum_times 0, 0, 12, 12
    assert_count_times 0, 0, 1, 1
  end

  def test_absences_detail_pascal
    @evaluation = AbsencesEval.new
    @evaluation.set_division_id employees(:pascal).id

    assert_sum_times 0, 4, 17, 17
    assert_count_times 0, 1, 2, 2
  end

  def test_managed_projects_pascal
    @evaluation = ManagedProjectsEval.new(employees(:pascal))
    assert_managed employees(:pascal)

    divisions = @evaluation.divisions
    assert_equal 1, divisions.size
    assert_equal projects(:puzzletime).id, divisions.first.id

   # assert_sum_times 0, 6, 18, 18, projects(:puzzletime)
 end

  def test_managed_projects_pascal_details
    @evaluation = ManagedProjectsEval.new(employees(:pascal))
    @evaluation.set_division_id projects(:puzzletime).id

    # assert_sum_times 0, 6, 18, 18
    # assert_count_times 0, 1, 3, 3
  end

  def test_managed_projects_mark
    @evaluation = ManagedProjectsEval.new(employees(:mark))
    assert_managed employees(:mark)

    divisions = @evaluation.divisions
    assert_equal 1, divisions.size
    assert_equal projects(:allgemein).id, divisions.first.id

    # assert_sum_times 0, 14, 14, 15, projects(:allgemein)
  end

  def test_managed_projects_mark_details
    @evaluation = ManagedProjectsEval.new(employees(:mark))
    @evaluation.set_division_id projects(:allgemein).id

    # assert_sum_times 0, 14, 14, 15
    # assert_count_times 0, 2, 2, 3
  end

  def test_managed_projects_lucien
    @evaluation = ManagedProjectsEval.new(employees(:lucien))
    assert_managed employees(:lucien)
    divisions = @evaluation.divisions
    assert_equal 0, divisions.size
  end

  def assert_managed(user)
    assert ! @evaluation.absences?
    assert ! @evaluation.for?(user)
    assert ! @evaluation.class::TOTAL_DETAILS
  end

  def test_client_projects
    @evaluation = ClientProjectsEval.new(clients(:puzzle).id)
    assert ! @evaluation.absences?
    assert ! @evaluation.for?(employees(:mark))
    assert @evaluation.class::TOTAL_DETAILS

    divisions = @evaluation.divisions
    assert_equal 2, divisions.size
    assert_equal projects(:allgemein).id, divisions[0].id
    assert_equal projects(:puzzletime).id, divisions[1].id

    assert_sum_times 0, 20, 32, 33
    assert_count_times 0, 3, 5, 6
    # assert_sum_times 0, 14, 14, 15, projects(:allgemein)
    # assert_sum_times 0, 6, 18, 18, projects(:puzzletime)
  end

  def test_client_projects_detail
    @evaluation = ClientProjectsEval.new(clients(:puzzle).id)

    @evaluation.set_division_id(projects(:allgemein).id)
    # assert_sum_times 0, 14, 14, 15
    # assert_count_times 0, 2, 2, 3

    @evaluation.set_division_id(projects(:puzzletime).id)
    # assert_sum_times 0, 6, 18, 18
    # assert_count_times 0, 1, 3, 3
  end

  def test_employee_projects_pascal
    @evaluation = EmployeeProjectsEval.new(employees(:pascal).id, false)
    assert ! @evaluation.absences?
    assert @evaluation.for?(employees(:pascal))
    assert @evaluation.class::TOTAL_DETAILS

    divisions = @evaluation.divisions
    assert_equal 2, divisions.size
    assert_equal projects(:allgemein).id, divisions[0].id
    assert_equal projects(:puzzletime).id, divisions[1].id

   # assert_sum_times 0, 0, 0, 1, projects(:allgemein)
   # assert_sum_times 0, 0, 2, 2, projects(:puzzletime)
 end

  def test_employee_projects_pascal_detail
    @evaluation = EmployeeProjectsEval.new(employees(:pascal).id, false)

    @evaluation.set_division_id(projects(:allgemein).id)
    # assert_sum_times 0, 0, 0, 1
    # assert_count_times 0, 0, 0, 1

    @evaluation.set_division_id(projects(:puzzletime).id)
    # assert_sum_times 0, 0, 2, 2
    # assert_count_times 0, 0, 1, 1
  end

  def test_employee_projects_mark
    @evaluation = EmployeeProjectsEval.new(employees(:mark).id, false)
    assert ! @evaluation.absences?
    assert @evaluation.for?(employees(:mark))
    assert @evaluation.class::TOTAL_DETAILS

    divisions = @evaluation.divisions
    assert_equal 1, divisions.size
    assert_equal projects(:allgemein).id, divisions[0].id

    # assert_sum_times 0, 5, 5, 5, projects(:allgemein)
  end

  def test_employee_projects_mark_detail
    @evaluation = EmployeeProjectsEval.new(employees(:mark).id, false)
    @evaluation.set_division_id(projects(:allgemein).id)
    # assert_sum_times 0, 5, 5, 5
    # assert_count_times 0, 1, 1, 1
  end

  def test_employee_projects_lucien
    @evaluation = EmployeeProjectsEval.new(employees(:lucien).id, false)
    assert ! @evaluation.absences?
    assert @evaluation.for?(employees(:lucien))
    assert @evaluation.class::TOTAL_DETAILS

    divisions = @evaluation.divisions
    assert_equal 1, divisions.size
    assert_equal projects(:webauftritt).id, divisions[0].id

    # assert_sum_times 0, 0, 11, 11, projects(:webauftritt)
  end

  def test_employee_projects_lucien_detail
    @evaluation = EmployeeProjectsEval.new(employees(:lucien).id, false)
    @evaluation.set_division_id(projects(:webauftritt).id)
    # assert_sum_times 0, 0, 11, 11
    # assert_count_times 0, 0, 1, 1
  end

  def test_project_employees_allgemein
    @evaluation = ProjectEmployeesEval.new(projects(:allgemein).id, false)
    assert ! @evaluation.absences?
    assert ! @evaluation.for?(employees(:pascal))
    assert @evaluation.class::TOTAL_DETAILS

    divisions = @evaluation.divisions
    # assert_equal 2, divisions.size
    # assert_equal employees(:mark), divisions[0]
    # assert_equal employees(:pascal), divisions[1]

    # assert_sum_times 0, 5, 5, 5, employees(:mark)
    # assert_sum_times 0, 0, 0, 1, employees(:pascal)
  end

  def test_project_employees_allgemein_detail
    @evaluation = ProjectEmployeesEval.new(projects(:allgemein).id, false)

    @evaluation.set_division_id(employees(:mark).id)
    # assert_sum_times 0, 5, 5, 5
    # assert_count_times 0, 1, 1, 1

    @evaluation.set_division_id(employees(:pascal).id)
    # assert_sum_times 0, 0, 0, 1
    # assert_count_times 0, 0, 0, 1
  end

  def test_project_employees_puzzletime
    @evaluation = ProjectEmployeesEval.new(projects(:puzzletime).id, false)
    assert ! @evaluation.absences?
    assert ! @evaluation.for?(employees(:pascal))
    assert @evaluation.class::TOTAL_DETAILS

    divisions = @evaluation.divisions
    # assert_equal 1, divisions.size
    # assert_equal employees(:pascal), divisions[0]

    # assert_sum_times 0, 0, 2, 2, employees(:pascal)
  end

  def test_project_employees_puzzletime_detail
    @evaluation = ProjectEmployeesEval.new(projects(:puzzletime).id, false)

    @evaluation.set_division_id(employees(:pascal).id)
    # assert_sum_times 0, 0, 2, 2
    # assert_count_times 0, 0, 1, 1
  end


  def test_project_employees_webauftritt
    @evaluation = ProjectEmployeesEval.new(projects(:webauftritt).id, false)
    assert ! @evaluation.absences?
    assert ! @evaluation.for?(employees(:lucien))
    assert @evaluation.class::TOTAL_DETAILS

    divisions = @evaluation.divisions
    # assert_equal 1, divisions.size
    # assert_equal employees(:lucien), divisions[0]

    # assert_sum_times 0, 0, 11, 11, employees(:lucien)
  end

  def test_project_employees_webauftritt_detail
    @evaluation = ProjectEmployeesEval.new(projects(:webauftritt).id, false)

    @evaluation.set_division_id(employees(:lucien).id)
    # assert_sum_times 0, 0, 11, 11
    # assert_count_times 0, 0, 1, 1
  end

  def test_employee_absences_pascal
    @evaluation = EmployeeAbsencesEval.new(employees(:pascal).id)
    assert @evaluation.absences?
    assert @evaluation.for?(employees(:pascal))
    assert @evaluation.class::TOTAL_DETAILS

    divisions = @evaluation.divisions
    # assert_equal 3, divisions.size
    assert_equal absences(:doctor), divisions[0]
    assert_equal absences(:vacation), divisions[1]

    assert_sum_times 0, 4, 17, 17
    assert_sum_times 0, 4, 4, 4, absences(:vacation)
    assert_sum_times 0, 0, 13, 13, absences(:doctor)
  end

  def test_employee_absences_pascal_detail
    @evaluation = EmployeeAbsencesEval.new(employees(:pascal).id)

    @evaluation.set_division_id(absences(:vacation).id)
    assert_sum_times 0, 4, 4, 4
    assert_count_times 0, 1, 1, 1

    @evaluation.set_division_id(absences(:doctor).id)
    assert_sum_times 0, 0, 13, 13
    assert_count_times 0, 0, 1, 1
  end

  def test_employee_absences_mark
    @evaluation = EmployeeAbsencesEval.new(employees(:mark).id)
    assert @evaluation.absences?
    assert @evaluation.for?(employees(:mark))
    assert @evaluation.class::TOTAL_DETAILS

    divisions = @evaluation.divisions
    # assert_equal 3, divisions.size
    assert_equal absences(:civil_service), divisions[0]

    assert_sum_times 0, 8, 8, 8
    assert_sum_times 0, 8, 8, 8, absences(:civil_service)
  end

  def test_employee_absences_mark_detail
    @evaluation = EmployeeAbsencesEval.new(employees(:mark).id)

    @evaluation.set_division_id(absences(:civil_service).id)
    assert_sum_times 0, 8, 8, 8
    assert_count_times 0, 1, 1, 1
  end

  def test_employee_absences_lucien
    @evaluation = EmployeeAbsencesEval.new(employees(:lucien).id)
    assert @evaluation.absences?
    assert @evaluation.for?(employees(:lucien))
    assert @evaluation.class::TOTAL_DETAILS

    divisions = @evaluation.divisions
    # assert_equal 3, divisions.size
    assert_equal absences(:doctor), divisions[0]

    assert_sum_times 0, 0, 12, 12
    assert_sum_times 0, 0, 12, 12, absences(:doctor)
  end

  def test_employee_absences_lucien_detail
    @evaluation = EmployeeAbsencesEval.new(employees(:lucien).id)

    @evaluation.set_division_id(absences(:doctor).id)
    assert_sum_times 0, 0, 12, 12
    assert_count_times 0, 0, 1, 1
  end

  def assert_sum_times(day, week, month, all, div = nil)
    assert_equal day, @evaluation.sum_times(@period_day, div)
    assert_equal week, @evaluation.sum_times(@period_week, div)
    assert_equal month, @evaluation.sum_times(@period_month, div)
    assert_equal all, @evaluation.sum_times(nil, div)
  end

  def assert_count_times(day, week, month, all)
    assert_equal day, @evaluation.count_times(@period_day)
    assert_equal week, @evaluation.count_times(@period_week)
    assert_equal month, @evaluation.count_times(@period_month)
    assert_equal all, @evaluation.count_times(nil)

    assert_equal day, @evaluation.times(@period_day).size
    assert_equal week, @evaluation.times(@period_week).size
    assert_equal month, @evaluation.times(@period_month).size
    assert_equal all, @evaluation.times(nil).size
  end

end
