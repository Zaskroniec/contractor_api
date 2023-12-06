# frozen_string_literal: true

require "test_helper"

class ContractTest < ActiveSupport::TestCase
  test "generates unique guid for contract" do
    contract = contracts(:without_guid)
      .generate_guid

    assert_equal contract.guid, "N00001"
  end

  test "raises exception for non unique guid contract" do
    _contract_with_guid = contracts(:with_guid)
    contract_without_guid = contracts(:without_guid)

    assert_raise ActiveRecord::RecordNotUnique do
      contract_without_guid.update(guid: "N00002")
    end
  end
end
