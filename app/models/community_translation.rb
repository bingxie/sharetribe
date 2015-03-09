# == Schema Information
#
# Table name: community_translations
#
#  id              :integer          not null, primary key
#  community_id    :integer          not null
#  locale          :string(255)      not null
#  translation_key :string(255)      not null
#  translation     :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class CommunityTranslation < ActiveRecord::Base
  validates_presence_of :locale, :translation_key

  attr_accessible :community_id, :translation_key, :locale, :translation
end
