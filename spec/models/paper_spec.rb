require "rails_helper"

describe Paper, :type => :model do
  it "create paper is valid" do
    paper = create(:paper)
    expect(paper).to be
  end
end
