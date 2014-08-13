class Question

  def initialize(original_text)
    @origina_text = original_text
    @@pipeline=StanfordCoreNLP.load(:tokenize, :ssplit, :pos, :lemma, :parse, :ner, :dcoref)
    @text = StanfordCoreNLP::Annotation.new(original_text)
    @@pipeline.annotate(@text)
  end

  def questions_from_text
    questions = []
    @text.get(:sentences).each do |sentence|
      tree = sentence.get(:tree).to_a[0]

      puts sentence.to_s
      puts tree.to_s

      questions.append(sentence.to_s) if tree.to_s =~ /(\(SBARQ\s+|\(SQ\s+)/
    end

    questions
  end

end
