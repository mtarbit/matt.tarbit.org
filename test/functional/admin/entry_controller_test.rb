require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/entry_controller'

# Re-raise errors caught by the controller.
class Admin::EntryController; def rescue_action(e) raise e end; end

class Admin::EntryControllerTest < Test::Unit::TestCase
  def setup
    @controller = Admin::EntryController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
