require 'spec_helper'

describe ProjectOffice do
  let(:vacation)  { FactoryGirl.create(:project, :vacation) }
  let(:office)    { FactoryGirl.create(:office) }
  let(:sally)     { FactoryGirl.create(:person, office: office) }
  let(:bob)       { FactoryGirl.create(:person, office: office) }

  it "creates missing project allowances for employees on create" do
    office.people.each { |p| p.should_receive(:create_missing_project_allowances).once }

    office.project_offices.create(allowance: 160, project_id: vacation.id) do |po|
      po.project = vacation
    end
  end

  it "creates missing project allowances for employees on update" do
    proj_office = office.project_offices.create(allowance: 160) do |po|
      po.project = vacation
    end

    office.people.each { |p| p.should_receive(:create_missing_project_allowances).once }

    proj_office.update_attributes(allowance: 33)
  end

end

