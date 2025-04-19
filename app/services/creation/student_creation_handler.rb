module Creation
  class StudentCreationHandler < BaseCreationHandler
    def execute(context)
      user = context[:user]

      raise "User not created" unless user

      student = Student.new(
        user_id: user.id,
        name: context[:student_params].slice(:name)
        )
      if student.save
        context[:student] = student
        true
      else
        fail_with!(student)
        false
      end
    end
  end
end
