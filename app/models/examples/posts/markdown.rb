# == Schema Information
#
# Table name: examples_posts_markdowns
#
#  id         :integer          not null, primary key
#  body       :text             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Examples::Posts::Markdown < ApplicationRecord
end
