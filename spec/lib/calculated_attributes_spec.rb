require 'spec_helper'
require 'byebug'

describe "calculated_attributes" do
  it "includes calculated attributes" do
    expect(Post.where("").calculated(:comments)).to eq(1)
  end
end