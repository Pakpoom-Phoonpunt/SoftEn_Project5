class Movie < ActiveRecord::Base
  has_many :reviews
  has_many :moviegoers, :through => :reviews

  scope :with_good_reviews, lambda { |threshold|
    Movie.joins(:reviews).group(:movie_id).
      having(['AVG(reviews.potatoes) > ?', threshold.to_i])
  }
  scope :for_kids, lambda {
    Movie.where('rating in (?)', %w(G PG))
  }
  def self.all_ratings ; %w[ - G PG PG-13 R NC-17 NR ] ; end #  shortcut: array of strings
  before_save :capitalize_title
  def capitalize_title
    self.title = self.title.split(/\s+/).map(&:downcase).
      map(&:capitalize).join(' ')
  end
    validates :title, :presence => true
    validates :release_date, :presence => true
    validate :released_1930_or_later 
    # validates :rating, :inclusion => {:in => Movie.all_ratings},
    #   :unless => :grandfathered?
      
    def released_1930_or_later
      errors.add(:release_date, 'must be 1930 or later') if
        release_date && release_date < Date.parse('1 Jan 1930')
    end
    @@grandfathered_date = Date.parse('1 Nov 1968')

    def grandfathered?
      release_date && release_date < @@grandfathered_date
    end

    class Movie::InvalidKeyError < StandardError ; end

    def self.find_in_tmdb(string)
			begin
				Tmdb::Movie.find(string)
			rescue Tmdb::InvalidApiKeyError
				raise Movie::InvalidKeyError, 'Invalid API key'		
			end
    end
    def self.find_by_id_tmdb(id)
      Tmdb::Movie.detail(id)
    end
    def self.find_rating(id)
      detail = Tmdb::Movie.releases(id)
      @rating = ""
      detail["countries"].each{|tmp| 
      if tmp["iso_3166_1"]==="US" 
        @rating = tmp["certification"]
      end};
      return @rating
    end 
      
      #detail["countries"].each {|selected_list| if selected_list["iso_3166_1"] === "US"}
end
