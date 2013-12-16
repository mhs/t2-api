require 'spec_helper'

describe Company do

  before do
    FactoryGirl.create(:company, name: 'foo cia')
  end

  it 'should consider duplicates ignoring case' do
    company = Company.new(name: 'FOO CIA')
    company.valid?.should be_false
  end
end
