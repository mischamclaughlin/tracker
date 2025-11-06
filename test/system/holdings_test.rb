require "application_system_test_case"

class HoldingsTest < ApplicationSystemTestCase
  setup do
    @holding = holdings(:one)
  end

  test "visiting the index" do
    visit holdings_url
    assert_selector "h1", text: "Holdings"
  end

  test "should create holding" do
    visit holdings_url
    click_on "New holding"

    click_on "Create Holding"

    assert_text "Holding was successfully created"
    click_on "Back"
  end

  test "should update Holding" do
    visit holding_url(@holding)
    click_on "Edit this holding", match: :first

    click_on "Update Holding"

    assert_text "Holding was successfully updated"
    click_on "Back"
  end

  test "should destroy Holding" do
    visit holding_url(@holding)
    click_on "Destroy this holding", match: :first

    assert_text "Holding was successfully destroyed"
  end
end
