class NullSystemTestCase
  def self.driven_by(_, _)
  end

  def self.setup
  end

  def self.test(_)
    warn 'WARNING: Skipping system test because this version of Rails does not support it!'
  end
end