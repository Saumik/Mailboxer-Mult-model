class ConversationsController < ApplicationController
  before_filter :authenicate
  before_filter :find_model, only: [:reply, :trash, :untrash]
  helper_method :mailbox, :conversation

  def create
    recipients   = User.where(email: recipient_emails).all
    to           = user_signed_in? ? current_user : current_employee
    conversation = to.send_message(recipients,*convo_attrs).conversation
    redirect_to conversation_path(conversation)
  end

  def reply
    current_user.reply_to_conversation @model, *message_params
    redirect_to conversation_path(@model)
  end

  def trash
    @model.move_to_trash current_user
    redirect_to :conversations
  end

  def untrash
    @model.untrash current_user
    redirect_to :conversations
  end

  private

  def mailbox
    @mailbox ||= user_signed_in? ? current_user.mailbox : current_employee.mailbox
  end


  def find_model
    @model ||= mailbox.conversations.find(params[:id])
  end

  def conversation
    @model
  end


  def message_params
    params.require(:message).
      permit :body,
             :subject
  end

  def convo_params
    params.require(:conversation).
      permit :body,
             :subject,
             :recipients
  end

  def recipient_emails
    convo_params(:recipients).split(',')
  end

  def convo_attrs
    [convo_params[:body],[:subject]]
  end

  def authenicate
    authenticate_employee! || authenticate_user!
  end
end
