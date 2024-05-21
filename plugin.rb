# frozen_string_literal: true

# name: discourse-highest-post
# about: Adds hightest_post_excerpt to TopicListItem serializer
# version: 0.0.1
# authors: dsims
# url: https://github.com/dsims/discourse-highest-post
# required_version: 2.7.0

after_initialize do
  module ::HighestPost
    def self.prepended(base)
      base.has_one :highest_post,
                   ->(topic) do
                     if topic.highest_post_number > 1
                       where(post_number: topic.highest_post_number)
                     else
                       Post.none
                     end
                   end,
                   class_name: "Post"
    end
  end

  def addHighestPostExcerptToSerializer(serializer)
    add_to_serializer(serializer, :highest_post_excerpt) do
      content = Nokogiri::HTML.parse(object.highest_post&.cooked).css('p').first&.text || ""
      ActionController::Base.helpers.strip_tags(
        content
      )[0..SiteSetting.post_excerpt_maxlength]
    end
  end

  Topic.prepend HighestPost
  register_topic_preloader_associations(:highest_post)
  addHighestPostExcerptToSerializer(:topic_list_item)
  addHighestPostExcerptToSerializer(:search_topic_list_item)
end
