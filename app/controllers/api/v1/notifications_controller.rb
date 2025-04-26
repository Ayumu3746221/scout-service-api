class Api::V1::NotificationsController < ApplicationController
  include AuthenticationConcern
  before_action :authenticate_user!

  def index
    @notifications = current_user.notifications.order(created_at: :desc)

    render json: {
      notifications: @notifications.as_json(
        except: [ :updated_at ],
        include: {
          notifiable: {
            only: [ :id, :content ]
          }
        }
      ),
      unread_count: current_user.notifications.unread.count
    }
  end

  def mark_as_read
    @notification = current_user.notifications.find(params[:id])
    @notification.mark_as_read

    render json: { message: "Notification marked as read" }
  end

  def mark_all_as_read
    current_user.notifications.unread.update_all(is_read: true)

    render json: { message: "All notifications marked as read" }
  end
end
