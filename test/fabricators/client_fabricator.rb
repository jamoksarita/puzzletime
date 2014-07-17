# encoding: UTF-8
# == Schema Information
#
# Table name: clients
#
#  id           :integer          not null, primary key
#  name         :string(255)      not null
#  shortname    :string(4)        not null
#  work_item_id :integer
#

Fabricator(:client) do
  name { Faker::Company.name }
  shortname { ('A'..'Z').to_a.shuffle.take(4).join }
end
