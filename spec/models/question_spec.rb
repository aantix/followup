require 'rails_helper'

RSpec.describe Question, :type => :model do
  it "parses out the relevant questions" do
    q = Question.new("What's my age again? Hello Jim.  Are you going to the circus?  I wonder if we are going to go anywhere?")

    expect(q.questions_from_text).to eq ["What's my age again?", "Are you going to the circus?", "I wonder if we are going to go anywhere?"]
  end
end
