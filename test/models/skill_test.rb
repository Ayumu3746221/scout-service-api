require "test_helper"

class SkillTest < ActiveSupport::TestCase
  # 基本的な存在性のテスト
  test "valid skill" do
    skill = Skill.new(name: "TypeScript")
    assert skill.valid?
  end

  # nameの必須チェック
  test "should require a name" do
    skill = Skill.new(name: nil)
    assert_not skill.valid?
    assert_includes skill.errors[:name], "can't be blank"
  end

  # nameの一意性チェック
  test "should require a unique name" do
    existing_skill = Skill.create!(name: "UniqueTestSkill")
    duplicate_skill = Skill.new(name: "UniqueTestSkill")

    assert_not duplicate_skill.valid?
    assert_includes duplicate_skill.errors[:name], "has already been taken"
  end
end
