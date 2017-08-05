module CallbackHelpers
  def type=(type)
    content['type'] = type
    @stubbed_event = Stripe::Event.construct_from(content)
    Stripe::Event.stubs(:retrieve).returns(@stubbed_event)
  end

  def run_callback_with(callback)
    observer.class_eval do
      send(callback) do |evt, target|
        yield evt, target
      end
    end
  end
end