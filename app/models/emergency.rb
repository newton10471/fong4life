class Emergency
  include Mongoid::Document
  include Mongoid::Timestamps
  #include Mongoid::Versioning
  has_one :donation, as: :eventable
  embeds_many :pending_matches, class_name: "Donor", store_as: 'pending_matches'
  embeds_many :contacted_matches, class_name: "Donor", store_as: 'contacted_matches'

  
  field :title, type: String
  field :description, type: String
  field :sms_message_text, type: String
  field :created_by, type: String
  field :match_found, type: Boolean, default: false
  field :match_details, type: String
  field :blood_group, type: String
  field :status, type: String

  #TODO: Add a EmergencyComments; so emergency has_many comments
  
  after_create :set_status_to_draft, :populate_matches
  
  BATCH_SIZE = 5
  
  STATUS_DRAFT = 'draft'
  STATUS_ACTIVE = 'active'
  STATUS_CLOSE = 'closed'
  
  def set_status_to_draft
    self.status = STATUS_DRAFT
    self.save
  end
  
  def populate_matches
    # picks out a bunch of matches given criteria, and populates the pending matches list
    if self.blood_group == Donor::BLOOD_TYPE_UNIVERSAL_RECIPIENT 
      donors = Donor.all
    else
      donors = Donor.in(blood_group: [self.blood_group, Donor::BLOOD_TYPE_UNIVERSAL_DONOR])
    end
    # TODO: Fancy sorting happens here
    self.pending_matches = donors
  end
  
  def contact_matches(batch_size = BATCH_SIZE)
    # contact some or possibly all of the people we just selected out, depending on
    # batch size and move them to the contacted matches list
    count = 0
    while ((self.pending_matches.count > 0) && (count < batch_size)) do
      current_donor = self.pending_matches.pop
      #      current_donor.contact(self) #TODO: SMS Sending here; need to implement
      self.contacted_matches << current_donor
      count += 1
    end    
    self.save
  end
  
  def close_emergency(donor_found, donor_details)
    # set donor found
    # set donor_details if any
  end
  
end