class Api::V1::MessagesController < ApplicationController
  include AuthenticationConcern

  before_action :authenticate_user!

  def create
    message = Message.new(
      sender: current_user,
      receiver: User.find_by(id: message_params[:receiver_id]),
      content: message_params[:content]
    )

    if message.save
      render json: {
        message: "Message sent successfully",
        content: message.as_json(
          except: [ :created_at, :updated_at ],
          include: {
            sender: { only: [ :id, :name ] },
            receiver: { only: [ :id, :name ] }
          }
        )
      }, status: :created
    else
      render json: { errors: message.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def conversation
    @partner = User.find_by(id: params[:partner_id])
    message = Message.conversation_between(current_user, @partner)

    render json: {
      messages: message.as_json(
        except: [ :created_at, :updated_at ],
        include: {
          sender: { only: [ :id, :name ] },
          receiver: { only: [ :id, :name ] }
        }
      ) }, status: :ok
  end

  def partners
    messages = Message.where(sender_id: current_user.id).or(Message.where(receiver_id: current_user.id))
    partner_ids = messages.map do |m|
      m.sender_id == current_user.id ? m.receiver_id : m.sender_id
    end.uniq

    users = User.where(id: partner_ids).includes(student: {}, recruiter: :company)

    partners = users.map do |user|
      {
        id: user.id,
        name: user.name,
        company_name: user.company_name
      }
    end

    render json: { partners: partners }, status: :ok
  end

  private

  def message_params
    params.require(:message).permit(:receiver_id, :content)
  end
end
