# == Schema Information
#
# Table name: reservations
#
#  id          :integer          not null, primary key
#  start_time  :datetime
#  end_time    :datetime
#  type_flag   :string(255)
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  status      :string(255)
#

require 'spec_helper'

describe Reservation do
  before { @reservation = Reservation.new(start_time: "2013-12-12 10:00am", end_time: "2013-12-12 10:30am", type_flag: "Reserved", description: "") }
  
  subject { @reservation }
  
  it { should respond_to(:start_time) }
  it { should respond_to(:end_time) }
  it { should respond_to(:type_flag) }
  it { should respond_to(:description) }
  it { should respond_to(:conflict_id) }

  it { should be_valid }

	describe "when start_time is not present" do
    before { @reservation.start_time = "" }
    
    it { should_not be_valid }
	end

	describe "when end_time is not present" do
    before { @reservation.end_time = "" }
    
    it { should_not be_valid }
	end

	describe "when type is not present" do
		before { @reservation.type_flag = "" }
    
    it { should_not be_valid }
	end

	describe "when type is not in defined list" do
		before { @reservation.type_flag = "Not in list"}

		it { should_not be_valid }
	end
end
