require 'spec_helper'
require 'ostruct'

describe User do

  context "google oauth" do
    let(:provider) { "google" }
    let(:uid) { "abcdef123456" }
    let(:auth) { OpenStruct.new(provider: provider, uid: uid, extra: auth_info) }
    let(:auth_info) { OpenStruct.new(raw_info: OpenStruct.new(email: email, name: "Neon")) }
    let(:email) { "neon@example.com" }

    it "finds an existing authorized user" do
      user = FactoryGirl.create(:user, provider: provider, uid: uid)

      found_user = User.find_for_google_oauth2(auth)

      expect(found_user).to eq(user)
      expect(found_user.authentication_token).to_not eq(nil)
    end

    it "finds and updates existing unauthorized user by email" do
      user = FactoryGirl.create(:user, email: email)

      found_user = User.find_for_google_oauth2(auth)

      expect(found_user).to eq(user)
      expect(found_user.provider).to eq(provider)
      expect(found_user.uid).to eq(uid)
      expect(found_user.authentication_token).to_not eq(nil)
    end

    it "creates a new authorized user if from neo.com domain" do
      pending "this behavior is wrong now"

      new_email = auth_info.raw_info.email = 'neon@neo.com'

      expect {
        found_user = User.find_for_google_oauth2(auth)
        expect(found_user.provider).to eq(provider)
        expect(found_user.uid).to eq(uid)
        expect(found_user.name).to eq('Neon')
        expect(found_user.email).to eq(new_email)
        expect(found_user.authentication_token).to_not eq(nil)
      }.to change(User, :count).by(1)

    end

    it "does nothing if a new authorized user isn't from a neo.com domain" do
       new_email = auth_info.raw_info.email = 'neon@totally_something_else.com'

       expect {
         nil_user = User.find_for_google_oauth2(auth)
         expect(nil_user).to eq(nil)
       }.to_not change(User, :count)
    end
  end

end
