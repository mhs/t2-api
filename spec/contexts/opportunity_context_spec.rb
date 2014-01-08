require 'spec_helper'

describe 'OpportunityContext' do
  let(:person) {FactoryGirl.create(:person)}
  let(:another_person) { FactoryGirl.create(:person, email: 'another_person@neo.com') }
  let(:company) { FactoryGirl.create(:company) }

  before do
    3.times do
      FactoryGirl.create(:opportunity, person: person)
    end

    @opportunity_context = OpportunityContext.new(person)
  end

  describe 'create_opportunity' do

    it 'should create with default values' do
      opportunity = @opportunity_context.create_opportunity
      opportunity.title.should eq "#{person.name}'s new opportunity"
      opportunity.person.should eq person
      opportunity.confidence.should eq 'warm'
      opportunity.stage.should eq 'new'
    end

    it 'should allow to include description' do
      opportunity = @opportunity_context.create_opportunity({description: 'long project description'})
      opportunity.description.should eq Opportunity.last.description
    end

    it 'should create company if it does not exist' do
      opportunity = @opportunity_context.create_opportunity({company: {name: 'company inc'}, confidence: 'cold', title: 'some title'})
      opportunity.title.should eq 'some title'
      opportunity.company.name.should eq 'company inc'
      opportunity.confidence.should eq 'cold'
    end

    it 'should use an existent company' do
      opportunity = @opportunity_context.create_opportunity({company: {name: company.name, id: company.id}})
      opportunity.company.should eq company
    end

    it 'should allow to assign a different owner' do
      opportunity = @opportunity_context.create_opportunity({owner: {id: another_person.id, name: another_person.name}, title: 'some title', confidence: 'hot'})
      opportunity.title.should eq 'some title'
      opportunity.confidence.should eq 'hot'
      opportunity.person.should eq another_person
    end

    it 'should transform correctly date, DD-MM-YYYY format' do
      opportunity = @opportunity_context.create_opportunity({title: 'some title', expected_date_close: '13-11-2013'})
      opportunity.title.should eq 'some title'
      opportunity.expected_date_close.day.should eq 13
    end

    describe 'contacts' do
      let(:another_company) { FactoryGirl.create(:company) }
      let(:contact) { FactoryGirl.create(:contact, company: another_company) }

      it 'should use an existent contact' do
        opportunity = @opportunity_context.create_opportunity({contact: {id: contact.id, name: contact.name, email: contact.email}})
        opportunity.contact.should eq contact
        opportunity.company.should eq another_company
      end

      it 'should use an existent company and an existent company' do
        opportunity = @opportunity_context.create_opportunity({contact: {id: contact.id, name: contact.name, email: contact.email}, company: {id: company.id, name: company.name}})
        opportunity.contact.should eq contact
        opportunity.company.should eq company
      end

      it 'should associate contact to existent company' do
        opportunity = @opportunity_context.create_opportunity({contact: {name: 'foo', email: 'foo@bar.com'}, company: {id: company.id, name: company.name}})
        opportunity.contact.email.should eq 'foo@bar.com'
        opportunity.contact.company.should eq company
        opportunity.company.should eq company
      end

      it 'should not associate to company if it does not exist' do
        opportunity = @opportunity_context.create_opportunity({contact: {name: 'foo', email: 'foo@bar.com'}})
        opportunity.contact.email.should eq 'foo@bar.com'
        opportunity.contact.company.should eq nil
        opportunity.company.should eq nil
      end
    end
  end

  describe 'update opportunity' do

    it 'should update correctly' do
      opportunity = @opportunity_context.update_opportunity(Opportunity.last.id, {company: {name: 'acme inc'}, title: 'ux workshop', owner: {id: another_person.id}, confidence: 'hot'})
      opportunity.title.should eq 'ux workshop'
      opportunity.confidence.should eq 'hot'
      opportunity.person.should eq another_person
      opportunity.company.name.should eq 'acme inc'
    end
  end

  it 'delete opportunity' do
    opportunity = @opportunity_context.destroy_opportunity(Opportunity.last.id)
    Opportunity.count.should eq 2
  end
end
