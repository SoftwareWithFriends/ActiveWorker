module ActiveWorker
  class ParentEvent < ActiveWorker::Event
    extend Behavior::CreateFromError
  end
end