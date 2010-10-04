class EmployeePlanningGraph

  include PlanningHelper
  
  attr_reader :period, :plannings, :projects, :employee, :overview_graph, :absence_graph
  
  def initialize(employee, period = nil)
    @employee = employee
    period ||= Period.currentMonth
    @actual_period = period
    @period = extend_to_weeks period
    @cache = Hash.new
    @colorMap = AccountColorMapper.new
    @plannings = Planning.all(:conditions => ['employee_id = ? and start_week <= ?', @employee.id, Week::from_date(period.endDate).to_integer] )
    @projects = @plannings.select{|planning| planning.planned_during?(@period)}.collect{|planning| planning.project }.uniq.sort
    absences = Absencetime.all(:conditions => ['employee_id = ? AND work_date >= ? AND work_date <= ?', @employee.id, @period.startDate, @period.endDate])
    @absence_graph = AbsencePlanningGraph.new(absences, @period)
    @overview_graph = EmployeeOverviewPlanningGraph.new(@employee, @plannings, absence_graph, @period)
  end

end