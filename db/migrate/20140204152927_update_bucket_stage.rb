class UpdateBucketStage < ActiveRecord::Migration
  def change
    Opportunity.update_all("stage='idea'")
  end
end
