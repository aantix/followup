module EmailsHelper
  MARKED = "<mark>".html_safe
  UNMARKED = "</mark>".html_safe

  def highlight_body(text, questions)
    highlights = text

    questions.each do |question|
      index = highlights.index(question)
      if index
        highlights = highlights.insert(index, MARKED)
        highlights = highlights.insert(index + question.size + MARKED.size, MARKED)
      end
    end

    highlights.html_safe
  end

  def highlight_questions(questions)
    bolded_questions = questions.collect{|q| "#{MARKED}#{q.question}#{UNMARKED}"}
    bolded_questions.join(" ... ").html_safe
  end

  def subject_label(email, current_user)
    email.from_email == current_user.email ? "you" : email.from_name
  end

  def action_label(email, current_user)
    email.from_email == current_user.email ? "wrote" : "responded to"
  end

end
