class Post < ActiveRecord::Base
  belongs_to :user, :inverse_of => :posts
  validates_presence_of :title, :content, :user
  validates_uniqueness_of :slug, :scope => :user_id
  validates_length_of :title, :maximum => 50
  validates :image_url, :uri => true

  before_validation :generate_slug!, :if => 'slug.blank?'
  after_create :notify_twitter

  attr_accessible :title, :content

  def notify_twitter
    Twitter.update(title, content)
  end

  def posted_to_twitter?
    status_id && Twitter.status(status_id)
  end

  def uuid(lim=2**8)
    title.bytes.reduce(&:+) % lim
  end

  def to_param
    slug
  end

  private
  def generate_slug!
    self.slug = [uuid.to_s, title.parameterize].join('-')
  end
end
