require 'digest/md5'

module EmailsHelper
  MARKED = "<mark>".html_safe
  UNMARKED = "</mark>".html_safe

  def highlight_body(text, questions)
    highlights = text

    questions.each do |q|
      question = q.question
      index    = highlights.index(question)
      if index
        highlights = highlights.insert(index, MARKED)
        highlights = highlights.insert(index + question.size + MARKED.size, UNMARKED)
      end
    end

    highlights.html_safe
  end

  def name_initials(full_name)
    #initials = ''
    #names = full_name.split(' ')
    #
    #initials << "#{names[0][0]}."
    #initials << "#{names[1][0]}." rescue nil
    #initials
    full_name[0]
  end

  def string_color(full_name)
    Digest::MD5.hexdigest(full_name)[0..5]
  end

  def highlight_questions(questions)
    bolded_questions = questions.collect{|q| "&#8220;#{q.question.strip.capitalize}&#8221;"}
    bolded_questions.join(" ... ").html_safe

  end

  def subject_label(email, current_user)
    email.from_email == current_user.email ? "you" : email.from_name
  end

  def action_label(email, current_user, email_count)
    email_count == 1 ? "wrote to" : "responded to"
  end

  def email_body_class(message)
    message.length > Email::MAX_DISPLAY_LENGTH ? "email-body-long" : "email-body"
  end

  def email_body_display(message, content_type)
    (content_type == Email::TEXT ? simple_format(message) : message).html_safe
  end

  def gmail_reply_link(msg_id)
    "https://mail.google.com/mail/#inbox/#{msg_id.to_i.to_s(16)}"
  end

end
