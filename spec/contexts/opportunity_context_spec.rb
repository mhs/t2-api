require 'spec_helper'

describe 'OpportunityContext' do
  let(:person) {FactoryGirl.create(:person)}
  let(:another_person) { FactoryGirl.create(:person, email: 'another_person@neo.com') }
  let(:company) { FactoryGirl.create(:company) }
  let(:office) {FactoryGirl.create(:office)}

  before do
    3.times do
      FactoryGirl.create(:opportunity, person: person)
    end
  end

  describe 'create_opportunity' do

    it 'should create with default values' do
      opportunity = OpportunityContext.new(person).create_opportunity[:object]
      opportunity.title.should eq "#{person.name}'s new opportunity"
      opportunity.person.should eq person
      opportunity.confidence.should eq 'warm'
      opportunity.stage.should eq 'idea'
      opportunity.office.id.should eq person.office.id
    end

    it 'should allow to include office' do
      opportunity = OpportunityContext.new(person, {office: office.id}).create_opportunity[:object]
      opportunity.office.id.should eq office.id
    end

    it 'should allow to include description' do
      opportunity = OpportunityContext.new(person, {description: 'long project description'}).create_opportunity[:object]
      opportunity.description.should eq Opportunity.last.description
    end

    it 'should use an existent company' do
      opportunity = OpportunityContext.new(person, {company: company.id}).create_opportunity[:object]
      opportunity.company.should eq company
    end

    it 'should allow to assign a different owner' do
      opportunity = OpportunityContext.new(person, {owner: another_person.id, title: 'some title', confidence: 'hot'}).create_opportunity[:object]
      opportunity.title.should eq 'some title'
      opportunity.confidence.should eq 'hot'
      opportunity.person.should eq another_person
    end

    it 'should transform correctly date, DD-MM-YYYY format' do
      opportunity = OpportunityContext.new(person, {title: 'some title', expected_date_close: '13-11-2013'}).create_opportunity[:object]
      opportunity.title.should eq 'some title'
      opportunity.expected_date_close.day.should eq 13
    end

    describe 'contacts' do
      let(:another_company) { FactoryGirl.create(:company) }
      let(:contact) { FactoryGirl.create(:contact, company: another_company) }
      let(:orphan_contact) { FactoryGirl.create(:contact, company: nil) }
      let(:another_contact) { FactoryGirl.create(:contact, company: company, name: 'foo') }

      it 'should use an existent contact' do
        opportunity = OpportunityContext.new(person, {contact: contact.id}).create_opportunity[:object]
        opportunity.contact.should eq contact
        opportunity.company.should eq another_company
      end

      it 'should use an existent company and an existent contact' do
        opportunity = OpportunityContext.new(person, {contact: contact.id, company: company.id}).create_opportunity[:object]
        opportunity.contact.should eq contact
        opportunity.company.should eq company
      end

      it 'should associate contact to existent company' do
        
        opportunity = OpportunityContext.new(person, {contact: another_contact.id, company: company.id}).create_opportunity[:object]
        opportunity.contact.email.should eq another_contact.email
        opportunity.contact.company.should eq company
        opportunity.company.should eq company
      end

      it 'should not associate to company if it does not exist' do
        opportunity = OpportunityContext.new(person, {contact: orphan_contact.id}).create_opportunity[:object]
        opportunity.contact.email.should eq orphan_contact.email
        opportunity.contact.company.should eq nil
        opportunity.company.should eq nil
      end
    end
  end

  describe 'update opportunity' do
    let(:acme_company) { FactoryGirl.create(:company, name: 'acme inc') }

    it 'should update correctly' do
      opportunity = OpportunityContext.new(person, {company: acme_company.id, title: 'ux workshop', owner: another_person.id, confidence: 'hot'}).update_opportunity(Opportunity.last.id)[:object]
      opportunity.title.should eq 'ux workshop'
      opportunity.confidence.should eq 'hot'
      opportunity.person.should eq another_person
      opportunity.company.name.should eq 'acme inc'
    end
  end

  it 'delete opportunity' do
    opportunity = OpportunityContext.new(person).destroy_opportunity(Opportunity.last.id)
    Opportunity.count.should eq 2
  end
end
