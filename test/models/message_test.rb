require "test_helper"

class MessageTest < ActiveSupport::TestCase
  def setup
    # テスト用のユーザーを作成
    @industry = Industry.create!(name: "IT")

    # 企業を作成
    @company = Company.create!(
      name: "テスト株式会社",
      email: "company@example.com",
      industry: @industry
    )

    # 採用担当者用のユーザーとレコード
    @recruiter_user = User.create!(
      email: "recruiter@example.com",
      password: "password",
      password_confirmation: "password",
      role: "recruiter"
    )

    @recruiter = Recruiter.create!(
      user: @recruiter_user,
      company: @company,
      name: "採用担当者"
    )

    # 学生用のユーザーとレコード
    @student_user = User.create!(
      email: "student@example.com",
      password: "password",
      password_confirmation: "password",
      role: "student"
    )

    @student = Student.create!(
      user: @student_user,
      name: "テスト学生"
    )

    # 別の学生用のユーザーとレコード（ロールテスト用）
    @another_student_user = User.create!(
      email: "another_student@example.com",
      password: "password",
      password_confirmation: "password",
      role: "student"
    )

    @another_student = Student.create!(
      user: @another_student_user,
      name: "別のテスト学生"
    )

    # 別の採用担当者用のユーザーとレコード（ロールテスト用）
    @another_recruiter_user = User.create!(
      email: "another_recruiter@example.com",
      password: "password",
      password_confirmation: "password",
      role: "recruiter"
    )

    @another_recruiter = Recruiter.create!(
      user: @another_recruiter_user,
      company: @company,
      name: "別の採用担当者"
    )
  end

  test "should be valid with valid sender, receiver and content" do
    message = Message.new(
      sender: @student_user,
      receiver: @recruiter_user,
      content: "テストメッセージ内容"
    )
    assert message.valid?, "Message with valid attributes should be valid"
  end

  test "should not be valid without content" do
    message = Message.new(
      sender: @student_user,
      receiver: @recruiter_user,
      content: nil
    )
    assert_not message.valid?, "Message without content should not be valid"
    assert_includes message.errors[:content], "can't be blank"
  end

  test "should not be valid without sender" do
    message = Message.new(
      receiver: @recruiter_user,
      content: "テストメッセージ内容"
    )
    assert_not message.valid?, "Message without sender should not be valid"
  end

  test "should not be valid without receiver" do
    message = Message.new(
      sender: @student_user,
      content: "テストメッセージ内容"
    )
    assert_not message.valid?, "Message without receiver should not be valid"
  end

  test "should not allow messages between users with same role (students)" do
    message = Message.new(
      sender: @student_user,
      receiver: @another_student_user,
      content: "テストメッセージ内容"
    )
    assert_not message.valid?, "Message between two students should not be valid"
    assert_includes message.errors[:base], "must be different roles"
  end

  test "should not allow messages between users with same role (recruiters)" do
    message = Message.new(
      sender: @recruiter_user,
      receiver: @another_recruiter_user,
      content: "テストメッセージ内容"
    )
    assert_not message.valid?, "Message between two recruiters should not be valid"
    assert_includes message.errors[:base], "must be different roles"
  end

  test "conversation_between scope should return messages in correct order" do
    # メッセージを3つ作成（順番がランダムになるように）
    msg1 = Message.create!(
      sender: @student_user,
      receiver: @recruiter_user,
      content: "こんにちは",
      created_at: 2.hours.ago
    )

    msg3 = Message.create!(
      sender: @student_user,
      receiver: @recruiter_user,
      content: "ありがとうございます",
      created_at: Time.current
    )

    msg2 = Message.create!(
      sender: @recruiter_user,
      receiver: @student_user,
      content: "お元気ですか？",
      created_at: 1.hour.ago
    )

    # conversation_betweenスコープを使用して会話を取得
    conversation = Message.conversation_between(@student_user, @recruiter_user)

    # 正しい順序で取得されているか確認
    assert_equal [ msg1, msg2, msg3 ], conversation.to_a
  end

  test "conversation_between should include messages from both directions" do
    # 学生から採用担当者へのメッセージ
    msg1 = Message.create!(
      sender: @student_user,
      receiver: @recruiter_user,
      content: "こんにちは"
    )

    # 採用担当者から学生へのメッセージ
    msg2 = Message.create!(
      sender: @recruiter_user,
      receiver: @student_user,
      content: "お元気ですか？"
    )

    # 別の会話（含まれないはず）
    Message.create!(
      sender: @student_user,
      receiver: @another_recruiter_user,
      content: "別の会話です"
    )

    # conversation_betweenスコープを使用して会話を取得
    conversation = Message.conversation_between(@student_user, @recruiter_user)

    # 正しいメッセージが含まれているか確認
    assert_equal 2, conversation.count
    assert_includes conversation, msg1
    assert_includes conversation, msg2
  end
end
