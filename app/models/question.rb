class Question
  QUESTION_WORDS = ['who', 'what', 'when', 'where', 'why', 'are you']

  def initialize(original_text)
    @original_text = Sanitize.clean(original_text, Sanitize::Config::RESTRICTED)
    @@parser = TactfulTokenizer::Model.new
  end

  def questions_from_text
    sentences = @@parser.tokenize_text(@original_text)

    sentences.inject([]) do |questions, sentence|
      questions.append(sentence.to_s) if is_question?(sentence)
      questions
    end
  end

  def is_question?(text)
    words = text.strip.split(' ')
    words.any?{|w| QUESTION_WORDS.include?(w.downcase.gsub("'s", ""))}
  end

end
