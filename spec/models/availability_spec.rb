describe Availability do

  let(:person) { FactoryGirl.create(:person) }
  let(:start_date) { Date.today }
  let(:end_date) { Date.today + 1.week }
  describe ".available_dates" do
    let(:dates) { Availability.new(person_id: person.id, start_date: start_date, end_date: end_date).available_dates }
    context "the person isn't allocated during the specified dates" do
      it "returns the specified dates" do
      end
    end

    context "the person is allocated during the specified dates" do
      let(:project) { FactoryGirl.create(:project, :billable) }
      let(:allocation) { FactoryGirl.create(:allocation, :active, project: project, person: person) }
      it "returns date ranges for any times that the person isn't allocated" do

      end
    end

  end
end

