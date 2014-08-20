module EmailsHelper
  BOLDED = "<b>".html_safe
  UNBOLDED = "</b>".html_safe

  def highlight_body(text, questions)
    highlights = text

    questions.each do |question|
      index = highlights.index(question)
      if index
        highlights = highlights.insert(index, BOLDED).html_safe
        highlights = highlights.insert(index + question.size + BOLDED.size, UNBOLDED).html_safe
      end
    end

    highlights
  end

  def highlight_questions(questions)
    bolded_questions = questions.collect{|q| "<b>#{q.question}</b>".html_safe}
    bolded_questions.join(" ... ")
  end

end
