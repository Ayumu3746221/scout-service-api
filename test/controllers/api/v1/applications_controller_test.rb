require "test_helper"

class Api::V1::NotificationsControllerTest < ActionDispatch::IntegrationTest
  def setup
    # テスト用のユーザーを作成
    @user = User.create!(
      email: "test_user@example.com",
      password: "password123",
      password_confirmation: "password123",
      role: "student"
    )

    # 別のユーザーを作成（権限テスト用）
    @other_user = User.create!(
      email: "other_user@example.com",
      password: "password123",
      password_confirmation: "password123",
      role: "student"
    )

    # テスト用の通知を作成
    @notification1 = Notification.create!(
      user: @user,
      content: "最初の通知",
      is_read: false,
      notification_type: "general"
    )

    @notification2 = Notification.create!(
      user: @user,
      content: "2つ目の通知",
      is_read: false,
      notification_type: "new_message"
    )

    # 既読通知を作成
    @read_notification = Notification.create!(
      user: @user,
      content: "既読の通知",
      is_read: true,
      notification_type: "general"
    )

    # 別のユーザーの通知を作成
    @other_notification = Notification.create!(
      user: @other_user,
      content: "別のユーザーの通知",
      is_read: false,
      notification_type: "general"
    )

    # JWT認証トークン取得（ログイン）
    post user_session_path, params: {
      user: {
        email: @user.email,
        password: "password123"
      }
    }, as: :json

    @token = response.headers["Authorization"].split(" ").last

    # 別のユーザーのトークンも取得
    post user_session_path, params: {
      user: {
        email: @other_user.email,
        password: "password123"
      }
    }, as: :json

    @other_token = response.headers["Authorization"].split(" ").last
  end

  test "should get index with notifications" do
    get api_v1_notifications_path,
        headers: { "Authorization" => "Bearer #{@token}" },
        as: :json

    assert_response :success

    json_response = JSON.parse(response.body)

    # 自分の通知のみが含まれていることを確認
    assert_equal 3, json_response["notifications"].length

    # 未読カウントの確認
    assert_equal 2, json_response["unread_count"]

    # 通知が新しい順に並んでいることを確認（created_atの降順）
    notification_ids = json_response["notifications"].map { |n| n["id"] }
    assert_equal [ @read_notification.id, @notification2.id, @notification1.id ].sort.reverse, notification_ids.sort.reverse
  end

  test "should not get notifications without authentication" do
    get api_v1_notifications_path, as: :json

    assert_response :unauthorized
  end

  test "should mark notification as read" do
    patch mark_as_read_api_v1_notification_path(@notification1),
          headers: { "Authorization" => "Bearer #{@token}" },
          as: :json

    assert_response :success

    # 通知が既読になったことを確認
    @notification1.reload
    assert @notification1.is_read

    json_response = JSON.parse(response.body)
    assert_equal "Notification marked as read", json_response["message"]
  end

  test "should not mark other user's notification as read" do
    patch mark_as_read_api_v1_notification_path(@other_notification),
          headers: { "Authorization" => "Bearer #{@token}" },
          as: :json

    assert_response :not_found

    # 通知の状態が変わっていないことを確認
    @other_notification.reload
    assert_not @other_notification.is_read
  end

  test "should mark all notifications as read" do
    patch mark_all_as_read_api_v1_notifications_path,
         headers: { "Authorization" => "Bearer #{@token}" },
         as: :json

    assert_response :success

    # すべての通知が既読になったことを確認
    @notification1.reload
    @notification2.reload
    assert @notification1.is_read
    assert @notification2.is_read

    json_response = JSON.parse(response.body)
    assert_equal "All notifications marked as read", json_response["message"]
  end

  test "should not mark notifications as read without authentication" do
    patch mark_as_read_api_v1_notification_path(@notification1), as: :json

    assert_response :unauthorized

    # 通知の状態が変わっていないことを確認
    @notification1.reload
    assert_not @notification1.is_read
  end
end
