require "test_helper"

class NotificationTest < ActiveSupport::TestCase
  def setup
    # テスト用のユーザーを作成
    @user = User.create!(
      email: "user@example.com",
      password: "password",
      password_confirmation: "password",
      role: "student"
    )

    # テスト用のnotifiableオブジェクト（メッセージ）を作成するための準備
    @recruiter_user = User.create!(
      email: "recruiter@example.com",
      password: "password",
      password_confirmation: "password",
      role: "recruiter"
    )

    # 通知を作成
    @notification = Notification.create!(
      user: @user,
      content: "テスト通知内容",
      is_read: false
    )
  end

  test "should be valid with all required attributes" do
    notification = Notification.new(
      user: @user,
      content: "新しい通知内容",
      is_read: false
    )
    assert notification.valid?, "Notification with all required attributes should be valid"
  end

  test "should not be valid without a user" do
    notification = Notification.new(
      content: "テスト通知内容",
      is_read: false
    )
    assert_not notification.valid?, "Notification without a user should not be valid"
    assert_includes notification.errors[:user], "must exist"
  end

  test "should not be valid without content" do
    notification = Notification.new(
      user: @user,
      is_read: false
    )
    assert_not notification.valid?, "Notification without content should not be valid"
    assert_includes notification.errors[:content], "can't be blank"
  end

  test "should belong to a user" do
    assert_equal @user, @notification.user
  end

  test "should be polymorphic with notifiable" do
    # メッセージを作成
    message = Message.create!(
      sender: @recruiter_user,
      receiver: @user,
      content: "テストメッセージ"
    )

    # メッセージに関連する通知を作成
    notification = Notification.create!(
      user: @user,
      content: "新しいメッセージが届きました",
      is_read: false,
      notifiable: message
    )

    assert_equal message, notification.notifiable
  end

  test "should have unread scope" do
    # 既読の通知を作成
    read_notification = Notification.create!(
      user: @user,
      content: "既読の通知",
      is_read: true
    )

    # 未読スコープで取得
    unread_notifications = Notification.unread

    assert_includes unread_notifications, @notification
    assert_not_includes unread_notifications, read_notification
  end

  test "should have read scope" do
    # 既読の通知を作成
    read_notification = Notification.create!(
      user: @user,
      content: "既読の通知",
      is_read: true
    )

    # 既読スコープで取得
    read_notifications = Notification.read

    assert_includes read_notifications, read_notification
    assert_not_includes read_notifications, @notification
  end

  test "should mark notification as read" do
    assert_not @notification.is_read

    @notification.mark_as_read

    # リロードして最新の状態を取得
    @notification.reload
    assert @notification.is_read
  end
end
