class AIComparisonResult < ApplicationRecord
  belongs_to :occupation_standard

  validates :occupation_standard_id, uniqueness: true

  scope :needs_review, -> { where(needs_review: true) }
  scope :flagged, -> { where("flagged_by_system = ? OR flagged_by_user = ?", true, true) }
  scope :low_score, ->(threshold = 70) { where("overall_score < ?", threshold) }

  def flagged?
    flagged_by_system? || flagged_by_user?
  end

  def update_review_status
    # Automatically mark as needing review if score is low or flagged
    self.needs_review = overall_score.present? && (overall_score < 70 || flagged?)
    save!
  end
end
