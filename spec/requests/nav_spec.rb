require 'spec_helper'
include Warden::Test::Helpers
Warden.test_mode!

describe "Navigation", type: :feature do
  let!(:application2) { FactoryGirl.create(:t2_application, url: "/navbar", title: "Second App", position: 2) }
  let!(:application1) { FactoryGirl.create(:t2_application, title: "First App", position: 1) }
  let(:user) { FactoryGirl.create(:user) }

  before do
    login_as(user, scope: :user)
    visit root_path
  end

  after do
    Warden.test_reset!
  end

  subject { page }

  it { should have_selector("a[title='#{application1.title}']") }

  it "should be sorted" do
    should have_selector("a[title='#{application1.title}']")
    should have_selector("a[title='#{application2.title}']")
    should have_selector("a[title='#{application1.title}'] ~ a[title='#{application2.title}']")
  end
end
