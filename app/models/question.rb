class Question

  def initialize(original_text)
    @origina_text = text
    @@pipeline||=StanfordCoreNLP.load(:tokenize, :ssplit, :pos, :lemma, :parse, :ner, :dcoref)
    @text = StanfordCoreNLP::Annotation.new(text)
    @@pipeline.annotate(text)
  end

  def questions_from_text
    @text.get(:sentences).inject([]) do |questions, sentence|
      tree = sentence.get(:tree).to_a[0]
      questions << sentence.to_s if tree =~ /(\(SBARQ\d|\(SQ\d)/
    end
  end

end
