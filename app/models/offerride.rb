class Offerride < ActiveRecord::Base
  attr_accessible :cost, :date, :destination, :source, :time, :user_id, :seatsleft, :totalseats, :contactnum
  belongs_to :user
  has_many :bookrides, dependent: :destroy

  before_save { |offerride| offerride.source = source.downcase }
  before_save { |offerride| offerride.destination = destination.downcase }

  validates :source, presence: true
  validates :destination, presence: true
  validates :time, presence: true
  validates :date, presence: true
  validates :cost, presence: true
  validates :contactnum, presence: true, length: { minimum:10 }
  validates :totalseats, presence: true
  before_create :set_seatsleft
  before_save :validate_date
  before_save :validate_time
  before_save :validate_src_dest


  def validate_date
    if Date.parse(date) < Date.today
      errors.add(:date, " can't be in the past")
      return false
    end
  end

  def validate_time
    if Date.parse(date) == Date.today && Time.parse(time) < Time.now
      errors.add(:time, "Time can't be in the past")
      return false
    end
  end

  def validate_src_dest
    if source == destination
      errors.add(:time, "Source and destination can't be same")
      return false
    end
  end

  def set_seatsleft
    if self.totalseats <= 0
     errors.add(:totalseats, "cannot be negative or zero")
     return false
    else
      self.seatsleft = self.totalseats
    end
  end
end
