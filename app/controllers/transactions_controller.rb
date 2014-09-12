class TransactionsController < ApplicationController
  before_filter do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_view_your_inbox")
  end

  before_filter :only => [ :index, :received ] do |controller|
    controller.ensure_authorized t("layouts.notifications.you_are_not_authorized_to_view_this_content")
  end

  skip_filter :dashboard_only

  MessageForm = FormUtils.define_form("Message",
    :content,
    :conversation_id, # TODO Remove this
    :sender_id, # TODO Remove this
  ).with_validations {
    validates_presence_of :content, :conversation_id, :sender_id
  }

  def show
    transaction_id = params[:id]

    transaction_data = MarketplaceService::Transaction::Query.transaction_with_conversation(
      transaction_id,
      @current_user.id,
      @current_community.id)

    if transaction_data.blank?
      flash[:error] = t("layouts.notifications.you_are_not_authorized_to_view_this_content")
      return redirect_to root
    end

    # TODO MARK AS READ!
    # @current_user.read(conversation) unless conversation.read_by?(@current_user)

    message_form = MessageForm.new({sender_id: @current_user.id, conversation_id: transaction_data[:conversation][:id]})

    conversation = transaction_data[:conversation].to_h
    other = conversation[:participants].reject { |participant| participant[:id] == @current_user.id }.first
    conversation[:other_party] = other.to_h.merge({url: person_path(id: other[:username])})

    conversation[:listing_url] = listing_path(id: transaction_data[:listing][:id])

    messages = conversation[:messages].map(&:to_h).map { |message|
      sender = conversation[:participants].find { |participant| participant[:id] == message[:sender_id] }
      message.merge({mood: :neutral}).merge(sender: sender)
    }

    transaction = transaction_data.to_h
    author_id = transaction[:listing][:author_id]
    starter_id = transaction[:starter_id]

    author = conversation[:participants].find { |participant| participant[:id] == author_id }
    starter = conversation[:participants].find { |participant| participant[:id] == starter_id }

    author_url = {url: person_path(id: author[:username])}
    starter_url = {url: person_path(id: starter[:username])}

    transaction = transaction.merge({author: author, starter: starter, conversation: conversation})

    messages_and_actions = TransactionViewUtils::merge_messages_and_transitions(messages, TransactionViewUtils::create_messages_from_actions(transaction))

    render "transactions/show", locals: {
      messages: messages_and_actions.reverse,
      transaction_data: transaction,
      message_form: message_form,
      message_form_action: person_message_messages_path(@current_user, :message_id => conversation[:id])
    }
  end


end
