# encoding: utf-8
# == Schema Information
#
# Table name: employments
#
#  id                     :integer          not null, primary key
#  employee_id            :integer
#  percent                :decimal(5, 2)    not null
#  start_date             :date             not null
#  end_date               :date
#  vacation_days_per_year :decimal(5, 2)
#

require 'test_helper'

class EmploymentTest < ActiveSupport::TestCase
  def test_musttime
    half_year = Employment.find(1)
    assert_equal half_year.period.length, 184
    assert_equal half_year.period.musttime, 127 * 8
    assert_equal half_year.percent_factor, 1
    assert_in_delta 12.59, half_year.vacations, 0.005
    assert_equal half_year.musttime, 127 * 8

    various = Employment.find(2)
    assert_equal various.period.length, 92
    assert_equal various.period.musttime, 64 * 8
    assert_equal various.percent_factor, 0.4
    assert_in_delta 2.52, various.vacations, 0.005
    assert_equal various.musttime, 64 * 8 * 0.4

    open_end = Employment.find(4)
    open_end.end_date = Date.new(2006, 12, 31)
    assert_equal open_end.period.length, 107
    assert_equal open_end.period.musttime, 73 * 8
    assert_equal open_end.percent_factor, 1
    assert_in_delta 7.32, open_end.vacations, 0.005
    assert_equal open_end.musttime, 73 * 8

    with_vacations = Employment.find(3)
    assert_equal with_vacations.period.length, 227
    assert_in_delta 3.73, with_vacations.vacations, 0.005
  end

  def test_musttime_for_period
    period = Period.new("1.9.2007", "30.9.2007")

    assert_equal period.musttime, employments(:various_100).musttime(period)
    assert_equal period.musttime * 0.9, employments(:long_time).musttime(period)
  end

  def test_periods_must_not_overlap
    employee = Employee.find(6)
    one = Employment.create!(employee: employee, start_date: '1.1.2015', end_date: '31.5.2015', percent: 80)
    two = Employment.create!(employee: employee, start_date: '1.6.2015', percent: 100)

    open_end = Employment.new(employee: employee, start_date: '1.3.2015', percent: 50)
    assert_not_valid open_end, :base

    closed = Employment.new(employee: employee, start_date: '1.3.2015', end_date: '31.3.2015', percent: 50)
    assert_not_valid closed, :base

    before = Employment.new(employee: employee, start_date: '1.1.2014', end_date: '31.12.2014', percent: 50)
    assert_valid before

    after = Employment.new(employee: employee, start_date: '1.9.2015', percent: 50)
    assert_valid after
  end

  def test_updates_previous_end_date
    employee = Employee.find(6)
    one = Employment.create!(employee: employee, start_date: '1.1.2015', end_date: '31.5.2015', percent: 80)
    two = Employment.create!(employee: employee, start_date: '1.6.2015', percent: 100)

    after = Employment.create(employee: employee, start_date: '1.9.2015', end_date: '31.12.2015', percent: 50)
    assert_equal Date.parse('31.8.2015'), two.reload.end_date

    after2 = Employment.create(employee: employee, start_date: '1.3.2016', percent: 50)
    assert_equal Date.parse('31.12.2015'), after.reload.end_date

    before = Employment.create!(employee: employee, start_date: '1.1.2014', percent: 50)
    assert_equal Date.parse('31.12.2014'), before.end_date

    before2 = Employment.create!(employee: employee, start_date: '1.1.2013', end_date: '1.6.2013', percent: 50)
    assert_equal Date.parse('1.6.2013'), before2.end_date
  end
end
