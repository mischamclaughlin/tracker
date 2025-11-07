ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/spec"

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)
    fixtures :all
    self.use_transactional_tests = true
  end
end

class Minitest::Spec
  include ActiveSupport::Callbacks
  include ActiveSupport::Testing::SetupAndTeardown
  include ActiveSupport::Testing::Assertions
  include ActiveRecord::TestFixtures

  define_callbacks :setup, :teardown

  self.fixture_paths = [Rails.root.join("test", "fixtures")]
  self.use_transactional_tests = true

  fixtures :all

  def before_setup
    super
    run_callbacks(:setup) { super }
  end

  def after_teardown
    super
    run_callbacks(:teardown) { super }
  end
end

module Kernel
  alias_method :context, :describe
end
