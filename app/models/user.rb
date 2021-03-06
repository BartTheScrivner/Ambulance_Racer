class User < ApplicationRecord

    has_many :accepted_requests, foreign_key: :lawyer_id, class_name: 'Request'
    has_many :clients, through: :accepted_requests
    
    has_many :requests, foreign_key: :client_id, class_name: 'Request'
    has_many :lawyers, through: :requests

    has_many :consults, through: :requests
    has_many :consults, through: :accepted_requests

    #before save to database, downcase all emails in case two emails are same
    before_save { self.email = email.downcase } 

    #user only gets made if name less than 50 chars., and present
    validates :name,  presence: true, length: { maximum: 50 }
    #set to constant and uses REGEX to filter correct email formats
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
    #validates email is valid format and not already used (i.e. unique)
    validates :email, presence:   true, length: { maximum: 255 },
                      format:     { with: VALID_EMAIL_REGEX },
                      uniqueness: { case_sensitive: false }
    has_secure_password
    validates :password, presence: true, length: { minimum: 6 }

    def self.lawyers
        User.all.where(lawyer: true)
    end

    def self.clients
        User.all.where(lawyer: false)
    end

    def client_requests
        Request.all.where(client_id: self.id)
    end

    def current_or_lawyer?(arg)
        self == arg || self.lawyer
    end

    def format_phone_number(phone_num)
        pn_chunks = phone_num.split(/[\ ,(,),-]/).reject{|s| s.empty?}
        pn_chunks[0].prepend('(').concat(')') + pn_chunks[1..2].join('-')
    end

    def client_notification_count
        self.requests.where.not(lawyer_id: nil).count
    end

    def lawyer_notification_count
        self.accepted_requests.count
    end

    def pending_requests
        self.consults.where.not(status: 'completed')
    end

    def pending_count
        self.pending_requests.count
    end

end
