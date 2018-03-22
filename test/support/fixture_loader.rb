module FixtureLoader
  def load_request_fixture(name)
    Pathname.new(__FILE__).join('..', '..', 'fixtures', name).read
  end
end
