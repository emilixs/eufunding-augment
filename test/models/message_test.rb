require "test_helper"

class MessageTest < ActiveSupport::TestCase
  def setup
    @chat = Chat.create!(model_id: "gpt-4.1-nano")
  end

  test "should belong to chat" do
    message = Message.new(chat: @chat, role: "user", content: "Hello")
    assert_respond_to message, :chat
    assert_equal @chat, message.chat
  end

  test "should create message with role and content" do
    message = Message.new(chat: @chat, role: "user", content: "Hello")
    assert message.save
  end

  test "should create message without role" do
    message = Message.new(chat: @chat, content: "Hello")
    assert message.save
  end

  test "should create message without content" do
    message = Message.new(chat: @chat, role: "user")
    assert message.save
  end

  test "should respond to acts_as_message methods" do
    message = Message.create!(chat: @chat, role: "user", content: "Hello")
    assert_respond_to message, :chat
  end
end
