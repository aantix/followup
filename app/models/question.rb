class Question < ActiveRecord::Base
  QUESTION_WORDS = ['who', 'what', 'when', 'where', 'why', 'are you']

  PARSER = TactfulTokenizer::Model.new

  def self.questions_from_text(original_text)
    text = Sanitize.clean(original_text, Sanitize::Config::RESTRICTED)
    sentences = PARSER.tokenize_text(text)

    sentences.inject([]) do |questions, sentence|
      questions.append(sentence.to_s) if is_question?(sentence)
      questions
    end
  end

  def self.is_question?(text)
    text.include?("?")
  end

end
