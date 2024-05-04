# frozen_string_literal: true

RSpec.describe Topic do
  let!(:topic) { Fabricate(:topic) }
  let!(:post) { Fabricate(:post, topic: topic) }
  let!(:reply) { Fabricate(:post, topic: topic) }

  describe "has_one highest_post" do
    it "finds the highest post" do
      Topic.reset_all_highest!
      topic.reload
      expect(topic.highest_post.id).to eq(reply.id)
    end
    it "does not include whispers as highest post" do
      another_reply = Fabricate(:post, topic: topic)
      Fabricate(:post, topic: topic, post_type: Post.types[:whisper])
      Topic.reset_all_highest!
      topic.reload
      expect(topic.highest_post.id).to eq(another_reply.id)
    end
  end
end
