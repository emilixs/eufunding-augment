require "test_helper"

class ChatTest < ActiveSupport::TestCase
  test "should create a chat with model_id" do
    chat = Chat.new(model_id: "gpt-4.1-nano")
    assert chat.save
  end

  test "should create a chat without model_id" do
    chat = Chat.new
    assert chat.save
  end

  test "should have many messages" do
    chat = Chat.create!(model_id: "gpt-4.1-nano")
    assert_respond_to chat, :messages
    assert_equal 0, chat.messages.count
  end

  test "should respond to acts_as_chat methods" do
    chat = Chat.create!(model_id: "gpt-4.1-nano")
    assert_respond_to chat, :ask
  end
end
